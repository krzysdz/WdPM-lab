interface alu_if(input logic clk);
    logic alu_ce;
    logic cy_ce;
    logic [3:0] opcode;
    logic [7:0] register;
    logic [7:0] argument;
    logic [7:0] acc;
    logic cy;
    logic [7:0] jmp_addr_temp;
    logic jmp_ce_temp;
endinterface
