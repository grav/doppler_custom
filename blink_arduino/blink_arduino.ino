#include <ICEClass.h>
#include "blink.h" // set up the path to doppler_simple_io or custom firmware
ICEClass ice40;   // subclass ICEClass to implement custom spi protocol
 
void setup() {
   ice40.upload(blink_bin,sizeof(blink_bin)); // Upload BitStream Firmware to FPGA -> see variant.h
   ice40.initSPI();  // start SPI runtime Link to FPGA
}

void loop() {
     
//   static uint16_t x = 0;
//   ice40.sendSPI16(x++);   
//   delay(10);
}
