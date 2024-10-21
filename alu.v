`ifndef ALU_V
`define ALU_V
`default_nettype none

module alu (
    input clk,
    input [2:0] op,
    input ce_cy,
    input [7:0] in_a,
    input [7:0] in_r,
    output [7:0] result,
    output reg cy
);
    reg [8:0] tmp;
    assign result = tmp;

    always @(*) begin
        casex (op)
            3'b000: tmp = in_a + in_r + cy;
            3'b001: tmp = {1'b1, in_a} - in_r - cy;
            3'b010: tmp = in_a & in_r;
            3'b011: tmp = in_a | in_r;
            3'b100: tmp = in_a ^ in_r;
            3'b101: tmp = ~in_a;
            default: tmp = in_r;
        endcase
    end

    always @(posedge clk) begin
        if (ce_cy)
            case(op)
                3'b000: cy <= tmp[8];
                3'b001: cy <= ~tmp[8];
                default: cy <= 0;
            endcase
    end
endmodule
`endif
