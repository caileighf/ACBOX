#!/bin/bash

# Prints help messages for ACBOX
PRINT_HEADER=true
HEADER=$(cat <<-END
    ------------------------------------------------------
    | Help Message for the Acoustic Data Acquisition Box |
    ------------------------------------------------------
END
)

DEBUG_HELP=$(cat <<-END
     Remote Debugging Help/Tools:

        Useful alias: 
            $ has_fix    # find out if GPS has fix
            $ has_pps    # find out if PPS is being used
            $ echo_loc   # echo lat, lon and, google maps link
            $ see_daq    # checks if DAQ is connected
            $ is_running # 
END
)

CLI_HELP=$(cat <<-END
     Start Command Line Spectrogram:

        $ cd ~/ACBOX/cli-spectrogram/
        $ python cli-spectrogram/cli_spectrogram.py

        Useful shortcuts: 
            "f" -----> Toggle fullscreen
            "c" -----> Cycle through channels
            "B" -----> Go to beginning of data set
            "A" -----> Go back 10 mins
            "a" -----> Go back 1 min
            "D" -----> Go forward 10 mins
            "d" -----> Go forward 1 min
            "PgDn" --> Previous file
            "PgUp" --> Next file
            "ESC" ---> Back to real-time
            "Up" ----> Increase threshold (dB)
            "Down" --> Decrease threshold (dB)
            "^Up" ---> Increase NFFT
            "^Down" -> Decrease NFFT
END
)

MCCDAQ_HELP=$(cat <<-END
     Start Acoustic Data Collection:

        $ cd ~/ACBOX/MCC_DAQ/   # ACBOX driver directory
        $ ./config_daq          # Interactive config
        $ ./start_collect       # Start data acquisition
END
)

USAGE=$(cat <<-END
 usage: ./echo-help.sh              # for BOTH help messages
        ./echo-help.sh --mccdaq     # for MCC_DAQ help
        ./echo-help.sh --cli        # for cli-spectrogram help
        ./echo-help.sh --help | -h  # print this usage message
END
)

HLINE=$(cat <<-END
\n     ----------------------------------------------------\n
END
)

function print_help {
    echo -e "\n\
$HEADER\n\
$MCCDAQ_HELP\n\
    $HLINE\n\
$CLI_HELP\n\
    $HLINE\n\
$DEBUG_HELP\n";
}

MSG=""
if [[ "$#" = 0 ]] ; then
    print_help
else
    for ARG in "$@"; do
        # check for known args
        if [ "$ARG" = "--mccdaq" ]; then 
            MSG="$MCCDAQ_HELP"
        elif [ "$ARG" = "--cli" ]; then
            MSG="$CLI_HELP"
        elif [ "$ARG" = "--debug" ]; then
            MSG="$DEBUG_HELP"
        else 
            printf "$USAGE\n"
            break;
        fi

        # print header on first iter
        # .. the following iterations will add hline
        if "$PRINT_HEADER" ; then 
            echo -e "\n$HEADER\n"
            echo -e "$MSG"
            PRINT_HEADER=false
        else
            echo -e "    $HLINE"
            echo -e "$MSG"
        fi
        MSG=""
    done
fi
echo ""