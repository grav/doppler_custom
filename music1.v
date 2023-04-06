module xtop(clk);
input clk;
reg [15:0] data16;

// first create a 16bit binary counter
reg [15:0] counter;
always @(posedge clk) counter <= counter+1;

// and use the most significant bit (MSB) of the counter to drive the speaker
assign data16 = counter[15] ? 32 : 0;
endmodule
