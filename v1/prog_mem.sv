`ifndef PROG_MEM_SV
`define PROG_MEM_SV
`default_nettype none

module prog_mem (
    input [7:0] addr,
    output [15:0] inst
);
    reg [15:0] mem [256];

    initial begin
        $readmemh("asm.hex", mem);
    end

    assign inst = mem[addr];
endmodule
`endif
