`ifndef ACC_V
`define ACC_V
`default_nettype none

module acc (
    input clk,
    input ce,
    input [7:0] in,
    output reg [7:0] out
);
    initial begin
        out = 0;
    end

    always @(posedge clk) begin
        if (ce)
            out <= in;
    end
endmodule
`endif
