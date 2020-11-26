
/****************************************************************************
 * fwpayload.v
 ****************************************************************************/

`ifndef MPRJ_IO_PADS
	`define MPRJ_IO_PADS 38
`endif

/**
 * Module: fwpayload
 * 
 * Payload to go in Caravel
 *
 * - For simplicity, the IO's by and large mirror those of the user_project_wrapper
 */
module fwpayload(
		inout vdda1,	// User area 1 3.3V supply
		inout vdda2,	// User area 2 3.3V supply
		inout vssa1,	// User area 1 analog ground
		inout vssa2,	// User area 2 analog ground
		inout vccd1,	// User area 1 1.8V supply
		inout vccd2,	// User area 2 1.8v supply
		inout vssd1,	// User area 1 digital ground
		inout vssd2,	// User area 2 digital ground

		// Wishbone Slave ports (WB MI A)
		input 			wb_clk_i,
		input 			wb_rst_i,
		input 			wbs_stb_i,
		input 			wbs_cyc_i,
		input 			wbs_we_i,
		input [3:0] 	wbs_sel_i,
		input [31:0] 	wbs_dat_i,
		input [31:0] 	wbs_adr_i,
		output 			wbs_ack_o,
		output [31:0] 					wbs_dat_o,

		// Logic Analyzer Signals
		input  [127:0] 					la_data_in,
		output [127:0] 					la_data_out,
		input  [127:0] 					la_oen,

		// IOs
		input  [`MPRJ_IO_PADS-1:0] 		io_in,
		output [`MPRJ_IO_PADS-1:0] 		io_out,
		output [`MPRJ_IO_PADS-1:0] 		io_oeb
		);
	
	wire clk, rst;

	// System interconnect
	localparam N_INITIATORS = 3;
	localparam INIT_ID_CORE_I = 0;
	localparam INIT_ID_CORE_D = 1;
	localparam INIT_ID_MGMT   = 2;
	
	localparam N_TARGETS = 1;
	localparam TGT_ID_SRAM = 0;
	// TBD
	localparam TGT_ID_SPI  = 1;
	localparam TGT_ID_UART = 2;
	localparam TGT_ID_GPIO = 3;
	wire[32*N_INITIATORS-1:0]		IC_I_ADR;
	wire[32*N_INITIATORS-1:0]		IC_I_DAT_W;
	wire[32*N_INITIATORS-1:0]		IC_I_DAT_R;
	wire[N_INITIATORS-1:0]			IC_I_CYC;
	wire[N_INITIATORS-1:0]			IC_I_ERR;
	wire[4*N_INITIATORS-1:0]		IC_I_SEL;
	wire[N_INITIATORS-1:0]			IC_I_STB;
	wire[N_INITIATORS-1:0]			IC_I_ACK;
	wire[N_INITIATORS-1:0]			IC_I_WE;
	
	wire[32*(N_TARGETS+1)-1:0]		IC_T_ADR;
	wire[32*(N_TARGETS+1)-1:0]		IC_T_DAT_W;
	wire[32*(N_TARGETS+1)-1:0]		IC_T_DAT_R;
	wire[N_TARGETS:0]				IC_T_CYC;
	wire[N_TARGETS:0]				IC_T_ERR;
	wire[4*(N_TARGETS+1)-1:0]		IC_T_SEL;
	wire[N_TARGETS:0]				IC_T_STB;
	wire[N_TARGETS:0]				IC_T_ACK;
	wire[N_TARGETS:0]				IC_T_WE;

	// Interconnect has a default target that
	// to which unmapped accesses are directed
	assign IC_T_ACK[N_TARGETS] = 1;
	assign IC_T_ERR[N_TARGETS] = 1;
	assign IC_T_DAT_R[32*N_TARGETS+:32] = 0;
	
	// Interconnect
	wb_interconnect_NxN #(
			.WB_ADDR_WIDTH(32),
			.WB_DATA_WIDTH(32),
			.N_INITIATORS(N_INITIATORS),
			.N_TARGETS(N_TARGETS),
			.I_ADR_MASK({
				{ 8'hFF, {24{1'b0}} }
				}),
			.T_ADR({
				{ 32'h8000_0000 }
				})
		) u_ic (
			.clk(clk),
			.rst(rst),
			.ADR(IC_I_ADR),
			.DAT_W(IC_I_DAT_W),
			.DAT_R(IC_I_DAT_R),
			.CYC(IC_I_CYC),
			.ERR(IC_I_ERR),
			.SEL(IC_I_SEL),
			.STB(IC_I_STB),
			.ACK(IC_I_ACK),
			.WE(IC_I_WE),
			
			.TADR(IC_T_ADR),
			.TDAT_W(IC_T_DAT_W),
			.TDAT_R(IC_T_DAT_R),
			.TCYC(IC_T_CYC),
			.TERR(IC_T_ERR),
			.TSEL(IC_T_SEL),
			.TSTB(IC_T_STB),
			.TACK(IC_T_ACK),
			.TWE(IC_T_WE)
		);

	/****************************************************************
	 * Connect management interface to port 1 on the interconnect
	 ****************************************************************/
	assign IC_I_ADR[32*INIT_ID_MGMT+:32] = wbs_adr_i;
	assign IC_I_DAT_W[32*INIT_ID_MGMT+:32] = wbs_dat_i;
	assign wbs_dat_o = IC_I_DAT_R[32*INIT_ID_MGMT+:32];
	assign IC_I_CYC[INIT_ID_MGMT] = wbs_cyc_i;
