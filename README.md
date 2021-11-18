# default firmware for doppler
 2 bytes SPI fullduplex sequence
- input to led matrix
- output from gpios and buttons see pcf file file for pin mapping

Based on https://github.com/noscene/Doppler_FPGA_Firmware/tree/master/doppler_simple_io

Needs icestorm docker image - see https://github.com/noscene/Doppler_FPGA_Firmware#build

## additional stuff
- Removed weird upload of default firmware (`ice40.upload()`)
- Added make.sh to build in Docker with correct permissions
- Removed need for renaming var in `.h` file
