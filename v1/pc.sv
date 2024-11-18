`ifndef PC_SV
`define PC_SV
`default_nettype none
`include "enums.svh"

module pc (
    input rst,
    input clk,
    input is_jump,
    input jump_t jump_cond, // 00 - always, 01 - zero, 10 - nz, 11 - lt
    input flag_z, // zero
    input flag_s, // sign
    input flag_o, // overflow
    input [7:0] jump_addr,
    output reg [7:0] addr
);
    wire incremented = addr + 5'd1;

    always_ff @(posedge clk, posedge rst) begin
        if (rst)
            addr <= 0;
        else begin
            if (is_jump)
                unique case (jump_cond)
                    JMP: addr <= jump_addr;
                    JZ: addr <= flag_z ? jump_addr : incremented;
                    JNZ: addr <= flag_z ? incremented : jump_addr;
                    JL: addr <= (flag_s || (~flag_s && flag_o)) ? jump_addr : incremented;
                    default: addr <= incremented;
                endcase
            else
                addr <= incremented;
        end
    end
endmodule
`endif
