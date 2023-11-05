// No default net type is assumed for undeclared identifiers
`default_nettype none

module blink ( 
  input wire clk,
  output wire led_on

);            

  reg [22:0] counter; 

  always @(posedge clk) begin
    counter<=counter+1 ; 
    if (counter == 0) begin
      led_on = ~led_on;
    end

  end
  
endmodule  
