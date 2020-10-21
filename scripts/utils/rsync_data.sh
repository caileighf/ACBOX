#!/bin/bash

function get_yn {
    PROMPT=$1
    echo "$PROMPT"
    while true; do
        read -p "Please answer [Yes/No]: " yn
        case $yn in
            [Yy]* ) local return_val=true; break;;
            [Nn]* ) local return_val=false; break;;
            * ) echo "Please answer yes or no.";;
        esac
    done
    echo $return_val
}

USAGE=$(cat <<-END
 usage: rsync_data.sh -u <REMOTE-USER> -i <REMOTE-IP-ADDRESS> -d <REMOTE-DEST> [OPTIONAL-ARGS]
        [OPTIONAL-ARGS]:
        --all ------------------> Copy all data in one go (default mode if none passed)
        --clean ----------------> Delete source data after successful transfer
        --parallel -------------> Copy data in parallel with periodic sync
                                  Note: if you pass --clean this will delete files
                                  and makes the cli-spectrogram less useful
                                  (-s <FREQ-SEC> default is 5 seconds)

        --dry-run --------------> Run as dry run with no actual changes
        --include-gps ----------> Include gps data in transfer
        --include-gps-logs -----> Include gps debugging logs
        -f <CONFIG.JSON-FILE> --> Pass config file if different than $HOME/ACBOX/MCC_DAQ/config.json

END
)

# will get over written if user passed different config
CONFIG_FILE=$(cat $HOME/ACBOX/MCC_DAQ/config.json)
SECONDS=5

while getopts u:i:d:f:s: flag
do
    case "${flag}" in
        u) REMOTE_USER=${OPTARG};;
        i) REMOTE_IP=${OPTARG};;
        d) REMOTE_DEST=${OPTARG};;
        f) CONFIG_FILE=$(cat ${OPTARG});;
        s) SECONDS=${OPTARG};;
        \? ) echo "Unknown option: -$OPTARG" >&2; ;;
        :  ) echo "Missing option argument for -$OPTARG" >&2; ;;
        *  ) echo "Unimplemented option: -$OPTARG" >&2; ;;
    esac
done

if ((OPTIND == 1)); then
    echo "No options specified";
    echo "$USAGE";
    kill -SIGINT $$
fi

CLEAN=false
PARALLEL=false
DATA_DIR=$( echo "$CONFIG_FILE"  | jsawk 'return this.data_directory' )
HEADER=$(head -n 10 "${DATA_DIR}/SINGLE_log.log")
TEMP_LOG=".temp_rsync"
RSYNC_LOG_OPT="--log-file ${TEMP_LOG}"
RSYNC_OPTIONS=(
    --recursive
    --progress
    -a
    -h
    -v
)

i=0;
for ARG in "$@" 
do
    i=$((i + 1));

    if [ ARG = '--dry-run' ]; then
        RSYNC_OPTIONS+=(--dry-run)

    elif [ ARG = '--include-gps' ]; then
        DATA_DIR="${DATA_DIR} ${GPS_DATA_DIR}"

    elif [ ARG = '--include-gps-logs' ]; then
        DATA_DIR="${DATA_DIR} ${GPS_LOG_DIR}"

    elif [ ARG = '--clean' ]; then
        CLEAN=true
        RSYNC_OPTIONS+=(--remove-source-files)

    elif [ ARG = '--parallel' ]; then
        PARALLEL=true

    elif [ ARG = '--help' ]; then
        echo -e "\n$USAGE\n"
        kill -SIGINT $$
    fi
    shift;
done

RSYNC_CMD=("rsync" "${RSYNC_OPTIONS[@]}" "${DATA_DIR}" "${REMOTE_USER}@${REMOTE_IP}:${REMOTE_DEST}")
PAYLOAD=$(cat <<-END

This data was transferred on:
    $(date)

ACBOX USER: $USER
ACBOX HOST: $HOSTNAME
    SOURCE: $DATA_DIR

REMOTE USER: $REMOTE_USER
  REMOTE IP: $REMOTE_IP
       DEST: $REMOTE_DEST

rysnc command run:
$ ${RSYNC_CMD[@]}

END
)
echo -e "$HEADER\n$PAYLOAD\n" > "$TEMP_LOG"

if [ "$CLEAN" = true ]; then
    RESP=$(get_yn "Are you sure you want to delete the source files after transfer?")
    if [ "$RESP" = false ]; then
        kill -SIGINT $$
    fi
fi

if [ "$PARALLEL" = true ]; then
    DAQ_STATE=$($HOME/ACBOX/scripts/status/get_daq_state.sh)
    while [ "$DAQ_STATE" = "Running" ]; do
        rsync "${RSYNC_OPTIONS[@]}" "${DATA_DIR}" "${REMOTE_USER}@${REMOTE_IP}:${REMOTE_DEST}"
        echo -e "\n$(date) --> rsync will start again in $FREQ_SECONDS second(s)\n" | tee "$TEMP_LOG"
        sleep "$SECONDS";
        DAQ_STATE=$($HOME/ACBOX/scripts/status/get_daq_state.sh)
    done
else
    rsync "${RSYNC_OPTIONS[@]}" "${DATA_DIR}" "${REMOTE_USER}@${REMOTE_IP}:${REMOTE_DEST}"
fi

# ask if they want log header copied
RESP=$(get_yn "Would you like the log file or \"receipt\" for this transaction transferred as well?")
if [ "$RESP" = true ]; then
    rsync -arPhv "$TEMP_LOG" "$REMOTE_USER@$REMOTE_IP:$REMOTE_DEST" --remove-source-files;
fi