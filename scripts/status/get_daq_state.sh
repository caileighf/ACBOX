#!/bin/bash
lsusb | grep 'Measurement Computing Corp' > /dev/null
RC=$?

if [ $RC -eq 0 ]; then
    pgrep -af python | grep single_DAQ_collect > /dev/null && echo 'Running' || echo 'Idle'
else
    echo "DAQ Not Found"
fi