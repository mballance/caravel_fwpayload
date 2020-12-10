
FWPROTOCOL_DEFS_MKFILES_DIR := $(dir $(lastword $(MAKEFILE_LIST)))

ifneq (1,$(RULES))

FWPROTOCOL_DEFS := $(abspath $(FWPROTOCOL_DEFS_MKFILES_DIR)/..)
export FWPROTOCOL_DEFS

else # Rules

endif
