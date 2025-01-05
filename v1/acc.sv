`ifndef ACC_SV
`define ACC_SV

module acc #(
    parameter int WIDTH = 8
) (
    input rst,
    input clk,
    input ce,
    input [WIDTH-1:0] in,
    output reg [WIDTH-1:0] out
);
    always_ff @(posedge clk, posedge rst) begin
        if (rst)
            out <= 0;
        else if (ce)
            out <= in;
    end
endmodule
`endif
