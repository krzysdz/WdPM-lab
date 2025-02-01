class random_sequence extends uvm_sequence #(alu_seq_item);
    `uvm_object_utils(random_sequence)

    function new(string name = "random_sequence");
        super.new(name);
    endfunction

    virtual task body();
        `uvm_do(req)
    endtask
endclass

class ld_sequence extends uvm_sequence #(alu_seq_item);
    `uvm_object_utils(ld_sequence)

    function new(string name = "ld_sequence");
        super.new(name);
    endfunction

    virtual task body();
`ifndef VERILATOR
        `uvm_do_with(req, { opcode == `LD; })
`else
        req = alu_seq_item::type_id::create("req");
        start_item(req);
        assert(req.randomize());
        req.opcode = `LD;
        finish_item(req);
`endif
    endtask
endclass

class clear_acc_sequence extends uvm_sequence #(alu_seq_item);
    `uvm_object_utils(clear_acc_sequence)

    function new(string name = "clear_acc_sequence");
        super.new(name);
    endfunction

    virtual task body();
`ifndef VERILATOR
        `uvm_do_with(req, { opcode == `LD; register == 8'd0; })
`else
        req = alu_seq_item::type_id::create("req");
        start_item(req);
        assert(req.randomize());
        req.opcode = `LD;
        req.register = 8'd0;
        finish_item(req);
`endif
    endtask
endclass

class add_sequence extends uvm_sequence #(alu_seq_item);
    `uvm_object_utils(add_sequence)

    function new(string name = "add_sequence");
        super.new(name);
    endfunction

    virtual task body();
`ifndef VERILATOR
        `uvm_do_with(req, { opcode == `ADD; })
`else
        req = alu_seq_item::type_id::create("req");
        start_item(req);
        assert(req.randomize());
        req.opcode = `ADD;
        finish_item(req);
`endif
    endtask
endclass

class sub_sequence extends uvm_sequence #(alu_seq_item);
    `uvm_object_utils(sub_sequence)

    function new(string name = "sub_sequence");
        super.new(name);
    endfunction

    virtual task body();
`ifndef VERILATOR
        `uvm_do_with(req, { opcode == `SUB; })
`else
        req = alu_seq_item::type_id::create("req");
        start_item(req);
        assert(req.randomize());
        req.opcode = `SUB;
        finish_item(req);
`endif
    endtask
endclass

class st_sequence extends uvm_sequence #(alu_seq_item);
    `uvm_object_utils(st_sequence)

    function new(string name = "st_sequence");
        super.new(name);
    endfunction

    virtual task body();
`ifndef VERILATOR
        `uvm_do_with(req, { opcode == `ST; })
`else
        req = alu_seq_item::type_id::create("req");
        start_item(req);
        assert(req.randomize());
        req.opcode = `ST;
        finish_item(req);
`endif
    endtask
endclass

class and_sequence extends uvm_sequence #(alu_seq_item);
    `uvm_object_utils(and_sequence)

    function new(string name = "and_sequence");
        super.new(name);
    endfunction

    virtual task body();
`ifndef VERILATOR
        `uvm_do_with(req, { opcode == `AND; })
`else
        req = alu_seq_item::type_id::create("req");
        start_item(req);
        assert(req.randomize());
        req.opcode = `AND;
        finish_item(req);
`endif
    endtask
endclass

class or_sequence extends uvm_sequence #(alu_seq_item);
    `uvm_object_utils(or_sequence)

    function new(string name = "or_sequence");
        super.new(name);
    endfunction

    virtual task body();
`ifndef VERILATOR
        `uvm_do_with(req, { opcode == `OR; })
`else
        req = alu_seq_item::type_id::create("req");
        start_item(req);
        assert(req.randomize());
        req.opcode = `OR;
        finish_item(req);
`endif
    endtask
endclass

class xor_sequence extends uvm_sequence #(alu_seq_item);
    `uvm_object_utils(xor_sequence)

    function new(string name = "xor_sequence");
        super.new(name);
    endfunction

    virtual task body();
`ifndef VERILATOR
        `uvm_do_with(req, { opcode == `XOR; })
`else
        req = alu_seq_item::type_id::create("req");
        start_item(req);
        assert(req.randomize());
        req.opcode = `XOR;
        finish_item(req);
`endif
    endtask
endclass

class nop_sequence extends uvm_sequence #(alu_seq_item);
    `uvm_object_utils(nop_sequence)

    function new(string name = "nop_sequence");
        super.new(name);
    endfunction

    virtual task body();
`ifndef VERILATOR
        `uvm_do_with(req, { opcode == `NOP; })
`else
        req = alu_seq_item::type_id::create("req");
        start_item(req);
        assert(req.randomize());
        req.opcode = `NOP;
        finish_item(req);
`endif
    endtask
endclass

class not_sequence extends uvm_sequence #(alu_seq_item);
    `uvm_object_utils(not_sequence)

    function new(string name = "not_sequence");
        super.new(name);
    endfunction

    virtual task body();
