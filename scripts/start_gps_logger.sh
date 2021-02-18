#!/bin/sh
sleep 60
DST=`date +"%Y-%m-%d_%H%M%S"`

echo "[${DST}]: Sourcing /home/pi/.bashrc" | tee /home/pi/acbox_debug_$DST.log 2>&1
source /home/pi/.bashrc | tee /home/pi/acbox_debug_$DST.log 2>&1

echo "[${DST}]: Starting GPS logger" | tee /home/pi/acbox_debug_$DST.log 2>&1
echo "/home/pi/track_$DST.nmea" | tee /home/pi/gps_filename.txt 2>&1
gpspipe -t -uu -r | tee /home/pi/track_$DST.nmea 2>&1

DST=`date +"%Y-%m-%d_%H%M%S"`
echo "[${DST}]: Returning from GPS logger" | tee /home/pi/acbox_debug_$DST.log 2>&1