class alu_monitor extends uvm_monitor;
`ifdef NO_DRAIN_TIME
    bit finished;
`endif
    virtual alu_if vif;
    uvm_analysis_port #(alu_seq_item) item_collected_port;
    alu_seq_item trans_collected;

    `uvm_component_utils(alu_monitor)

    function new(string name, uvm_component parent);
        super.new(name, parent);
        trans_collected = new();
        item_collected_port = new("item_collected_port", this);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual alu_if)::get(this, "", "vif", vif))
            `uvm_fatal("NOVIF", {"virtual interface must be set for: ", get_full_name(), ".vif"});
`ifdef NO_DRAIN_TIME
        finished = 0;
`endif
    endfunction

    virtual task run_phase(uvm_phase phase);
        forever begin
            @(posedge vif.clk);
            // Inputs are set at negedge and can be read at posedge
            trans_collected.alu_ce = vif.alu_ce;
            trans_collected.cy_ce = vif.cy_ce;
            trans_collected.opcode = vif.opcode;
            trans_collected.register = vif.register;
            trans_collected.argument = vif.argument;

            #1; // This delay is necessary, or data from before posedge will be read from registers
            // These combinational outputs are synchronized on posedge by wrapper in top
            trans_collected.jmp_ce_temp = vif.jmp_ce_temp;
            trans_collected.jmp_addr_temp = vif.jmp_addr_temp;
            @(negedge vif.clk);
            #1; // Make sure that the new inputs are there
            // These are supposed to be registered and should not change after new inputs are provided
            trans_collected.acc = vif.acc;
            trans_collected.cy = vif.cy;

            item_collected_port.write(trans_collected);
        end
    endtask

`ifdef NO_DRAIN_TIME
`ifndef VERILATOR
    // This is probably better than set_drain_time, because it'll work when clock period changes, but in Verilator the simulation does not end
    function void phase_ready_to_end(uvm_phase phase);
        if (phase.is(uvm_run_phase::get()) && !finished) begin
            phase.raise_objection(this);
            fork
                begin
                    wait_end();
                    phase.drop_objection(this);
                end
            join_none
        end
    endfunction

    task wait_end();
        @(negedge vif.clk);
        #1;
        finished = 1;
    endtask
`else // NO_DRAIN_TIME && VERILATOR
    $fatal(0, "Verilator code does not work with NO_DRAIN_TIME");
`endif // !VERILATOR
`endif // NO_DRAIN_TIME
endclass
