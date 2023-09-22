`default_nettype none

module top ( 
  output  [3:0] kled, output [3:0] aled, // led matrix  see the .pcf file in projectfolder for physical pins
  input cfg_cs, input  cfg_si, input cfg_sck, // SPI:     samd51 <-> ice40  for bitstream and user cases

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
    // F25 <= LED2;
    
  end
  
endmodule  // end top module

module Blink (input wire clk ,  output reg  [3:0] kled_tri );
 reg led_on; 
 reg [25:0] counter; 
 always @(posedge clk) begin
   counter<=counter+1 ; 
 end
 
 // Just blink  
 always @(posedge counter[25]) begin // do the logic
  led_on = !led_on;
  kled_tri[3:0] <= led_on ? 4'b0001 :  4'd0;
 end
endmodule

/**
 * PLL configuration
 *
 * This Verilog module was generated automatically
 * using the icepll tool from the IceStorm project.
 * Use at your own risk.
 *
 * icepll -i 48 -o 100 -m -f pll.v
 *
 * Given input frequency:        60.000 MHz
 * Requested output frequency:  100.000 MHz
 * Achieved output frequency:   100.000 MHz
 */

module pll(
 input  clock_in,
 output clock_out,
 output locked
 );


SB_PLL40_CORE #(
  .FEEDBACK_PATH("SIMPLE"),
  .DIVR(4'b0010),  // DIVR =  2
  .DIVF(7'b0111111), // DIVF = 63
  .DIVQ(3'b110),  // DIVQ =  6
  .FILTER_RANGE(3'b001) // FILTER_RANGE = 1
 ) uut (
  .LOCK(locked),
  .RESETB(1'b1),
  .BYPASS(1'b0),
  .REFERENCECLK(clock_in),
  .PLLOUTCORE(clock_out)
  );

endmodule


