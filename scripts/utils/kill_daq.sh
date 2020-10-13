#!/bin/bash
PID=$(ps ax -O tpgid | grep "single_DAQ_collect" | grep -Eiv "grep" | awk '{print $1}')

if [ "$PID" = "" ]; then
    echo -e "Unable to find DAQ Driver PID -- is it running?"
    kill -SIGINT $$
fi

kill -n 9 $PID
echo -e "pid:$PID DAQ Driver -- Killed"