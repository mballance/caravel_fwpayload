
COMMON_DIR    := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))

ifneq (1,$(RULES))
RTL_DIR       := $(abspath $(COMMON_DIR)/../../verilog/rtl)
GL_DIR        := $(abspath $(COMMON_DIR)/../../verilog/gl)
PACKAGES_DIR  := $(abspath $(COMMON_DIR)/../../packages)
SIM ?= icarus
SIMTYPE ?= functional


PYBFMS_MODULES += wishbone_bfms logic_analyzer_bfms
VLSIM_CLKSPEC += -clkspec clk=10ns

TOP_MODULE ?= fwpayload_tb
TB_SRCS ?= $(COMMON_DIR)/sv/fwpayload_tb.sv

PYTHONPATH := $(COMMON_DIR)/python:$(PYTHONPATH)
export PYTHONPATH

PATH := $(PACKAGES_DIR)/python/bin:$(PATH)
export PATH

#********************************************************************
#* Source setup
#********************************************************************
FWRISC_SRCS = $(wildcard $(PACKAGES_DIR)/fwrisc/rtl/*.sv)
INCDIRS += $(PACKAGES_DIR)/fwrisc/rtl
INCDIRS += $(PACKAGES_DIR)/fwprotocol-defs/src/sv

DEFINES += MPRJ_IO_PADS=38

ifeq (gate,$(SIMTYPE))
SRCS += $(GL_DIR)/fwpayload.v
else
SRCS += $(RTL_DIR)/fwpayload.v
SRCS += $(PACKAGES_DIR)/fw-wishbone-interconnect/verilog/rtl/wb_interconnect_NxN.v
SRCS += $(PACKAGES_DIR)/fw-wishbone-interconnect/verilog/rtl/wb_interconnect_arb.v
SRCS += $(RTL_DIR)/spram_32x256.sv
SRCS += $(RTL_DIR)/spram_32x512.sv
SRCS += $(RTL_DIR)/spram.v
SRCS += $(RTL_DIR)/simple_spi_master.v
SRCS += $(RTL_DIR)/simpleuart.v
SRCS += $(FWRISC_SRCS) 
endif
SRCS += $(TB_SRCS)

include $(COMMON_DIR)/$(SIM).mk

else # Rules

clean ::
	rm -f results.xml

include $(COMMON_DIR)/$(SIM).mk
include $(wildcard $(COMMON_DIR)/*_clean.mk)

endif