#!/bin/bash
PID=$(ps ax -O tpgid | grep "single_DAQ_collect" | grep -Eiv "grep" | awk '{print $1}')
kill -n 9 $PID
echo -e "pid:$PID DAQ Driver -- Killed"