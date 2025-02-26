all: simulate

NPROC = $(shell nproc)

# Verilator path
VERILATOR := verilator
ifdef VERILATOR_ROOT
VERILATOR := $(VERILATOR_ROOT)/bin/verilator
endif

# Default UVM path
UVM_ROOT ?= ./uvm
# Default test to run
UVM_TEST ?= random_loop_test

VERILOG_DEFINE_FILES = ${UVM_ROOT}/src/uvm.sv ./tb/tb_top.sv ./cpu-src/Projektowanie_Lab/ALU.v
VERILOG_INCLUDE_DIRS = ./cpu-src/Projektowanie_Lab ./tb ${UVM_ROOT}/src

# Compilation settings
SIM_NAME ?= alu_tb
SIM_DIR := ${SIM_NAME}-sim
TEMPFILE := $(shell mktemp)
COMPILE_ARGS += --output-groups $(NPROC) -DUVM_NO_DPI
COMPILE_ARGS += --prefix $(SIM_NAME) -o $(SIM_NAME)
COMPILE_ARGS += $(addprefix +incdir+, $(VERILOG_INCLUDE_DIRS))
EXTRA_ARGS += --timescale 1ns/1ps --error-limit 100
WARNING_ARGS += -Wno-lint \
	-Wno-style \
	-Wno-SYMRSVDWORD \
	-Wno-IGNOREDRETURN \
	-Wno-ZERODLY \
	-Wno-WIDTH \
	-Wno-CASTCONST

$(SIM_DIR)/$(SIM_NAME).mk: $(wildcard tb/*.sv tb/*.svh)
	$(VERILATOR) --cc --exe --main --timing -Mdir $(SIM_DIR) \
	${COMPILE_ARGS} ${EXTRA_ARGS} \
	${VERILOG_DEFINE_FILES} \
	${WARNING_ARGS}

$(SIM_DIR)/$(SIM_NAME): $(SIM_DIR)/$(SIM_NAME).mk
	$(MAKE) -j${NPROC} -C $(SIM_DIR) $(BUILD_ARGS) -f $(SIM_NAME).mk

simulate: $(SIM_DIR)/$(SIM_NAME).mk $(SIM_DIR)/$(SIM_NAME)
	$(SIM_DIR)/$(SIM_NAME) +UVM_TESTNAME=$(UVM_TEST) | tee $(TEMPFILE)
	@grep "^UVM_ERROR\\s*:\\s*0$$" $(TEMPFILE) -q
	@grep "^UVM_FATAL\\s*:\\s*0$$" $(TEMPFILE) -q

clean:
	rm -rf simv*.daidir csrc
	rm -rf csrc* simv*
	rm -rf $(SIM_DIR)


.PHONY: simulate clean
