#!/bin/sh
#
# Copyright 2014 Jonathan Dieter <jdieter@gmail.com>
# Distributed under the terms of the GNU General Public
# License v2 or later

export LD_LIBRARY_PATH=/mnt/mmc/autobackup/lib:/usr/lib:/lib

ERROR=0

if [ ! -e /mnt/mmc/autobackup/config ]; then
    echo "No configuration file" >> /mnt/mmc/autobackup.log
    exit 1
fi

WIFI_MODE="as-needed"
DATE_FORMAT="+%Y/%Y.%m.%d"

. /mnt/mmc/autobackup/config

# Validate date format
date "$DATE_FORMAT" > /dev/null
if [ "$?" -ne 0 ]; then
    echo "$DATE_FORMAT is not a valid date format" >> /mnt/mmc/autobackup.log
    exit 1
fi

# Copy ssh key and known_hosts to /root (which is a temporary file anyway)
if [ -e /mnt/mmc/autobackup/ssh/id_rsa ]; then
    mkdir -p /root/.ssh
    cp -a /mnt/mmc/autobackup/ssh/* /root/.ssh/
else
    echo "No SSH key in ssh/id_rsa" >> /mnt/mmc/autobackup.log
    exit 1
fi
chown root.root /root/.ssh -R
chmod 700 /root/.ssh
chmod 600 /root/.ssh/id_rsa
chmod ugo-X /root/.ssh -R

while [ 1 -eq 1 ]; do
    CHANGED=0
    for i in `ls /mnt/mmc/DCIM`; do
        cd /mnt/mmc/DCIM/"${i}"
        for file in `ls`; do
            if [ $file == ".backup-list" ]; then
                continue
            fi
            grep "$file" .backup-list -q 2>/dev/null
            if [ "$?" -ne "0" ]; then
                # Don't allow camera to automatically shut down
                /mnt/mmc/autobackup/keep_alive.sh &

                # Connect to WiFi if available
                /mnt/mmc/autobackup/connect.sh
                if [ "$?" -ne "0" ]; then
                    ERROR=1
                    break
                fi

                DATESTAMP=`stat -c "%Y" "$file"`
                if [ "$?" -ne "0" ]; then
                    ERROR=1
                    break
                fi
                DATE=`date -d "@$DATESTAMP" "$DATE_FORMAT"`
                if [ "$?" -ne "0" ]; then
                    ERROR=1
                    break
                fi
                ssh -o PasswordAuthentication=no $DEST_SERVER "mkdir -p \"$DEST_PATH/$DATE\""
                if [ "$?" -ne "0" ]; then
                    ERROR=1
                    break
                fi

                # Verify that file isn't currently open
                lsof | grep -q "$file"
                retval="$?"
                while [ "$retval" -eq 0 ]; do
                    sleep 1
                    lsof | grep -q "$file"
                    retval="$?"
                done

                # Copy file to server
                scp -p "$file" "$DEST_SERVER:~/$DEST_PATH/$DATE/"
                if [ "$?" -ne "0" ]; then
                    ERROR=1
                    break
                fi

                CHANGED=1
                ssh -o PasswordAuthentication=no $DEST_SERVER "chmod ugo-x \"$DEST_PATH/$DATE/$file\""
                if [ "$?" -ne "0" ]; then
                    ERROR=1
                    break
                fi
                echo $file >> .backup-list
                sync
            fi
        done
        if [ "$ERROR" -ne "0" ]; then
            break
        fi
    done
    if [ "$CHANGED" -eq "0" ] || [ "$ERROR" -ne "0" ]; then
        break
    fi
done
ps aux | grep -q keep_alive.sh
if [ "$?" -eq 0 ]; then
    echo "Shutting down Wifi"
    killall keep_alive.sh
    /mnt/mmc/autobackup/disconnect.sh
fi

if [ "$ERROR" -ne "0" ]; then
    exit "$ERROR"
fi
