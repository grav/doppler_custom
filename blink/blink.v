// No default net type is assumed for undeclared identifiers
`default_nettype none

module top ( 
  // led matrix  see the .pcf file in projectfolder for physical pins
  // Gotcha: removing aled here stops blinking from working, eventhough aled doesn't seem to be in use(!)
  output [3:0] kled,
  output [3:0] aled,

);            
 
  // use ice40up5k 48Mhz internal oscillator
  wire clk; 
  SB_HFOSC inthosc ( .CLKHFPU(1'b1), .CLKHFEN(1'b1), .CLKHF(clk) );
 
  // Led
  wire kled_tri;   // connect katode via SB_IO modules to allow high impadance  or 3.3V

  // configure/connect IO Pins for LED driver logic
  SB_IO 
    #( .PIN_TYPE(6'b 1010_01), .PULLUP(1'b 0) ) 
    led_io1 ( .PACKAGE_PIN(kled[0]), .OUTPUT_ENABLE(kled_tri), .D_OUT_0(1'b1)  ); 
  

  reg [22:0] counter; 

  always @(posedge clk) begin
    counter<=counter+1 ; 
    if (counter == 0) begin
      kled_tri = ~kled_tri;
    end

  end
  
endmodule  // end top module
