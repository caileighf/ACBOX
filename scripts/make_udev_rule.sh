#!/bin/bash

SUBSYSTEM="tty"
ATTRS_VENDOR_KEY="{idVendor}"
ATTRS_PRODUCT_KEY="{idProduct}"
ATTRS_SERIAL_KEY="{serial}"
SYMLINK="tty"

function get_attr {
    FD=$1
    KEY=$2

    local return_val=$(udevadm info -a -n $FD | grep $KEY | head -n1)
    echo $return_val
}

function make_udev_rule {
    VENDOR=$(get_attr $1 $ATTRS_VENDOR_KEY)
    PRODUCT=$(get_attr $1 $ATTRS_PRODUCT_KEY)
    SERIAL=$(get_attr $1 $ATTRS_SERIAL_KEY)

    local return_val="SUBSYSTEM==\"$SUBSYSTEM\", $VENDOR, $PRODUCT, $SERIAL, SYMLINK+=\"$SYMLINK\""
    echo $return_val
}

if [[ $# -ne 2 ]] ; then
    printf "usage: ./make_udev_rule.sh [FILE DESCRIPTOR] [SYMLINK]\n"
    printf "   ex: ./make_udev_rule.sh /dev/ttyUSB0 ttyNONAME\n\n"
    printf "ex output: SUBSYSTEM==\"tty\", ATTRS{idVendor}==\"0403\", ATTRS{idProduct}==\"6001\", ATTRS{serial}==\"A403JWP8\", SYMLINK+=\"ttyNONAME\"\n"
else
    FD=$1
    SYMLINK=$2
    udev_rule=$(make_udev_rule $FD $SYMLINK)
    printf "$udev_rule\n" 
fi