TEST_DIR := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))

TOP_MODULE = fwpayload_tb
TB_SRCS += $(COMMON_DIR)/sv/fwpayload_tb.sv

include $(TEST_DIR)/../common/defs_rules.mk

#********************************************************************
#* cocotb testbench setup
#********************************************************************
PYTHONPATH := $(TEST_DIR):$(PYTHONPATH)
export PYTHONPATH

MODULE=fwpayload_tests.mgmt_mem_access
export MODULE

VLSIM_OPTIONS += -Wno-fatal --autoflush

RULES := 1

all : run

include $(TEST_DIR)/../common/defs_rules.mk

