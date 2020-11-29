set script_dir [file dirname [file normalize [info script]]]

set ::env(DESIGN_NAME) fwpayload
set ::env(FP_PIN_ORDER_CFG) $script_dir/pin_order.cfg

#set ::env(CLOCK_PORT) "user_clock2"
set ::env(CLOCK_PORT) "wb_clk_i"
#set ::env(CLOCK_PORT) ""
set ::env(CLOCK_NET) "u_core.clock"

set ::env(CLOCK_PERIOD) "10"

set ::env(FP_SIZING) absolute
#set ::env(DIE_AREA) "0 0 2700 3700"
set ::env(DIE_AREA) "0 0 2500 3500"
set ::env(DESIGN_IS_CORE) 0

# Default density is 0.4
set ::env(PL_TARGET_DENSITY) 0.25
# TODO: Older version doesn't contain this
#set ::env(PL_BASIC_PLACEMENT) 1

# TODO: Latest example doesn't contain this
set ::env(PL_OPENPHYSYN_OPTIMIZATIONS) 0


set vlog_files ""
#lappend vlog_files "$script_dir/../../verilog/rtl/user_project_wrapper.v"
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
lappend vlog_files $script_dir/../../packages/fwrisc/rtl/fwrisc_tracer.sv

puts "vlog_files=$vlog_files"

set ::env(VERILOG_INCLUDE_DIRS) "\
        $script_dir/../../packages/fwrisc/rtl \
        $script_dir/../../packages/fwprotocol-defs/src/sv"
set ::env(VERILOG_FILES) "$vlog_files"


