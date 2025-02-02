class alu_monitor extends uvm_monitor;
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
endclass
