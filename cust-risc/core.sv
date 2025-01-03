`include "alu32.sv"
`include "mem_mgr.sv"
`include "program_counter.sv"
`include "reg_file.sv"

module core (
    input logic clk,
    input logic rst
);
    localparam int Width = 32;

    // Instruction Fetch (1)
    // (1) internal
    logic [Width-1:0] s1i_pc; // program counter passed to memory
    // (1) registered outputs
    logic [Width-1:0] s1_pc;
    logic [Width-1:0] s1_inst; // registered by the memory

    // Instruction Decode + Operand Fetch (2)
    // (2) internal
    logic[4:0] s2i_rs1;
    logic[4:0] s2i_rs2;
    logic[4:0] s2i_rs1_data;
    logic[4:0] s2i_rs2_data;
    logic[4:0] s2i_rd;
    logic s2i_rd_we;
    alu_op_t s2i_alu_op;
    logic[Width-1:0] s2i_imm;
    logic s2i_use_imm;
    logic s2i_mem_rd;
    logic s2i_mem_rd_unsigned;
    logic s2i_mem_wr;
    logic[2:0] s2i_mem_bytes;
    logic s2i_branch_not;
    logic s2i_branch_eq;
    logic s2i_branch;
    logic s2i_jump_link;
    logic s2i_jump_alu;
    logic s2i_add_to_pc;
    // (2) registered outputs
    logic[Width-1:0] s2_pc;
    logic[4:0] s2_rs1;
    logic[4:0] s2_rs2;
    logic[4:0] s2_rs1_data;
    logic[4:0] s2_rs2_data;
    logic[4:0] s2_rd;
    logic s2_rd_we;
    alu_op_t s2_alu_op;
    logic[Width-1:0] s2_imm;
    logic s2_use_imm;
    logic s2_mem_rd;
    logic s2_mem_rd_unsigned;
    logic s2_mem_wr;
    logic[2:0] s2_mem_bytes;
    logic s2_branch_not;
    logic s2_branch_eq;
    logic s2_branch;
    logic s2_jump_link;
    logic s2_jump_alu;
    logic s2_add_to_pc;

    // Execute - ALU operations/LD/branching conditions (3)
    // (3) internal
    logic[Width-1:0] s3i_rs1_data;
    logic[Width-1:0] s3i_rs2_data;
    logic[Width-1:0] s3i_arg2_data;
    logic[Width-1:0] s3i_alu_out;
    logic[Width-1:0] s3i_reg_output;
    logic[Width-1:0] s3i_pc_plus_imm;
    logic[Width-1:0] s3i_next_pc;
    logic[Width-1:0] s3i_jump_addr;
    logic s3i_jump;
    // (3) registered outputs
    logic[Width-1:0] s3_reg_output;
    logic[Width-1:0] s3_mem_out; // registered by memory
    logic[Width-1:0] s3_jump_addr;
    logic s3_jump;
    logic[4:0] s3_rd;
    logic s3_rd_we;
    logic s3_mem_rd;
    logic s3_mem_wr;
    logic[2:0] s3_mem_bytes;
    logic[Width-1:0] s3_mem_wr_data;

    // Write back (4)
    // (4) forward to (3)
    logic[Width-1:0] s4f_rd_data; // forwarded rd val from mux (mem load or comb)

    mem_mgr #(.WIDTH(Width)) main_mem(
        .clk(clk), .rst(rst),
        .wr_addr(s3_reg_output), .we(s3_mem_wr), .wr_bytes(s3_mem_bytes), .wr_data(s3_mem_wr_data), .wr_misaligned(),
        .rd_addr(s3i_alu_out), .re(s2_mem_rd), .rd_bytes(s2_mem_bytes), .rd_unsigned(s2_mem_rd_unsigned), .rd_data(s3_mem_out), .rd_misaligned(),
        .inst_addr(s1i_pc), .inst_data(s1_inst));
    program_counter #(.WIDTH(Width)) pc(
        .clk(clk), .rst(rst),
        .jump(s3_jump), .jump_addr(s3_jump_addr),
        .pc(s1i_pc));
    decoder32 decoder(
        .inst(s1_inst),
        .rs1(s2i_rs1), .rs2(s2i_rs2), .rd(s2i_rd), .rd_we(s2_rd_we),
        .alu_op(s2i_alu_op), .imm(s2i_imm), .use_imm(s2i_use_imm),
        .mem_rd(s2i_mem_rd), .mem_rd_unsigned(s2i_mem_rd_unsigned), .mem_wr(s2i_mem_wr), .mem_bytes(s2i_mem_bytes),
        .branch_not(s2i_branch_not), .branch_eq(s2i_branch_eq), .branch(s2i_branch), .jump_link(s2i_jump_link), .jump_alu(s2i_jump_alu),
        .add_to_pc(s2i_add_to_pc),
        .illegal_inst());
    reg_file #(.WIDTH(Width)) rf(
        .clk(clk), .rst(rst),
        .rd(s3_rd), .rd_data(s4f_rd_data), .rd_we(s3_rd_we),
        .rs1(s2i_rs1), .rs1_data(s2i_rs1_data),
        .rs2(s2i_rs2), .rs2_data(s2i_rs2_data));
    alu32 alu(
        .op(s2_alu_op),
        .arg_1(s3i_rs1_data),
        .arg_2(s3i_arg2_data),
        .result(s3i_alu_out));

    assign s3i_rs1_data = s2_rs1 != 0 && s2_rs1 == s3_rd && s3_rd_we
                            ? s4f_rd_data
                            : s2_rs1_data;
    assign s3i_rs2_data = s2_rs2 != 0 && s2_rs2 == s3_rd && s3_rd_we
                            ? s4f_rd_data
                            : s2_rs2_data;
    assign s3i_arg2_data = s2_use_imm ? s2_imm : s3i_rs2_data;
    assign s3i_pc_plus_imm = s2_pc + s2_imm;
    assign s3i_next_pc = s2_pc + (Width / 8);
    assert property (@(posedge clk) $onehot0({s2_add_to_pc, s2_jump_link}));
    always_comb unique case({s2_add_to_pc, s2_jump_link})
        2'b01: s3i_reg_output = s3i_next_pc;
        2'b10: s3i_reg_output = s3i_pc_plus_imm;
        default: s3i_reg_output = s3i_alu_out;
    endcase
    assign s3i_jump_addr = s2_jump_alu ? s3i_alu_out : s3i_pc_plus_imm;
    assign s3i_jump = s2_jump_link
                        || (s2_branch
                            && ((s2_branch_eq
                                ? ~|s3i_alu_out
                                : s3i_alu_out[0])
                            ^ s2_branch_not));

    assign s4f_rd_data = s3_mem_rd ? s3_mem_out : s3_reg_output;

    always_ff @(posedge clk) begin
        if (rst) begin
            // s1_pc <= 0;
            // s2_pc <= 0;
            // s2_rs1 <= 0;
            // s2_rs2 <= 0;
            // s2_rs1_data <= 0;
            // s2_rs2_data <= 0;
            // s2_rd <= 0;
            s2_rd_we <= 0;
            // s2_alu_op <= ALU_ADD;
            // s2_imm <= 0;
            // s2_use_imm <= 0;
            s2_mem_rd <= 0;
            // s2_mem_rd_unsigned <= 0;
            s2_mem_wr <= 0;
            // s2_mem_bytes <= 0;
            // s2_branch_not <= 0;
            // s2_branch_eq <= 0;
            s2_branch <= 0;
            s2_jump_link <= 0;
            // s2_jump_alu <= 0;
            // s2_add_to_pc <= 0;
            // s3_reg_output <= 0;
            // s3_jump_addr <= 0;
            s3_jump <= 0;
            // s3_rd <= 0;
            s3_rd_we <= 0;
            // s3_mem_rd <= 0;
            s3_mem_wr <= 0;
            // s3_mem_bytes <= 0;
            // s3_mem_wr_data <= 0;
        end else begin
            // Stage 1 (instruction fetch) output registers
            s1_pc <= s1i_pc;
            // Stage 2 (decode+operand fetch) output registers
            s2_pc <= s1_pc;
            s2_rs1 <= s2i_rs1;
            s2_rs2 <= s2i_rs2;
            s2_rs1_data <= s2i_rs1_data;
            s2_rs2_data <= s2i_rs2_data;
            s2_rd <= s2i_rd;
            s2_rd_we <= s2i_rd_we;
            s2_alu_op <= s2i_alu_op;
            s2_imm <= s2i_imm;
            s2_use_imm <= s2i_use_imm;
            s2_mem_rd <= s2i_mem_rd;
            s2_mem_rd_unsigned <= s2i_mem_rd_unsigned;
            s2_mem_wr <= s2i_mem_wr;
            s2_mem_bytes <= s2i_mem_bytes;
            s2_branch_not <= s2i_branch_not;
            s2_branch_eq <= s2i_branch_eq;
            s2_branch <= s2i_branch;
            s2_jump_link <= s2i_jump_link;
            s2_jump_alu <= s2i_jump_alu;
            s2_add_to_pc <= s2i_add_to_pc;
            // Stage 3 (execute) output registers
            s3_reg_output <= s3i_reg_output;
            s3_jump_addr <= s3i_jump_addr;
            s3_jump <= s3i_jump;
            s3_rd <= s2_rd;
            s3_rd_we <= s2_rd_we;
            s3_mem_rd <= s2_mem_rd;
            s3_mem_wr <= s2_mem_wr;
            s3_mem_bytes <= s2_mem_bytes;
            s3_mem_wr_data <= s3i_rs2_data;
        end
    end
endmodule
