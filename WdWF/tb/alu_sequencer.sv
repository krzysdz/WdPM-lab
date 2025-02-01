// Workaround for https://github.com/verilator/verilator/issues/4497 (more details in https://github.com/verilator/verilator/pull/4629)
`ifdef VERILATOR
class alu_sequencer extends uvm_sequencer #(alu_seq_item, alu_seq_item);
`else
class alu_sequencer extends uvm_sequencer #(alu_seq_item);
`endif
    `uvm_component_utils(alu_sequencer)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction
endclass
