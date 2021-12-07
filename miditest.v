`default_nettype none


//
//		This is the default firmware for ice40up5k doppler board
//		
//
module top ( inout  [7:0] pinbank1,													// breakout io pins F11,  F12 , F13, F18, F19, F20, F21, F23
					inout  [7:0] pinbank2,													// breakout io pins F41,  F40 , F39, F38, F37, F36, F35, F34
					output  [3:0] kled  , output [3:0]  aled,  						// led matrix  see the .pcf file in projectfolder for physical pins
					input button1,  	input	button2, 									// 2 Buttons 
					input cfg_cs,  	input  cfg_si,  input cfg_sck,				// SPI:     samd51 <-> ice40  for bitstream and user cases
					output cfg_so,															// SPI Out
					inout pa19, inout pa21, inout pa22,							// alternat SPI Port
					inout pa20,
					inout F25, F32
					 );												
	
	// use ice40up5k 48Mhz internal oscillator
	wire clk; 
  SB_HFOSC inthosc ( .CLKHFPU(1'b1), .CLKHFEN(1'b1), .CLKHF(clk) );
 
  reg [23:0] pin_state_out ;
  wire [23:0] pin_state_in;
  reg  [23:0] out_eneable_cfg;

//   assign  pin_state_out = 24'h0;
//   assign  out_eneable_cfg = 24'h0;

  // configure/connect IO Pins for LED driver logic
  SB_IO #( .PIN_TYPE(6'b 1010_01), .PULLUP(1'b 0) ) led_io1 ( .PACKAGE_PIN(kled[0]), .OUTPUT_ENABLE(kled_tri[0]), .D_OUT_0(1'b1)  );  // .D_IN_0(dummy2)
  SB_IO #( .PIN_TYPE(6'b 1010_01), .PULLUP(1'b 0) ) led_io2 ( .PACKAGE_PIN(kled[1]), .OUTPUT_ENABLE(kled_tri[1]), .D_OUT_0(1'b1)  ); 
  SB_IO #( .PIN_TYPE(6'b 1010_01), .PULLUP(1'b 0) ) led_io3 ( .PACKAGE_PIN(kled[2]), .OUTPUT_ENABLE(kled_tri[2]), .D_OUT_0(1'b1)  );
  SB_IO #( .PIN_TYPE(6'b 1010_01), .PULLUP(1'b 0) ) led_io4 ( .PACKAGE_PIN(kled[3]), .OUTPUT_ENABLE(kled_tri[3]), .D_OUT_0(1'b1)  );
  
  SB_IO #( .PIN_TYPE(6'b 1010_01), .PULLUP(1'b0) ) upin_15 	( .PACKAGE_PIN(pinbank2[3]), .OUTPUT_ENABLE(1'b1), .D_OUT_0(pin_state_out[15]) , .D_IN_0(pin_state_in[15]) );

	// Led
	wire [3:0]  kled_tri;			// connect katode via SB_IO modules to allow high impadance  or 3.3V
	wire [15:0] data16	;			// data register for 16 leds
 	
  wire LED1;
  wire LED2;
	 
  reg [15:0] spi_out;
  reg [15:0] prev_spi_out;

  MYSPI myspi(.clk(clk),.cfg_cs(cfg_cs), 
    .cfg_si(cfg_si),
    .cfg_sck(cfg_sck),
    .cfg_so(cfg_so),
    .data16(spi_out));

  LED16  myleds (.clk(clk),	.ledbits(data16)	,  .aled(aled), .kled_tri(kled_tri) );

  wire [9:0] amp_in;
  wire rst;
  Synth mysynth(.clk(clk), .gate(rst), .amp_in(amp_in), .dout(LED2), .aux_out1(LED1));

  always @(posedge clk) begin
    data16 <= (LED1 ? 32 : 0) + (LED2 ? 1024 : 0); 
    amp_in <= spi_out > 0 ? 1023 : 0 ;
    rst = prev_spi_out != spi_out ? 1 : 0;
    prev_spi_out = spi_out;

    // for some reason, assigning LED1 will make both data16 constantly 32 and pin_state_pit[15] constantly on ...
    pin_state_out[15] <= LED2;
  end		
		
endmodule		// end top module


module Synth (input clk, input gate, input [15:0] amp_in, output dout, output aux_out1);

  wire [9:0] saw_out;
  wire [9:0] sine_out;
  wire [9:0] pdm_sine_err;
  wire [9:0] pdm_saw_err;

  localparam clockspeed = 50_000_000;


  // douple clock speed to get lower than 1 freq (0.5Hz)
  saw #(.CLKSPEED(clockspeed*2),.FREQ(1)) s1(.clk(clk),.rst(gate),.out(saw_out));
  // putting eg `button1` as `.rst` param produces weird results,
  // so disabling reset by putting constant 0
  pdm p1(.clk(clk),.din(saw_out),.rst(0),.dout(aux_out1),.error(pdm_saw_err));    
  
  
  
  sine_gen#(.CLKSPEED(clockspeed), .FREQ(10), .MAX_FREQ_MOD(1024) ) 
  s2(
    .clk(clk),
    .freq_mod(saw_out),
    .out(sine_out)
    );

  wire [9:0] amp_out;
  Amp amp(.clk(clk),.in(sine_out),.amp(amp_in),.out(amp_out));
  pdm p2(.clk(clk),.din(amp_out),.rst(0),.dout(dout),.error(pdm_sine_err)); 
endmodule 

// LED 4x4 Matrix
// we need to use tri state outputs to avoid bad polarity for LED´s 
// just set Pins to static 1 and control by output_enable wire 
module LED16 (input wire clk, input  [15:0] ledbits , output reg  [3:0] aled ,  output reg  [3:0] kled_tri );

	reg [31:0] counter;  // = 32'h00000000;	
	always @(posedge clk)	begin
			counter<=counter+1 ; 
	end
 
	// Show 16bit values
	always @(posedge counter[4])	begin // do the logic
		case ( counter[8:5] )	 
			4'b0000:		begin   kled_tri[3:0]  <= ledbits[0]   ? 4'b0001 :  4'd0 ;	 	   aled[3:0] <=	 4'b1110; 	end	
			4'b0001:   	begin   kled_tri[3:0]  <= ledbits[1]   ? 4'b0001 :  4'd0;	 	   aled[3:0] <=	 4'b1101; 	end	
			4'b0010:		begin   kled_tri[3:0]  <= ledbits[2]   ? 4'b0001 :  4'd0;	 	   aled[3:0] <=	 4'b1011; 	end	
			4'b0011:   	begin   kled_tri[3:0]  <= ledbits[3]   ? 4'b0001 :  4'd0;	 	   aled[3:0] <=	 4'b0111; 	end	
			4'b0100:		begin   kled_tri[3:0]  <= ledbits[4]   ? 4'b0010 :  4'd0;	 	   aled[3:0] <=	 4'b1110; 	end	
			4'b0101:   	begin   kled_tri[3:0]  <= ledbits[5]   ? 4'b0010 :  4'd0;	 	   aled[3:0] <=	 4'b1101; 	end	
			4'b0110:		begin   kled_tri[3:0]  <= ledbits[6]   ? 4'b0010 :  4'd0;	 	   aled[3:0] <=	 4'b1011; 	end	
			4'b0111:   	begin   kled_tri[3:0]  <= ledbits[7]   ? 4'b0010 :  4'd0;	 	   aled[3:0] <=	 4'b0111; 	end	
			4'b1000:		begin   kled_tri[3:0]  <= ledbits[8]   ? 4'b0100 :  4'd0;	 	   aled[3:0] <=	 4'b1110; 	end	
			4'b1001:   	begin   kled_tri[3:0]  <= ledbits[9]   ? 4'b0100 :  4'd0;	 	   aled[3:0] <=	 4'b1101; 	end	
			4'b1010:		begin   kled_tri[3:0]  <= ledbits[10] ? 4'b0100 :  4'd0;	 	   aled[3:0] <=	 4'b1011; 	end	
			4'b1011:   	begin   kled_tri[3:0]  <= ledbits[11] ? 4'b0100 :  4'd0;	 	   aled[3:0] <=	 4'b0111; 	end	
			4'b1100:		begin   kled_tri[3:0]  <= ledbits[12] ? 4'b1000 :  4'd0;	 	   aled[3:0] <=	 4'b1110; 	end	
			4'b1101:   	begin   kled_tri[3:0]  <= ledbits[13] ? 4'b1000 :  4'd0;	 	   aled[3:0] <=	 4'b1101; 	end	
			4'b1110:		begin   kled_tri[3:0]  <= ledbits[14] ? 4'b1000 :  4'd0;	 	   aled[3:0] <=	 4'b1011; 	end	
			4'b1111:   	begin   kled_tri[3:0]  <= ledbits[15] ? 4'b1000 :  4'd0;	 	   aled[3:0] <=	 4'b0111;	end	
		endcase
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
		.DIVR(4'b0010),		// DIVR =  2
		.DIVF(7'b0111111),	// DIVF = 63
		.DIVQ(3'b110),		// DIVQ =  6
		.FILTER_RANGE(3'b001)	// FILTER_RANGE = 1
	) uut (
		.LOCK(locked),
		.RESETB(1'b1),
		.BYPASS(1'b0),
		.REFERENCECLK(clock_in),
		.PLLOUTCORE(clock_out)
		);

endmodule

