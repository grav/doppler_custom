#!/bin/bash
set -euvx pipefail
: "$PROJ"


## make firmware (either with docker or natively)
# docker run --user $(id -u):$(id -g) -it -v $PWD:/PRJ icestorm bash -c 'cd PRJ && make clean && make'
make clean PROJ="$PROJ"; make PROJ="$PROJ"

## Compile and upload
## "Fully qualified board name" and port found with `arduino-cli board list`
FQBN="dadamachines - M4:samd:doppler"
port=$(arduino-cli board list | grep "$FQBN" |  awk '{print $1}' )
( cd "${PROJ}_arduino" && arduino-cli compile --fqbn "$FQBN" && arduino-cli upload --fqbn "$FQBN" --port "$port" )

