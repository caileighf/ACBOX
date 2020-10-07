#!/bin/bash

GPSPORT=$1
sudo gpsd $GPSPORT -F /var/run/gpsd.sock && echo "gpsd client started on port -- $GPSPORT" || "gpsd client FAILED to start on port -- $GPSPORT"