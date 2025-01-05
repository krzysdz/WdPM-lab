`ifndef DECODER_V
`define DECODER_V
`default_nettype none
`include "enums.svh"

module decoder (
    input [15:0] inst,
    output [2:0] op,
    output [9:0] operand,
    output data_src_t data_src,
    output ce_reg,
    output ce_mem,
    output ce_a,
    output ce_cy,
    output ce_bank,
    output is_jump,
    output jump_t jump_cond,
    output call,
    output ret
);
    // Instruction format
    // ==============================
    // |  S S  | O O O O | A/D/R... |
    // | 15-14 | 13 - 10 | 9 ---- 0 |
    // ==============================
    //
    // S - operand type (data source/target)
    // O - opcode
    //
    // A/D/R depending on bits 15:14 is:
    // - for 00: 10-bit ADDRESS [9:0] (ADDR)
    // - for 01: 8-bit DATA [7:0]     (#DATA)
    // - for 1x: 3-bit REGISTER [2:0] (10 - [Rx], 11 - Rx)
    // Unused A/D/R bits can be anything

    logic [3:0] full_opcode;
    assign full_opcode = inst[13:10];
    // ALU opcode, operations with top bit 0 are ALU operations
    assign op = full_opcode[2:0];
    assign operand = inst[9:0];
    assign data_src = data_src_t'(inst[15:14]);
    // Write to registers only with ST (1100) with src pointing to registers
    assign ce_reg = full_opcode == 4'b1100 && data_src == SRC_REG;
    // Write to memory only with ST and src using memory
    assign ce_mem = full_opcode == 4'b1100 && (data_src == SRC_MEM_ADDR || data_src == SRC_INDIRECT);
    // Write to accumulator for all ALU operations except NOP (0000)
    assign ce_a = full_opcode[3] == 0 && full_opcode != 0;
    // Update carry and overflow flags for all ALU operations except LD (0001) and NOP
    assign ce_cy = full_opcode[3:2] == 2'b01 || full_opcode[3:1] == 3'b001;
    // Update bank register using CHB (1101)
    assign ce_bank = full_opcode == 4'b1101;
    // Jumps are 10xx, where the lower 2 bits are jump type
    // Call (1110) and ret (1111) are handled like unconditional jump, but use return stack
    assign is_jump = full_opcode[3:2] == 2'b10 || full_opcode[3:1] == 3'b111;
    assign jump_cond = full_opcode[3:1] == 3'b111 ? JMP : jump_t'(full_opcode[1:0]);
    assign call = full_opcode == 4'b1110;
    assign ret = full_opcode == 4'b1111;
endmodule
`endif
