`ifndef MEM_MGR_SV
`define MEM_MGR_SV
`include "ram.sv"

module mem_mgr #(
    parameter int WIDTH = 32,
    parameter longint unsigned MEM_WORDS = 'h1000,
    parameter int BYTES = WIDTH / 8
) (
    input logic clk,
    input logic rst,
    // Write port
    input logic [WIDTH-1:0] wr_addr,
    input logic we,
    input logic [2:0] wr_bytes, // 0 = 1 byte, 1 = 2 bytes, 2 = 4 bytes, 3 = 8 bytes, 4 = 16 bytes
    input logic [WIDTH-1:0] wr_data,
    output logic wr_misaligned,
    // Read port
    input logic [WIDTH-1:0] rd_addr,
    input logic re,
    input logic [2:0] rd_bytes,
    input logic rd_unsigned,
    output logic [WIDTH-1:0] rd_data,
    output logic rd_misaligned,
    // Instruction read port
    input logic [WIDTH-1:0] inst_addr,
    output logic [WIDTH-1:0] inst_data
);
    initial assert (WIDTH % 8 == 0 && BYTES * 8 == WIDTH);
    initial assert (WIDTH <= 128);
    localparam int AddrAlign = $clog2(BYTES);

    // Combinational outputs
    logic [WIDTH-1:0] addr_a;
    logic [WIDTH-1:0] data_in_a;
    logic [BYTES-1:0] we_a; // byte enables
    // Combinational intermediates
    logic [WIDTH-1:0] aligned_wr_addr;
    logic [WIDTH-1:0] aligned_wr_data;
    logic [BYTES-1:0] aligned_wr_bytes;
    logic [AddrAlign-1:0] align_wr_shift;
    logic [WIDTH-1:0] aligned_rd_addr;
    logic [AddrAlign-1:0] align_rd_shift;
    logic update_delay_registers;
    logic clear_delay_registers;
    // RAM output
    logic [WIDTH-1:0] data_a;

    // Registers
    logic [WIDTH-1:0] delayed_wr_addr;
    logic [WIDTH-1:0] delayed_wr_data;
    logic [BYTES-1:0] delayed_wr_bytes;
    logic [AddrAlign-1:0] read_out_shift;
    logic [2:0] read_out_bytes;
    logic read_out_unsigned;

    // Make sure that there is no cached write when a new write appears
    assert property (@(posedge clk) !(|delayed_wr_bytes && |we_a));
    // Make sure that wr/rd_bytes does not suggest mask wider than BYTES
    // TODO: Detect and prevent this in decoder
    assert property (@(posedge clk) wr_bytes <= AddrAlign);
    assert property (@(posedge clk) rd_bytes <= AddrAlign);

    // Address aligned to word size
    assign aligned_wr_addr = {wr_addr[WIDTH-1:AddrAlign], {AddrAlign{1'b0}}};
    assign aligned_rd_addr = {rd_addr[WIDTH-1:AddrAlign], {AddrAlign{1'b0}}};
    // Write data aligned correctly
    assign aligned_wr_data = wr_data << align_wr_shift;

    // Byte enables at correct positions
    byte_enable_decoder #(.BYTES(BYTES)) bed_wr(.bytes(wr_bytes), .addr(wr_addr), .byte_enables(aligned_wr_bytes), .shift(align_wr_shift));
    byte_enable_decoder #(.BYTES(BYTES)) bed_rd(.bytes(rd_bytes), .addr(rd_addr), .byte_enables(), .shift(align_rd_shift));

    // Misaligned signals
    alignment_checker #(.WIDTH(WIDTH)) align_wr(.bytes(wr_bytes), .addr(wr_addr), .enable(we), .misaligned(wr_misaligned));
    alignment_checker #(.WIDTH(WIDTH)) align_rd(.bytes(rd_bytes), .addr(rd_addr), .enable(re), .misaligned(rd_misaligned));

    always_comb begin
        we_a = 0;
        data_in_a = {WIDTH{1'bx}};
        addr_a = {WIDTH{1'bx}};
        update_delay_registers = 0;
        clear_delay_registers = 0;
        // Cases:
        // 1. only write
        // 2. read & write:
        //    a) read of data being written - handled by write first RAM
        //    b) independent read
        // 3. only read:
        //    a) no cached write
        //    b) delayed write allows eliminating read (same aligned address) - handled by write first RAM
        //    c) read independent of delayed write
        // 4. no request:
        //    a) delayed write
        //    b) nothing to do
        if (!re && we) begin // 1. write only
            addr_a = wr_addr;
            data_in_a = aligned_wr_data;
            we_a = aligned_wr_bytes;
        end else if (re && we) begin // 2. read & write
            addr_a = rd_addr;
            if (wr_addr == rd_addr) begin // 2. a) same (aligned) address - write & read
                data_in_a = aligned_wr_data;
                we_a = aligned_wr_bytes;
            end else begin // 2. b) different addresses - read now, delay write
                update_delay_registers = 1;
            end
        end else if (re && !we) begin // 3. read only
            addr_a = rd_addr;
            if (delayed_wr_bytes && delayed_wr_addr == rd_addr) begin // same address as delayed write - write & read
                data_in_a = delayed_wr_data;
                we_a = delayed_wr_bytes;
                clear_delay_registers = 1;
            end
        end else if (!re && !we) begin // 4. no request
            if (delayed_wr_bytes) begin // 4. a) perform delayed write
                addr_a = delayed_wr_addr;
                data_in_a = delayed_wr_data;
                we_a = delayed_wr_bytes;
                clear_delay_registers = 1;
            end
        end
    end

    ram #(.BYTES(BYTES), .MAX_ADDR(MEM_WORDS)) memory(
        .clk(clk),
        // Port A
        .addr_a(addr_a),
        .we_a(we_a),
        .data_in_a(data_in_a),
        .data_a(data_a),
        // Port B
        .addr_b(inst_addr),
        .data_b(inst_data)
    );

    // Output correct read value
    always_comb begin
        rd_data = data_a >> (read_out_shift * 8);
        case (read_out_bytes)
            3'b000: rd_data = {{(WIDTH-8){read_out_unsigned ? 1'b0 : rd_data[7]}}, rd_data[7:0]};
            3'b001: rd_data = BYTES < 2 ? {WIDTH{1'bx}} : {{(WIDTH-16){read_out_unsigned ? 1'b0 : rd_data[15]}}, rd_data[15:0]};
            3'b010: rd_data = BYTES < 4 ? {WIDTH{1'bx}} : {{(WIDTH-32){read_out_unsigned ? 1'b0 : rd_data[31]}}, rd_data[31:0]};
            3'b011: rd_data = BYTES < 8 ? {WIDTH{1'bx}} : {{(WIDTH-64){read_out_unsigned ? 1'b0 : rd_data[63]}}, rd_data[63:0]};
            3'b100: rd_data = BYTES < 16 ? {WIDTH{1'bx}} : rd_data;
            default: rd_data = {WIDTH{1'bx}};
        endcase
    end

    always_ff @(posedge clk) begin
        if (rst || clear_delay_registers) begin
            delayed_wr_bytes <= 0;
        end else begin
            if (update_delay_registers) begin
                delayed_wr_bytes <= aligned_wr_bytes;
                delayed_wr_addr <= aligned_wr_addr;
                delayed_wr_data <= aligned_wr_data;
            end
            if (re) begin
                read_out_bytes <= rd_bytes;
                read_out_shift <= align_rd_shift;
                read_out_unsigned <= rd_unsigned;
            end
        end
    end
endmodule

module byte_enable_decoder #(
    parameter int BYTES
) (
    input [2:0] bytes,
    input [BYTES*8-1:0] addr,
    output [BYTES-1:0] byte_enables,
    output [$clog2(BYTES)-1:0] shift
);
    // Bytes must be a power of 2, not greater than 16
    initial assert (BYTES > 0 && BYTES <= 16 && 2**$clog2(BYTES) == BYTES);

    logic [BYTES-1:0] mask;

    always_comb begin
        unique case (bytes)
            3'b000: mask = 1'b1;
            3'b001: mask = 2'b11;
            3'b010: mask = 4'b1111;
            3'b011: mask = 8'b11111111;
            3'b100: mask = 16'b1111111111111111;
            default: mask = 0;
        endcase
    end

    if (BYTES == 1)
        assign shift = 0;
    else
        assign shift = addr[$clog2(BYTES)-1:0];

    assign byte_enables = mask << shift;
endmodule

module alignment_checker #(
    parameter int WIDTH
) (
    input [2:0] bytes,
    input [WIDTH-1:0] addr,
    input enable,
    output logic misaligned
);
    always_comb begin
        if (!enable)
            misaligned = 0;
        else
            unique case (bytes)
                3'b000: misaligned = 0;
                3'b001: misaligned = addr[0] != 0;
                3'b010: misaligned = addr[1:0] != 0;
                3'b011: misaligned = addr[2:0] != 0;
                3'b100: misaligned = addr[3:0] != 0;
                default: misaligned = 1;
            endcase
    end
endmodule
`endif
