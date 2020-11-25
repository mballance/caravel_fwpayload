#****************************************************************************
#* questa.mk
#*
#* Simulator support for Mentor Questa
#*
#* SRCS           - List of source files
#* INCDIRS        - Include paths
#* DEFINES        - Defines
#* TOP_MODULE     - Top module to load
#* SIM_ARGS       - generic simulation arguments
#* QUESTA_SIM_ARGS - vlsim-specific simulation arguments
#* VPI_LIBS       - List of PLI libraries
#* DPI_LIBS       - List of DPI libraries
#* TIMEOUT        - Simulation timeout, in units of ns,us,ms,s
#****************************************************************************

COMMON_DIR := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
PACKAGES_DIR := $(abspath $(COMMON_DIR)/../../packages)

ifneq (,$(DEBUG))
VLSIM_OPTIONS += --trace-fst
SIMV_ARGS += +vlsim.trace
SIMV := simv.debug
else
SIMV := simv.ndebug
endif

# Enable VPI for Verilator
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
