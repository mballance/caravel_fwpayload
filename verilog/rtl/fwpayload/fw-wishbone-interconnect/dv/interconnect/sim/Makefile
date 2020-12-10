SIM_DIR := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
DV_DIR := $(abspath $(SIM_DIR)/../..)
RTL_DIR:=$(abspath $(DV_DIR)/../verilog/rtl)
GL_DIR:=$(abspath $(DV_DIR)/../verilog/gl)
PACKAGES_DIR:=$(abspath $(DV_DIR)/../packages)
TIMEOUT=1ms
SIM?=vlsim
SIMTYPE?=functional

#********************************************************************
#* Source setup
#********************************************************************
INCDIRS += $(PACKAGES_DIR)/fwprotocol-defs/src/sv

PYBFMS_MODULES += wishbone_bfms
ifeq (gate,$(SIMTYPE))
  SRCS += $(GL_DIR)/wb_interconnect_2x4.v
else
  SRCS += $(RTL_DIR)/wb_interconnect_NxN.v
  SRCS += $(RTL_DIR)/wb_interconnect_arb.v
endif
SRCS += $(SIM_DIR)/sv/wb_interconnect_tb.sv

TOP_MODULE = wb_interconnect_tb

TESTS=single_access

#********************************************************************
#* cocotb testbench setup
#********************************************************************
MODULE=interconnect.$(TEST)
export MODULE
PYTHONPATH := $(SIM_DIR)/python:$(PYTHONPATH)
export PYTHONPATH
PATH := $(PACKAGES_DIR)/python/bin:$(PATH)
export PATH


VLSIM_CLKSPEC += -clkspec clk=10ns
VLSIM_OPTIONS += -Wno-fatal --autoflush


all : build 
	for test in $(TESTS); do \
		$(MAKE) -f $(SIM_DIR)/Makefile run TEST=$${test}; \
	done

clean ::
	echo "TODO"
	for sim in $(DV_DIR)/common/*.mk; do \
		$(MAKE) -f $$sim clean; \
	done
	

include $(DV_DIR)/common/$(SIM).mk

