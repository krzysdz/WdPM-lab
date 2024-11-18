`ifndef ACC_SV
`define ACC_SV
`default_nettype none

module acc (
    input rst,
    input clk,
    input ce,
    input [7:0] in,
    output reg [7:0] out
);
    always_ff @(posedge clk, posedge rst) begin
        if (rst)
            out <= 0;
        else if (ce)
            out <= in;
    end
endmodule
`endif
