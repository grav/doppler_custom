#!/bin/bash
# docker run --user $(id -u):$(id -g) -it -v $PWD:/PRJ icestorm bash -c 'cd PRJ && make clean && make'
make

( cd doppler_custom_arduino && arduino-cli upload -b "dadamachines - M4:samd:doppler" -p /dev/ttyACM0 )
