`ifndef ALU_IN_SV
`define ALU_IN_SV
`default_nettype none
`include "enums.svh"

module alu_in_mux #(
    parameter int WIDTH = 8
) (
    input data_src_t source,
    input logic[WIDTH-1:0] id_operand,
    input logic[WIDTH-1:0] rf_data,
    input logic[WIDTH-1:0] mem_data,
    output logic[WIDTH-1:0] data
);
    always_comb begin
        unique case (source)
            SRC_MEM_ADDR: data = mem_data;
            SRC_IMMEDIATE: data = id_operand;
            SRC_INDIRECT: data = mem_data;
            SRC_REG: data = rf_data;
            default: data = 8'hxx;
        endcase
    end
endmodule
`endif