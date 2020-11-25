#****************************************************************************
#* icarus.mk
#*
#* Simulator support for Icarus Verilog
#*
#* SRCS           - List of source files
#* INCDIRS        - Include paths
#* DEFINES        - Defines
#* PYBFMS_MODULES - Modules to query for BFMs
#* SIM_ARGS       - generic simulation arguments
#* VPI_LIBS       - List of PLI libraries
#* DPI_LIBS       - List of DPI libraries
#* TIMEOUT        - Simulation timeout, in units of ns,us,ms,s
#****************************************************************************

COMMON_DIR := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
PACKAGES_DIR := $(abspath $(COMMON_DIR)/../../packages)
VLSIM := $(PACKAGES_DIR)/python/bin/vlsim
PYBFMS_VPI_LIB := $(shell $(PACKAGES_DIR)/python/bin/pybfms lib)

SIMV=simv.vvp
ifneq (,$(DEBUG))
VLSIM_OPTIONS += --trace-fst
SIMV_ARGS += +vlsim.trace
SIMV := simv.debug
else
SIMV := simv.ndebug
endif

# Enable VPI for Verilator
VLSIM_OPTIONS += --vpi
VLSIM_OPTIONS += --top-module $(TOP_MODULE)

IVERILOG_OPTIONS += $(foreach inc,$(INCDIRS),-I $(inc))
IVERILOG_OPTIONS += $(foreach def,$(DEFINES),-D $(def))
VVP_ARGS += $(foreach vpi,$(VPI_LIBS),-m $(vpi))

VPI_LIBS += $(PYBFMS_DPI_LIB)

build : $(SIMV)

$(SIMV) : $(SRCS) pybfms_gen.v
	iverilog -o $@ $(IVERILOG_OPTIONS) $(SRCS) pybfms_gen.v 

run : $(SIMV)
	vvp $(SIMV) $(VVP_ARGS)
	
pybfms_gen.v :
	$(PACKAGES_DIR)/python/bin/pybfms generate \
		-l vlog $(foreach m,$(PYBFMS_MODULES),-m $(m)) -o $@

clean ::
	rm -f simv.* simx.fst simx.vcd pybfms_gen.v
	rm -rf obj_dir
