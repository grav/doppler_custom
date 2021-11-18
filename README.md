# default firmware for doppler
 2 bytes SPI fullduplex sequence
- input to led matrix
- output from gpios and buttons see pcf file file for pin mapping

## additional stuff
- Removed weird upload of default firmware (`ice40.upload()`)
- Added make.sh to build in Docker with correct permissions
- Removed need for renaming var in `.h` file
