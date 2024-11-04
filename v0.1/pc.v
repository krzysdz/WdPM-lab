`ifndef PC_V
`define PC_V
`default_nettype none

module pc (
    input clk,
    output reg [4:0] addr
);
    initial begin
        addr = 0;
    end

    always @(posedge clk) begin
        addr <= addr + 5'd1;
    end
endmodule
`endif
