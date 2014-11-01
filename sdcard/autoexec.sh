#!/bin/sh
#
# Copyright 2014 Jonathan Dieter <jdieter@gmail.com>
# Distributed under the terms of the GNU General Public
# License v2 or later

LOG=/dev/null

if [ -e /mnt/mmc/autobackup/config ]; then
    . /mnt/mmc/autobackup/config
fi

cat /dev/null > $LOG

# Run telnet server
#/mnt/mmc/autobackup/telnet.sh 2>&1 | cat >> $LOG

# Connect to wifi
#/mnt/mmc/autobackup/keep_alive.sh 2>&1 | cat >> $LOG &
#/mnt/mmc/autobackup/connect.sh 2>&1 | cat >> $LOG

# Run backup server
/mnt/mmc/autobackup/backup.sh 2>&1 | cat >> "$LOG"
