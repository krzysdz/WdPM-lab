`ifndef ALU_ACC_FLAGS_SV
`define ALU_ACC_FLAGS_SV

`include "acc.sv"
`include "alu.sv"
`include "alu_in_mux.sv"
`include "flags.sv"

module alu_acc_flags #(
    parameter int WIDTH = 8
) (
    input rst,                   // async reset
    input clk,                   // clock
    input data_src_t data_src,   // data source (?0 - mem, 01 - imm, 11 - reg)
    input [WIDTH-1:0] immediate, // immediate value
    input [WIDTH-1:0] reg_out,   // value from register
    input [WIDTH-1:0] mem_out,   // value from memory
    input [2:0] op,              // ALU operation
    input ce_a,                  // clock-enable for accumulator and flags
    input ce_cy,                 // clock-enable for carry
    output [WIDTH-1:0] alu_in,   // data from alu_in_mux - whatever goes to ALU (comb)
    output [WIDTH-1:0] acc_v,    // accumulator value (registered)
    output flag_cy,              // carry flag (registered)
    output flag_z,               // zero flag (registered as a part of accumulator)
    output flag_s,               // sign flag (comb: f(acc) = acc == 0)
    output flag_o                // overflow flag (registered)
);
    logic [WIDTH-1:0] alu_in;
    logic [WIDTH-1:0] alu_out;
    logic new_cy;
    logic new_ov;

    acc #(.WIDTH(WIDTH)) accumulator(.rst(rst), .clk(clk), .ce(ce_a), .in(alu_out), .out(acc_v));
    flags #(.WIDTH(WIDTH)) flag_reg(.rst(rst), .clk(clk), .ce_cy(ce_cy), .cy_new(new_cy), .ov_new(new_ov), .acc(acc_v), .cy(flag_cy), .ov(flag_o), .zf(flag_z), .sf(flag_s));
    alu_in_mux #(.WIDTH(WIDTH)) alu_mux(.source(data_src), .immediate(immediate), .rf_data(reg_out), .mem_data(mem_out), .data(alu_in));
    alu #(.WIDTH(WIDTH)) alu_i(.op(op), .in_a(acc_v), .in_b(alu_in), .ci(flag_cy), .result(alu_out), .co(new_cy), .ov(new_ov));
endmodule
`endif
