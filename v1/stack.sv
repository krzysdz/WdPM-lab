`ifndef STACK_SV
`define STACK_SV

// A simple stack that can handle either push or pop (not both at the same time).
// Always exposes the top entry. 0 for uninitialized entries (empty and underflow).
// Will happily overflow if told to do so.
module stack #(
    parameter int WIDTH = 8,
    parameter int DEPTH = 4
) (
    input rst,
    input clk,
    input push,
    input [WIDTH-1:0] data_in,
    input pop,
    output [WIDTH-1:0] data_out,
    output reg [DEPTH-1:0] count
);
    reg [WIDTH-1:0] entries [2**DEPTH];
    wire [DEPTH-1:0] current_ptr;

    assert property (@(posedge clk) $onehot0({push, pop}));

    assign current_ptr = count - 1;
    assign data_out = entries[current_ptr];

    always_ff @(posedge clk, posedge rst) begin
        if (rst) begin
            count <= 0;
            for (int i = 0; i < 2**DEPTH; i++)
                entries[i] <= 0;
        end else unique case ({push, pop})
            2'b01: begin
                entries[current_ptr] <= 0;
                count <= current_ptr;
            end
            2'b10: begin
                entries[count] <= data_in;
                count <= count + 1;
            end
        endcase
    end
endmodule
`endif
