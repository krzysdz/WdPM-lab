`ifndef DECODER32_SV
`define DECODER32_SV
`include "data_types.svh"
`include "opcodes.svh"

module decoder32 (
    input logic[31:0] inst,

    // Register file inputs
    output logic[4:0] rs1,
    output logic[4:0] rs2,
    output logic[4:0] rd,
    output logic rd_we,

    // ALU inputs
    output alu_op_t alu_op,
    output logic[31:0] imm,
    output logic use_imm,

    // Memory
    output logic mem_rd,
    output logic mem_rd_unsigned,
    output logic mem_wr,
    output logic[2:0] mem_bytes,

    // Adjust ALU output to branch and other branch/jump logic
    output logic branch_not,
    output logic branch_eq,
    output logic branch,    // conditional
    output logic jump_link, // unconditional, write return address to rd
    output logic jump_alu,  // jump target to be calculated from rs1

    // PC access
    output logic add_to_pc,

    // Additional/debug
    output logic illegal_inst
);
    logic[6:0] opcode = inst[6:0];
    logic[2:0] funct3 = inst[14:12];
    logic[3:0] f7_imm = inst[31:25];
    logic[31:0] imm_i = {{20{inst[31]}}, inst[31:20]};
    logic[31:0] imm_s = {{20{inst[31]}}, inst[31:25], inst[11:7]};
    logic[31:0] imm_b = {{19{inst[31]}}, inst[7], inst[30:25], inst[11:8], 1'b0};
    logic[31:0] imm_u = {inst[31:12], 12'd0};
    logic[31:0] imm_j = {{12{inst[31]}}, inst[19:12], inst[20], inst[30:21], 1'b0};
    assign rd = inst[11:7];
    assign rs1 = inst[19:15];
    assign rs2 = inst[24:20];
    assign mem_rd_unsigned = funct3[2];
    assign mem_bytes = {1'b0, funct3[1:0]};
    always_comb begin
        rd_we = 0;
        alu_op = ALU_ADD;
        imm = 0;
        use_imm = 0;
        mem_rd = 0; mem_wr = 0;
        branch_not = 0; branch_eq = 0; branch = 0;
        jump_link = 0; jump_alu = 0;
        add_to_pc = 0;
        illegal_inst = 1;
        unique case (opcode)
            OPC_LUI: begin
                rd_we = 1;
                imm = imm_u;
                use_imm = 1;
                illegal_inst = 0;
            end
            OPC_AUIPC: begin
                rd_we = 1;
                imm = imm_u;
                add_to_pc = 1;
                illegal_inst = 0;
            end
            OPC_JAL: begin
                rd_we = 1;
                imm = imm_j;
                jump_link = 1;
                illegal_inst = 0;
            end
            OPC_JALR: begin
                imm = imm_i;
                if (funct3 == 3'b000) begin
                    rd_we = 1;
                    use_imm = 1;
                    jump_alu = 1;
                    jump_link = 1;
                    illegal_inst = 0;
                end
            end
            OPC_BRANCH: begin
                imm = imm_b;
                if (funct3[2:1] != 2'b01) begin
                    branch = 1;
                    illegal_inst = 0;
                    branch_not = funct3[0];
                    unique case (funct3[2:1])
                        2'b00: begin
                            alu_op = ALU_SUB;
                            branch_eq = 1;
                        end
                        2'b10: alu_op = ALU_SLT;
                        2'b11: alu_op = ALU_SLTU;
                    endcase
                end
            end
            OPC_LOAD: begin
                imm = imm_i;
                use_imm = 1;
                if (funct3[2:1] != 2'b11 && funct3[1:0] != 2'b11) begin
                    rd_we = 1;
                    mem_rd = 1;
                    illegal_inst = 0;
                end
            end
            OPC_STORE: begin
                imm = imm_s;
                use_imm = 1;
                if (funct3[2] == 0 && funct3[1:0] != 2'b11) begin
                    mem_wr = 1;
                    illegal_inst = 0;
                end
            end
            OPC_OP_IMM: begin
                imm = imm_i;
                use_imm = 1;
                alu_op = alu_op_t'({1'b0, funct3});
                if (funct3[1:0] != 2'b01 || inst[31:25] == 0) begin
                    // Not shift, or shift with top 7 bits 0
                    rd_we = 1;
                    illegal_inst = 0;
                end else if (funct3 == 3'b101 && inst[31:25] == 7'b0100000) begin
                    // Right arithmetic shift
                    alu_op = alu_op_t'({inst[30], funct3});
                    rd_we = 1;
                    illegal_inst = 0;
                end
            end
            OPC_OP: begin
                alu_op = alu_op_t'({inst[30], funct3});
                if (inst[31:25] == 0 || (inst[31:25] == 7'b0100000 && (funct3 == 0 || funct3 == 3'b101))) begin
                    rd_we = 1;
                    illegal_inst = 0;
                end
            end
            OPC_FENCE: illegal_inst = funct3 != 0;
            OPC_SYSTEM: illegal_inst = {inst[31:21], inst[19:7]} != 0;
        endcase
    end
endmodule
`endif
