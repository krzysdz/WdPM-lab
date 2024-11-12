`ifndef ALU_SV
`define ALU_SV
`default_nettype none

module alu (
    input [2:0] op,
    input [7:0] in_a,
    input [7:0] in_b,
    input ci,
    output [7:0] result,
    output co,
    output ov
);
    reg [8:0] tmp;
    assign result = tmp[7:0];

    always_comb begin
        unique case (op)
            3'b010: tmp = in_a + in_b + ci;
            3'b011: tmp = in_a - in_b - ci;
            3'b100: tmp = ~in_a;
            3'b101: tmp = in_a & in_b;
            3'b110: tmp = in_a | in_b;
            3'b111: tmp = in_a ^ in_b;
            // 000 - NOP, 001 - LD
            default: tmp = in_b;
        endcase
    end

    // Top 2 bits are 0 for addition and subtraction, tmp[8] is carry out
    assign co = (op[2:1] == 2'b00) ? tmp[8] : 0;
    assign ov = (op[2:1] != 2'b00 || in_a[7] ^ in_b[7]) ? 0 : in_a[7] ^ tmp[7];
endmodule
`endif
