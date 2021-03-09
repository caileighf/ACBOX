#!/bin/sh
sleep 60
DST=`date +"%Y-%m-%d_%H%M%S"`

cd /home/pi

echo "[${DST}]: Starting IMU logger" | tee /home/pi/acbox_debug_$DST.log 2>&1

python3 ahrs.py

DST=`date +"%Y-%m-%d_%H%M%S"`
echo "[${DST}]: Returning from IMU logger" | tee /home/pi/acbox_debug_$DST.log 2>&1

#   sudo hwclock -r
#   sudo date -s "Thu Feb 18 00:07:00 UTC 2021"
#   date # check is right?
#   sudo hwclock -w