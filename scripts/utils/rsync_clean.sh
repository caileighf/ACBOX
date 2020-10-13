#!/bin/bash
USAGE=$(cat <<-END
 usage: rsync_clean.sh -u <REMOTE-USER> -i <REMOTE-IP-ADDRESS> -d <REMOTE-DEST> [OPTIONAL-ARGS]
        [OPTIONAL-ARGS]:
        --dry-run ----> Run as dry run with no actual changes
        -f <CONFIG.JSON-FILE>

END
)

# will get over written if user passed different config
CONFIG_FILE=$(cat $HOME/ACBOX/MCC_DAQ/config.json)

while getopts u:i:d:f: flag
do
    case "${flag}" in
        u) REMOTE_USER=${OPTARG};;
        i) REMOTE_IP=${OPTARG};;
        d) REMOTE_DEST=${OPTARG};;
        f) CONFIG_FILE=$(cat ${OPTARG});;
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
    shift;
done

DATA_DIR=$( echo "$CONFIG_FILE"  | jsawk 'return this.data_directory' )
HEADER=$(head -n 10 "${DATA_DIR}SINGLE_log.log")
TEMP_LOG=".temp_rsync"
RSYNC_CMD="rsync -a -r -P -h -v ${DATA_DIR} ${REMOTE_USER}@${REMOTE_IP}:${REMOTE_DEST} --log-file ${TEMP_LOG} ${DRY_RUN} --remove-source-files"
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

if [ "$DRY_RUN" = true ]; then
    rsync -a -r -P -h -v "$DATA_DIR" "$REMOTE_USER@$REMOTE_IP:$REMOTE_DEST" --log-file "$TEMP_LOG" --dry-run --remove-source-files
else
    echo "Information about the data to be transferred:"
    cat "$TEMP_LOG"
    echo "---"
    echo "Are you sure you want to remove the source files after transfer?"
    select yn in "Yes" "No"; do
        case $yn in
            Yes ) rsync -a -r -P -h -v "$DATA_DIR" "$REMOTE_USER@$REMOTE_IP:$REMOTE_DEST" --log-file "$TEMP_LOG" --remove-source-files; break;;
            No ) exit;;
        esac
    done
fi