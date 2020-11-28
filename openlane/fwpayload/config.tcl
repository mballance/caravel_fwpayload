set script_dir [file dirname [file normalize [info script]]]

set ::env(DESIGN_NAME) user_project_wrapper
set ::env(FP_PIN_ORDER_CFG) $script_dir/pin_order.cfg

#set ::env(CLOCK_PORT) "user_clock2"
set ::env(CLOCK_PORT) "wb_clk_i"
set ::env(CLOCK_NET) "mprj.clk"
#set ::env(CLOCK_NET) "wb_clk_i"

set ::env(CLOCK_PERIOD) "10"

set ::env(FP_SIZING) absolute
#set ::env(DIE_AREA) "0 0 2700 3700"
set ::env(DIE_AREA) "0 0 2000 2000"
# Default density is 0.4
set ::env(PL_TARGET_DENSITY) 0.15
# set ::env(PL_TARGET_DENSITY) 0.85
set ::env(PL_OPENPHYSYN_OPTIMIZATIONS) 0

set ::env(PL_SKIP_INITIAL_PLACEMENT) 1

set vlog_files ""
lappend vlog_files "$script_dir/../../verilog/rtl/user_project_wrapper.v"
lappend vlog_files "$script_dir/../../verilog/rtl/fwpayload.v"
lappend vlog_files "$script_dir/../../verilog/rtl/spram_32x256.sv"
lappend vlog_files "$script_dir/../../verilog/rtl/spram.v"
lappend vlog_files "$script_dir/../../verilog/rtl/simple_spi_master.v"
lappend vlog_files "$script_dir/../../verilog/rtl/simpleuart.v"
lappend vlog_files "$script_dir/../../packages/fw-wishbone-interconnect/verilog/rtl/wb_interconnect_NxN.v"
lappend vlog_files "$script_dir/../../packages/fw-wishbone-interconnect/verilog/rtl/wb_interconnect_arb.v"
lappend vlog_files $script_dir/../../packages/fwrisc/rtl/fwrisc.sv 
lappend vlog_files $script_dir/../../packages/fwrisc/rtl/fwrisc_wb.sv 
lappend vlog_files $script_dir/../../packages/fwrisc/rtl/fwrisc_alu.sv 
lappend vlog_files $script_dir/../../packages/fwrisc/rtl/fwrisc_c_decode.sv 
lappend vlog_files $script_dir/../../packages/fwrisc/rtl/fwrisc_decode.sv 
lappend vlog_files $script_dir/../../packages/fwrisc/rtl/fwrisc_exec.sv 
lappend vlog_files $script_dir/../../packages/fwrisc/rtl/fwrisc_fetch.sv 
lappend vlog_files $script_dir/../../packages/fwrisc/rtl/fwrisc_mem.sv 
lappend vlog_files $script_dir/../../packages/fwrisc/rtl/fwrisc_mul_div_shift.sv
lappend vlog_files $script_dir/../../packages/fwrisc/rtl/fwrisc_regfile.sv 
lappend vlog_files $script_dir/../../packages/fwrisc/rtl/fwrisc_rv32i.sv 
lappend vlog_files $script_dir/../../packages/fwrisc/rtl/fwrisc_rv32i_wb.sv 
#lappend vlog_files $script_dir/../../packages/fwrisc/rtl/fwrisc_rv32im.sv 
#lappend vlog_files $script_dir/../../packages/fwrisc/rtl/fwrisc_rv32imc.sv 
#lappend vlog_files $script_dir/../../packages/fwrisc/rtl/fwrisc_system_op.svh 
lappend vlog_files $script_dir/../../packages/fwrisc/rtl/fwrisc_tracer.sv
#foreach path [glob -directory "$script_dir/../../packages/fwrisc/rtl" "*.sv*"] {
#	lappend vlog_files $path
#}

puts "vlog_files=$vlog_files"

set ::env(VERILOG_INCLUDE_DIRS) "\
        $script_dir/../../packages/fwrisc/rtl \
        $script_dir/../../packages/fwprotocol-defs/src/sv"
set ::env(VERILOG_FILES) "$vlog_files"
#set ::env(VERILOG_FILES) "\
#	$script_dir/../../rtl/user_project_wrapper.v \
#	$script_dir/../../rtl/fwpayload.v"

#set ::env(VERILOG_FILES_BLACKBOX) "\
#	$script_dir/../../rtl/fwpayload.v"

#set ::env(EXTRA_LEFS) "\
#	$script_dir/../../lef/user_proj_example.lef"

#set ::env(EXTRA_GDS_FILES) "\
#	$script_dir/../../gds/user_proj_example.gds"
