`default_nettype none

module decoder (
    input [5:0] inst,
    output [2:0] op,
    output [1:0] a,
    output ce_reg,
    output ce_a,
    output ce_cy
);
    assign op = inst[4:2];
    assign a = inst[1:0];
    assign ce_reg = inst[5:2] == 4'b0111;
    assign ce_a = inst[4:2] != 3'b111;
    assign ce_cy = inst[4:3] != 2'b11;
endmodule
