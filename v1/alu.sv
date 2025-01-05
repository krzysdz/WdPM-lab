`ifndef ALU_SV
`define ALU_SV

module alu #(
    parameter int WIDTH = 8
) (
    input [2:0] op,
    input [WIDTH-1:0] in_a,
    input [WIDTH-1:0] in_b,
    input ci,
    output [WIDTH-1:0] result,
    output co,
    output ov
);
    reg [WIDTH:0] tmp;
    assign result = tmp[WIDTH-1:0];

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

    // Top 2 bits of op are 0 for addition and subtraction, tmp[WIDTH] is carry out
    assign co = (op[2:1] == 2'b00) ? tmp[WIDTH] : 0;
    assign ov = (op[2:1] != 2'b00 || in_a[WIDTH-1] ^ in_b[WIDTH-1]) ? 0 : in_a[WIDTH-1] ^ tmp[WIDTH-1];
endmodule
`endif
