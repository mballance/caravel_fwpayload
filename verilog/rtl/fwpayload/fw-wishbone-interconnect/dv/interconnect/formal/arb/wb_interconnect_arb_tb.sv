
/****************************************************************************
 * wb_interconnect_arb_tb.sv
 ****************************************************************************/

  
/**
 * Module: wb_interconnect_arb_tb
 * 
 * TODO: Add module documentation
 */
module wb_interconnect_arb_tb(input clk);
	
	localparam N_BITS;
	
	wire rst;
	wire [N_BITS-1:0] req;
	wire [N_BITS-1:0] gnt;
	
	wb_interconnect_arb #(N_BITS) u_dut (
			clk,
			rst,
			req,
			gnt);


endmodule


