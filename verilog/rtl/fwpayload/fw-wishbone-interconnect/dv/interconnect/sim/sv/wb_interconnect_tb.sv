
/****************************************************************************
 * wb_interconnect_tb.sv
 ****************************************************************************/
`include "wishbone_macros.svh"
  
/**
 * Module: wb_interconnect_tb
 * 
 * TODO: Add module documentation
 */
module wb_interconnect_tb(input clk);
	
`ifdef HAVE_HDL_CLOCKGEN
	reg clk_r = 0;
	initial begin
		forever begin
			#10;
			clk_r <= ~clk_r;
		end
	end
	assign clk = clk_r;
`endif

`ifdef IVERILOG
	// Icarus requires help with timeout 
	// and wave capture
	reg[31:0]               timeout;
	initial begin
		if ($test$plusargs("dumpvars")) begin
			$dumpfile("simx.vcd");
			$dumpvars(0, wb_interconnect_tb);
		end
		if (!$value$plusargs("timeout=%d", timeout)) begin
			timeout=1000;
		end
		$display("--> Wait for timeout");
		# timeout;
		$display("<-- Wait for timeout");
		$finish();
	end		
`endif
	
	localparam ADDR_WIDTH = 32;
	localparam DATA_WIDTH = 32;
	
	wire clock = clk;

	reg[15:0]			reset_cnt;
	reg[15:0]			reset_key /*verilator public*/ = 0;
	
	always @(posedge clock) begin
		if (reset_key != 16'ha520) begin
			reset_key <= 16'ha520;
			reset_cnt <= 16'h0000;
		end else if (reset_cnt != 1000) begin
			reset_cnt <= reset_cnt + 1;
		end
	end
	
	wire reset = (reset_key != 16'ha520 || reset_cnt != 1000);

	`WB_WIRES_ARR(i2ic_,ADDR_WIDTH,DATA_WIDTH,2);
	`WB_WIRES_ARR(ic2t_,ADDR_WIDTH,DATA_WIDTH,4);
	
	wb_initiator_bfm #(
			.ADDR_WIDTH(ADDR_WIDTH), 
			.DATA_WIDTH(DATA_WIDTH)
			) u_init_0 (
			.clock(clock),
			.reset(reset),
			`WB_CONNECT_ARR(,i2ic_,0,ADDR_WIDTH,DATA_WIDTH)
		);
	
	wb_initiator_bfm #(
			.ADDR_WIDTH(ADDR_WIDTH), 
			.DATA_WIDTH(DATA_WIDTH)
			) u_init_1 (
			.clock(clock),
			.reset(reset),
			`WB_CONNECT_ARR(,i2ic_,1,ADDR_WIDTH,DATA_WIDTH)
		);

	wb_interconnect_NxN #(
		.WB_ADDR_WIDTH  (ADDR_WIDTH ), 
		.WB_DATA_WIDTH  (DATA_WIDTH ), 
		.N_INITIATORS   (2  ), 
		.N_TARGETS      (4     ), 
		.I_ADR_MASK     ({
			{32'hFF00_0000},
			{32'hFF00_0000}
			}), 
		.T_ADR          ({
			{32'h1000_0000},
			{32'h2000_0000},
			{32'h3000_0000},
			{32'h4000_0000}
			})
		) wb_interconnect_NxN (
			.clock        (clock           ), 
			.reset        (reset           ), 
			`WB_CONNECT(,i2ic_),
			`WB_CONNECT(t,ic2t_));
	
	wb_target_bfm #(
			.ADDR_WIDTH(ADDR_WIDTH),
			.DATA_WIDTH(DATA_WIDTH)
		) u_target_0 (
			.clock(clock),
			.reset(reset),
			`WB_CONNECT_ARR(,ic2t_,0, ADDR_WIDTH,DATA_WIDTH)
		);
	
	wb_target_bfm #(
			.ADDR_WIDTH(ADDR_WIDTH),
			.DATA_WIDTH(DATA_WIDTH)
		) u_target_1 (
			.clock(clock),
			.reset(reset),
			`WB_CONNECT_ARR(,ic2t_,1, ADDR_WIDTH,DATA_WIDTH)
		);
	
	wb_target_bfm #(
			.ADDR_WIDTH(ADDR_WIDTH),
			.DATA_WIDTH(DATA_WIDTH)
		) u_target_2 (
			.clock(clock),
			.reset(reset),
			`WB_CONNECT_ARR(,ic2t_,2, ADDR_WIDTH,DATA_WIDTH)
		);
	
	wb_target_bfm #(
			.ADDR_WIDTH(ADDR_WIDTH),
			.DATA_WIDTH(DATA_WIDTH)
		) u_target_3 (
			.clock(clock),
			.reset(reset),
			`WB_CONNECT_ARR(,ic2t_,3, ADDR_WIDTH,DATA_WIDTH)
		);
	

endmodule


