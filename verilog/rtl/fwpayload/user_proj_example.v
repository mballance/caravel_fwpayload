/*
 *-------------------------------------------------------------
 *
 * user_proj_example
 *
 * Updated version of the user_proj_example with 
 * integrated fwpayload
 * 
 *-------------------------------------------------------------
 */
 
`ifndef MPRJ_IO_PADS
`define MPRJ_IO_PADS 38
`endif /* MPRJ_IO_PADS */

module user_proj_example #(
    parameter BITS = 32
)(
`ifdef USE_POWER_PINS
    inout vdda1,	// User area 1 3.3V supply
    inout vdda2,	// User area 2 3.3V supply
    inout vssa1,	// User area 1 analog ground
    inout vssa2,	// User area 2 analog ground
    inout vccd1,	// User area 1 1.8V supply
    inout vccd2,	// User area 2 1.8v supply
    inout vssd1,	// User area 1 digital ground
    inout vssd2,	// User area 2 digital ground
`endif

    input wb_clk_i,
    input wb_rst_i,
    input wbs_stb_i,
    input wbs_cyc_i,
    input wbs_we_i,
    input [3:0] wbs_sel_i,
    input [31:0] wbs_dat_i,
    input [31:0] wbs_adr_i,
    output wbs_ack_o,
    output [31:0] wbs_dat_o,

    // Logic Analyzer Signals
    input  [127:0] 		la_data_in,
    output [127:0] 	la_data_out,
    input  [127:0] 		la_oen,

    // IOs
    input  [`MPRJ_IO_PADS-1:0] io_in,
    output [`MPRJ_IO_PADS-1:0] io_out,
    output [`MPRJ_IO_PADS-1:0] io_oeb
);
    wire clk;
    wire rst;

	localparam LA_CLOCK					= 127;
	localparam LA_RESET_SYS				= 126;
	localparam LA_RESET_CORE			= 125;
	// 124
	localparam LA_CLKDIV 				= 120; // 120..123

	localparam LA_GPIO_IN				= 116;
	localparam LA_GPIO_OUT				= 112; 
	
	// 99..111 (13)
	localparam LA_UNUSED_BLOCK_1        = 99;
	localparam LA_UNUSED_SZ_1           = 13;
	
	localparam LA_UART_RX				= 98;
	localparam LA_UART_TX				= 97;
	localparam LA_INSTR_COMPLETE        = 96;
	
	localparam LA_PC      				= 64; // 64..95
	
	// 55..63 (9)
	localparam LA_UNUSED_BLOCK_2        = 55;
	localparam LA_UNUSED_SZ_2           = 9;
	
	localparam LA_WBA_ACK               = 54;
	localparam LA_WBA_WE                = 53;
	localparam LA_WBA_STB_CYC           = 52;
	localparam LA_WBA_SEL               = 48;
	localparam LA_WBA_ADR               = 32;
	localparam LA_WBA_DAT               = 0;

    wire[3:0]			clkdiv = (!(&la_oen[LA_CLKDIV+4-1:LA_CLKDIV]))?la_data_in[LA_CLKDIV+4-1:LA_CLKDIV]:{4{1'b0}};
    reg[3:0]			clkcnt;
    reg					clock_r;
    wire				clock = (clkdiv==0)?wb_clk_i:clock_r;
  
    always @(posedge wb_clk_i) begin
    	if (wb_rst_i) begin
    		clkcnt <= {4{1'b0}};
    		clock_r <= 1'b0;
    	end else if (clkcnt == clkdiv) begin
    		clock_r <= ~clock_r;
    		clkcnt <= 4'b0;
    	end else begin
    		clkcnt <= clkcnt + 1;
    	end
    end
    
    // Assuming LA probes [65:64] are for controlling the count clk & reset  
    assign payload_clock = (~la_oen[LA_CLOCK]) ? la_data_in[LA_CLOCK]: clock;
    assign payload_sys_reset = (~la_oen[LA_RESET_SYS]) ? ~la_data_in[LA_RESET_SYS]: wb_rst_i;
    assign payload_core_reset = (~la_oen[LA_RESET_CORE]) ? ~la_data_in[LA_RESET_CORE]: wb_rst_i;
    
	wire 		wba_stb_i = (~la_oen[LA_WBA_STB_CYC])?la_data_in[LA_WBA_STB_CYC]:1'b0;
	wire 		wba_cyc_i = (~la_oen[LA_WBA_STB_CYC])?la_data_in[LA_WBA_STB_CYC]:1'b0;
	wire 		wba_we_i  = (~la_oen[LA_WBA_WE])?la_data_in[LA_WBA_WE]:1'b0;
	wire [3:0] 	wba_sel_i = (~(|la_oen[LA_WBA_SEL+4-1:LA_WBA_SEL]))?la_data_in[LA_WBA_SEL+4-1:LA_WBA_SEL]:{4{1'b0}};
	wire [31:0] wba_dat_i = (~(|la_oen[LA_WBA_DAT+32-1:LA_WBA_DAT]))?la_data_in[LA_WBA_DAT+32-1:LA_WBA_DAT]:{32{1'b0}};
	wire [31:0] wba_adr_i = (~(|la_oen[LA_WBA_ADR+16-1:LA_WBA_ADR]))?la_data_in[LA_WBA_ADR+16-1:LA_WBA_ADR]:{32{1'b0}};
	wire 		wba_ack_o;
	wire [31:0]	wba_dat_o;

	/*
	 */
	assign la_data_out[LA_WBA_STB_CYC] = 1'b0;
	assign la_data_out[LA_WBA_WE] = 1'b0;
	assign la_data_out[LA_WBA_SEL+4-1:LA_WBA_SEL] = {4{1'b0}};
	assign la_data_out[LA_WBA_ADR+16-1:LA_WBA_ADR] = {32{1'b0}};
	assign la_data_out[LA_WBA_ACK] = wba_ack_o;
	assign la_data_out[LA_WBA_DAT+32-1:LA_WBA_DAT] = wba_dat_o;
	
	wire[31:0] pc;
	assign la_data_out[LA_PC+32-1:LA_PC] = pc;
	wire instr_complete;
	assign la_data_out[LA_INSTR_COMPLETE] = instr_complete;
	wire ser_tx;
	wire ser_rx;
	
	wire sdi;
	wire csb;
	wire sck;
	wire sdo;
	wire sdoenb;
	
	wire[7:0]	gpio_out;
	assign la_data_out[LA_GPIO_OUT+4-1:LA_GPIO_OUT] = gpio_out[3:0];
	wire[7:0]	gpio_in;
	// TODO: handle la gpio_in

	assign la_data_out[LA_UART_TX] = ser_tx;

	localparam PIN_UNUSED_BLOCK_1       = 0;
	localparam PIN_UNUSED_SZ_1          = 12;
	localparam PIN_UART_TX				= 16;
	localparam PIN_UART_RX				= 17;
	localparam PIN_GPIO_OUT_LOW			= 12;
	localparam PIN_GPIO_OUT_HIGH		= 23;
	localparam PIN_GPIO_IN				= 27;
	localparam PIN_SPI_SDI				= 18;
	localparam PIN_SPI_CSB				= 19;
	localparam PIN_SPI_SCK				= 20;
	localparam PIN_SPI_SDO				= 21;
	localparam PIN_SPI_SDOENB			= 22;
	localparam PIN_UNUSED_BLOCK_2       = 35;
	localparam PIN_UNUSED_SZ_2          = 2;
	localparam PIN_DIR_OUT              = 1'b0;
	localparam PIN_DIR_IN               = 1'b1;

	assign io_out[PIN_UNUSED_BLOCK_1+PIN_UNUSED_SZ_1-1:PIN_UNUSED_BLOCK_1] = {PIN_UNUSED_SZ_1{1'b0}};
	assign io_oeb[PIN_UNUSED_BLOCK_1+PIN_UNUSED_SZ_1-1:PIN_UNUSED_BLOCK_1] = {PIN_UNUSED_SZ_1{PIN_DIR_IN}};
	assign io_out[PIN_UART_TX] = ser_tx;
	assign io_oeb[PIN_UART_TX] = PIN_DIR_OUT;
	assign ser_rx = (~la_oen)?la_data_in[LA_UART_RX]:io_in[PIN_UART_RX];
	assign io_oeb[PIN_UART_RX] = PIN_DIR_IN;
	assign io_oeb[PIN_SPI_SDI] = PIN_DIR_IN;
	assign io_out[PIN_SPI_CSB] = csb;
	assign io_oeb[PIN_SPI_SDI] = PIN_DIR_OUT;
	assign io_out[PIN_SPI_SCK] = sck;
	assign io_oeb[PIN_SPI_SCK] = PIN_DIR_OUT;
	assign io_out[PIN_SPI_SDO] = sdo;
	assign io_oeb[PIN_SPI_SDO] = PIN_DIR_OUT;
	assign io_out[PIN_SPI_SDOENB] = sdoenb;
	assign io_oeb[PIN_SPI_SDOENB] = PIN_DIR_OUT;
	assign sdi = io_in[PIN_SPI_SDI];
	
	assign io_out[PIN_GPIO_OUT_LOW+4-1:PIN_GPIO_OUT_LOW] = gpio_out[3:0];
	assign io_oeb[PIN_GPIO_OUT_LOW+4-1:PIN_GPIO_OUT_LOW] = {4{PIN_DIR_OUT}};
	assign io_out[PIN_GPIO_OUT_HIGH+4-1:PIN_GPIO_OUT_HIGH] = gpio_out[7:4];
	assign io_oeb[PIN_GPIO_OUT_HIGH+4-1:PIN_GPIO_OUT_HIGH] = {4{PIN_DIR_OUT}};
	assign gpio_in = io_in[PIN_GPIO_IN+8-1:PIN_GPIO_IN+4];
	assign gpio_in[3] = (~la_oen[LA_GPIO_IN+3])?la_data_in[LA_GPIO_IN+3]:io_in[PIN_GPIO_IN+3];
	assign gpio_in[2] = (~la_oen[LA_GPIO_IN+2])?la_data_in[LA_GPIO_IN+2]:io_in[PIN_GPIO_IN+2];
	assign gpio_in[1] = (~la_oen[LA_GPIO_IN+1])?la_data_in[LA_GPIO_IN+1]:io_in[PIN_GPIO_IN+1];
	assign gpio_in[0] = (~la_oen[LA_GPIO_IN+0])?la_data_in[LA_GPIO_IN+0]:io_in[PIN_GPIO_IN+0];
	assign io_oeb[PIN_GPIO_IN+8-1:PIN_GPIO_IN] = {8{PIN_DIR_IN}};
	
	assign io_out[PIN_UNUSED_BLOCK_2+PIN_UNUSED_SZ_2-1:PIN_UNUSED_BLOCK_2] = {PIN_UNUSED_SZ_2{1'b0}};
	assign io_oeb[PIN_UNUSED_BLOCK_2+PIN_UNUSED_SZ_2-1:PIN_UNUSED_BLOCK_2] = {PIN_UNUSED_SZ_2{PIN_DIR_IN}};
	
	wire b2payload_stb;
	wire b2payload_cyc;
	wire b2payload_we;
	wire[3:0] b2payload_sel;
	wire[31:0] b2payload_dat_w;
	wire[31:0] b2payload_adr;
	wire b2payload_ack;
	wire[31:0] b2payload_dat_r;
	
	// bridge for the management interface
	wb_clockdomain_bridge #(
			.ADR_WIDTH(32),
			.DAT_WIDTH(32)
		) u_bridge (
			.reset(payload_sys_reset),
			.i_clock(wb_clk_i),
			.i_stb(wbs_stb_i),
			.i_cyc(wbs_cyc_i),
			.i_we(wbs_we_i),
			.i_sel(wbs_sel_i),
			.i_dat_w(wbs_dat_i),
			.i_adr(wbs_adr_i),
			.i_ack(wbs_ack_o),
			.i_dat_r(wbs_dat_o),
			
			.t_clock(payload_clock),
			.t_stb(b2payload_stb),
			.t_cyc(b2payload_cyc),
			.t_we(b2payload_we),
			.t_sel(b2payload_sel),
			.t_dat_w(b2payload_dat_w),
			.t_adr(b2payload_adr),
			.t_ack(b2payload_ack),
			.t_dat_r(b2payload_dat_r)
		);
    
    fwpayload u_payload(
    		.clock(payload_clock),
    		.sys_reset(payload_sys_reset),
    		.core_reset(payload_core_reset),
    		
    		.wbs_stb_i(b2payload_stb),
    		.wbs_cyc_i(b2payload_cyc),
   			.wbs_we_i(b2payload_we),
    		.wbs_sel_i(b2payload_sel),
    		.wbs_dat_i(b2payload_dat_w),
    		.wbs_adr_i(b2payload_adr),
    		.wbs_ack_o(b2payload_ack),
    		.wbs_dat_o(b2payload_dat_r),
    		
    		.wba_stb_i(wba_stb_i),
    		.wba_cyc_i(wba_cyc_i),
    		.wba_we_i(wba_we_i),
    		.wba_sel_i(wba_sel_i),
    		.wba_dat_i(wba_dat_i),
    		.wba_adr_i(wba_adr_i),
    		.wba_ack_o(wba_ack_o),
    		.wba_dat_o(wba_dat_o),
    		
    		.pc(pc),
		.instr_complete(instr_complete),
    		
    		.ser_tx(ser_tx),
    		.ser_rx(ser_rx),
    		
    		.sdi(sdi),
    		.csb(csb),
    		.sck(sck),
    		.sdo(sdo),
    		.sdoenb(sdoenb),
    		
    		.gpio_out(gpio_out),
    		.gpio_in(gpio_in)
    		
    	);

endmodule

