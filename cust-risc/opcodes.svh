`ifndef OPCODES_SVH
`define OPCODES_SVH

typedef enum logic [6:0] {
    OPC_LUI    = 7'b0110111,
    OPC_AUIPC  = 7'b0010111,
    OPC_JAL    = 7'b1101111,
    OPC_JALR   = 7'b1100111,
    OPC_BRANCH = 7'b1100011,
    OPC_LOAD   = 7'b0000011,
    OPC_STORE  = 7'b0100011,
    OPC_OP_IMM = 7'b0010011,
    OPC_OP     = 7'b0110011,
    OPC_FENCE  = 7'b0001111,
    OPC_SYSTEM = 7'b1110011
} opcode_t;

`endif
