`ifndef ALU_V
`define ALU_V
`default_nettype none

module alu (
    input [2:0] op,
    input ci,
    input [7:0] in_a,
    input [7:0] in_r,
    output [7:0] result,
    output co
);
    reg [8:0] tmp;
    assign result = tmp;

    always @(*) begin
        casex (op)
            3'b000: tmp = in_a + in_r + ci;
            3'b001: tmp = in_a - in_r - ci;
            3'b010: tmp = in_a & in_r;
            3'b011: tmp = in_a | in_r;
            3'b100: tmp = in_a ^ in_r;
            3'b101: tmp = ~in_a;
            default: tmp = in_r;
        endcase
    end

    // Top 2 bits are 0 for addition and subtraction, tmp[8] is carry out
    assign co = (op[2:1] == 2'b00) ? tmp[8] : 0;
endmodule
`endif
