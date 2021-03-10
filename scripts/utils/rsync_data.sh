#!/bin/bash

# For styling prompt to stick out
bold=$(tput bold)
normal=$(tput sgr0)
AUTO=false

function get_yn() {
    if [ "$AUTO" = false ]; then
        while true; do
            read -p "Please answer [Yes/No]: " yn
            case $yn in
                [Yy]* ) local return_val=true; break;;
                [Nn]* ) local return_val=false; break;;
                * ) echo "${bold}Please answer yes or no.${normal}";;
            esac
        done
    else
        local return_val=true;
    fi
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
        --include-all-logs -----> Include gps, and other general logs
        -f <CONFIG.JSON-FILE> --> Pass config file if different than $HOME/ACBOX/MCC_DAQ/config.json

* enviroment variables this script uses
 \$GPS_DATA_DIR ----------------> Directory containing GPS data files (track_<EPOCH>.nmea)
 \$GPS_LOG_DIR -----------------> Directory containing GPS log files (debug_<EPOCH>.log)
 \$DAQ_CONFIG ------------------> Path to MCC_DAQ driver config.json (required if using default config)
 \$LOG_DIR ---------------------> Directory containing general log files (<desc>_<EPOCH>.log)

END
)

CONFIG_FILE=$(cat ${DAQ_CONFIG})
SECONDS=5
#
#   HANDLE REQUIRED AND OPTIONAL SHORT ARGS
#
while getopts u:i:d:f:s:-:a flag
do
    case "${flag}" in
        a) AUTO=true;;
        u) REMOTE_USER=${OPTARG};;
        i) REMOTE_IP=${OPTARG};;
        d) REMOTE_DEST=${OPTARG};;
        f) CONFIG_FILE=$(cat ${OPTARG});;
        s) SECONDS=${OPTARG};;
        -) break;; # this allows long args to pass to next section
        \? ) echo "Unknown option: -$OPTARG" >&2; ;;
        :  ) echo "Missing option argument for -$OPTARG" >&2; ;;
        *  ) echo "Unimplemented option: -$OPTARG" >&2; ;;
    esac
done

#
#   HANDLE NO ARGS
#
if ((OPTIND == 1)); then
    echo "No options specified";
    echo "$USAGE";
    kill -SIGINT $$
fi

#
#   HANDLE LONG ARGS --  Handle long args and add options to rsync command
#
DRY_RUN=false
CLEAN=false
PARALLEL=false
DATA_DIR=$( echo "$CONFIG_FILE"  | jsawk 'return this.data_directory' )
SOURCE_DIRS=(
    "--include=${DATA_DIR}"
)
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

echo "ARGS: $@"
i=0;
for ARG in "$@" 
do
    i=$((i + 1));

    if [ ${ARG} = '--dry-run' ]; then
        DRY_RUN=true
        RSYNC_OPTIONS+=(--dry-run)

    elif [ ${ARG} = '--include-gps' ]; then
        SOURCE_DIRS+=("--include=${GPS_DATA_DIR}")

    elif [ ${ARG} = '--include-gps-logs' ]; then
        SOURCE_DIRS+=("--include=${GPS_LOG_DIR}")

    elif [ ${ARG} = '--include-all-logs' ]; then
        SOURCE_DIRS+=("--include=${GPS_LOG_DIR}")
        SOURCE_DIRS+=("--include=${LOG_DIR}")

    elif [ ${ARG} = '--clean' ]; then
        CLEAN=true
        RSYNC_OPTIONS+=(--remove-source-files)

    elif [ ${ARG} = '--parallel' ]; then
        PARALLEL=true

    elif [ ${ARG} = '--help' ]; then
        echo -e "\n$USAGE\n"
        kill -SIGINT $$
    fi
    shift;
done

RSYNC_CMD=("rsync" "${RSYNC_OPTIONS[@]}" "${SOURCE_DIRS[@]}" "${REMOTE_USER}@${REMOTE_IP}:${REMOTE_DEST}")
PAYLOAD=$(cat <<-END

This data was transferred on:
    $(date)

ACBOX USER: $USER
ACBOX HOST: $HOSTNAME
    SOURCE: ${SOURCE_DIRS[@]}

REMOTE USER: $REMOTE_USER
  REMOTE IP: $REMOTE_IP
       DEST: $REMOTE_DEST

rysnc command run:
$ ${RSYNC_CMD[@]}

END
)

#
#   SHOW USER -- info about upcoming transfer
#
echo -e "$HEADER\n$PAYLOAD\n" | tee "$TEMP_LOG"

if [ "$CLEAN" = true ]; then
    echo "----------------------------------------------------------------"
    echo "${bold}Are you sure you want to delete the source files after transfer?${normal}"
    echo "----------------------------------------------------------------"
    RESP=$(get_yn)
    if [ "$RESP" = false ]; then
        kill -SIGINT $$
    fi
fi

#
#   PROMPT USER -- Give user chance to look over header & payload before starting transfer
#
if [ "$DRY_RUN" = false ]; then
    echo "---------------"
    echo "${bold}Start transfer?${normal}"
    echo "---------------"
    RESP=$(get_yn)
    if [ "$RESP" = false ]; then
        kill -SIGINT $$
    fi
fi

#
#   TRANSFER DATA -- if PARALLEL, transfer in loop until DAQ stops running
#                 -- if default (--all), transfer in one go
#
#   * if user passes --parallel and the DAQ isn't running, we default to --all mode
#
DAQ_STATE=$($HOME/ACBOX/scripts/status/get_daq_state.sh)
if [[ "$PARALLEL" = true && "$DAQ_STATE" = "Running" ]]; then
    while [ "$DAQ_STATE" = "Running" ]; do
        rsync "${RSYNC_OPTIONS[@]}" "${DATA_DIR}" "${REMOTE_USER}@${REMOTE_IP}:${REMOTE_DEST}"
        echo -e "\n$(date) --> rsync will start again in $FREQ_SECONDS second(s)\n" | tee "$TEMP_LOG"
        sleep "$SECONDS";
        DAQ_STATE=$($HOME/ACBOX/scripts/status/get_daq_state.sh)
    done
else
    rsync "${RSYNC_OPTIONS[@]}" "${DATA_DIR}" "${REMOTE_USER}@${REMOTE_IP}:${REMOTE_DEST}"
fi

#
#   CLEAN UP -- transfer rsync log file/receipt if not dry run
#
if [ "$DRY_RUN" = true ]; then
    echo -e "\nDone!\n"
else
    # ask if they want log header copied
    echo -e "\n----------------------------------------------------------------------------------"
    echo "${bold}Would you like the log file or \"receipt\" for this transaction transferred as well?${normal}"
    echo "----------------------------------------------------------------------------------"
    RESP=$(get_yn)
    if [ "$RESP" = true ]; then
        rsync -arPhv "$TEMP_LOG" "$REMOTE_USER@$REMOTE_IP:$REMOTE_DEST/rsync_transaction_receipt.txt" --remove-source-files;
    fi
fi
