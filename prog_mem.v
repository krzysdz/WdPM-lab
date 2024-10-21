`default_nettype none

module prog_mem (
    input [4:0] addr,
    output [5:0] inst
);
    reg [5:0] mem [0:31];

    $readmemh("aaa.hex", mem);

    assign inst = mem[addr];
endmodule
