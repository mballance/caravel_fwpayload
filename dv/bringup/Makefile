BRINGUP_DIR := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
RTL_DIR:=$(abspath $(BRINGUP_DIR)/../../rtl)
PACKAGES_DIR:=$(abspath $(BRINGUP_DIR)/../../packages)
FWRISC_RTL_DIR:=$(PACKAGES_DIR)/fwrisc/rtl

#********************************************************************
#* Source setup
#********************************************************************
FWRISC_SRCS = $(wildcard $(FWRISC_RTL_DIR)/*.sv)
INCDIRS += $(FWRISC_RTL_DIR)

DEFINES += MPRJ_IO_PADS=38
SRCS += $(RTL_DIR)/fwpayload.v $(RTL_DIR)/user_project_wrapper.v
SRCS += $(FWRISC_SRCS) 

#********************************************************************
#* cocotb testbench setup
#********************************************************************
MODULE=bringup_tb
export MODULE
PYTHONPATH := $(BRINGUP_DIR)/python:$(PYTHONPATH)
export PYTHONPATH
PATH := $(PACKAGES_DIR)/python/bin:$(PATH)
export PATH
COCOTB_PREFIX := $(shell $(PACKAGES_DIR)/python/bin/cocotb-config --prefix)
VPI_LIBS += $(COCOTB_PREFIX)/cocotb/libs/libcocotbvpi_verilator.so


VLSIM_CLKSPEC += -clkspec clk=10ns
VLSIM_OPTIONS += -Wno-fatal --top-module bringup_tb
SRCS += $(BRINGUP_DIR)/bringup_tb.sv

SIM?=vlsim

all : build run

clean ::
	echo "TODO"

include $(BRINGUP_DIR)/../common/$(SIM).mk

