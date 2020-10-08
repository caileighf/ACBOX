#!/bin/bash

echo "This script sets environment variables and sets up the python virtual env"
echo "========================================================================="
echo "[1/4]: Setting up python environment..."
virtualenv -p python3 /home/pi/venv
source /home/pi/venv/bin/activate
echo "[2/4]: Installing python dependencies..."
pip install -r /home/pi/ACBOX/MCC_DAQ/requirements.txt
echo "Leaving python virtualenv..."
deactivate
echo "[3/4]: Adding PYTHON_EXE=~/venv/bin/python"
echo "export PYTHON_EXE=~/venv/bin/python" >> /home/pi/.bashrc
echo "[4/4]: Adding shell_history log"
export PROMPT_COMMAND='RETRN_VAL=$?;echo "$(whoami) $(date) [$$]: $(history 1 | sed "s/^[ ]*[0-9]\+[ ]*//" ) [$RETRN_VAL]" >> ~/shell_history'
echo export\ PROMPT_COMMAND=\'$PROMPT_COMMAND\' >> /home/pi/.bashrc
source /home/pi/.bashrc
echo "The python environment and shell environment are setup."
echo "========================================================================="