`ifndef REG_FILE_V
`define REG_FILE_V
`default_nettype none

module reg_file (
    input clk,
    input [1:0] a,
    input ce,
    input [7:0] in,
    output reg [7:0] out,
    input [7:0] user_in
);
    reg [7:0] r0;
    reg [7:0] r1;
    reg [7:0] r2;

    initial begin
        r0 = 0;
        r1 = 0;
        r2 = 0;
    end

    always @(*) begin
        case (a)
            2'd0: out = r0;
            2'd1: out = r1;
            2'd2: out = r2;
            2'd3: out = user_in;
            default: out = 0;
        endcase
    end

    always @(posedge clk) begin
        if (ce) begin
            case (a)
                2'd0: r0 <= in;
                2'd1: r1 <= in;
                2'd2: r2 <= in;
                default: ;
            endcase
        end
    end
endmodule
`endif
