`include "alu_acc_flags.sv"
`include "decoder.sv"
`include "hex_disp.sv"
`include "mem.sv"
`include "mem_bank_reg.sv"
`include "pc.sv"
`include "prog_mem.sv"
`include "reg_file.sv"
`include "stack.sv"

module top (
    input rst,
    input clk,
    input [7:0] user_in,
    output [7:0] acc_v,
    output [6:0] seg_ip_h,
    output [6:0] seg_ip_l
);
    logic [7:0] ip;
    logic [7:0] ip_inc;
    logic is_jump;
    jump_t jump_cond;
    logic [15:0] inst;
    logic call;
    logic ret;
    logic [7:0] ret_addr;
    logic [2:0] op;
    logic [9:0] operand;
    data_src_t data_src;
    logic ce_reg;
    logic ce_mem;
    logic ce_a;
    logic ce_cy;
    logic ce_bank;
    logic [1:0] bank;
    logic [7:0] reg_out;
    logic [7:0] mem_out;
    logic [7:0] alu_in;
    logic flag_cy;
    logic flag_z;
    logic flag_s;
    logic flag_o;

    pc counter(.rst(rst), .clk(clk), .is_jump(is_jump), .jump_cond(jump_cond), .flag_z(flag_z), .flag_s(flag_s), .flag_o(flag_o), .jump_addr(ret ? ret_addr : alu_in), .addr(ip), .incremented(ip_inc));
    prog_mem pmem(.addr(ip), .inst(inst));
    decoder id(.inst(inst), .op(op), .operand(operand), .data_src(data_src), .ce_reg(ce_reg), .ce_mem(ce_mem), .ce_a(ce_a), .ce_cy(ce_cy), .ce_bank(ce_bank), .is_jump(is_jump), .jump_cond(jump_cond), .call(call), .ret(ret));
    stack rstack(.rst(rst), .clk(clk), .push(call), .data_in(ip_inc), .pop(ret), .data_out(ret_addr));
    reg_file rf(.rst(rst), .clk(clk), .a(operand[2:0]), .ce(ce_reg), .in(acc_v), .out(reg_out), .user_in(user_in));
    mem_bank_reg bank_reg(.rst(rst), .clk(clk), .ce(ce_bank), .new_bank(operand[1:0]), .bank(bank));
    mem memory(.clk(clk), .addr_id(operand), .addr_rf({bank, reg_out}), .a_source(data_src), .ce(ce_mem), .data_in(acc_v), .data_out(mem_out));
    alu_acc_flags aaf(
        // Inputs
        .rst(rst), .clk(clk),
        .data_src(data_src), .immediate(operand[7:0]), .reg_out(reg_out), .mem_out(mem_out),
        .op(op),
        .ce_a(ce_a), .ce_cy(ce_cy),
        // Outputs
        .alu_in(alu_in),
        .acc_v(acc_v),
        .flag_cy(flag_cy), .flag_z(flag_z), .flag_s(flag_s), .flag_o(flag_o));

    hex_disp hex_ip_h(.data({3'd0, ip[4]}), .seg(seg_ip_h));
    hex_disp hex_ip_l(.data(ip[3:0]), .seg(seg_ip_l));
endmodule
