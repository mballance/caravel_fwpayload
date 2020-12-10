/****************************************************************************
 * wb_interconnect_2x2.sv
 * 
 * Completely-combinatorial  Wishbone interconnect
 ****************************************************************************/
`include "wishbone_macros.svh"

/**
 * Module: wb_interconnect_NxN
 * 
 * TODO: Add module documentation
 */
module wb_interconnect_2x2(
		input										clock,
		input										reset,
		// Target ports into the interconnect
		`WB_TARGET_PORT_ARR(,32,32,22),
	
		// Initiator ports out of the interconnect
		`WB_INITIATOR_PORT_ARR(t,32,32,2)
		);

	wb_interconnect_NxN #(
		.WB_ADDR_WIDTH(32),
		.WB_DATA_WIDTH(32),
		.N_INITIATORS(2),
		.N_TARGETS(2),
		.I_ADR_MASK({
		{32'hF000_0000},
		{32'hF000_0000}
		}),
		.T_ADR({
		{32'h1000_0000},
		{32'h8000_0000}
		})
	) u_ic (
		.clock(clock),
		.reset(reset),
		`WB_CONNECT(,),
		`WB_CONNECT(t,t)
	);

endmodule
