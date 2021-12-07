`timescale 1ns / 1ps


module nexys_a7_top(
input wire CLK100MHZ, input wire SW0, output wire PWM_AUDIO_0_pwm,output wire LED1,
output wire LED2
    );
    Synth #(.CLKSPEED(100_000_000)) 
    s(
        .clk(CLK100MHZ),
        .gate(SW0),
        .amp_in(1023),
        .dout(PWM_AUDIO_0_pwm), 
        .aux_out1(LED2));
endmodule
