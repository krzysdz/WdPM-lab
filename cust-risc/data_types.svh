`ifndef DATA_TYPES_SVH
`define DATA_TYPES_SVH

// Encoded as {inst[30], funct3} for R-Type encoded instructions
typedef enum logic[3:0] {
    ALU_ADD  = 4'b0000,
    ALU_SUB  = 4'b1000,
    ALU_SLL  = 4'b0001, // shift left logical
    ALU_SLT  = 4'b0010, // set less than
    ALU_SLTU = 4'b0011, // unsigned set less than
    ALU_XOR  = 4'b0100,
    ALU_SRL  = 4'b0101, // shift right logical
    ALU_SRA  = 4'b1101, // shift right arithmetic
    ALU_OR   = 4'b0110,
    ALU_AND  = 4'b0111
} alu_op_t;
`endif
