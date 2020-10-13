#!/bin/bash

sudo apt update && sudo apt upgrade
sudo apt install tree screen network-manager htop virtualenv libatlas-base-dev
sudo apt install gpsd gpsd-clients python-gps pps-tools ntpsec-ntpdate ntpdate
sudo apt install gcc g++ make libusb-1.0 libusb-1.0-0-dev
sudo apt install minicom sysstat
sudo apt install libmozjs-24-bin gawk