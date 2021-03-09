#!/bin/bash

# for using the little mini pi TFT display
# further instruction can be found here:
# https://learn.adafruit.com/adafruit-mini-pitft-135x240-color-tft-add-on-for-raspberry-pi/kernel-module-install

cd ~
sudo pip3 install --upgrade adafruit-python-shell click==7.0
git clone https://github.com/adafruit/Raspberry-Pi-Installer-Scripts.git
cd Raspberry-Pi-Installer-Scripts
sudo python3 adafruit-pitft.py --display=st7789_240x135 --rotation=90 --install-type=console