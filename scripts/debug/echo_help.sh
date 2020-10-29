#!/bin/bash

# Prints help messages for ACBOX
PRINT_HEADER=true
HEADER=$(cat <<-END
    ------------------------------------------------------
    | \033[1mHelp Message for the Acoustic Data Acquisition Box\033[0m |
    ------------------------------------------------------
END
)

DEBUG_HELP=$(cat <<-END
     \033[1mDEBUGGING INFO AND HELPFUL SHORTCUTS\033[0m
     ------------------------------------
 
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
            $ help_offload # show data offload help message | less
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
            C-a t -- show cpu temp ----------------------- [$USER@$HOSTNAME | cpu temp: 49.4'C]
            C-a l -- show system load -------------------- [$USER@$HOSTNAME | cpu load: 0.02 0.14 0.10]
            C-a s -- show volume on RPi headphone jack --- [$USER@$HOSTNAME | volume: -20.00dB]
            C-a m -- show available disk space ----------- [$USER@$HOSTNAME | free space: 53G]
            C-a u -- show machine up time ---------------- [$USER@$HOSTNAME | up since: 2020-09-29 15:58:51]
            C-a D -- show DAQ state (Default at launch) -- [$USER@$HOSTNAME | DAQ state: Idle]
 
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
     \033[1mUSING THE CLI-SPECTROGRAM\033[0m
     -------------------------
 
     Start Command Line Spectrogram:
 
        $ cli_spectrogram [OPTIONS] # alias to launch cli_spectrogram.py
        $ cli_spectrogram_auto      # starts cli-spectrogram with DAQ config file
 
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
     \033[1mSTART COLLECTING DATA\033[0m
     ---------------------
 
     Start Acoustic Data Collection:
 
        Default data directory:
        /home/$USER/ACBOX/MCC_DAQ/data/ 
 
        Commands:
            $ config_daq    # Interactive config
            $ start_collect # Start data acquisition
            $ kill_daq      # Kill DAQ (same as Ctrl+c in shell where it was started)
END
)


OFFLOAD_HELP=$(cat <<-END
     \033[1mOFFLOADING/TRANSFERRING DATA\033[0m
     ----------------------------
 
     The following rsync scripts are for ease of offloading/transferring data
     to a remote machine. They will not create duplicate files on the remote machine so.
     Running any of these scripts with --dry-run
   
        rsync_all --------> Transfer all data files using the data directory ..
                            .. in the config.json file for the DAQ (.../MCC_DAQ/config.json)
                            It will NOT delete files on source or remote machine
 
        rsync_clean ------> Transfer all data files using the data directory ..
                            .. in the config.json file for the DAQ (.../MCC_DAQ/config.json)
                            It will not delete files on the remote machine 
                            \033[1m* FILES WILL BE DELETED ON SOURCE MACHINE AFTER TRANSFER *\033[0m
 
        rsync_parallel ---> Starts a transfer periodically (-s <FREQ-SEC>)
                            It will NOT delete files on source or remote machine
 
     Offloading/Transferring Data:
        $ screen -R ACBOX   # attach to screen session setup for ACBOX

        $ rsync_all -u <REMOTE-USER> -i <REMOTE-IP-ADDRESS> -d <REMOTE-DEST>
        $ rsync_clean -u <REMOTE-USER> -i <REMOTE-IP-ADDRESS> -d <REMOTE-DEST>
 
        ---------------- SSH keys need to be setup for the parallel rsync mode ----------------
        ----- This avoids the process being blocked while waiting for the remote password -----
        ---------------------------------------------------------------------------------------
        $ rsync_parallel -u <REMOTE-USER> -i <REMOTE-IP-ADDRESS> -d <REMOTE-DEST> -s <FREQ-SEC>

        ------------------- SSH keys should be setup for the auto rsync mode ------------------
        ----------------------- In this mode NO user input is required ------------------------
        ---------------------------------------------------------------------------------------
        $ config_rsync   # configure rsync remote client info for rsync_auto
        $ rsync_auto     # this alias calls a script called rsync_auto.sh that has the remote
                         # info saved in rsync_config.json
 
END
)

GPS_HELP=$(cat <<-END
     \033[1mGPS Logger\033[0m
     ----------
 
     To start the gps logger run:
        $ start_logging_gps

     This will output data to stdout AND a file.
     The actual command is:
        $ gpspipe -t -uu -r | tee $HOME/ACBOX/gps_logger/data/track_$(date +%s).nmea
 
END
)

HLINE=$(cat <<-END
\n   ---------------------------------------------------
END
)

SCREEN_MSG=$(cat <<-END
\033[1m
==========================================================================================
==================== YOU ARE CURRENTLY IN THE ACBOX SCREEN SESSION... ====================
==========================================================================================
\033[0m
END
)

WELCOME=$(cat <<-END
$(cat $HOME/ACBOX/scripts/banner.txt)

 \033[1mHelpful keyboard shortcuts and aliases:\033[0m
    $ help         # show complete help message
    $ show_welcome # show this message again
 
 \033[1mStart/Monitor Data Collection:\033[0m
    $ screen -R ACBOX      # attach to screen session setup for ACBOX
    $ config_daq           # interactive config
    $ start_collect        # start data collection with config file
    -- 
    $ cli_spectrogram      # starts cli-spectrogram 
    $ cli_spectrogram_auto # starts cli-spectrogram with DAQ config file
    
 \033[1mOffloading Data:\033[0m
    $ screen -R ACBOX      # attach to screen session setup for ACBOX
    $ rsync_all -u <REMOTE-USER> -i <REMOTE-IP-ADDRESS> -d <REMOTE-DEST>
    --
    $ rsync_parallel -u <REMOTE-USER> -i <REMOTE-IP-ADDRESS> -d <REMOTE-DEST> -s <FREQ-SEC>

 \033[1mACBOX screen session:\033[0m
    The ACBOX screen session has the following four windows:

    0 - "DAQ":   [C-a 0] For running the cli-spectrogram
    1 - "cli":   [C-a 1] For running the config_daq and start_collect processes
    2 - "sync":  [C-a 2] For running rsync scripts and watching progress (if parallel)
    3 - "debug": [C-a 3] For debugging 
    4 - "GPS":   [C-a 4] For GPS logging

 \033[1mTo exit and detach:\033[0m
    C-a d -----> Detatches the screen session. All processes will continue running
    $ exit ----> End ssh session

END
)

USAGE=$(cat <<-END
 usage: ./echo-help.sh            # for BOTH help messages
        ./echo-help.sh --mccdaq   # for MCC_DAQ help
        ./echo-help.sh --cli      # for cli-spectrogram help
        ./echo-help.sh --offload  # for rsync help
        ./echo-help.sh --debug    # for debugging help
        ./echo-help.sh --gps      # for GPS logging help
        ./echo-help.sh --help/-h  # print this usage message
END
)

function print_help {
    echo -e "\n\
$HEADER\n\
$MCCDAQ_HELP\
    $HLINE\n\
$CLI_HELP\
    $HLINE\n\
$OFFLOAD_HELP\
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
        elif [ "$ARG" = "--offload" ]; then
            MSG="$OFFLOAD_HELP"
        elif [ "$ARG" = "--gps" ]; then
            MSG="$GPS_HELP"
        elif [ "$ARG" = "--screen" ]; then 
            printf "\n$WELCOME\n$SCREEN_MSG\n"
            kill -SIGINT $$
        else 
            printf "$USAGE\n"
            kill -SIGINT $$
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