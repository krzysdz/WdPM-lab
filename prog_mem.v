`default_nettype none

module prog_mem (
    input [4:0] addr,
    output [5:0] inst
);
    reg [5:0] mem [0:31];

    initial begin
        $readmemh("aaa.hex", mem);
    end

    assign inst = mem[addr];
endmodule
