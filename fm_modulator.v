module fm_modulator (
    input clk,                    // Clock input
    input wire [9:0] carrier_freq,    // Carrier frequency control
    input wire [9:0] modulator_freq,  // Modulator frequency control
    input wire [9:0] mod_depth,       // Modulation depth/index
    output reg [9:0] out             // Output signal
);

    // Parameters
    parameter CLKSPEED = 100_000_000;  // 100MHz default clock
    localparam SIZE = 1024;            // Size of sine lookup table

    // Sine lookup table memory
    reg [9:0] sine_rom[SIZE-1:0];
    
    // Phase accumulators for carrier and modulator
    reg [31:0] carrier_phase = 0;
    reg [31:0] modulator_phase = 0;
    
    // Phase increment calculations
    wire [31:0] carrier_phase_inc;
    wire [31:0] modulator_phase_inc;
    
    // Calculate phase increments
    // phase_inc = (freq * 2^32) / CLKSPEED
    assign carrier_phase_inc = (carrier_freq * 32'h100000000) / CLKSPEED;
    assign modulator_phase_inc = (modulator_freq * 32'h100000000) / CLKSPEED;
    
    // Initialize sine lookup table
    initial begin
        $readmemh("sine.mem", sine_rom);
    end
    
    // Modulator processing
    reg [9:0] mod_value;
    wire [9:0] mod_index = (SIZE-1);
    
    always @(posedge clk) begin
        // Update phase accumulators
        modulator_phase <= modulator_phase + modulator_phase_inc;
        carrier_phase <= carrier_phase + carrier_phase_inc;
        
        // Get modulator value from sine table
        mod_value <= sine_rom[modulator_phase[31:22]];
        
        // Calculate final output with FM
        // Use modulator to modify carrier phase
        out <= sine_rom[(carrier_phase[31:22] + ((mod_value * mod_depth) >> 10)) & mod_index];
    end

endmodule