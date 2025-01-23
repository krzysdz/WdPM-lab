`ifndef PC_SV
`define PC_SV
`include "enums.svh"

module pc #(
    parameter int A_WIDTH = 8
) (
    input rst,
    input clk,
    input is_jump,
    input jump_t jump_cond, // 00 - always, 01 - zero, 10 - nz, 11 - lt
    input flag_z, // zero
    input flag_s, // sign
    input flag_o, // overflow
    input [A_WIDTH-1:0] jump_addr,
    output reg [A_WIDTH-1:0] addr,
    output [A_WIDTH-1:0] incremented
);
    assign incremented = addr + 5'd1;

    always_ff @(posedge clk, posedge rst) begin
        if (rst)
            addr <= 0;
        else begin
            if (is_jump)
                unique case (jump_cond)
                    JMP: addr <= jump_addr;
                    JZ: addr <= flag_z ? jump_addr : incremented;
                    JNZ: addr <= flag_z ? incremented : jump_addr;
                    JL: addr <= flag_s ? jump_addr : incremented;
                    default: addr <= incremented;
                endcase
            else
                addr <= incremented;
        end
    end
endmodule
`endif
