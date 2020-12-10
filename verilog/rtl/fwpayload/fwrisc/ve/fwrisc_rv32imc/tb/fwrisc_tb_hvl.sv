/****************************************************************************
 * fwrisc_tb_hvl.sv
 ****************************************************************************/
`ifdef HAVE_UVM
	`include "uvm_macros.svh"
`endif

/**
 * Module: fwrisc_tb_hvl
 * 
 * TODO: Add module documentation
 */
module fwrisc_tb_hvl;
`ifdef HAVE_UVM
		import uvm_pkg::*;
		import fwrisc_tests_pkg::*;
`endif
	
	initial begin
`ifdef HAVE_UVM
		run_test();
`else
		googletest_sv_pkg::run_all_tests();
`endif /* HAVE_UVM */
		
	end


endmodule


