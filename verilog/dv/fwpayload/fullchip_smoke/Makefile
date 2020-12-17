TEST_DIR := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))

DV_DIR := $(abspath $(TEST_DIR)/../..)
RTL_DIR := $(abspath $(TEST_DIR)/../../../rtl)

TEST_NAME := $(notdir $(TEST_DIR))

TIMEOUT=2ms
SIMLEVEL=fullchip

DEFINES += SIM FUNCTIONAL TEST_FIRMWARE_HEX=\"$(TEST_NAME).hex\"
INCDIRS += $(RTL_DIR)/fwpayload $(RTL_DIR) $(PDK_PATH)
SRCS += $(RTL_DIR)/defines.v
SRCS += $(RTL_DIR)/caravel.v
SRCS += $(DV_DIR)/caravel/spiflash.v
SRCS += $(DV_DIR)/caravel/tbuart.v

TOP_MODULE = fullchip_tb
TB_SRCS += $(COMMON_DIR)/sv/fullchip_tb.v

include $(TEST_DIR)/../common/defs_rules.mk

#********************************************************************
#* cocotb testbench setup
#********************************************************************
PYTHONPATH := $(TEST_DIR):$(PYTHONPATH)
export PYTHONPATH

MODULE=fwpayload_tests.$(TEST_NAME)
export MODULE

VLSIM_OPTIONS += -Wno-fatal --autoflush

RUN_DEPS += $(TEST_NAME).hex

RULES := 1

all : run

include $(TEST_DIR)/../common/defs_rules.mk

