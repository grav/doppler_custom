#!/bin/bash
docker run --user $(id -u):$(id -g) -it -v $PWD:/PRJ icestorm bash -c 'cd PRJ && make clean && make'