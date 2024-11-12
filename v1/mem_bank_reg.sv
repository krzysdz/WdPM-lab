`ifndef MEM_BANK_REG_SV
`define MEM_BANK_REG_SV
`default_nettype none

module mem_bank_reg #(
    parameter int WIDTH = 2
) (
    input logic clk,
    input logic ce,
    input logic [WIDTH-1:0] new_bank,
    output logic [WIDTH-1:0] bank
);
    always_ff @(posedge clk) begin
        if (ce)
            bank <= new_bank;
    end
endmodule
`endif
