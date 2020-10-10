#!/bin/bash

# http://thomasloughlin.com/gpspipe-gps-client/

gpsdata=$( timeout 2 gpspipe -w -n 5 | grep -m 1 lon )

if [ "$gpsdata" = "" ] ; then
    echo "No GPS data"
else
    lat=$( echo "$gpsdata"  | jsawk 'return this.lat' )
    lon=$( echo "$gpsdata"  | jsawk 'return this.lon' )
    echo "$lat, $lon - https://maps.google.com/maps?q=$lat,+$lon"
fi