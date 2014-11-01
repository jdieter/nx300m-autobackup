nx300m-autobackup
=================

When this set of scripts is configured correctly, the
Samsung NX300M will automatically backup all photos and
videos via scp whenever the camera is turned on.

##Installing##
To use this, your camera must be using the 1.10 camera body
firmware.  I've tested on the 1.13 firmware, and it doesn't
work with that.  I've not tested 1.11 or 1.12, so it may or
may not work with those revisions.  You can downgrade your
camera's firmware to 1.10 with minimal effort.

Copy the contents of the sdcard directory onto the sdcard
from the camera.

In autobackup/config:
1. Set the ESSID of the network you want to connect to
2. Set the hostname you want to connect to in the form
user@hostname
3. Set the path you want to copy the files to on the
destination

Then:
Copy the id_rsa and id_rsa.pub to autobackup/ssh for a
user with write permissions to the destination

##Details##
autoexec.sh is run every time the camera is turned on and
calls autobackup/backup.sh.

backup.sh checks to see if there are any new files that
haven't been backed up yet, and, if there are, connects to
the listed WiFi AP, runs a "keep alive" script so the
camera won't automatically shut down, and sends each new
file to the backup server.  After all the new files have
been sent, it shuts down the WiFi connection and the "keep
alive" script.

##To Do##
1. Keep-alive script currently sends keypresses to the
display, keeping the display on as well as the camera.  I'd
like to find a way to just keep the camera on while letting
the display go off.
2. Use smbclient so you can autobackup to Windows without
using Samsung's software (not sure whether this is worth
the effort).
3. See if we can somehow get the camera to wake up to
automatically run the backup without having to manually
turn it on.
4. Show a pretty backup status in the corner of the screen
as the backup runs.
