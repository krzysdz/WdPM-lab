`ifndef REG_FILE_SV
`define REG_FILE_SV

module reg_file #(
    parameter int WIDTH = 32
) (
    input clk,
    input rst,
    input [4:0] rd,
    input [WIDTH-1:0] rd_data,
    input rd_we,
    input [4:0] rs1,
    output [WIDTH-1:0] rs1_data,
    input [4:0] rs2,
    output [WIDTH-1:0] rs2_data
);
    reg [WIDTH-1:0] registers [32];

    assign rs1_data = rs1 == 0 ? 0 : registers[rs1];
    assign rs2_data = rs2 == 0 ? 0 : registers[rs2];

    always_ff @(posedge clk, posedge rst) begin
        if (rst) begin
            for (int i = 1; i < 32; i += 1)
                registers[i] <= 0;
        end
        else if (rd_we && rd != 0)
                registers[rd] <= rd_data;
    end
endmodule
`endif
