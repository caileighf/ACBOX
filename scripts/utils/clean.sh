#!/bin/bash

#
#   This script is meant to be run when,
#   ..you want to clean out all the data and log directories
#

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
 usage: clean.sh [OPTIONAL-ARGS]
        [OPTIONAL-ARGS]:
        --help -----------------> Print this help message
        --all ------------------> Clean all data and log directories (default)
                                  * --keep-[gps/daq/logs] will remove those dirs from list
        --keep-gps -------------> Clean all data and log directories EXCEPT GPS
        --keep-daq -------------> Clean all data and log directories EXCEPT DAQ
        --keep-logs ------------> Clean all data and log directories EXCEPT LOGS

        * --keep-<target_system> can be combined to keep GPS data && DAQ data && LOGS.
        ex: --keep-gps --keep-daq # will only delete general log files

        --dry-run --------------> Run as dry run with no actual changes

        * short arguments MUST preceed long arguments
        -f <CONFIG.JSON-FILE> --> Pass config file if different than $HOME/ACBOX/MCC_DAQ/config.json
        -q ---------------------> Quiet (will not ask for user input)

* enviroment variables this script uses
 \$GPS_DATA_DIR ----------------> Directory containing GPS data files (track_<EPOCH>.nmea)
 \$GPS_LOG_DIR -----------------> Directory containing GPS log files (debug_<EPOCH>.log)
 \$DAQ_CONFIG ------------------> Path to MCC_DAQ driver config.json (required if using default config)
 \$LOG_DIR ---------------------> Directory containing general log files (<desc>_<EPOCH>.log)

END
)

CONFIG_FILE=$(cat ${DAQ_CONFIG})
QUIET=false
#
#   HANDLE REQUIRED AND OPTIONAL SHORT ARGS
#
while getopts f:-:q flag
do
    case "${flag}" in
        f) CONFIG_FILE=$(cat ${OPTARG});;
        q) QUIET=true;;
        -) break;; # this allows long args to pass to next section
        \? ) echo "Unknown option: -$OPTARG" >&2; ;;
        :  ) echo "Missing option argument for -$OPTARG" >&2; ;;
        *  ) echo "Unimplemented option: -$OPTARG" >&2; ;;
    esac
done
#
#   HANDLE LONG ARGS --  Handle long args
#
declare -a PASSED_OPTS=()
DATA_DIR=$( echo "$CONFIG_FILE"  | jsawk 'return this.data_directory' )
DRY_RUN=false
TARGET_DIRS=("${GPS_DATA_DIR}" "${GPS_LOG_DIR}" "${DATA_DIR}" "${LOG_DIR}")

i=0;
for ARG in "$@"
do
    i=$((i + 1));
    PASSED_OPTS+=(${ARG})

    if [ ${ARG} = '--help' ]; then
        echo -e "\n$USAGE\n"
        kill -SIGINT $$
    fi

    if [ ${ARG} = '--dry-run' ]; then
        DRY_RUN=true

    elif [ ${ARG} = '--keep-gps' ]; then
        delete=("${GPS_DATA_DIR}" "${GPS_LOG_DIR}")
        TARGET_DIRS=("${TARGET_DIRS[@]/${delete[@]}}")

    elif [ ${ARG} = '--keep-daq' ]; then
        delete=("${DATA_DIR}")
        TARGET_DIRS=("${TARGET_DIRS[@]/$delete}")

    elif [ ${ARG} = '--keep-logs' ]; then
        delete=("${LOG_DIR}")
        TARGET_DIRS=("${TARGET_DIRS[@]/$delete}")
    fi
done

#
#   Loop through target dirs and build command string
#
declare -a CLEAN_CMD=()
for ARG in "${TARGET_DIRS[@]}"
do
    if [[ "${ARG}" != "" ]]; then
        #printf "rm %s/*.txt\n" ${ARG}
        CLEAN_CMD+=(`printf "%s/*.txt" ${ARG}`)
    CLEAN_CMD+=(`printf "%s/*.log" ${ARG}`)

        if [ ${ARG} = ${GPS_DATA_DIR} ]; then
            #printf "rm %s/*.nmea\n" ${ARG}
            CLEAN_CMD+=(`printf "%s/*.nmea" ${ARG}`)
    fi
    fi
done

PAYLOAD=$(cat <<-END

=============================
         ACBOX Clean
=============================
$(date)

Dry run: ${DRY_RUN}
Passed Options:
`printf '\t%s\n' ${PASSED_OPTS[@]}`
Target Directories:
`printf '\t%s\n' ${TARGET_DIRS[@]}`

Files types to purge:
- *.txt
- *.log
- *.nmea

END
)

#
#   SHOW USER -- info about what they are cleaning out
#
echo -e "$PAYLOAD\n"

if [ ${QUIET} = false ]; then
    read -p "Hit ENTER to conntinue OR Ctrl + c to quit."
fi

i=0;
for ARG in ${CLEAN_CMD[@]}
do
    i=$((i + 1));
    if ${DRY_RUN}; then
        echo "(DRY-RUN) rm $ARG"
    else
        echo "$ rm $ARG"; rm ${ARG}
    fi
done

printf "\n============\n Done! \n============\n"