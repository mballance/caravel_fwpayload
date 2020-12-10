set script_dir [file dirname [file normalize [info script]]]

set ::env(DESIGN_NAME) wb_interconnect_2x2
#set ::env(FP_PIN_ORDER_CFG) $script_dir/pin_order.cfg

set ::env(CLOCK_PORT) "clock"

set ::env(CLOCK_PERIOD) "10"

#set ::env(FP_SIZING) absolute
#set ::env(DIE_AREA) "0 0 700 700"
#set ::env(PL_TARGET_DENSITY) 0.08
set ::env(PL_OPENPHYSYN_OPTIMIZATIONS) 0
set ::env(PL_SKIP_INITIAL_PLACEMENT) 1

set vlog_files ""
lappend vlog_files $script_dir/../../verilog/rtl/wb_interconnect_NxN.v
lappend vlog_files $script_dir/../../verilog/rtl/wb_interconnect_arb.v
lappend vlog_files $script_dir/wb_interconnect_2x4.v

#foreach path [glob -directory "$script_dir/../../packages/fwrisc/rtl" "*.sv*"] {
#	lappend vlog_files $path
#}

puts "vlog_files=$vlog_files"

set ::env(VERILOG_INCLUDE_DIRS) "\
        $script_dir/../../packages/fwprotocol-defs/src/sv"
set ::env(VERILOG_FILES) "$vlog_files"

