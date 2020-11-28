#****************************************************************************
#* questa_target.mk
#*
#* Clean target for Mentor Questa
#*
#****************************************************************************

COMMON_DIR := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
PACKAGES_DIR := $(abspath $(COMMON_DIR)/../../packages)

clean ::
	rm -rf work transcript modelsim.ini
