module Amp(
  input clk,
  input wire[9:0] amp,
  input wire[9:0] in,
  output reg[9:0] out
);
parameter MAX_AMP = 1024;
always @(posedge clk) begin
  out <= ( in * amp ) /1024;
end

endmodule

module sine_gen(
    input clk,
    input wire[9:0] freq_mod,
    output reg [9:0] out
    );
parameter MAX_FREQ_MOD = 1024; // frequency amp divisor (aka max freq. mod amp)
parameter CLKSPEED = 100_000_000;// clockspeed of Nexys A7
parameter FREQ = 440; // something audiable
localparam SIZE = 1024; // size of sample memory (one cycle)

// localparam CLKDIV = CLKSPEED/FREQ/SIZE;
reg[26:0] clk_counter = 0;
reg[26:0] clk_div;
reg [9:0] rom_memory [SIZE-1:0];
integer i;
initial begin
    $readmemh("sine.mem", rom_memory); //File with the signal
    i = 0;
end    

always @(posedge clk) 
begin
  // clk_div <=11482;// (CLKSPEED / SIZE * MAX_FREQ_MOD) / (freq_mod * FREQ);
  // clk_div <= (CLKSPEED / SIZE * MAX_FREQ_MOD) / (512 * FREQ);
  clk_div <= CLKSPEED / (freq_mod * FREQ);
end

always@(posedge clk)
begin
    if (clk_counter < clk_div) clk_counter <= clk_counter+1;
    else begin
        clk_counter <= 0;
        i = i + 1;
        if(i == SIZE)
            i = 0;
    end
end

always@(posedge clk) begin
    out <= rom_memory[i];
end

endmodule

module square(input clk, output reg[9:0] out);
  reg[26:0] clk_counter = 0;
  always @(posedge clk) begin
    out<=10'b1111111111;
  end
endmodule

module saw (input clk, input rst, output reg[9:0] out);
parameter NBITS = 10;
parameter CLKSPEED = 100_000_000;// clockspeed of Nexys A7
parameter FREQ = 440; // something audiable


 // something audiable
localparam AMPMAX = 2**NBITS-1;
localparam CLKDIV = CLKSPEED/FREQ/AMPMAX;

reg[26:0] clk_counter = 0;
reg[NBITS-1:0] amp = AMPMAX;

always@(posedge clk) begin
    if (rst) amp <= AMPMAX;
    if (clk_counter < CLKDIV) clk_counter <= clk_counter+1;
    else begin
        clk_counter <= 0;
        if (amp  > 0) amp <= amp - 1;
        else amp <= AMPMAX;
    end
    
end
always@(posedge clk) begin
    out <= amp;//(pwm_counter < 50) ? 1 : 0;
end
endmodule 

module pdm #(parameter NBITS = 10)
(
  input wire                      clk,
  input wire [NBITS-1:0]          din,
  input wire                      rst,
  output reg                      dout,
  output reg [NBITS-1:0]          error
);

  localparam integer MAX = 2**NBITS - 1;
  reg [NBITS-1:0] din_reg;
  reg [NBITS-1:0] error_0;
  reg [NBITS-1:0] error_1;

  always @(posedge clk) begin
    din_reg <= din;
    error_1 <= error + MAX - din_reg;
    error_0 <= error - din_reg;
  end

  always @(posedge clk) begin
    if (rst == 1'b1) begin
      dout <= 0;
      error <= 0;
    end
    else if (din_reg >= error) begin
      dout <= 1;
      error <= error_1;
    end else begin
      dout <= 0;
      error <= error_0;
    end
  end

endmodule
