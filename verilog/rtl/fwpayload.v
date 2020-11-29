
/****************************************************************************
 * fwpayload.v
 ****************************************************************************/
`define WB_WIRES_ARR(PREFIX,ADDR_WIDTH,DATA_WIDTH,SIZE) \
	wire[(SIZE*ADDR_WIDTH)-1:0]		PREFIX``adr; \
	wire[(SIZE*DATA_WIDTH)-1:0]		PREFIX``dat_w; \
	wire[(SIZE*DATA_WIDTH)-1:0]		PREFIX``dat_r; \
	wire[SIZE-1:0]					PREFIX``cyc; \
	wire[SIZE-1:0]					PREFIX``err; \
	wire[SIZE*(DATA_WIDTH/8)-1:0]	PREFIX``sel; \
	wire[SIZE-1:0]					PREFIX``stb; \
	wire[SIZE-1:0]					PREFIX``ack; \
	wire[SIZE-1:0]					PREFIX``we

`define WB_CONNECT(P_PREFIX,W_PREFIX) 	\
	.P_PREFIX``adr(W_PREFIX``adr), 		\
	.P_PREFIX``dat_w(W_PREFIX``dat_w), 	\
	.P_PREFIX``dat_r(W_PREFIX``dat_r), 	\
	.P_PREFIX``cyc(W_PREFIX``cyc), 		\
	.P_PREFIX``err(W_PREFIX``err), 		\
	.P_PREFIX``sel(W_PREFIX``sel), 		\
	.P_PREFIX``stb(W_PREFIX``stb), 		\
	.P_PREFIX``ack(W_PREFIX``ack), 		\
	.P_PREFIX``we(W_PREFIX``we)

