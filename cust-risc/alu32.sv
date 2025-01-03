`ifndef ALU32_SV
`define ALU32_SV
`include "data_types.svh"

module alu32 (
    input alu_op_t op,
    input logic[31:0] arg_1,
    input logic[31:0] arg_2,
    output logic[31:0] result
);
    always_comb begin
        unique case (op)
            ALU_ADD: result = arg_1 + arg_2;
            ALU_SUB: result = arg_1 - arg_2;
            ALU_SLL: result = arg_1 << arg_2[4:0];
            ALU_SLT: result = $signed(arg_1) < $signed(arg_2);
            ALU_SLTU: result = arg_1 < arg_2;
            ALU_XOR: result = arg_1 ^ arg_2;
            ALU_SRL: result = arg_1 >> arg_2[4:0];
            ALU_SRA: result = $signed(arg_1) >>> arg_2[4:0];
            ALU_OR: result = arg_1 | arg_2;
            ALU_AND: result = arg_1 & arg_2;
            default: result = 0;
        endcase
    end
endmodule
`endif
