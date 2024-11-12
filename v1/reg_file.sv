`ifndef REG_FILE_SV
`define REG_FILE_SV
`default_nettype none

module reg_file #(
    parameter int WIDTH = 8,
    parameter int N_REG = 8
) (
    input clk,
    input [$clog2(N_REG)-1:0] a,
    input ce,
    input [WIDTH-1:0] in,
    output [WIDTH-1:0] out,
    input [WIDTH-1:0] user_in
);
    localparam int ExtReg = N_REG - 1;
    reg [WIDTH-1:0] regs [N_REG - 1];

    assign out = a == ExtReg ? user_in : regs[a];

    always_ff @(posedge clk) begin
        if (ce && a != ExtReg)
            regs[a] <= in;
    end
endmodule
`endif