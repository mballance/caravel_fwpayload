set script_dir [file dirname [file normalize [info script]]]

set ::env(DESIGN_NAME) user_project_wrapper
#set ::env(DESIGN_NAME) fwpayload
set ::env(FP_PIN_ORDER_CFG) $script_dir/pin_order.cfg

set ::env(CLOCK_PORT) "user_clock2"
set ::env(CLOCK_NET) "mprj.clk"

set ::env(CLOCK_PERIOD) "10"

set ::env(FP_SIZING) absolute
set ::env(DIE_AREA) "0 0 2700 3700"
set ::env(PL_TARGET_DENSITY) 0.25
set ::env(PL_OPENPHYSYN_OPTIMIZATIONS) 0

set vlog_files ""
set vlog_bb_files ""
lappend vlog_files "$script_dir/../../verilog/rtl/user_project_wrapper.v"
lappend vlog_bb_files "$script_dir/../../verilog/rtl/fwpayload.v"

set incdirs ""
lappend incdirs $script_dir/../../packages/fwrisc/rtl
lappend incdirs $script_dir/../../packages/fwprotocol-defs/src/sv

puts "vlog_files=$vlog_files"
puts "incdirs=$incdirs"

set ::env(VERILOG_INCLUDE_DIRS) "$incdirs"
set ::env(VERILOG_FILES) "$vlog_files"

set ::env(VERILOG_FILES_BLACKBOX) "$vlog_bb_files"

set ::env(EXTRA_LEFS) "\
	$script_dir/../../lef/fwpayload.lef"

set ::env(EXTRA_GDS_FILES) "\
	$script_dir/../../gds/fwpayload.gds"

