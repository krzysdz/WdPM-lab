`include "top.sv"

module simple_tb;
    logic clk;
    logic rst;
    logic [7:0] user_in;
    logic [7:0] acc_out;
    logic [7:0] prev_inst;

    top dut(.rst(rst), .clk(clk), .user_in(user_in), .acc_v(acc_out));

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        rst = 1;
        repeat(2) @(posedge clk);
        @(negedge clk);
        rst = 0;
        $monitor("[%0t] PC=%0d ACC=%0d, R1=%0d, R2=%0d R5=%0d, R6=%0d",
                 $time, dut.ip, acc_out,
                 dut.rf.regs[1], dut.rf.regs[2], dut.rf.regs[5], dut.rf.regs[6]);
        user_in = 8'd126;
        @(posedge clk);
        user_in = 8'd105;
        prev_inst = 8'hxx;
        while (dut.ip !== prev_inst) begin
            if (dut.ip != prev_inst+1) $display("JUMP");
            prev_inst = dut.ip;
            @(posedge clk);
        end
        $finish;
    end

    initial begin
        $dumpfile("simple_tb.vcd");
        $dumpvars(0, simple_tb);
        $dumpon;
    end
endmodule
