#!/bin/bash

cd ~/
wget -N https://github.com/mccdaq/uldaq/releases/download/v1.2.0/libuldaq-1.2.0.tar.bz2
tar -xvjf libuldaq-1.2.0.tar.bz2
cd libuldaq-1.2.0
./configure && make
sudo make install && echo "Successfully built and installed uldaq software" || echo "Failed to install uldaq software!"