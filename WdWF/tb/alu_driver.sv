class alu_driver extends uvm_driver #(alu_seq_item);
    virtual alu_if vif;

    `uvm_component_utils(alu_driver);

    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(virtual alu_if)::get(this, "", "vif", vif))
            `uvm_fatal("NO_VIF", {"virtual interface must be set for: ", get_full_name(), ".vif"});
    endfunction

    virtual task run_phase(uvm_phase phase);
        forever begin
            seq_item_port.get_next_item(req);
            drive();
            seq_item_port.item_done();
        end
    endtask

    virtual task drive();
        // Write only after negedge, so monitor's values won't get overwritten
        @(negedge vif.clk);
        vif.alu_ce = req.alu_ce;
        vif.cy_ce = req.cy_ce;
        vif.opcode = req.opcode;
        // On jump only argument is used, others use register or nothing
        vif.argument = req.argument;
        vif.register = req.register;

        // if (req.opcode == `JMP || req.opcode == `JZ) begin
        //     vif.argument = req.argument;
        // end else begin
        //     vif.register = req.register;
        // end
        @(posedge vif.clk) #1;
    endtask
endclass
