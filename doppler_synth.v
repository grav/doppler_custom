`default_nettype none

module top (
    inout [7:0] pinbank1,  // breakout io pins F11,  F12 , F13, F18, F19, F20, F21, F23
    inout [7:0] pinbank2,  // breakout io pins F41,  F40 , F39, F38, F37, F36, F35, F34
    output [3:0] kled,
    output [3:0] aled,  // led matrix  see the .pcf file in projectfolder for physical pins
    input button1,
    input button2,  // 2 Buttons 
    input cfg_cs,
    input cfg_si,
    input cfg_sck,  // SPI:     samd51 <-> ice40  for bitstream and user cases
    output cfg_so,  // SPI Out
    inout pa19,
    inout pa21,
    inout pa22,  // alternat SPI Port
    inout pa20,
    // Pins
    inout F25,
    F32
);

  // use ice40up5k 48Mhz internal oscillator
  wire clk;
  SB_HFOSC inthosc (
      .CLKHFPU(1'b1),
      .CLKHFEN(1'b1),
      .CLKHF  (clk)
  );

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

  // Led
  wire [3:0] kled_tri;  // connect katode via SB_IO modules to allow high impadance  or 3.3V
  reg [15:0] data16;  // data register for 16 leds

  wire [9:0] saw_out;
  wire [9:0] sine_out;
  wire [9:0] pdm_sine_err;
  wire [9:0] pdm_saw_err;

  // could be used instead of pins, to visualize
  wire LED1;
  wire LED2;

  localparam clockspeed = 48_000_000;

  LED16 myleds (
      .clk(clk),
      .ledbits(data16),
      .aled(aled),
      .kled_tri(kled_tri)
  );


  Synth #(
      .CLKSPEED (clockspeed),
      .SINE_FREQ(880),
      .SAW_FREQ (2)
  ) s (
      .clk(clk),
      // putting eg `button1` as `.gate` param produces weird results,
      // so disabling reset by putting constant 0
      .gate(0),
      .amp_in(1023),
      // output signal on one pin
      .dout(F32),
      // freq control signal on another 
      .aux_out1(F25)
  );

  always @(posedge clk) begin
    // hack - copy freq control signal to LED1 
    // to show amplitude visually
    LED1   <= F25;
    data16 <= (LED1 ? 32 : 0) + (LED2 ? 1024 : 0);
  end

endmodule  // end top module


