#!/bin/sh
#
# Copyright 2014 Jonathan Dieter <jdieter@gmail.com>
# Distributed under the terms of the GNU General Public
# License v2 or later

export DISPLAY=:0
export LD_LIBRARY_PATH=/mnt/mmc/autobackup/lib:/usr/lib:/lib

while [ 1 -eq 1 ]; do
    /mnt/mmc/autobackup/bin/xdotool key XF86Reload
    sleep 5
done
