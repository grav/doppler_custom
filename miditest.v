`default_nettype none


//
//		This is the default firmware for ice40up5k doppler board
//		
//
module top (
    inout  [7:0] pinbank1,  // breakout io pins F11,  F12 , F13, F18, F19, F20, F21, F23
    inout  [7:0] pinbank2,  // breakout io pins F41,  F40 , F39, F38, F37, F36, F35, F34
    output [3:0] kled,
    output [3:0] aled,      // led matrix  see the .pcf file in projectfolder for physical pins
    input        button1,
    input        button2,   // 2 Buttons 
    input        cfg_cs,
    input        cfg_si,
    input        cfg_sck,   // SPI:     samd51 <-> ice40  for bitstream and user cases
    output       cfg_so,    // SPI Out
    inout        pa19,
    inout        pa21,
    inout        pa22,      // alternat SPI Port
    inout        pa20,
    inout        F25,
    F32
);

  // use ice40up5k 48Mhz internal oscillator
  wire clk;
  SB_HFOSC inthosc (
      .CLKHFPU(1'b1),
      .CLKHFEN(1'b1),
      .CLKHF  (clk)
  );

  reg  [23:0] pin_state_out;
  wire [23:0] pin_state_in;
  reg  [23:0] out_eneable_cfg;

  //   assign  pin_state_out = 24'h0;
  //   assign  out_eneable_cfg = 24'h0;

  // configure/connect IO Pins for LED driver logic
  SB_IO #(
      .PIN_TYPE(6'b1010_01),
      .PULLUP  (1'b0)
  ) led_io1 (
      .PACKAGE_PIN(kled[0]),
      .OUTPUT_ENABLE(kled_tri[0]),
      .D_OUT_0(1'b1)
  );  // .D_IN_0(dummy2)
  SB_IO #(
      .PIN_TYPE(6'b1010_01),
      .PULLUP  (1'b0)
  ) led_io2 (
      .PACKAGE_PIN(kled[1]),
      .OUTPUT_ENABLE(kled_tri[1]),
      .D_OUT_0(1'b1)
  );
  SB_IO #(
      .PIN_TYPE(6'b1010_01),
      .PULLUP  (1'b0)
  ) led_io3 (
      .PACKAGE_PIN(kled[2]),
      .OUTPUT_ENABLE(kled_tri[2]),
      .D_OUT_0(1'b1)
  );
  SB_IO #(
      .PIN_TYPE(6'b1010_01),
      .PULLUP  (1'b0)
  ) led_io4 (
      .PACKAGE_PIN(kled[3]),
      .OUTPUT_ENABLE(kled_tri[3]),
      .D_OUT_0(1'b1)
  );

  SB_IO #(
      .PIN_TYPE(6'b1010_01),
      .PULLUP  (1'b0)
  ) upin_15 (
      .PACKAGE_PIN(pinbank2[3]),
      .OUTPUT_ENABLE(1'b1),
      .D_OUT_0(pin_state_out[15]),
      .D_IN_0(pin_state_in[15])
  );

  // Led
  wire [3:0] kled_tri;  // connect katode via SB_IO modules to allow high impadance  or 3.3V
  wire [15:0] data16;  // data register for 16 leds

  // saw amp (frequency modulator)
  wire LED1;
  // midi on/off
  wire LED2;

  reg [15:0] spi_out;
  reg [15:0] prev_spi_out;

  MYSPI myspi (
      .clk(clk),
      .cfg_cs(cfg_cs),
      .cfg_si(cfg_si),
      .cfg_sck(cfg_sck),
      .cfg_so(cfg_so),
      .data16(spi_out)
  );

  led16 myleds (
      .clk(clk),
      .ledbits(data16),
      .aled(aled),
      .kled_tri(kled_tri)
  );

  wire [9:0] amp_in;
  wire rst;
  localparam clockspeed = 50_000_000;
  synth #(
      .CLKSPEED(clockspeed)
  ) mysynth (
      .clk(clk),
      .gate(rst),
      .amp_in(amp_in),
      .dout(F32),
      .aux_out1(LED1)
  );

  always @(posedge clk) begin
    LED2   <= spi_out > 0 ? 1 : 0;
    data16 <= (LED1 ? 32 : 0) + (LED2 ? 1024 : 0);
    amp_in <= spi_out > 0 ? 1023 : 0;
    // comment in to reset freq mod on each note-on
    //rst = prev_spi_out != spi_out ? 1 : 0;
    prev_spi_out = spi_out;

    // Not sure what this is? -mikkel
    // for some reason, assigning LED1 will make both data16 constantly 32 and pin_state_pit[15] constantly on ...
    //pin_state_out[15] <= LED2;
  end

endmodule  // end top module

