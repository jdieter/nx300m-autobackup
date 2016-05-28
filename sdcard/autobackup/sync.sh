#!/bin/bash

export LD_LIBRARY_PATH=/mnt/mmc/autobackup/lib:/usr/lib:/lib

METHOD="power-up"

. /mnt/mmc/autobackup/config

if [ "$METHOD" != "continuous" ] && [ "$METHOD" != "power-up" ]; then
    echo "Unknown sync method: $METHOD"
    echo "Defaulting to power-up"
    METHOD="power-up"
fi

echo "Sync method: $METHOD"
/mnt/mmc/autobackup/backup.sh

if [ "$METHOD" != "continuous" ]; then
    exit "$?"
fi

echo "Now in continuous mode"
retval=0
while [ 1 -eq 1 ]; do
    # If we failed last time we uploaded, wait 25 seconds and try again
    if [ "$retval" -ne "0" ]; then
        timeout=25
    else
        timeout=0
    fi
    /mnt/mmc/autobackup/bin/inotifywait -e modify -r /mnt/mmc/DCIM -t $timeout
    /mnt/mmc/autobackup/backup.sh
    retval="$?"
done
