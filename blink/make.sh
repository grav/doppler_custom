#!/usr/bin/env bash

yosys -v 3 -p 'synth_ice40 -top top -blif blink.blif' blink.v
