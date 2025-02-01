//`include "uvm_pkg.sv"
`include "uvm_macros.svh"

import uvm_pkg::*;

`include "alu_if.sv"
`include "alu_tests.sv"

// This wrapper synchronizes combinational outputs before passing them to the interface
// This is necessary to avoid https://github.com/verilator/verilator/issues/5116
module dut_wrap(alu_if intf);
    logic [7:0] jmp_addr_temp;
    logic jmp_ce_temp;

    ALU DUT(
        .clk(intf.clk),
        .alu_ce(intf.alu_ce),
        .cy_ce(intf.cy_ce),
        .opcode(intf.opcode),
        .register(intf.register),
        .argument(intf.argument),
        .acc(intf.acc),
        .cy(intf.cy),
        .jmp_addr_temp(jmp_addr_temp),
        .jmp_ce_temp(jmp_ce_temp)
    );

    always_ff @(posedge intf.clk) begin
        intf.jmp_addr_temp <= jmp_addr_temp;
        intf.jmp_ce_temp <= jmp_ce_temp;
    end
endmodule

module tb_top;
    bit clk = 1;

    always #5 clk = ~clk;

    alu_if intf(clk);

    // ALU DUT(
    //     .clk(intf.clk),
    //     .alu_ce(intf.alu_ce),
    //     .cy_ce(intf.cy_ce),
    //     .opcode(intf.opcode),
    //     .register(intf.register),
    //     .argument(intf.argument),
    //     .acc(intf.acc),
    //     .cy(intf.cy),
    //     .jmp_addr_temp(intf.jmp_addr_temp),
    //     .jmp_ce_temp(intf.jmp_ce_temp)
    // );
    dut_wrap dut(.intf(intf));

    initial begin
        uvm_config_db #(virtual alu_if)::set(uvm_root::get(), "*", "vif", intf);
        run_test();
    end
endmodule
