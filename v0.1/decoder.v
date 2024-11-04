`ifndef DECODER_V
`define DECODER_V
`default_nettype none

module decoder (
    input [5:0] inst,
    output [2:0] op,
    output [1:0] a,
    output ce_reg,
    output ce_a,
    output ce_cy
);
    // ALU opcode, top bit distinguishes only between ST and NOP,
    // for which writes to A and CY are disabled.
    assign op = inst[4:2];
    // Register address
    assign a = inst[1:0];
    // Write to registers only with ST
    assign ce_reg = inst[5:2] == 4'b0111;
    // Write to accumulator for all operations except ST (0111) and NOP (1111)
    assign ce_a = inst[4:2] != 3'b111;
    // Update carry flag for all operations except LD (0110, 1110), ST and NOP
    assign ce_cy = inst[4:3] != 2'b11;
endmodule
`endif
