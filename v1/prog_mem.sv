`ifndef PROG_MEM_SV
`define PROG_MEM_SV
`default_nettype none

module prog_mem #(
    parameter int A_WIDTH = 8,
    parameter int I_WIDTH = 16
) (
    input [A_WIDTH-1:0] addr,
    output [I_WIDTH-1:0] inst
);
    reg [I_WIDTH-1:0] mem [2**A_WIDTH];

    initial begin
        $readmemh("asm.hex", mem);
    end

    assign inst = mem[addr];
endmodule
`endif
