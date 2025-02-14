`ifndef ALU_TB_MACROS_SVH
`define ALU_TB_MACROS_SVH

`define RAND_OR_FAIL(obj) if (!obj.randomize()) `uvm_fatal(get_type_name(), `"obj``.randomize() call failed`")
`endif
