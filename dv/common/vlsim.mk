#****************************************************************************
#* vlsim.mk
#*
#* Simulator support for Verilator via the vlsim script
#*
#* SRCS           - List of source files
#* INCDIRS        - Include paths
#* DEFINES        - Defines
#* SIM_ARGS       - generic simulation arguments
#* VLSIM_SIM_ARGS - vlsim-specific simulation arguments
#* VLSIM_CLKSPEC  - clock-generation options for VLSIM
#* VPI_LIBS       - List of PLI libraries
#* DPI_LIBS       - List of DPI libraries
#* TIMEOUT        - Simulation timeout, in units of ns,us,ms,s
#****************************************************************************

COMMON_DIR := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
PACKAGES_DIR := $(abspath $(COMMON_DIR)/../../packages)
VLSIM := $(PACKAGES_DIR)/python/bin/vlsim

ifneq (,$(DEBUG))
VLSIM_OPTIONS += --trace-fst
SIMV_ARGS += +vlsim.trace
SIMV := simv.debug
else
SIMV := simv.ndebug
endif

VLSIM_OPTIONS += --vpi --public-flat-rw

VLSIM_OPTIONS += $(foreach inc,$(INCDIRS),+incdir+$(inc))
VLSIM_OPTIONS += $(foreach def,$(DEFINES),+define+$(def))
SIMV_ARGS += $(foreach vpi,$(VPI_LIBS),+vpi=$(vpi))

build : $(SIMV)

$(SIMV) : $(SRCS)
	$(VLSIM) -o $@ $(VLSIM_CLKSPEC) $(VLSIM_OPTIONS) $(SRCS)

run : $(SIMV)
	./$(SIMV) $(SIMV_ARGS)

clean ::
	rm -f simv.* simx.fst simx.vcd
	rm -rf obj_dir
