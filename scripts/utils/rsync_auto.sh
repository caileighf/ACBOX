#!/bin/bash

#
#   For easier rsync data transfers with saved user credentials and preferences
#
REMOTE_USER="caileigh"
REMOTE_IP="caileigh-XPS-13-9370.local"
REMOTE_DEST="/home/caileigh/ACBOX_data"
INCLUDE_GPS_DATA=true
INCLUDE_GPS_LOGS=true
CLEAN=false
PARALLEL=false

AUTO_OPTS=(
    --all
    )

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
              "${AUTO_OPTS[@]}"