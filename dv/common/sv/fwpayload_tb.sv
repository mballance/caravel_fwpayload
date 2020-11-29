/****************************************************************************
 * fwpayload_tb.sv
 ****************************************************************************/
`ifdef IVERILOG
`timescale 1ns/1ns
`endif

`ifndef MPRJ_IO_PADS
	`define MPRJ_IO_PADS 38
`endif
/**
 * Module: fwpayload_tb
 * 
 * TODO: Add module documentation
 */
module fwpayload_tb(input clk);
	
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
				$dumpvars(0, fwpayload_tb);
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
	
	wire vdda1, vdda2, vssa1, vssa2, vccd1, vccd2, vssd1, vssd2;
	wire wb_clk_i = clock;
	wire wb_rst_i = reset;
	wire wbs_stb_i;
	wire wbs_cyc_i;
	wire wbs_we_i;
	wire [3:0] wbs_sel_i;
	wire [31:0] wbs_dat_i;
	wire [31:0] wbs_adr_i;
	wire wbs_ack_o;
	wire [31:0] wbs_dat_o;
	
	wb_initiator_bfm #(
			.ADDR_WIDTH(32),
			.DATA_WIDTH(32)
		) u_wb (
			.clock(wb_clk_i),
			.reset(wb_rst_i),
			.stb(wbs_stb_i),
			.cyc(wbs_cyc_i),
			.we(wbs_we_i),
			.sel(wbs_sel_i),
			.dat_w(wbs_dat_i),
			.adr(wbs_adr_i),
			.ack(wbs_ack_o),
			.dat_r(wbs_dat_o)
		);
	
	wire [127:0] la_data_in;
	wire [127:0] la_data_out;
	wire [127:0] la_oen; //  = 128'hFFFF_FFFF_FFFF_FFFF__FFFF_FFFF_FFFF_FFFF;
	
	la_initiator_bfm #(
			.WIDTH(128)
		) u_la (
			.clock(wb_clk_i),
			.reset(wb_rst_i),
			.data_in(la_data_out),
			.data_out(la_data_in),
			.oen(la_oen)
		);
	
	wire [`MPRJ_IO_PADS-1:0] io_in;
	wire [`MPRJ_IO_PADS-1:0] io_out;
	wire [`MPRJ_IO_PADS-1:0] io_oeb;

	wire [`MPRJ_IO_PADS-8:0] analog_io;
	
	wire   user_clock2 = clock;

	user_project_wrapper u_dut(
			.vdda1(vdda1),	// User area 1 3.3V supply
			.vdda2(vdda2),	// User area 2 3.3V supply
			.vssa1(vssa1),	// User area 1 analog ground
			.vssa2(vssa2),	// User area 2 analog ground
			.vccd1(vccd1),	// User area 1 1.8V supply
			.vccd2(vccd2),	// User area 2 1.8v supply
			.vssd1(vssd1),	// User area 1 digital ground
			.vssd2(vssd2),	// User area 2 digital ground

			// Wishbone Slave ports (WB MI A)
			.wb_clk_i(wb_clk_i),
			.wb_rst_i(wb_rst_i),
			.wbs_stb_i(wbs_stb_i),
			.wbs_cyc_i(wbs_cyc_i),
			.wbs_we_i(wbs_we_i),
			.wbs_sel_i(wbs_sel_i),
			.wbs_dat_i(wbs_dat_i),
			.wbs_adr_i(wbs_adr_i),
			.wbs_ack_o(wbs_ack_o),
			.wbs_dat_o(wbs_dat_o),

			// Logic Analyzer Signals
			.la_data_in(la_data_in),
			.la_data_out(la_data_out),
			.la_oen(la_oen),

			// IOs
			.io_in(io_in),
			.io_out(io_out),
			.io_oeb(io_oeb)

			/*
			// Analog (direct connection to GPIO pad---use with caution)
			// Note that analog I/O is not available on the 7 lowest-numbered
			// GPIO pads, and so the analog_io indexing is offset from the
			// GPIO indexing by 7.
			.analog_io(analog_io),

			// Independent clock (on independent integer divider)
			.user_clock2(user_clock2)
			 */
			);

endmodule


