`ifndef FLAGS_SV
`define FLAGS_SV
`default_nettype none

module flags (
    input clk,
    input ce_cy,
    input cy_new,
    input ov_new,
    input [7:0] acc,
    output reg cy,
    output reg ov,
    output zf,
    output sf
);
    always_ff @(posedge clk) begin
        if (ce_cy) begin
            cy <= cy_new;
            ov <= ov_new;
        end
    end

    assign zf = acc == 0;
    assign sf = acc[7];
endmodule
`endif
