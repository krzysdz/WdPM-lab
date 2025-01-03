`ifndef PROGRAM_COUNTER_SV
`define PROGRAM_COUNTER_SV

module program_counter #(
    parameter int WIDTH = 32
) (
    input logic clk,
    input logic rst,
    input logic jump,
    input logic[WIDTH-1:0] jump_addr,
    output logic[WIDTH-1:0] pc
);
    always_ff @(posedge clk) begin
        if (rst)
            pc <= 0;
        else
            pc <= jump ? jump_addr : pc + $clog2(WIDTH);
    end
endmodule
`endif
