## Setting Up The Raspberry Pi For Acoustic Data Logging

### Installing General Dependencies 
__Requires Internet Connection__ -- The following command will install USB drivers, networking tools, gpsd, screen and, htop to name a few. Make sure you're running this script from the `scripts/` directory.
```
$ ./install-dependencies.sh
```

### Installing `uldaq` Dependencies 
__Requires Internet Connection__ -- The following script will get the 1.2.0 version of the uldaq software suite, make, build and, install it. The directory containing the binaries will be here: `~/libuldaq-1.2.0/`
```
$ ./init-uldaq.sh
```

### Setting Up `udev` Rules The Adafruit Ultimate GPS Breakout Board
The following script will output the udev rule needed to name the GPS port `/dev/ttyGPS`. The scripts that handle data logging will be looking for the GPS on this port.
```
$ ./make_udev_rule.sh /dev/ttyUSB0 /dev/ttyGPS # USB0 should be replaced with the port the GPS is connected to 
                                               # The following output is an example of the output from this script

SUBSYSTEM=="tty", ATTRS{idVendor}=="0403", ATTRS{idProduct}=="6001", ATTRS{serial}=="AK08V3TP", SYMLINK+="ttyGPS"
```
```
$ sudo nano /etc/udev/rules.d/55-daq.rules     # paste the previous output in this file, save and exit.
$ udevadm trigger                              # should force udev to re-check rules but a reboot will also work
```

### Starting The `gpsd` Client For The Adafruit Ultimate GPS Breakout Board
The following script will start the gpsd client.
```
$ ./init-gpsd.sh /dev/ttyGPS
```