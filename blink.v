`default_nettype none

module top ( 
  // led matrix  see the .pcf file in projectfolder for physical pins
  // Gotcha: removing aled here stops blinking from working, eventhough aled doesn't seem to be in use(!)
  output [3:0] kled,
  output [3:0] aled,
  // defined in doppler.pcf
  inout F25,

);            
 
  // use ice40up5k 48Mhz internal oscillator
  wire clk; 
  SB_HFOSC inthosc ( .CLKHFPU(1'b1), .CLKHFEN(1'b1), .CLKHF(clk) );
 
  // configure/connect IO Pins for LED driver logic
  SB_IO #( .PIN_TYPE(6'b 1010_01), .PULLUP(1'b 0) ) led_io1 ( .PACKAGE_PIN(kled[0]), .OUTPUT_ENABLE(kled_tri[0]), .D_OUT_0(1'b1)  );  // .D_IN_0(dummy2)
  SB_IO #( .PIN_TYPE(6'b 1010_01), .PULLUP(1'b 0) ) led_io2 ( .PACKAGE_PIN(kled[1]), .OUTPUT_ENABLE(kled_tri[1]), .D_OUT_0(1'b1)  ); 
  SB_IO #( .PIN_TYPE(6'b 1010_01), .PULLUP(1'b 0) ) led_io3 ( .PACKAGE_PIN(kled[2]), .OUTPUT_ENABLE(kled_tri[2]), .D_OUT_0(1'b1)  );
  SB_IO #( .PIN_TYPE(6'b 1010_01), .PULLUP(1'b 0) ) led_io4 ( .PACKAGE_PIN(kled[3]), .OUTPUT_ENABLE(kled_tri[3]), .D_OUT_0(1'b1)  );
  
  // Led
  wire [3:0] kled_tri;   // connect katode via SB_IO modules to allow high impadance  or 3.3V

  Blink myblink (.clk(clk),.kled_tri(kled_tri));

  always @(posedge clk) begin
    // Assign a voltage to pin F25
    F25 <= kled_tri > 0 ? 1 : 0;
  end
  
endmodule  // end top module

module Blink (input wire clk ,  output reg  [3:0] kled_tri );
 reg led_on; 
 reg [25:0] counter; 
 always @(posedge clk) begin
   counter<=counter+1 ; 
 end
 
 // Just blink  
 always @(posedge counter[22]) begin // do the logic
  led_on = !led_on;
  kled_tri[3:0] <= led_on ? 4'b0001 :  4'd0;
 end
endmodule

