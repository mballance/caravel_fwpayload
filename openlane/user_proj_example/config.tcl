set script_dir [file dirname [file normalize [info script]]]

set ::env(DESIGN_NAME) user_proj_example

set vlog_files ""
lappend vlog_files $script_dir/../../verilog/rtl/defines.v
lappend vlog_files $script_dir/../../verilog/rtl/fwpayload/user_proj_example.v
lappend vlog_files $script_dir/../../verilog/rtl/fwpayload/fwpayload.v
lappend vlog_files $script_dir/../../verilog/rtl/fwpayload/fw-wishbone-bridges/verilog/rtl/wb_clockdomain_bridge.v
lappend vlog_files $script_dir/../../verilog/rtl/fwpayload/fw-wishbone-interconnect/verilog/rtl/wb_interconnect_NxN.v
lappend vlog_files $script_dir/../../verilog/rtl/fwpayload/fw-wishbone-interconnect/verilog/rtl/wb_interconnect_arb.v
lappend vlog_files $script_dir/../../verilog/rtl/fwpayload/spram_32x256.sv
lappend vlog_files $script_dir/../../verilog/rtl/fwpayload/spram_32x512.sv
lappend vlog_files $script_dir/../../verilog/rtl/fwpayload/spram.v
lappend vlog_files $script_dir/../../verilog/rtl/fwpayload/simple_spi_master.v
lappend vlog_files $script_dir/../../verilog/rtl/fwpayload/simpleuart.v

lappend vlog_files $script_dir/../../verilog/rtl/fwpayload/fwrisc/rtl/fwrisc.sv
lappend vlog_files $script_dir/../../verilog/rtl/fwpayload/fwrisc/rtl/fwrisc_wb.sv
lappend vlog_files $script_dir/../../verilog/rtl/fwpayload/fwrisc/rtl/fwrisc_alu.sv
lappend vlog_files $script_dir/../../verilog/rtl/fwpayload/fwrisc/rtl/fwrisc_c_decode.sv
lappend vlog_files $script_dir/../../verilog/rtl/fwpayload/fwrisc/rtl/fwrisc_decode.sv
lappend vlog_files $script_dir/../../verilog/rtl/fwpayload/fwrisc/rtl/fwrisc_exec.sv
lappend vlog_files $script_dir/../../verilog/rtl/fwpayload/fwrisc/rtl/fwrisc_fetch.sv
lappend vlog_files $script_dir/../../verilog/rtl/fwpayload/fwrisc/rtl/fwrisc_mem.sv
lappend vlog_files $script_dir/../../verilog/rtl/fwpayload/fwrisc/rtl/fwrisc_mul_div_shift.sv
lappend vlog_files $script_dir/../../verilog/rtl/fwpayload/fwrisc/rtl/fwrisc_regfile.sv
lappend vlog_files $script_dir/../../verilog/rtl/fwpayload/fwrisc/rtl/fwrisc_rv32i.sv
lappend vlog_files $script_dir/../../verilog/rtl/fwpayload/fwrisc/rtl/fwrisc_rv32i_wb.sv
lappend vlog_files $script_dir/../../verilog/rtl/fwpayload/fwrisc/rtl/fwrisc_tracer.sv


set vlog_incdirs ""
lappend vlog_incdirs $script_dir/../../verilog/rtl/fwpayload/fwprotocol-defs/src/sv
lappend vlog_incdirs $script_dir/../../verilog/rtl/fwpayload/fwrisc/rtl

set ::env(VERILOG_FILES) $vlog_files
set ::env(VERILOG_INCLUDE_DIRS) $vlog_incdirs

set ::env(CLOCK_PORT) "wb_clk_i"
#set ::env(CLOCK_NET) "u_payload.clock"
set ::env(CLOCK_PERIOD) "30"

set ::env(FP_SIZING) absolute
#set ::env(DIE_AREA) "0 0 1100 1100"
set ::env(DIE_AREA) "0 0 1200 1200"
set ::env(DESIGN_IS_CORE) 0

set ::env(FP_PIN_ORDER_CFG) $script_dir/pin_order.cfg
# set ::env(FP_CONTEXT_DEF) $script_dir/../user_project_wrapper/runs/user_project_wrapper/tmp/floorplan/ioPlacer.def.macro_placement.def
# set ::env(FP_CONTEXT_LEF) $script_dir/../user_project_wrapper/runs/user_project_wrapper/tmp/merged_unpadded.lef

#set ::env(PL_BASIC_PLACEMENT) 1
set ::env(PL_TARGET_DENSITY) 0.35

set ::env(DIODE_INSERTION_STRATEGY) 1
#set ::env(GLB_RT_MAX_DIODE_INS_ITERS) 4

set ::env(ROUTING_CORES) 10

