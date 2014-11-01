#!/bin/sh
#
# Copyright 2014 Jonathan Dieter <jdieter@gmail.com>
# Distributed under the terms of the GNU General Public
# License v2 or later

mount -oremount,rw /
if [ ! -e /usr/sbin/telnetd ]; then
    cd /usr/sbin
    ln -s ../../bin/busybox telnetd
fi
cd /dev
mkdir pts
mount -oremount,ro /
mount -t devpts none /dev/pts
telnetd -l /bin/bash

