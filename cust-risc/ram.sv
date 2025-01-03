`ifndef RAM_SV
`define RAM_SV

// Addressing based on 32-bit words
// Port A is R/W with byte enables (for LOAD and STORE), write-first (read new data)
// Port B is read-only (for instruction fetch)

module ram #(
    parameter int BYTES = 4,
    parameter int MAX_ADDR = 32'h1000,
    parameter int WIDTH = BYTES * 8
) (
    input clk,
    input [WIDTH-1:0] addr_a,
    input [BYTES-1:0] we_a,
    input [WIDTH-1:0] data_in_a,
    output reg [WIDTH-1:0] data_a,
    input [WIDTH-1:0] addr_b,
    output reg [WIDTH-1:0] data_b
);
    initial assert (WIDTH == BYTES * 8);

    // Vendor-specific memory and port A
`ifdef VENDOR_ALTERA // Quartus
    (* ramstyle = "M10K, no_rw_check" *) reg [BYTES-1:0][7:0] mem [MAX_ADDR];

    initial assert (BYTES <= 16);

    // It would be nice if Quartus could infer RAM with byte enable from generate for
    always_ff @(posedge clk) begin
        if (we_a[0])
            mem[addr_a][0] = data_in_a[0 +: 8];
        if (BYTES >= 2)
            if (we_a[1])
                mem[addr_a][1] = data_in_a[8 +: 8];
        if (BYTES >= 3)
            if (we_a[2])
                mem[addr_a][2] = data_in_a[16 +: 8];
        if (BYTES >= 4)
            if (we_a[3])
                mem[addr_a][3] = data_in_a[24 +: 8];
        if (BYTES >= 5)
            if (we_a[4])
                mem[addr_a][4] = data_in_a[32 +: 8];
        if (BYTES >= 6)
            if (we_a[5])
                mem[addr_a][5] = data_in_a[40 +: 8];
        if (BYTES >= 7)
            if (we_a[6])
                mem[addr_a][6] = data_in_a[48 +: 8];
        if (BYTES >= 8)
            if (we_a[7])
                mem[addr_a][7] = data_in_a[56 +: 8];
        if (BYTES >= 9)
            if (we_a[8])
                mem[addr_a][8] = data_in_a[64 +: 8];
        if (BYTES >= 10)
            if (we_a[9])
                mem[addr_a][9] = data_in_a[72 +: 8];
        if (BYTES >= 11)
            if (we_a[10])
                mem[addr_a][10] = data_in_a[80 +: 8];
        if (BYTES >= 12)
            if (we_a[11])
                mem[addr_a][11] = data_in_a[88 +: 8];
        if (BYTES >= 13)
            if (we_a[12])
                mem[addr_a][12] = data_in_a[96 +: 8];
        if (BYTES >= 14)
            if (we_a[13])
                mem[addr_a][13] = data_in_a[104 +: 8];
        if (BYTES >= 15)
            if (we_a[14])
                mem[addr_a][14] = data_in_a[112 +: 8];
        if (BYTES >= 16)
            if (we_a[15])
                mem[addr_a][15] = data_in_a[120 +: 8];
        data_a = mem[addr_a];
    end
`else // Vivado, maybe Yosys
    (* ram_style = "block" *) reg [WIDTH-1:0] mem [MAX_ADDR];

    genvar i;
    for (i = 0; i < BYTES; i++) begin : g_port_a_byte_en
        always_ff @(posedge clk) begin
            if (we_a[i]) begin
                mem[addr_a][i*8 +: 8] <= data_in_a[i*8 +: 8];
                data_a[i*8 +: 8] <= data_in_a[i*8 +: 8];
            end else
                data_a[i*8 +: 8] <= mem[addr_a][i*8 +: 8];
        end
    end
`endif // VENDOR

    // Port B
    always_ff @(posedge clk)
        data_b <= mem[addr_b];
endmodule
`endif
