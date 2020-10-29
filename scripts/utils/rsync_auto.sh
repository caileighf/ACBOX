#!/bin/bash

CONFIG_FILE="$HOME/ACBOX/scripts/utils/rsync_config.json"

INCLUDE_GPS_DATA=$(echo "$CONFIG_FILE" | jsawk 'return this.INCLUDE_GPS_DATA')
INCLUDE_GPS_LOGS=$(echo "$CONFIG_FILE" | jsawk 'return this.INCLUDE_GPS_LOGS')
CLEAN=$(echo "$CONFIG_FILE" | jsawk 'return this.CLEAN')
PARALLEL=$(echo "$CONFIG_FILE" | jsawk 'return this.PARALLEL')

REMOTE_USER=$(echo "$CONFIG_FILE" | jsawk 'return this.REMOTE_USER')
REMOTE_IP=$(echo "$CONFIG_FILE" | jsawk 'return this.REMOTE_IP')
REMOTE_DEST=$(echo "$CONFIG_FILE" | jsawk 'return this.REMOTE_DEST')

AUTO_OPTS=()

# handle user set flags
if [ "$INCLUDE_GPS_DATA" = true ]; then
    AUTO_OPTS+=(--include-gps)
fi

if [ "$INCLUDE_GPS_LOGS" = true ]; then
    AUTO_OPTS+=(--include-gps-logs)
fi

if [ "$PARALLEL" = true ]; then
    AUTO_OPTS+=(--parallel)
elif [ "$CLEAN" = true ]; then
    AUTO_OPTS+=(--clean)
fi

rsync_data.sh -u "$REMOTE_USER" \
              -i "$REMOTE_IP"   \
              -d "$REMOTE_DEST" \
              -a \
              "${AUTO_OPTS[@]}"