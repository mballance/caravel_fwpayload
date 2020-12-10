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
	reg power1 = 0;
	reg power2 = 0;	
	
	always @(posedge clock) begin
		if (reset_key != 16'ha520) begin
			reset_key <= 16'ha520;
			reset_cnt <= 16'h0000;
		end else if (reset_cnt != 1000) begin
			if (reset_cnt == 20) begin
				power1 <= 1;
				power2 <= 1;
			end
			reset_cnt <= reset_cnt + 1;
		end
	end
	
	wire reset = (reset_key != 16'ha520 || reset_cnt != 1000);
	
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

	wire la_clk = la_data_in[127];
	wire la_sys_rst = la_data_in[126];
	wire la_core_rst = la_data_in[125];
	wire[31:0] pc = la_data_out[31:0];
	wire[3:0]  gpio_out = la_data_out[39:36];
	
	la_initiator_bfm #(
			.WIDTH(128)
		) u_la (
			.clock(wb_clk_i),
			.reset(wb_rst_i),
			.data_in(la_data_out),
			.data_out(la_data_in),
			.oen(la_oen)
		);
	
	wire [`MPRJ_IO_PADS-1:0] io_in = {`MPRJ_IO_PADS{1'b0}};
	wire [`MPRJ_IO_PADS-1:0] io_out;
	wire [`MPRJ_IO_PADS-1:0] io_oeb;

	wire [`MPRJ_IO_PADS-8:0] analog_io;
	
	wire   user_clock2 = clock;

	wire VDD3V3;
        wire VDD1V8;
        wire VSS;

        assign VDD3V3 = power1;
        assign VDD1V8 = power2;
        assign VSS = 1'b0;

	user_proj_example u_dut(
		/*
			.vdda1(VDD3V3),	// User area 1 3.3V supply
			.vdda2(VDD3V3),	// User area 2 3.3V supply
			.vssa1(VSS),	// User area 1 analog ground
			.vssa2(VSS),	// User area 2 analog ground
			.vccd1(VDD1V8),	// User area 1 1.8V supply
			.vccd2(VDD1V8),	// User area 2 1.8v supply
			.vssd1(VSS),	// User area 1 digital ground
			.vssd2(VSS),	// User area 2 digital ground
		 */
`ifdef USE_POWER_PINS
			.VPWR(power1),
			.VGND(VSS),
`endif

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


