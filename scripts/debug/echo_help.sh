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

        Useful aliases: (type directly from the prompt)
            $ has_fix      # find out if GPS has fix
            $ has_pps      # find out if PPS is being used
            $ get_loc      # echo lat, lon and, google maps link
            $ see_daq      # checks if DAQ is connected
            $ daq_state    # checks if DAQ is Running or Idle
            $ help         # show complete help message | less
            $ help_cli     # show cli-spectrogram help message | less
            $ help_daq     # show MCC_DAQ driver help message | less
            $ help_debug   # show THIS help message | less
            $ get_volume   # get volume on RPi headphone jack
            $ get_cpu_temp # get cpu temp in celsius
            $ get_free_mem # get remaining disk space

        GNU screen status bar section info
            1. [$USER@$HOST | DAQ state: Idle]
                |     |            |
                |     |            -- User selectable (see next table)
                |     --------------- Host machine
                --------------------- Current user

            2. no fix state: [    GPS HAS NO FIX    ]
               gpsd error:   [      No GPS data     ]
               fix state: 
            [ 41.525098,-70.672022 - https://maps.google.com/maps?q=41.525098,+-70.672022 ]
                |           |               |
                |           |               --- URL to google maps location
                |           ------------------- Longitude (Decimal Degrees)
                ------------------------------- Latitude (Decimal Degrees)

            3. [system time: 10/11/20 14:50:17] -- Current system date/time

        Change screen session status bar:
         * C-a --> Ctrl + a
            C-a t -- show cpu temp ----------------------- [$USER@$HOSTNAME | cpu temp: ]
            C-a s -- show volume on RPi headphone jack --- [$USER@$HOSTNAME | DAQ state: Idle]
            C-a m -- show available disk space ----------- [$USER@$HOSTNAME | DAQ state: Idle]
            C-a u -- show machine up time ---------------- [$USER@$HOSTNAME | up since: 2020-09-29 15:58:51]
            C-a d -- show DAQ state (Default at launch) -- [$USER@$HOSTNAME | DAQ state: Idle]

        Other helpful screen keyboard shortcuts:
            C-a ? --- Show screen keyboard shortcuts
            C-a ESC - Scroll mode (hit ESC again to exit)
            C-a w --- Show all windows
            C-a F2 -- Puts Screen into resize mode. 
                      Resize regions using hjkl keys
            C-a f --- Hide both status bars
            C-a F --- Show both status bars

END
)

CLI_HELP=$(cat <<-END
     Start Command Line Spectrogram:

        $ cli_spectrogram [OPTIONS]

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

        Default data directory:
        /home/$USER/ACBOX/MCC_DAQ/data/ 

        Commands:
            $ config_daq    # Interactive config
            $ start_collect # Start data acquisition
END
)

WELCOME=$(cat <<-END
$(cat $HOME/ACBOX/scripts/banner.txt)

 Helpful keyboard shortcuts and aliases:
    $ help         # show complete help message
    $ show_welcome # show this message again
 
 Start/Monitor Data Collection:
    $ screen -R ACBOX      # attach to screen session setup for ACBOX
    $ config_daq           # interactive config
    $ start_collect        # start data collection with config file
    -- 
    $ cli_spectrogram      # starts cli-spectrogram (no args uses DAQ config)
    
 Offloading Data:
    $ screen -R ACBOX      # attach to screen session setup for ACBOX
    $ rsync_all -u <REMOTE-USER> -i <REMOTE-IP-ADDRESS> -d <REMOTE-DEST>
    --
    $ rsync_parallel -u <REMOTE-USER> -i <REMOTE-IP-ADDRESS> -d <REMOTE-DEST>

 ACBOX screen session:
    The ACBOX screen session has the following four windows:

    0 - "DAQ":   [C-a 0] For running the cli-spectrogram
    1 - "cli":   [C-a 1] For running the config_daq and start_collect processes
    2 - "sync":  [C-a 2] For debugging 
    3 - "debug": [C-a 3] For running rsync scripts and watching progress (if parallel)

 To exit and detach:
    C-a d -----> Detatches the screen session. All processes will continue running
    $ exit ----> End ssh session

END
)

USAGE=$(cat <<-END
 usage: ./echo-help.sh            # for BOTH help messages
        ./echo-help.sh --mccdaq   # for MCC_DAQ help
        ./echo-help.sh --cli      # for cli-spectrogram help
        ./echo-help.sh --help/-h  # print this usage message
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
elif [[ "$1" = "welcome" ]] ; then
    PRINT_HEADER=false
    printf "\n$WELCOME\n"
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