#!/bin/bash

echo "This script sets environment variables and sets up the python virtual env"
echo "========================================================================="
echo "[1/7]: Setting up python environment..."
virtualenv -p python3 $HOME/venv
source $HOME/venv/bin/activate
echo "[2/7]: Installing python dependencies..."
pip install -r $HOME/ACBOX/MCC_DAQ/requirements.txt
echo "Leaving python virtualenv..."
deactivate
echo "[3/7]: Adding PYTHON_EXE=~/venv/bin/python"
echo "export PYTHON_EXE=~/venv/bin/python" >> $HOME/.bashrc
echo "[4/7]: Adding shell_history log"
export PROMPT_COMMAND='RETRN_VAL=$?;echo "$(whoami) $(date) [$$]: $(history 1 | sed "s/^[ ]*[0-9]\+[ ]*//" ) [$RETRN_VAL]" >> ~/shell_history'
echo export\ PROMPT_COMMAND=\'$PROMPT_COMMAND\' >> $HOME/.bashrc
echo "alias python=$PYTHON_EXE" >> $HOME/.bashrc
echo "[5/7]: Setting up jawk dep for location scripts"
curl -L http://github.com/micha/jsawk/raw/master/jsawk > jsawk
chmod 755 jsawk && sudo mv jsawk /bin/
sudo ln -s /usr/bin/js24 /usr/bin/js
source $HOME/.bashrc
echo "[6/7]: Generating ssh keys with no password"
ssh-keygen -t rsa -f ~/.ssh/id_rsa -P ''
echo "[7/7]: Enabling sysstat to log system activity for cpu stats"
sudo sed -i 's/ENABLED="false"/ENABLED="true"/g' /etc/default/sysstat
sudo service sysstat restart
echo "The python environment and shell environment are setup."
echo "========================================================================="