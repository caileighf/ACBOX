#!/bin/sh
sleep 60
DST=`date +"%Y-%m-%d_%H%M%S"`

echo "[${DST}]: Sourcing /home/pi/.bashrc" | tee /home/pi/acbox_debug_$DST.log 2>&1
source /home/pi/.bashrc | tee /home/pi/acbox_debug_$DST.log 2>&1

echo "[${DST}]: Starting DAQ logger" | tee /home/pi/acbox_debug_$DST.log 2>&1
start_collect

DST=`date +"%Y-%m-%d_%H%M%S"`
echo "[${DST}]: Returning from DAQ logger" | tee /home/pi/acbox_debug_$DST.log 2>&1