`ifndef VERILATOR
        `uvm_do_with(req, { opcode == `NOT; })
`else
        req = alu_seq_item::type_id::create("req");
        start_item(req);
        assert(req.randomize());
        req.opcode = `NOT;
        finish_item(req);
`endif
    endtask
endclass

class jmp_sequence extends uvm_sequence #(alu_seq_item);
    `uvm_object_utils(jmp_sequence)

    function new(string name = "jmp_sequence");
        super.new(name);
    endfunction

    virtual task body();
`ifndef VERILATOR
        `uvm_do_with(req, { opcode == `JMP; })
`else
        req = alu_seq_item::type_id::create("req");
        start_item(req);
        assert(req.randomize());
        req.opcode = `JMP;
        finish_item(req);
`endif
    endtask
endclass

class jz_sequence extends uvm_sequence #(alu_seq_item);
    `uvm_object_utils(jz_sequence)

    function new(string name = "jz_sequence");
        super.new(name);
    endfunction

    virtual task body();
`ifndef VERILATOR
        `uvm_do_with(req, { opcode == `JZ; })
`else
        req = alu_seq_item::type_id::create("req");
        start_item(req);
        assert(req.randomize());
        req.opcode = `JZ;
        finish_item(req);
`endif
    endtask
endclass

class add_set_cy_sequence extends uvm_sequence #(alu_seq_item);
    rand bit [7:0] num;
`ifdef VERILATOR
    rand bit [7:0] num2;
    constraint num_lim_c { num inside {[1:255]}; num2 > (8'd255 - num); }
`else
    constraint num_lim_c { num inside {[1:255]}; }
`endif

    `uvm_object_utils(add_set_cy_sequence)

    function new(string name = "add_set_cy_sequence");
        super.new(name);
    endfunction

    virtual task body();
`ifndef VERILATOR
        `uvm_do_with(req, { opcode == `LD; register == num; })
        `uvm_do_with(req, { opcode == `ADD; register > (8'd255 - num); })
`else
        req = alu_seq_item::type_id::create("req");
        start_item(req);
        assert(req.randomize());
        req.opcode = `LD;
        req.register = num;
        finish_item(req);
        req = alu_seq_item::type_id::create("req");
        start_item(req);
        assert(req.randomize());
        req.opcode = `ADD;
        req.register = num2;
        finish_item(req);
`endif
    endtask
endclass

class sub_set_cy_sequence extends uvm_sequence #(alu_seq_item);
    rand bit [7:0] num;
`ifdef VERILATOR
    rand bit [7:0] num2;
    constraint num_lim_c { num < 8'd255; num2 > num; }
`else
    constraint num_lim_c { num < 8'd255; }
`endif

    `uvm_object_utils(sub_set_cy_sequence)

    function new(string name = "sub_set_cy_sequence");
        super.new(name);
    endfunction

    virtual task body();
`ifndef VERILATOR
        `uvm_do_with(req, { opcode == `LD; register == num; })
        `uvm_do_with(req, { opcode == `SUB; register > num; })
`else
        req = alu_seq_item::type_id::create("req");
        start_item(req);
        assert(req.randomize());
        req.opcode = `LD;
        req.register = num;
        finish_item(req);
        req = alu_seq_item::type_id::create("req");
        start_item(req);
        assert(req.randomize());
        req.opcode = `SUB;
        req.register = num2;
        finish_item(req);
`endif
    endtask
endclass

class t_set_clr_cy_sequence extends uvm_sequence #(alu_seq_item);
`ifdef VERILATOR
    rand bit [3:0] op;
    constraint cy_clr_op_c { op inside {`LD, `ST, `AND, `OR, `XOR, `NOP, `NOT, `JMP, `JZ}; }
`endif
    add_set_cy_sequence set_cy_seq;
    `uvm_object_utils(t_set_clr_cy_sequence)

    function new(string name = "t_set_clr_cy_sequence");
        super.new(name);
    endfunction

    virtual task body();
        `uvm_do(set_cy_seq)
`ifndef VERILATOR
        `uvm_do_with(req, { opcode inside {`LD, `ST, `AND, `OR, `XOR, `NOP, `NOT, `JMP, `JZ}; })
`else
        req = alu_seq_item::type_id::create("req");
        start_item(req);
        assert(req.randomize());
        req.opcode = op;
        finish_item(req);
`endif
    endtask
endclass

class t_set_clr_nop_cy_sequence extends uvm_sequence #(alu_seq_item);
    sub_set_cy_sequence set_cy_seq;
    nop_sequence nop_seq;
    `uvm_object_utils(t_set_clr_nop_cy_sequence)

    function new(string name = "t_set_clr_nop_cy_sequence");
        super.new(name);
    endfunction

    virtual task body();
        `uvm_do(set_cy_seq)
        `uvm_do(nop_seq)
    endtask
endclass

class t_random_loop_sequence extends uvm_sequence #(alu_seq_item);
    ld_sequence ld_seq;
    rand int loop_n;

    constraint loop_lim_c { loop_n inside {[50:200]}; }

    `uvm_object_utils(t_random_loop_sequence)

    function new(string name = "t_random_loop_sequence");
        super.new(name);
    endfunction

    virtual task body();
        `uvm_info(get_type_name(), $sformatf("Loop iterations %0d", loop_n), UVM_NONE);
        `uvm_do(ld_seq);
        for (int i = 0; i < loop_n; i++) begin
            `uvm_do(req)
        end
    endtask
endclass

class t_jz_zero_sequence extends uvm_sequence #(alu_seq_item);
    clear_acc_sequence clr_acc_seq;
    jz_sequence jz_seq;
    `uvm_object_utils(t_jz_zero_sequence)

    function new(string name = "t_jz_zero_sequence");
        super.new(name);
    endfunction

    virtual task body();
        `uvm_do(clr_acc_seq)
        `uvm_do(jz_seq)
    endtask
