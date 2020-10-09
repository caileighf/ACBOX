#!/bin/bash

echo "This script sets environment variables and sets up the python virtual env"
echo "========================================================================="
echo "[1/5]: Setting up python environment..."
virtualenv -p python3 /home/pi/venv
source /home/pi/venv/bin/activate
echo "[2/5]: Installing python dependencies..."
pip install -r /home/pi/ACBOX/MCC_DAQ/requirements.txt
echo "Leaving python virtualenv..."
deactivate
echo "[3/5]: Adding PYTHON_EXE=~/venv/bin/python"
echo "export PYTHON_EXE=~/venv/bin/python" >> /home/pi/.bashrc
echo "[4/5]: Adding shell_history log"
export PROMPT_COMMAND='RETRN_VAL=$?;echo "$(whoami) $(date) [$$]: $(history 1 | sed "s/^[ ]*[0-9]\+[ ]*//" ) [$RETRN_VAL]" >> ~/shell_history'
echo export\ PROMPT_COMMAND=\'$PROMPT_COMMAND\' >> /home/pi/.bashrc
echo "alias python=$PYTHON_EXE" >> /home/pi/.bashrc
echo "[5/5]: Setting up jawk dep for location scripts"
curl -L http://github.com/micha/jsawk/raw/master/jsawk > jsawk
chmod 755 jsawk && sudo mv jsawk /bin/
sudo ln -s /usr/bin/js24 /usr/bin/js
source /home/pi/.bashrc
echo "The python environment and shell environment are setup."
echo "========================================================================="