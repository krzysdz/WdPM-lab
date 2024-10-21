`default_nettype none
`include "acc.v"
`include "alu.v"
`include "decoder.v"
`include "pc.v"
`include "prog_mem.v"
`include "reg_file.v"

module top (
    input clk,
    input [7:0] user_in,
    output [7:0] acc_v,
    output cy
);
    wire [4:0] ip;
    wire [5:0] inst;
    wire [2:0] op;
    wire [1:0] reg_a;
    wire ce_reg;
    wire ce_a;
    wire ce_cy;
    wire [7:0] reg_out;
    wire [7:0] alu_out;

    pc counter(.clk(clk), .addr(ip));
    prog_mem pmem(.addr(ip), .inst(inst));
    decoder id(.inst(inst), .op(op), .a(reg_a), .ce_reg(ce_reg), .ce_a(ce_a), .ce_cy(ce_cy));
    reg_file rf(.clk(clk), .a(reg_a), .ce(ce_reg), .in(acc_v), .out(reg_out), .user_in(user_in));
    acc accumulator(.clk(clk), .ce(ce_a), .in(alu_out), .out(acc_v));
    alu alu_(.clk(clk), .op(op), .ce_cy(ce_cy), .in_a(acc_v), .in_r(reg_out), .result(alu_out), .cy(cy));
endmodule
