`ifndef MEM_SV
`define MEM_SV
`include "enums.svh"

module mem #(
    parameter int WIDTH = 8,
    parameter int A_WIDTH = 10
) (
    input logic clk,
    // Two possible address sources; 0 - ID, 1 - RF
    input logic [A_WIDTH-1:0] addr_id,
    input logic [A_WIDTH-1:0] addr_rf,
    input data_src_t a_source,
    input logic ce,
    input logic [WIDTH-1:0] data_in,
    output logic [WIDTH-1:0] data_out
);
    initial assert(SRC_MEM_ADDR[1] == 1'b0 && SRC_INDIRECT[1] == 1'b1);
    wire from_reg = a_source[1];
    wire [A_WIDTH-1:0] addr = from_reg ? addr_rf : addr_id;
    reg [WIDTH-1:0] mem_data [(2**A_WIDTH)];

    always_ff @(posedge clk) begin
        if (ce)
            mem_data[addr] <= data_in;
    end

    assign data_out = mem_data[addr];
endmodule
`endif
