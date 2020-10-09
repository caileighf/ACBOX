#!/bin/bash

# http://thomasloughlin.com/gpspipe-gps-client/

gpsdata=$( gpspipe -w -n 10 |   grep -m 1 lon )

# added to check values was returned
diff <(echo "$gpsdata") <(echo "") > /dev/null || echo "No GPS data"; exit 1;

lat=$( echo "$gpsdata"  | jsawk 'return this.lat' )
lon=$( echo "$gpsdata"  | jsawk 'return this.lon' )
echo "$lat, $lon - https://maps.google.com/maps?q=$lat,+$lon"
exit 0;