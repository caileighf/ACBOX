# The Acoustic Data Collection Box Documentation
##### *MURAL* - Marine Unmanned Robotics Acoustics Lab - [[wiki]]()

| <img src="https://raw.githubusercontent.com/caileighf/ACBOX/master/images/open_all.png" alt="open_all" width="" height=""> |<img src="https://raw.githubusercontent.com/caileighf/ACBOX/master/images/array_angle.png" alt="array_angle" width="1150" height=""><img src="https://raw.githubusercontent.com/caileighf/cli-spectrogram/master/images/default.png" alt="cli-spectrogram" width="1150" height=""> |
|-|-|


### System Diagram
<img src="https://raw.githubusercontent.com/caileighf/ACBOX/master/images/ACBOX-diagram.png" alt="block diagram" width="" height="">

### Hardware Components
| | Wiring Diagram | Datasheet | Input | Output |
|-|-------|-----------------|-----------------|--------|
|__Hydrophone(s)__| <img src="https://raw.githubusercontent.com/caileighf/ACBOX/master/images/ACBOX-hydrophone-array-wiring-diagram.png" alt="ACBOX-hydrophone-wiring-diagram" width="" height=""> | [HTI-96-Min Exportable](http://www.hightechincusa.com/products/hydrophones/hti96minexportable.html) | Sound | Raw voltage |
|__Array Adapter__| <img src="https://raw.githubusercontent.com/caileighf/ACBOX/master/images/ACBOX-adapter.png" alt="adapter" width="" height=""> |  |  |  |
|__Analog Front End__| <img src="https://raw.githubusercontent.com/caileighf/ACBOX/master/images/ACBOX-analog-board-wiring-diagram.png" alt="block diagram" width="" height=""> |  | Raw voltage | Power for the hydrophone(s) and Filtered voltage to the DAQ |
|__MCC DAQ 1608FS-Plus__| <img src="https://raw.githubusercontent.com/caileighf/ACBOX/master/images/ACBOX-daq-highlight.png" alt="ACBOX-daq-highlight" width="" height=""> | [[MCC 1608FS-Plus datasheet]](https://www.mccdaq.com/GetPDF.aspx?t=/PDFs/specs/DS-USB-1608FS-Plus.pdf) [[User manual]](https://www.mccdaq.com/GetPDF.aspx?t=/PDFs/manuals/USB-1608FS-Plus.pdf) [[Product page]](https://www.mccdaq.com/usb-data-acquisition/USB-1608FS-Plus-Series) | Filtered voltage from the analog board | voltage values to it's hardware buffer |
|__Raspberry Pi__| <img src="https://raw.githubusercontent.com/caileighf/ACBOX/master/images/ACBOX-pi-highlight.png" alt="ACBOX-pi-highlight" width="" height=""> | [Raspberry Pi 3B+](https://www.raspberrypi.org/products/raspberry-pi-3-model-b-plus/) | voltage values from the hardware buffer on the DAQ | Text or binary files containing voltage per channel data |

### Software Components
| | Screen Capture | Purpose | Links |
|-|----------------|---------|-------|
|__MCCDAQ Driver__| <img src="https://raw.githubusercontent.com/caileighf/ACBOX/master/images/MCCDAQ-screen-capture.png" alt="MCCDAQ-screen-capture" width="" height=""> | MCCDAQ drives the DAQ with a user defined configuration | (private repo) [MCCDAQ Driver](https://github.com/nicrip/MCCDAQ) |
|__cli-sprectrogram__| <img src="https://raw.githubusercontent.com/caileighf/cli-spectrogram/master/images/default.png" alt="cli-spectrogram" width="" height=""> | The cli-spectrogram allows the user to see (in real-time & post mission) what the hydrophones are picking up | (PyPi) [cli-spectrogram](https://pypi.org/project/cli-spectrogram/) |

### Recording Acoustic Data with the ACBOX

__To configure and launch the MCCDAQ driver__
```
    $ cd /<path-to-MCCDAQ>/MCCDAQ/bin/
    $ ./config_daq  # will walk you through setting the sample rate, file-length, etc...
    $ ./run_daq     # the data files will be in ./data
```

__Launch the cli-spectrogram__
```
    $ cd /<path-to-MCCDAQ>/MCCDAQ/bin/
    $ cli_spectrogram --sample-rate <SAMPLE-RATE> --file-length <FILE-LENGTH> --source ./data
```
*You'll need two terminal windows to launch the MCCDAQ Driver and cli-spectrogram (unless you run with nohup or use a terminal multiplexer like screen or tmux).*

<img src="https://raw.githubusercontent.com/caileighf/ACBOX/master/images/open_electronics.png" alt="open_electronics" width="400" height=""> <img src="https://raw.githubusercontent.com/caileighf/ACBOX/master/images/analog_top.png" alt="analog_top" width="400" height=""> <img src="https://raw.githubusercontent.com/caileighf/ACBOX/master/images/closed_angle_ports.png" alt="closed_angle_ports" width="400" height=""> <img src="https://raw.githubusercontent.com/caileighf/ACBOX/master/images/display_keyboard.png" alt="display_keyboard" width="400" height="">
<img src="https://raw.githubusercontent.com/caileighf/ACBOX/master/images/adapter_6pin_focus.png" alt="adapter_6pin_focus" width="400" height=""> <img src="https://raw.githubusercontent.com/caileighf/ACBOX/master/images/adapter_9pin_focus.png" alt="adapter_9pin_focus" width="400" height="">
<img src="https://raw.githubusercontent.com/caileighf/ACBOX/master/images/analog_angle.png" alt="analog_angle" width="400" height=""> <img src="https://raw.githubusercontent.com/caileighf/ACBOX/master/images/array_6pin.png" alt="array_6pin" width="400" height="">
<img src="https://raw.githubusercontent.com/caileighf/ACBOX/master/images/array_angle.png" alt="array_angle" width="400" height=""> <img src="https://raw.githubusercontent.com/caileighf/ACBOX/master/images/array_pots.png" alt="array_pots" width="400" height="">
<img src="https://raw.githubusercontent.com/caileighf/ACBOX/master/images/closed.png" alt="closed" width="400" height=""> <img src="https://raw.githubusercontent.com/caileighf/ACBOX/master/images/closed_angle.png" alt="closed_angle" width="400" height="">
<img src="https://raw.githubusercontent.com/caileighf/ACBOX/master/images/open_analog_bottom.png" alt="open_analog_bottom" width="400" height=""> <img src="https://raw.githubusercontent.com/caileighf/ACBOX/master/images/open_electronics_angle.png" alt="open_electronics_angle" width="400" height="">

