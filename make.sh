#!/bin/bash
set -euvx

## make firmware (either with docker or natively)
# docker run --user $(id -u):$(id -g) -it -v $PWD:/PRJ icestorm bash -c 'cd PRJ && make clean && make'
make clean; make

## Compile and upload
## "Fully qualified board name" and port found with `arduino-cli board list`
FQBN="dadamachines - M4:samd:doppler"
( cd doppler_custom_arduino && arduino-cli compile --fqbn "$FQBN" && arduino-cli upload --fqbn "$FQBN" --port /dev/ttyACM0 )
