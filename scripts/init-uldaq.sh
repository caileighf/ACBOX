#!/bin/bash
cd ~/
wget -N https://github.com/mccdaq/uldaq/releases/download/v1.2.0/libuldaq-1.2.0.tar.bz2
tar -xvjf libuldaq-1.2.0.tar.bz2
cd libuldaq-1.2.0
./configure && make
sudo make install
RC=$?
if [ $RC -eq 0 ] ; then
    clear
    echo "Successfully built and installed uldaq software"
else
    echo "Failed to install uldaq software!"
fi