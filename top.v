`default_nettype none
`include "acc.v"
`include "alu.v"
`include "decoder.v"
`include "flags.v"
`include "hex_disp.v"
`include "pc.v"
`include "prog_mem.v"
`include "reg_file.v"

module top (
    input clk,
    input [7:0] user_in,
    output [7:0] acc_v,
    output cy,
    output [6:0] seg_ip_h,
    output [6:0] seg_ip_l
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
    wire cy_new;
    wire cy_saved;

    pc counter(.clk(clk), .addr(ip));
    prog_mem pmem(.addr(ip), .inst(inst));
    decoder id(.inst(inst), .op(op), .a(reg_a), .ce_reg(ce_reg), .ce_a(ce_a), .ce_cy(ce_cy));
    reg_file rf(.clk(clk), .a(reg_a), .ce(ce_reg), .in(acc_v), .out(reg_out), .user_in(user_in));
    acc accumulator(.clk(clk), .ce(ce_a), .in(alu_out), .out(acc_v));
    flags flag_reg(.clk(clk), .ce_cy(ce_cy), .cy_new(cy_new), .cy(cy_saved));
    alu alu_(.op(op), .in_a(acc_v), .in_r(reg_out), .result(alu_out), .ci(cy_saved), .co(cy_new));

    hex_disp hex_ip_h(.data({3'd0, ip[4]}), .seg(seg_ip_h));
    hex_disp hex_ip_l(.data(ip[3:0]), .seg(seg_ip_l));
endmodule
