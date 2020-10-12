#!/bin/bash
USAGE=$(cat <<-END
 usage: rsync_parallel.sh -u <REMOTE-USER> -i <REMOTE-IP-ADDRESS> -d <REMOTE-DEST> -s <FREQ-SECONDS>

END
)

DRY_RUN=false
i=0;
for ARG in "$@" 
do
    i=$((i + 1));

    if [ ARG = '--dry-run' ]; then
        DRY_RUN=true;
    elif [ ARG = '--help' ]; then
        echo -e "\n$USAGE\n"
        exit 1;
    fi
done

while getopts u:i:d:s: flag
do
    case "${flag}" in
        u) REMOTE_USER=${OPTARG};;
        i) REMOTE_IP=${OPTARG};;
        d) REMOTE_DEST=${OPTARG};;
        s) SECONDS=${OPTARG};;
    esac
done

CONFIG_FILE=$(cat /home/pi/ACBOX/MCC_DAQ/config.json)
DATA_DIR=$( echo "$CONFIG_FILE"  | jsawk 'return this.data_directory' )
HEADER=$(head -n 10 "${DATA_DIR}/SINGLE_log.log")
TEMP_LOG=".temp_rsync"
RSYNC_CMD="rsync -a -r -P -h -v ${DATA_DIR} ${REMOTE_USER}@${REMOTE_IP}:${REMOTE_DEST} --log-file ${TEMP_LOG} ${DRY_RUN}"
PAYLOAD=$(cat <<-END

$(date)

ACBOX USER: $USER
ACBOX HOST: $HOSTNAME
    SOURCE: $DATA_DIR

REMOTE USER: $REMOTE_USER
  REMOTE IP: $REMOTE_IP
       DEST: $REMOTE_DEST

rysnc command run:
$ $RSYNC_CMD

END
)
echo -e "$HEADER\n$PAYLOAD\n" > "$TEMP_LOG"

DAQ_STATE=$($HOME/ACBOX/scripts/status/get_daq_state.sh)
while [ "$DAQ_STATE" = "Running" ]; do
    rsync -a -r -P -h -v "$DATA_DIR" "$REMOTE_USER@$REMOTE_IP:$REMOTE_DEST" --log-file "$TEMP_LOG"
    echo -e "\n$(date) --> rsync will start again in $SECONDS second(s)\n" | tee "$TEMP_LOG"
    sleep "$SECONDS";
done