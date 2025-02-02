`include "alu_env.sv"

class alu_base_test extends uvm_test;
    `uvm_component_utils(alu_base_test)

    alu_env env;

    function new(string name = "alu_base_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        env = alu_env::type_id::create("env", this);
    endfunction

    virtual function void end_of_elaboration_phase(uvm_phase phase);
        uvm_phase run_phase;
        // Print topology
        print();
        // Make sure we don't finish too early (dirty workaround)
        // Add a bit over half cycle - driver waits until posedge+1, this will end at negedge+2 - 1 time unit after monitor read of registered data (negedge+2)
        run_phase = phase.find(uvm_run_phase::get(), 0);
        run_phase.phase_done.set_drain_time(this, 6ns);
    endfunction

    function void report_phase(uvm_phase phase);
        uvm_report_server svr;
        super.report_phase(phase);

        svr = uvm_report_server::get_server();
        if (svr.get_severity_count(UVM_FATAL) + svr.get_severity_count(UVM_ERROR) > 0) begin
            `uvm_info(get_type_name(), "---------------------------------------", UVM_NONE)
            `uvm_info(get_type_name(), "----            TEST FAIL          ----", UVM_NONE)
            `uvm_info(get_type_name(), "---------------------------------------", UVM_NONE)
        end else begin
            `uvm_info(get_type_name(), "---------------------------------------", UVM_NONE)
            `uvm_info(get_type_name(), "----           TEST PASS           ----", UVM_NONE)
            `uvm_info(get_type_name(), "---------------------------------------", UVM_NONE)
        end
    endfunction
endclass

class random_loop_test extends alu_base_test;
    `uvm_component_utils(random_loop_test)

    t_random_loop_sequence seq;

    function new(string name = "random_loop_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        seq = t_random_loop_sequence::type_id::create("seq");
    endfunction

    virtual task run_phase(uvm_phase phase);
        super.run_phase(phase);

        phase.raise_objection(this);
        assert(seq.randomize());
        seq.start(env.agent.sequencer);
        phase.drop_objection(this);
    endtask
endclass

class cy_clr_nop_test extends alu_base_test;
    `uvm_component_utils(cy_clr_nop_test)

    t_set_clr_nop_cy_sequence seq;

    function new(string name = "cy_clr_nop_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        seq = t_set_clr_nop_cy_sequence::type_id::create("seq");
    endfunction

    virtual task run_phase(uvm_phase phase);
        super.run_phase(phase);

        phase.raise_objection(this);
        seq.start(env.agent.sequencer);
        phase.drop_objection(this);
    endtask
endclass

class cy_clr_any_test extends alu_base_test;
    `uvm_component_utils(cy_clr_any_test)

    t_set_clr_cy_sequence seq;

    function new(string name = "cy_clr_any_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        seq = t_set_clr_cy_sequence::type_id::create("seq");
    endfunction

    virtual task run_phase(uvm_phase phase);
        super.run_phase(phase);

        phase.raise_objection(this);
        assert(seq.randomize());
        seq.start(env.agent.sequencer);
        phase.drop_objection(this);
    endtask
endclass

class jz_zero_test extends alu_base_test;
    `uvm_component_utils(jz_zero_test)

    t_jz_zero_sequence seq;

    function new(string name = "jz_zero_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        seq = t_jz_zero_sequence::type_id::create("seq");
    endfunction

    virtual task run_phase(uvm_phase phase);
        super.run_phase(phase);

        phase.raise_objection(this);
        seq.start(env.agent.sequencer);
        phase.drop_objection(this);
    endtask
endclass

class jz_nz_test extends alu_base_test;
    `uvm_component_utils(jz_nz_test)

    t_jz_nz_sequence seq;

    function new(string name = "jz_nz_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        seq = t_jz_nz_sequence::type_id::create("seq");
    endfunction

    virtual task run_phase(uvm_phase phase);
        super.run_phase(phase);

        phase.raise_objection(this);
        assert(seq.randomize());
        seq.start(env.agent.sequencer);
        phase.drop_objection(this);
    endtask
endclass

class not_test extends alu_base_test;
    `uvm_component_utils(not_test)
    not_sequence seq;

    function new(string name = "not_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        seq = not_sequence::type_id::create("seq");
    endfunction

    virtual task run_phase(uvm_phase phase);
        super.run_phase(phase);
        phase.raise_objection(this);
        seq.start(env.agent.sequencer);
        phase.drop_objection(this);
    endtask
endclass

`define SIMPLE_TEST(INST) \
    class INST``_test extends alu_base_test; \
        `uvm_component_utils(INST``_test) \
        t_``INST``_sequence seq; \
        function new(string name = `"INST``_test`", uvm_component parent = null); \
            super.new(name, parent); \
        endfunction \
        virtual function void build_phase(uvm_phase phase); \
            super.build_phase(phase); \
            seq = t_``INST``_sequence::type_id::create("seq"); \
        endfunction \
        virtual task run_phase(uvm_phase phase); \
            super.run_phase(phase); \
            phase.raise_objection(this); \
            seq.start(env.agent.sequencer); \
            phase.drop_objection(this); \
        endtask \
    endclass

`SIMPLE_TEST(jmp)
`SIMPLE_TEST(st)
`SIMPLE_TEST(and)
`SIMPLE_TEST(or)
`SIMPLE_TEST(xor)

// TODO: Remove ifndef when sequences will start working with Verilator
`ifndef VERILATOR
class add_set_clr_cy_test extends alu_base_test;
    `uvm_component_utils(add_set_clr_cy_test)

    t_add_set_clr_cy_sequence seq;

    function new(string name = "add_set_clr_cy_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        seq = t_add_set_clr_cy_sequence::type_id::create("seq");
    endfunction

    virtual task run_phase(uvm_phase phase);
        super.run_phase(phase);

        phase.raise_objection(this);
        assert(seq.randomize());
        seq.start(env.agent.sequencer);
        phase.drop_objection(this);
    endtask
endclass

class sub_set_clr_cy_test extends alu_base_test;
    `uvm_component_utils(sub_set_clr_cy_test)

    t_sub_set_clr_cy_sequence seq;

    function new(string name = "sub_set_clr_cy_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        seq = t_sub_set_clr_cy_sequence::type_id::create("seq");
    endfunction

    virtual task run_phase(uvm_phase phase);
        super.run_phase(phase);

        phase.raise_objection(this);
        assert(seq.randomize());
        seq.start(env.agent.sequencer);
        phase.drop_objection(this);
    endtask
endclass
`endif
