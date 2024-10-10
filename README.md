# default firmware for doppler
 2 bytes SPI fullduplex sequence
- input to led matrix
- output from gpios and buttons see pcf file file for pin mapping

Based on https://github.com/noscene/Doppler_FPGA_Firmware/tree/master/doppler_simple_io

Can be build using icestorm docker image - see https://github.com/noscene/Doppler_FPGA_Firmware#build

Can also be build directly, if `icestorm` and `arache-pnr` are installed

## additional stuff
- Avoid absolut names by coping header-file to arduino_dir
- Removed weird upload of default firmware (`ice40.upload()`)
- Added make.sh to build in Docker with correct permissions
- Removed need for renaming var in `.h` file

## scripts
`make.sh` - compile fpga AND arduino project, upload to doppler.

Eg: `$ PROJ=doppler_custom ./make.sh` FPGA project in [doppler_custom.v](doppler_custom.v) and
arduino project in [doppler_custom_arduino/doppler_custom_arduino.ino](doppler_custom_arduino/doppler_custom_arduino.ino)

Or: `$ PROJ=miditest ./make.sh`


## projs

### synth.v

A sine-wav, frequence modulated by a saw wave

### miditest.v

Turns the Doppler into a midi-enabled synth (really just enables Midi on and Midi off for now).

Requires the [MIDIUSB.h](https://www.arduinolibraries.info/libraries/midiusb) library installed, which makes the Doppler expose a MIDI device over USB.

Install like this:

```
arduino-cli lib install MIDIUSB
```


After the Arduino project has been uploaded to the Doppler, check that the midi device is active with `aplaymidi` (part of the `alsa-utils` package):

```
$ aplaymidi --list
 Port    Client name                      Port name
 14:0    Midi Through                     Midi Through Port-0
 20:0    doppler                          doppler MIDI 1
 ```

The `playmidi.sh` script continuously plays the `miditest.mid` file on the 
Doppler.

For now it just turns amp on/off on midi on/off.

## AArch64

The Doppler requires a few "cores" (confusingly referred to as "Boards" in 
the Arduino IDE):
- Adafruit SAMD Boards
- dadamachines - M4 Boards

This is nicely described here: 
https://github.com/dadamachines/arduino-board-index/blob/master/README.md

But it can be done via CLI:
```
$ arduino-cli core install adafruit:samd --additional-urls 'https://adafruit.github.io/arduino-board-index/package_adafruit_index.json'
$ arduino-cli core install 'dadamachines - M4:samd' --additional-urls 'https://grav.github.io/arduino-board-index/package_dadamachines-m4_index.json' # notice I'm using my own index, as it has correct size and checksum, which is necessary for arduino-cli
```

However, the old "Adafruit SAMD Boards" v1.3 isn't compatible with Aarch64, and 
the Doppler core is hard-wired to use v1.3 (or similar old version).

To fix this, install a newer version of "Adafruit SAMD Boards" (eg 1.7.13), then install the old version of the "dadamachines - M4 Boards" and patch it up, like so:

```
$ cd ~/.arduino15/packages/dadamachines\ -\ M4/hardware/samd/1.3.1 # linux
$ cd ~/Library/Arduino15/packages/dadamachines\ -\ M4/hardware/samd/1.3.1 # mac
$ patch < /path/to/doppler_custom/doppler_aarch64_patch.diff
```

TODO: Just upload a fixed version of the doppler core
