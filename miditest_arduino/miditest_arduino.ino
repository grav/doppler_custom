#include <ICEClass.h>
#include "MIDIUSB.h"
#include "miditest.h" // set up the path to doppler_simple_io or custom firmware
ICEClass ice40;   // subclass ICEClass to implement custom spi protocol
 
void setup() {
   ice40.upload(miditest_bin,sizeof(miditest_bin)); // Upload BitStream Firmware to FPGA -> see variant.h
   ice40.initSPI();  // start SPI runtime Link to FPGA
    ice40.sendSPI16(0);   

  // midi stuff
  Serial.begin(115200);
  pinMode(LED_BUILTIN, OUTPUT);

}

void loop() {
  //MidiUSB.accept();
  //delayMicroseconds(1);
  midiEventPacket_t rx;
  do {
    rx = MidiUSB.read();
    if (rx.header == 0x09) {
      ice40.sendSPI16(1);   
    } else if ( rx.header == 0x08){
      ice40.sendSPI16(0);
    }
  } while (rx.header != 0);
}