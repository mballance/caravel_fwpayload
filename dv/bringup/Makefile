BRINGUP_DIR := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
RTL_DIR:=$(abspath $(BRINGUP_DIR)/../../verilog/rtl)
PACKAGES_DIR:=$(abspath $(BRINGUP_DIR)/../../packages)
FWRISC_RTL_DIR:=$(PACKAGES_DIR)/fwrisc/rtl

#********************************************************************
#* Source setup
#********************************************************************
FWRISC_SRCS = $(wildcard $(FWRISC_RTL_DIR)/*.sv)
INCDIRS += $(FWRISC_RTL_DIR)

DEFINES += MPRJ_IO_PADS=38
PYBFMS_MODULES += wishbone_bfms logic_analyzer_bfms
SRCS += $(RTL_DIR)/fwpayload.v $(RTL_DIR)/user_project_wrapper.v
SRCS += $(RTL_DIR)/wb_interconnect_NxN.sv
SRCS += $(RTL_DIR)/spram_32x256.sv
SRCS += $(RTL_DIR)/spram.v
SRCS += $(FWRISC_SRCS) 

TOP_MODULE = bringup_tb

TESTS=mgmt_mem_access

#********************************************************************
#* cocotb testbench setup
#********************************************************************
MODULE=bringup_tests.$(TEST)
export MODULE
PYTHONPATH := $(BRINGUP_DIR)/python:$(PYTHONPATH)
export PYTHONPATH
PATH := $(PACKAGES_DIR)/python/bin:$(PATH)
export PATH


VLSIM_CLKSPEC += -clkspec clk=10ns
VLSIM_OPTIONS += -Wno-fatal --top-module bringup_tb --autoflush
SRCS += $(BRINGUP_DIR)/bringup_tb.sv

SIM?=vlsim

all : build 
	for test in $(TESTS); do \
		$(MAKE) -f $(BRINGUP_DIR)/Makefile run TEST=$${test}; \
	done

clean ::
	echo "TODO"
	for sim in $(BRINGUP_DIR)/../common/*.mk; do \
		$(MAKE) -f $$sim clean; \
	done
	

include $(BRINGUP_DIR)/../common/$(SIM).mk

