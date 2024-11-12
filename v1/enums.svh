`ifndef ENUMS_SVH
`define ENUMS_SVH

typedef enum logic[1:0] {
    SRC_MEM_ADDR = 2'b00,
    SRC_IMMEDIATE = 2'b01,
    SRC_INDIRECT = 2'b10,
    SRC_REG = 2'b11
} data_src_t;

typedef enum logic[1:0] {
    JMP = 2'b00, // always
    JZ = 2'b01,  // zero
    JNZ = 2'b10, // not zero
    JL = 2'b11   // negative or overflow to pos
} jump_t;

`endif