`define WB_CONNECT_ARR(P_PREFIX,W_PREFIX,INDEX,ADDR_WIDTH,DATA_WIDTH) 		\
	.P_PREFIX``adr(W_PREFIX``adr[(INDEX)*(ADDR_WIDTH)+:(ADDR_WIDTH)]), 		\
	.P_PREFIX``dat_w(W_PREFIX``dat_w[(INDEX)*(DATA_WIDTH)+:(DATA_WIDTH)]), 	\
	.P_PREFIX``dat_r(W_PREFIX``dat_r[(INDEX)*(DATA_WIDTH)+:(DATA_WIDTH)]), 	\
	.P_PREFIX``cyc(W_PREFIX``cyc[INDEX]), 									\
	.P_PREFIX``err(W_PREFIX``err[INDEX]), 									\
	.P_PREFIX``sel(W_PREFIX``sel[(INDEX)*(DATA_WIDTH/8)+:(DATA_WIDTH/8)]), 	\
	.P_PREFIX``stb(W_PREFIX``stb[INDEX]), 									\
	.P_PREFIX``ack(W_PREFIX``ack[INDEX]), 									\
	.P_PREFIX``we(W_PREFIX``we[INDEX])

`define WB_WIRES_ARR(PREFIX,ADDR_WIDTH,DATA_WIDTH,SIZE) \
	wire[(SIZE*ADDR_WIDTH)-1:0]		PREFIX``adr; \
	wire[(SIZE*DATA_WIDTH)-1:0]		PREFIX``dat_w; \
	wire[(SIZE*DATA_WIDTH)-1:0]		PREFIX``dat_r; \
	wire[SIZE-1:0]					PREFIX``cyc; \
	wire[SIZE-1:0]					PREFIX``err; \
	wire[SIZE*(DATA_WIDTH/8)-1:0]	PREFIX``sel; \
	wire[SIZE-1:0]					PREFIX``stb; \
	wire[SIZE-1:0]					PREFIX``ack; \
	wire[SIZE-1:0]					PREFIX``we

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
		output [31:0] 	wbs_dat_o,

		// Logic Analyzer Signals
		input  [127:0] 					la_data_in,
		output [127:0] 					la_data_out,
		input  [127:0] 					la_oen,

		// IOs
		input  [`MPRJ_IO_PADS-1:0] 		io_in,
		output [`MPRJ_IO_PADS-1:0] 		io_out,
		output [`MPRJ_IO_PADS-1:0] 		io_oeb
		);
	
	// Clock/reset control
	// Allow the logic analyzer to take control of clock/reset
	wire clk = (~la_oen[127]) ? la_data_in[127]: wb_clk_i;
	wire rst = (~la_oen[126]) ? ~la_data_in[126]: wb_rst_i;
	wire core_rst = (~la_oen[125]) ? ~la_data_in[125]: wb_rst_i;

	/****************************************************************
	 * Interconnect definitions
	 ****************************************************************/
	// System interconnect
	localparam N_INITIATORS = 3;
	localparam INIT_ID_CORE_I = 0;
	localparam INIT_ID_CORE_D = 1;
	localparam INIT_ID_MGMT   = 2;
	`WB_WIRES_ARR(i_ic_,32,32,N_INITIATORS);
	
	localparam N_TARGETS = 4;
	localparam TGT_ID_SRAM = 0;
	localparam TGT_ID_SPI  = 1;
	localparam TGT_ID_UART = 2;
	localparam TGT_ID_GPIO = 3;
	`WB_WIRES_ARR(ic_t_,32,32,N_TARGETS);
	
	// Memory map
	//
	// 28-bit address space, with the upper 4 bits masked
	//
	// 0x00000000..0x00000FFFF - Program/data memory
	// 0x01000000..0x010000000 - UART
	// 0x01000000..0x010000100 - SPI
	// 0x01000000..0x010000200 - GPIO
	
	// Interconnect
	wb_interconnect_NxN #(
			.WB_ADDR_WIDTH(32),
			.WB_DATA_WIDTH(32),
			.N_INITIATORS(N_INITIATORS),
			.N_TARGETS(N_TARGETS),
			.I_ADR_MASK({
				{ 32'h0F00_0000    },
				{ 32'h0FFF_FF00    },
				{ 32'h0FFF_FF00    },
				{ 32'h0FFF_FF00    }
				}),
			.T_ADR({
				{ 32'h0000_0000 },
				{ 32'h0100_0000 },
				{ 32'h0100_0100 },
				{ 32'h0100_0200 }
				})
		) u_ic (
			.clock(clk),
			.reset(rst),
		
			`WB_CONNECT(,i_ic_),
			`WB_CONNECT(t,ic_t_)
		);

	/****************************************************************
	 * Connect management interface to port 1 on the interconnect
	 ****************************************************************/
	assign i_ic_adr[32*INIT_ID_MGMT+:32] = wbs_adr_i;
	assign i_ic_dat_w[32*INIT_ID_MGMT+:32] = wbs_dat_i;
	assign wbs_dat_o = i_ic_dat_r[32*INIT_ID_MGMT+:32];
	assign i_ic_cyc[INIT_ID_MGMT] = wbs_cyc_i;
	assign i_ic_sel[4*INIT_ID_MGMT+:4] = wbs_sel_i;
	assign i_ic_stb[INIT_ID_MGMT] = wbs_stb_i;
	assign wbs_ack_o = i_ic_ack[INIT_ID_MGMT];
	assign i_ic_we[INIT_ID_MGMT] = wbs_we_i;
	
	
	/****************************************************************
	 * FWRISC instance
	 ****************************************************************/
	fwrisc_rv32i_wb u_core (
				.clock(clk),
				.reset(core_rst),

				`WB_CONNECT_ARR(wbi_,i_ic_,INIT_ID_CORE_I,32,32),
				`WB_CONNECT_ARR(wbd_,i_ic_,INIT_ID_CORE_D,32,32)
			);

	// Probes
	// - PC 
	//   - [31:0] input
	// - instr_complete
	//   - [32]   input
	// - gpio_out
	//   - [39:36] input
	// - Clock and reset
	//   - 127 output     - clock
	//   - 126 output     - reset
	//   - 125 output     - core_reset
	localparam LA_CLOCK					= 127;
	localparam LA_RESET_SYS				= 126;
	localparam LA_RESET_CORE			= 125;
	localparam LA_GPIO_IN				= 40;
	localparam LA_GPIO_OUT				= 36;
	localparam LA_UART_RX				= 34;
	localparam LA_UART_TX				= 33;
	localparam LA_INSTR_COMPLETE        = 32;
	localparam LA_PC      				= 0;
	
	wire[31:0]      pc_probe = u_core.u_core.u_core.pc;
	assign la_data_out[127:40] = 0;
	assign la_data_out[35:33]  = 0;
	assign la_data_out[LA_PC+:32] = pc_probe;
	assign la_data_out[LA_INSTR_COMPLETE] = u_core.u_core.u_core.instr_complete;

	/****************************************************************
	 * Simple WB to SRAM bridge
	 ****************************************************************/
	reg[1:0] wb_bridge_state = 0;
	wire[31:0] sram_adr_i = ic_t_adr[32*TGT_ID_SRAM+:32];
	wire[31:0] sram_dat_w = ic_t_dat_w[32*TGT_ID_SRAM+:32];
	wire[31:0] sram_dat_r;
	assign ic_t_dat_r[32*TGT_ID_SRAM+:32] = sram_dat_r;
	wire       sram_cyc_i = ic_t_cyc[TGT_ID_SRAM];
	assign     ic_t_err[TGT_ID_SRAM] = 0;
	wire[3:0]  sram_sel_i = ic_t_sel[4*TGT_ID_SRAM+:4];
	wire       sram_stb_i = ic_t_stb[TGT_ID_SRAM];
	wire       sram_ack_o;
	assign     ic_t_ack[TGT_ID_SRAM] = sram_ack_o;
	wire       sram_we_i  = ic_t_we[TGT_ID_SRAM];
	
	always @(posedge clk) begin
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
	
	/****************************************************************
	 * External interfaces
	 ****************************************************************/
	
	// - UART
	wire uart_enabled;
	wire ser_tx;
	wire ser_rx;
	simpleuart_wb #(
			.BASE_ADR(32'h0000_0000)
		) u_uart (
			.wb_clk_i(clk),
			.wb_rst_i(rst),
			.wb_adr_i({24'b0, ic_t_adr[32*TGT_ID_UART+:8]}),
			.wb_dat_i(ic_t_dat_w[32*TGT_ID_UART+:32]),
			.wb_sel_i(ic_t_sel[4*TGT_ID_UART+:4]),
			.wb_we_i(ic_t_we[TGT_ID_UART]),
			.wb_cyc_i(ic_t_cyc[TGT_ID_UART]),
			.wb_stb_i(ic_t_stb[TGT_ID_UART]),
			.wb_ack_o(ic_t_ack[TGT_ID_UART]),
			.wb_dat_o(ic_t_dat_r[32*TGT_ID_UART+:32]),
			
			.uart_enabled(uart_enabled),
			.ser_tx(ser_tx),
			.ser_rx(ser_rx)
		);
	assign ic_t_err[TGT_ID_UART] = 0;
	
	// - SPI
	wire hk_connect;
	wire sdi;
	wire csb;
	wire sck;
	wire sdo;
	wire sdoenb;
	wire irq;
	simple_spi_master_wb #(
			.BASE_ADR(32'h0000_0000)
		) u_spi (
			.wb_clk_i(clk),
			.wb_rst_i(rst),
			.wb_adr_i({24'b0, ic_t_adr[32*TGT_ID_SPI+:8]}),
			.wb_dat_i(ic_t_dat_w[32*TGT_ID_SPI+:32]),
			.wb_sel_i(ic_t_sel[4*TGT_ID_SPI+:4]),
			.wb_we_i(ic_t_we[TGT_ID_SPI]),
			.wb_cyc_i(ic_t_cyc[TGT_ID_SPI]),
			.wb_stb_i(ic_t_stb[TGT_ID_SPI]),
			.wb_ack_o(ic_t_ack[TGT_ID_SPI]),
			.wb_dat_o(ic_t_dat_r[32*TGT_ID_SPI+:32]),
			
			.hk_connect(hk_connect),
			.sdi(sdi),
			.csb(csb),
			.sck(sck),
			.sdo(sdo),
			.sdoenb(sdoenb),
			.irq(irq)
		);
	assign ic_t_err[TGT_ID_SPI] = 0;
	
	// - Simple GPIO
	reg[3:0]	gpio_out;
	wire[3:0]	gpio_in;
	
	wire[31:0] gpio_adr_i = ic_t_adr[32*TGT_ID_GPIO+:32];
	wire[31:0] gpio_dat_w = ic_t_dat_w[32*TGT_ID_GPIO+:32];
	wire[31:0] gpio_dat_r = {20'b0, gpio_in, 4'b0, gpio_out};
	assign ic_t_dat_r[32*TGT_ID_GPIO+:32] = gpio_dat_r;
	wire       gpio_cyc_i = ic_t_cyc[TGT_ID_GPIO];
	assign     ic_t_err[TGT_ID_GPIO] = 0;
	wire[3:0]  gpio_sel_i = ic_t_sel[4*TGT_ID_GPIO+:4];
	wire       gpio_stb_i = ic_t_stb[TGT_ID_GPIO];
	reg        gpio_ack_o;
	assign     ic_t_ack[TGT_ID_GPIO] = gpio_ack_o;
	wire       gpio_we_i  = ic_t_we[TGT_ID_GPIO];
	
	always @(posedge clk) begin
		if (rst == 1) begin
			gpio_ack_o <= 1'b0;
			gpio_out <= 4'b0;
		end else begin
			gpio_ack_o <= (gpio_cyc_i && gpio_stb_i);
			
			if (gpio_cyc_i && gpio_stb_i && gpio_we_i) begin
				gpio_out <= gpio_dat_w[3:0];
			end
		end
	end	
	
	
	/****************************************************************
	 * Outputs
	 ****************************************************************/
	// UART
	assign io_out[16] = ser_tx;
	assign ser_rx = io_in[17];
	
	assign sdi = io_in[18];
	assign io_out[19] = csb;
	assign io_out[20] = sck;
	assign io_out[21] = sdo;
	assign io_out[22] = sdoenb;

	// GPIO
	assign io_out[26:23] = gpio_out;
	assign gpio_in = io_in[30:27];
	
	// Probe the GPIO output with the LA
	assign la_data_out[LA_GPIO_OUT+:4] = gpio_out;
	
endmodule