endclass

class t_jz_nz_sequence extends uvm_sequence #(alu_seq_item);
`ifdef VERILATOR
    rand bit [7:0] num;
    constraint num_nz_c { num != 0; }
`endif
    jz_sequence jz_seq;
    `uvm_object_utils(t_jz_nz_sequence)

    function new(string name = "t_jz_nz_sequence");
        super.new(name);
    endfunction

    virtual task body();
`ifndef VERILATOR
        `uvm_do_with(req, { opcode == `LD; register != 0; })
`else
        req = alu_seq_item::type_id::create("req");
        start_item(req);
        assert(req.randomize());
        req.opcode = `LD;
        req.register = num;
        finish_item(req);
`endif
        `uvm_do(jz_seq)
    endtask
endclass

class t_jmp_sequence extends uvm_sequence #(alu_seq_item);
    ld_sequence ld_seq;
    jmp_sequence jmp_seq;
    `uvm_object_utils(t_jmp_sequence)

    function new(string name = "t_jmp_sequence");
        super.new(name);
    endfunction

    virtual task body();
        `uvm_do(ld_seq)
        `uvm_do(jmp_seq)
    endtask
endclass

class t_st_sequence extends uvm_sequence #(alu_seq_item);
    ld_sequence ld_seq;
    st_sequence st_seq;
    `uvm_object_utils(t_st_sequence)

    function new(string name = "t_st_sequence");
        super.new(name);
    endfunction

    virtual task body();
        `uvm_do(ld_seq)
        `uvm_do(st_seq)
    endtask
endclass

class t_and_sequence extends uvm_sequence #(alu_seq_item);
    ld_sequence ld_seq;
    and_sequence and_seq;
    `uvm_object_utils(t_and_sequence)

    function new(string name = "t_and_sequence");
        super.new(name);
    endfunction

    virtual task body();
        `uvm_do(ld_seq)
        `uvm_do(and_seq)
    endtask
endclass

class t_or_sequence extends uvm_sequence #(alu_seq_item);
    ld_sequence ld_seq;
    or_sequence or_seq;
    `uvm_object_utils(t_or_sequence)

    function new(string name = "t_or_sequence");
        super.new(name);
    endfunction

    virtual task body();
        `uvm_do(ld_seq)
        `uvm_do(or_seq)
    endtask
endclass

class t_xor_sequence extends uvm_sequence #(alu_seq_item);
    ld_sequence ld_seq;
    xor_sequence xor_seq;
    `uvm_object_utils(t_xor_sequence)

    function new(string name = "t_xor_sequence");
        super.new(name);
    endfunction

    virtual task body();
        `uvm_do(ld_seq)
        `uvm_do(xor_seq)
    endtask
endclass

// TODO: Make these work with Verilator
`ifndef VERILATOR
class t_add_set_clr_cy_sequence extends uvm_sequence #(alu_seq_item);
    rand bit [7:0] n1;
    rand bit [7:0] n2;
    rand bit [7:0] n3;

    constraint num_limits_c { n1 > 0; n2 > (8'd255 - n1); n3 < (n1 + n2) & 8'hFF; }

    `uvm_object_utils(t_add_set_clr_cy_sequence)

    function new(string name = "t_add_set_clr_cy_sequence");
        super.new(name);
    endfunction

    virtual task body();
        `uvm_do_with(req, { opcode == `LD; register == n1; })
        `uvm_do_with(req, { opcode == `ADD; register == n2; })
        `uvm_do_with(req, { opcode == `ADD; register == n3; })
    endtask
endclass

class t_sub_set_clr_cy_sequence extends uvm_sequence #(alu_seq_item);
    rand bit [7:0] n1;
    rand bit [7:0] n2;
    rand bit [7:0] n3;

    constraint num_limits_c { n1 < 8'd255; n2 > n1; n3 < (n1 - n2) & 8'hFF; }

    `uvm_object_utils(t_sub_set_clr_cy_sequence)

    function new(string name = "t_sub_set_clr_cy_sequence");
        super.new(name);
    endfunction

    virtual task body();
        `uvm_do_with(req, { opcode == `LD; register == n1; })
        `uvm_do_with(req, { opcode == `SUB; register == n2; })
        `uvm_do_with(req, { opcode == `SUB; register == n3; })
    endtask
endclass
`endif
