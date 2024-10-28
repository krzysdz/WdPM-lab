`ifndef FLAGS_V
`define FLAGS_V
`default_nettype none

module flags (
    input clk,
    input cy_new,
    input ce_cy,
    output reg cy
);
    always @(posedge clk) begin
        if (ce_cy)
            cy <= cy_new;
    end
endmodule
`endif
