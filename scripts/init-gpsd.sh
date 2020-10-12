#!/bin/bash

GPSPORT=/dev/ttyGPS
sudo gpsd $GPSPORT -F /var/run/gpsd.sock && echo "gpsd client started on port -- $GPSPORT" || "gpsd client FAILED to start on port -- $GPSPORT"

printf "\n\
To enable special kernel support for Pulse Per Second input via a GPIO pin\n\
to help synchronize the time edit the /boot/config.txt file and adding the following lines:\n\n\
\
# enable GPS PPS\n\
dtoverlay=pps-gpio,gpiopin=4\n\n"

# server time.nist.gov