class alu_seq_item extends uvm_sequence_item;
    rand bit alu_ce;
    rand bit cy_ce;
    rand bit [3:0] opcode;
    rand bit [7:0] register;
    rand bit [7:0] argument;
    bit [7:0] acc;
    bit cy;
    bit [7:0] jmp_addr_temp;
    bit jmp_ce_temp;

    constraint valid_op_c { opcode <= 4'd10; }

    `uvm_object_utils_begin(alu_seq_item)
        // Given data
        `uvm_field_int(alu_ce ,UVM_ALL_ON)
        `uvm_field_int(cy_ce, UVM_ALL_ON)
        `uvm_field_int(opcode, UVM_ALL_ON | UVM_DEC)
        `uvm_field_int(register, UVM_ALL_ON | UVM_DEC)
        `uvm_field_int(argument, UVM_ALL_ON)
        // DUT outputs
        `uvm_field_int(acc, UVM_ALL_ON | UVM_DEC)
        `uvm_field_int(cy, UVM_ALL_ON)
        `uvm_field_int(jmp_addr_temp, UVM_ALL_ON)
        `uvm_field_int(jmp_ce_temp, UVM_ALL_ON)
    `uvm_object_utils_end

    function new(string name = "alu_seq_item");
        super.new(name);
    endfunction
endclass
