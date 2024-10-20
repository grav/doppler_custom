module MYSPI (
    input         clk,
    input         cfg_cs,
    input         cfg_si,
    input         cfg_sck,  // SPI:     samd51 <-> ice40  for bitstream and user cases
    output        cfg_so,   // SPI Out
    output [15:0] data16
);

  // use ice40up5k 48Mhz internal oscillator
  // wire clk; 
  //wire clk48; 
  // SB_HFOSC inthosc ( .CLKHFPU(1'b1), .CLKHFEN(1'b1), .CLKHF(clk) );
  // pll my100mhz(.clock_in(clk48), .clock_out(clk) /* , output locked */ );


  // Make connections from Pins in top tu Registers and support INPUT/ OUTPUT arrays
  wire [23:0] pin_state_in;

  // see this https://youtu.be/IOmG5y7VMrg?t=49m32s (german only)
  // Cross Domain Clock Syncing! SPI_INCOMING_CLK
  reg spi_clk1, spi_clk2;
  wire spi_clk_negedge = (~spi_clk1 && spi_clk2);
  wire spi_clk_posedge = (spi_clk1 && ~spi_clk2);
  always @(posedge clk) begin
    spi_clk1 <= cfg_sck;
    spi_clk2 <= spi_clk1;
  end

  // Cross Domain Clock Syncing! SPI_INCOMING_CS + register Set
  reg spi_cs1, spi_cs2;
  wire spi_cs_negedge = (~spi_cs1 && spi_cs2);
  wire spi_cs_posedge = (spi_cs1 && ~spi_cs2);
  always @(posedge clk) begin
    spi_cs1 <= cfg_cs;
    spi_cs2 <= spi_cs1;
  end  /*
	reg cs;
	always @(posedge clk) begin
		if(spi_cs_posedge)				cs<= 1'b1;
		else if(spi_cs_negedge)		cs<= 1'b0;
	end
	*/

  // Cross Domain Clock Syncing! SPI_INCOMING_MOSI + register Set
  reg spi_mosi1, spi_mosi2;
  wire spi_mosi_negedge = (~spi_mosi1 && spi_mosi2);
  wire spi_mosi_posedge = (spi_mosi1 && ~spi_mosi2);
  always @(posedge clk) begin
    spi_mosi1 <= cfg_si;
    spi_mosi2 <= spi_mosi1;
  end
  reg mosi;
  always @(posedge clk) begin
    if (spi_mosi_posedge) mosi <= 1'b1;
    else if (spi_mosi_negedge) mosi <= 1'b0;
  end

  // Spi Shifter
  reg [15:0] spi_in;
  reg [15:0] miso_shift;
  assign cfg_so = miso_shift[15];
  always @(posedge clk) begin
    if (spi_cs_posedge) begin
      data16 <= spi_in;  // Just Write data 2 LED
    end else if (spi_cs_negedge) begin
      // miso_shift 	<= data16; 					// loopbackTest
      miso_shift <= pin_state_in[15:0];  // PinRead
      //miso_shift 	<= 16'h53f0;					// constValues answer just for tesing
    end else begin
      if (spi_clk_posedge) spi_in[15:0] <= {spi_in[14:0], mosi};
      if (spi_clk_posedge) miso_shift[15:0] <= {miso_shift[14:0], 1'b1};
    end
  end



endmodule  // end top module
