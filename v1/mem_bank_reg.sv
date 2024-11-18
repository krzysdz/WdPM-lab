`ifndef MEM_BANK_REG_SV
`define MEM_BANK_REG_SV
`default_nettype none

module mem_bank_reg #(
    parameter int WIDTH = 2
) (
    input logic rst,
    input logic clk,
    input logic ce,
    input logic [WIDTH-1:0] new_bank,
    output logic [WIDTH-1:0] bank
);
    always_ff @(posedge clk, posedge rst) begin
        if (rst)
            bank <= 0;
        else if (ce)
            bank <= new_bank;
    end
endmodule
`endif
