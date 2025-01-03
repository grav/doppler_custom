module synth (
    input clk,
    input gate,
    input [15:0] amp_in,
    output dout,
    output aux_out1
);


  // These are defaults, but can be overridden when initializing a Synth
  parameter CLKSPEED = 50_000_000;  // clockspeed of Nexys A7
  parameter SINE_FREQ = 440;
  parameter SAW_FREQ = 2;


  wire [9:0] modulator;
  wire [9:0] sine_out;
  wire [9:0] pdm_sine_err;
  wire [9:0] pdm_saw_err;



  // douple clock speed to get lower than 1 freq (0.5Hz)
  saw #(
      .CLKSPEED(CLKSPEED * 2),
      .FREQ(SAW_FREQ)
  ) s1 (
      .clk(clk),
      .rst(gate),
      .out(modulator)
  );
  // putting eg `button1` as `.rst` param produces weird results,
  // so disabling reset by putting constant 0
  pdm p1 (
      .clk  (clk),
      .din  (modulator),
      .rst  (0),
      .dout (aux_out1),
      .error(pdm_saw_err)
  );

  wire [9:0] w1;

  sine_gen #(
      .CLKSPEED(CLKSPEED),
      .FREQ(110)
  ) s3 (
      .clk(clk),
      .freq_mod(modulator),
      .out(w1)
  );

  sine_gen #(
      .CLKSPEED(CLKSPEED),
      .FREQ(SINE_FREQ),
      .MAX_FREQ_MOD(1024)
  ) s2 (
      .clk(clk),
      .freq_mod(w1),
      .out(sine_out)
  );

  wire [9:0] amp_out;
  Amp amp (
      .clk(clk),
      .in (sine_out),
      .amp(amp_in),
      .out(amp_out)
  );
  pdm p2 (
      .clk  (clk),
      .din  (amp_out),
      .rst  (0),
      .dout (dout),
      .error(pdm_sine_err)
  );
endmodule

