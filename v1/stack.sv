`ifndef STACK_SV
`define STACK_SV

// A simple stack that can handle either push or pop (not both at the same time).
// Always exposes the top entry. 0 for uninitialized entries (empty and underflow).
// Will happily overflow if told to do so.
// Reset is synchronous unlike in other modules, to allow RAM inference.
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
    reg [DEPTH-1:0] r_addr;
    reg [DEPTH-1:0] w_addr;
    reg [WIDTH-1:0] w_data;
    reg [DEPTH-1:0] next_ptr;

    assert property (@(posedge clk) $onehot0({push, pop}));

    assign current_ptr = count - 1;

    always_comb begin
        w_addr = current_ptr;
        w_data = 0;
        next_ptr = current_ptr;
        if (push && !pop) begin
            w_addr = count;
            w_data = data_in;
            next_ptr = count + 1;
        end
    end

    assign data_out = entries[r_addr];
    always_ff @(posedge clk) begin
        if (rst) begin
            count <= 0;
            r_addr <= 0;
        end else begin
            if (push ^ pop) begin
                entries[w_addr] <= w_data;
                count <= next_ptr;
                r_addr <= push ? count : count - 2;
            end
        end
    end
endmodule
`endif
