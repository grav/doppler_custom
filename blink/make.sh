#!/usr/bin/env bash

set -euo pipefail
set -x

DEVICE=up5k

# "Fully qualified board name" and port found with `arduino-cli board list`
FQBN="dadamachines - M4:samd:doppler"

PORT="/dev/ttyACM0"

yosys -v 3 -p 'synth_ice40 -top top -blif blink.blif' top.v blink.v

arachne-pnr -d 5k -o blink.asc -p doppler.pcf blink.blif -P sg48

icepack blink.asc blink.bin

# Not mandatory
icetime -d $DEVICE -mtr blink.rpt blink.asc

xxd -i blink.bin > blink.h
sed -i -r 's/unsigned/const unsigned/g' blink.h

arduino-cli compile --fqbn "$FQBN"

arduino-cli upload --fqbn "$FQBN" --port "$PORT"
