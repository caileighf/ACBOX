#!/bin/bash

# Common path for all GPIO access
BASE_GPIO_PATH=/sys/class/gpio

# Assign names to GPIO pin numbers for each light
BLUE=21

# Assign names to states
ON="1"
OFF="0"

# Utility function to export a pin if not already exported
exportPin()
{
  if [ ! -e $BASE_GPIO_PATH/gpio$1 ]; then
    echo "$1" > $BASE_GPIO_PATH/export
  fi
}

# Utility function to set a pin as an output
setOutput()
{
  echo "out" > $BASE_GPIO_PATH/gpio$1/direction
}

# Utility function to change state of a light
setLightState()
{
# echo "echo $2 > $BASE_GPIO_PATH/gpio$1/value"
  echo $2 > $BASE_GPIO_PATH/gpio$1/value
}

# Utility function to turn all lights off
allLightsOff()
{
  setLightState $BLUE $OFF
}

# Ctrl-C handler for clean shutdown
shutdown()
{
  allLightsOff
  exit 0
}

trap shutdown SIGINT

# Export pins so that we can use them
exportPin $BLUE

# Set pins as outputs
setOutput $BLUE

# Turn lights off to begin
allLightsOff

DAQ_PREV_DIR_SIZE=$(du /home/pi/ACBOX/MCC_DAQ/data | head -n1 | sed -e 's/\s.*$//')
GPS_PREV_DIR_SIZE=$(du /home/pi/ACBOX/gps_logger/data | head -n1 | sed -e 's/\s.*$//')

RECOVERABLE="0"
RUNNING="1"
FAILURE="-1"

DAQ_STATE=${RECOVERABLE}
GPS_STATE=${RECOVERABLE}

FAIL_COUNT="0"
MAX_TRIES="360" # approx 15 mins before we say there is a serious issue 

# Loop forever until user presses Ctrl-C
while [ 1 ]
do

#
#    DAQ State 
#
if DAQ_CURRENT_DIR_SIZE=$(du /home/pi/ACBOX/MCC_DAQ/data | head -n1 | sed -e 's/\s.*$//'); then
    #echo "DAQ_PREV_DIR_SIZE: ${DAQ_PREV_DIR_SIZE}"
    #echo "DAQ_CURRENT_DIR_SIZE: ${DAQ_CURRENT_DIR_SIZE}"
    if [ $((DAQ_CURRENT_DIR_SIZE)) -gt $((DAQ_PREV_DIR_SIZE)) ]; then
        DAQ_STATE=${RUNNING}
        echo "[`date +'%s'`]: Data directory is growing. DAQ is logging. Data directory size: ${DAQ_CURRENT_DIR_SIZE}"
    else
        DAQ_STATE=${RECOVERABLE}
        echo "[`date +'%s'`]: Data directory is NOT growing... DAQ may not be running"
    fi
else
    DAQ_STATE=${FAILURE}
    echo "[`date +'%s'`]: Error -- Data directory does not exist or permissions issue"
fi
DAQ_PREV_DIR_SIZE=${DAQ_CURRENT_DIR_SIZE}

#
#    GPS State
#
if GPS_CURRENT_DIR_SIZE=$(du /home/pi/ACBOX/gps_logger/data | head -n1 | sed -e 's/\s.*$//'); then
    #echo "GPS_PREV_DIR_SIZE: ${GPS_PREV_DIR_SIZE}"
    #echo "GPS_CURRENT_DIR_SIZE: ${GPS_CURRENT_DIR_SIZE}"
    if [ $((GPS_CURRENT_DIR_SIZE)) -gt $((GPS_PREV_DIR_SIZE)) ]; then
        GPS_STATE=${RUNNING}
        echo "[`date +'%s'`]: Data directory is growing. GPS is logging. Data directory size: ${GPS_CURRENT_DIR_SIZE}"
    else
        GPS_STATE=${RECOVERABLE}
        echo "[`date +'%s'`]: Data directory is NOT growing... GPS may not be running"
    fi
else
    GPS_STATE=${FAILURE}
    echo "[`date +'%s'`]: Error -- Data directory does not exist or permissions issue"
fi
GPS_PREV_DIR_SIZE=${GPS_CURRENT_DIR_SIZE}

sleep 1 # everyone gets a sleep!

if [[ ${DAQ_STATE} = ${FAILURE} || ${GPS_STATE} = ${FAILURE} ]]; then
    # BLINK FAST
    echo "[`date +'%s'`]: DAQ OR GPS are in an un-recoverable state. Fast blinking until we shutdown..."
    while [ 1 ]
    do
        setLightState $BLUE $ON
        sleep 0.1
        setLightState $BLUE $OFF
        sleep 0.1
    done

elif [[ ${DAQ_STATE} = ${RECOVERABLE}  || ${GPS_STATE} = ${RECOVERABLE} ]]; then
    # SLOW_BLINK
    FAIL_COUNT=$((FAIL_COUNT+1))
    if [[ $((FAIL_COUNT)) -gt $((MAX_TRIES)) ]]; then
        echo "[`date +'%s'`]: Exceeded ${MAX_TRIES} tries! Switch to failure state."
        DAQ_STATE=${FAILURE}
        GPS_STATE=${FAILURE}
    else
        echo "[`date +'%s'`]: Attempt ${FAIL_COUNT} of ${MAX_TRIES}. DAQ and/or GPS may not have been started yet. They are still in a recoverable state"
        setLightState $BLUE $ON
        sleep 1.5
        setLightState $BLUE $OFF
    fi
else
    FAIL_COUNT="0"
    echo "[`date +'%s'`]: DAQ and GPS are in a running state!"
    # SOLID BLUE -- ALL OK
    setLightState $BLUE $ON
    sleep 20

fi
done

setLightState $BLUE $OFF
