`ifndef OPCODES_SVH
`define OPCODES_SVH

`define OPC_LUI    7'b0110111
`define OPC_AUIPC  7'b0010111
`define OPC_JAL    7'b1101111
`define OPC_JALR   7'b1100111
`define OPC_BRANCH 7'b1100011
`define OPC_LOAD   7'b0000011
`define OPC_STORE  7'b0100011
`define OPC_OP_IMM 7'b0010011
`define OPC_OP     7'b0110011
`define OPC_FENCE  7'b0001111
`define OPC_SYSTEM 7'b1110011

`endif
