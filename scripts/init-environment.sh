#!/bin/bash

echo "This script sets environment variables and sets up the python virtual env"
echo "========================================================================="
echo "[1/4]: Setting up python environment..."
virtualenv -p python3 ~/venv
source ~/venv/bin/activate
echo "[2/4]: Installing python dependencies..."
pip install -r ~/ACBOX/MCC_DAQ/requirements.txt
echo "Leaving python virtualenv..."
deactivate
echo "[3/4]: Adding PYTHON_EXE=~/venv/bin/python"
echo "export PYTHON_EXE=~/venv/bin/python" >> ~/.bashrc
echo "[4/4]: Adding shell_history log"
export PROMPT_COMMAND='RETRN_VAL=$?;echo "$(whoami) $(date) [$$]: $(history 1 | sed "s/^[ ]*[0-9]\+[ ]*//" ) [$RETRN_VAL]" >> ~/shell_history'
echo export\ _PROMPT_COMMAND=\'$_PROMPT_COMMAND\' >> ~/.bashrc
source ~/.bashrc
echo "The python environment and shell environment are setup."
echo "========================================================================="