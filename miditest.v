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


	// Led
	wire [3:0]  kled_tri;			// connect katode via SB_IO modules to allow high impadance  or 3.3V
	reg [15:0] data16	;			// data register for 16 leds
 	
	 
	 MYSPI myspi(.clk(clk),.cfg_cs(cfg_cs), 
	 .cfg_si(cfg_si),
	 .cfg_sck(cfg_sck),
	 .cfg_so(cfg_so),
	 .data16(data16));
	 LED16  myleds (.clk(clk),	.ledbits(data16)	,  .aled(aled), .kled_tri(kled_tri) );
 		
		
endmodule		// end top module


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