//	assign IC_I_ERR[INIT_ID_MGMT] = //wbs_cyc_i;
	assign IC_I_SEL[4*INIT_ID_MGMT+:4] = wbs_sel_i;
	assign IC_I_STB[INIT_ID_MGMT] = wbs_stb_i;
	assign wbs_ack_o = IC_I_ACK[INIT_ID_MGMT];
	assign IC_I_WE[INIT_ID_MGMT] = wbs_we_i;
	
	// Clock/reset control
	// Allow the logic analyzer to take control of clock/reset
	// Default to using the caravel clock/reset
	assign clk = (~la_oen[127]) ? la_data_in[127]: wb_clk_i;
	assign rst = (~la_oen[126]) ? ~la_data_in[126]: wb_rst_i;
	assign core_rst = (~la_oen[125]) ? ~la_data_in[125]: wb_rst_i;
//	assign clk = wb_clk_i;
//	assign rst = wb_rst_i;
	
	localparam RAM_BITS = 8;
	localparam ROM_BITS = 8;

	fwrisc_rv32i_wb u_core (
				.clock(clk),
				.reset(core_rst),

				.wbi_adr_o(IC_I_ADR[32*INIT_ID_CORE_I+:32]),
				.wbi_dat_o(IC_I_DAT_W[32*INIT_ID_CORE_I+:32]),
				.wbi_dat_i(IC_I_DAT_R[32*INIT_ID_CORE_I+:32]),
				.wbi_cyc_o(IC_I_CYC[INIT_ID_CORE_I]),
				.wbi_err_i(IC_I_ERR[INIT_ID_CORE_I]),
				.wbi_sel_o(IC_I_SEL[4*INIT_ID_CORE_I+:4]),
				.wbi_stb_o(IC_I_STB[INIT_ID_CORE_I]),
				.wbi_ack_i(IC_I_ACK[INIT_ID_CORE_I]),
				.wbi_we_o(IC_I_WE[INIT_ID_CORE_I]),
				
				.wbd_adr_o(IC_I_ADR[32*INIT_ID_CORE_D+:32]),
				.wbd_dat_o(IC_I_DAT_W[32*INIT_ID_CORE_D+:32]),
				.wbd_dat_i(IC_I_DAT_R[32*INIT_ID_CORE_D+:32]),
				.wbd_cyc_o(IC_I_CYC[INIT_ID_CORE_D]),
				.wbd_err_i(IC_I_ERR[INIT_ID_CORE_D]),
				.wbd_sel_o(IC_I_SEL[4*INIT_ID_CORE_D+:4]),
				.wbd_stb_o(IC_I_STB[INIT_ID_CORE_D]),
				.wbd_ack_i(IC_I_ACK[INIT_ID_CORE_D]),
				.wbd_we_o(IC_I_WE[INIT_ID_CORE_D])
			);

	
	// Probes
	// - PC 
	//   - [31:0] input
	// - Regs
	//   - [63:32] input  - registers (via mux)
	//   - [68:64] output - select
	//   - 127 output     - clock
	//   - 126 output     - reset
	localparam IVALID_OFF        = 65;
	localparam REG_PROBE_SEL_OFF = 64;
	localparam REG_PROBE_OFF     = 32;
	localparam PC_PROBE_OFF      = 0;
	wire[4:0]             reg_probe_sel = (
			la_oen[REG_PROBE_SEL_OFF+4:REG_PROBE_SEL_OFF] == 5'b0000)?
			la_data_in[REG_PROBE_SEL_OFF+4:REG_PROBE_SEL_OFF]:5'b0000;
	wire[31:0]            reg_probe;
	wire[31:0]            pc_probe;
	
	assign la_data_out[REG_PROBE_OFF+31:REG_PROBE_OFF] = reg_probe;
	assign la_data_out[PC_PROBE_OFF+31:PC_PROBE_OFF] = pc_probe;
//	assign la_data_out[IVALID_OFF] = u_core.u_core.instr_complete;

	// 640 pixels
	// 16x16?
	// - Each block is 40p wide
	// -
	// - 40ns per pix, 1600ns per block
	// TODO: dedicated reset for core, to allow us to isolate it from the system
	// Video shift register
	// - Need two levels
	// - Output
	// - Ready
	// - Need clock divider to control shift rate
	// - Need IRQ to signal empty

	// Small memory (1KB ok?)
	// - Must be dual-port with access from slave port
	// ROM: 'h8000_0000
	// RAM: 'h8000_8000
	// LED: 'hC000_0000
	
//	initial begin
//		$readmemh("rom.hex", rom);
//	end
	
	/****************************************************************
	 * Simple WB to SRAM bridge
	 ****************************************************************/
	reg[1:0] wb_bridge_state = 0;
	wire[31:0] sram_adr_i = IC_T_ADR[32*TGT_ID_SRAM+:32];
	wire[31:0] sram_dat_w = IC_T_DAT_W[32*TGT_ID_SRAM+:32];
	wire[31:0] sram_dat_r;
	assign IC_T_DAT_R[32*TGT_ID_SRAM+:32] = sram_dat_r;
	wire       sram_cyc_i = IC_T_CYC[TGT_ID_SRAM];
	assign     IC_T_ERR[TGT_ID_SRAM] = 0;
	wire[3:0]  sram_sel_i = IC_T_SEL[4*TGT_ID_SRAM+:4];
	wire       sram_stb_i = IC_T_STB[TGT_ID_SRAM];
	wire       sram_ack_o;
	assign     IC_T_ACK[TGT_ID_SRAM] = sram_ack_o;
	wire       sram_we_i  = IC_T_WE[TGT_ID_SRAM];

	always @(posedge wb_clk_i) begin
		if (rst == 1) begin
			wb_bridge_state <= 0;
		end else begin
			case (wb_bridge_state)
				0:
					if (sram_cyc_i && sram_stb_i) begin
						wb_bridge_state <= 1;
					end
				1:
					wb_bridge_state <= 2;
				2:
					wb_bridge_state <= 3;
				3:
					wb_bridge_state <= 0;
				default:
					wb_bridge_state <= 0;
			endcase
		end
	end
	
	/****************************************************************
	 * SRAM
	 ****************************************************************/
	spram_32x256 u_sram(
			.clock(clk),
			.a_adr(sram_adr_i),
			.a_dat_i(sram_dat_w),
			.a_dat_o(sram_dat_r),
			.a_we(sram_we_i),
			.a_sel(sram_sel_i));
	assign sram_ack_o = (wb_bridge_state == 3);
	
	// Some form of general I/O
	// - GPIO?
	// - 
	
	// Some form of specific I/O
	// - UART
	// - SPI
	
	
endmodule


