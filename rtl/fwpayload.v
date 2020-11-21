
/****************************************************************************
 * fwpayload.v
 ****************************************************************************/

  
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
	
	// Clock/reset control
	// Allow the logic analyzer to take control of clock/reset
	// Default to using the caravel clock/reset
	assign clk = (~la_oen[127]) ? la_data_in[127]: wb_clk_i;
	assign rst = (~la_oen[126]) ? la_data_in[126]: wb_rst_i;
	
	wire[31:0]			iaddr;
	reg[31:0]			idata;
	wire				ivalid;
	wire				iready;
	wire[31:0]			daddr;
	wire[31:0]			dwdata;
	wire[31:0]			dwstb;
	wire				dwrite;
	reg[31:0]			drdata;
	wire				dvalid;
	wire				dready;
	

	fwrisc_rv32imc u_core (
				.clock(clk),
				.reset(rst),
		
				.iaddr(iaddr),
				.idata(idata),
				.ivalid(ivalid),
				.iready(iready),
		
				.dvalid(dvalid),
				.daddr(daddr),
				.dwdata(dwdata),
				.dwstb(dwstb),
				.dwrite(dwrite),
				.drdata(drdata),
				.dready(dready)
			);
	
	// Probes
	// - PC 
	//   - [31:0] input
	// - Regs
	//   - [63:32] input  - registers (via mux)
	//   - [68:64] output - select
	//   - 127 output     - clock
	//   - 126 output     - reset
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
	reg[7:0]			ram_0[1023:0]; // 16k ram
	reg[7:0]			ram_1[1023:0]; // 16k ram
	reg[7:0]			ram_2[1023:0]; // 16k ram
	reg[7:0]			ram_3[1023:0]; // 16k ram
	reg[31:0]			rom[4095:0];   // 16k rom
	reg[31:0]			led;
	reg[31:0]			tx_r;
	reg					iready_r, dready_r;
	
	assign iready = iready_r;
	assign dready = dready_r;

//	initial begin
//		$readmemh("rom.hex", rom);
//	end
	
	reg[31:0]			addr_d;
	reg[31:0]			addr_i;
	
	always @(posedge clk) begin
		addr_d <= daddr;
		addr_i <= iaddr;

		if (dvalid && dready && dwrite) begin
			if (daddr[31:28] == 4'h8 && 
					daddr[15:12] == 4'h8) begin
				//				$display("Write to RAM: 'h%08h", daddr[13:2]);
				if (dwstb[0]) ram_0[daddr[13:2]] <= dwdata[7:0];
				if (dwstb[1]) ram_1[daddr[13:2]] <= dwdata[15:8];
				if (dwstb[2]) ram_2[daddr[13:2]] <= dwdata[23:16];
				if (dwstb[3]) ram_3[daddr[13:2]] <= dwdata[31:24];
			end else if (daddr[31:28] == 4'hc) begin
				if (daddr[3:2] == 4'h0) begin
					led <= dwdata;
				end else if (daddr[3:2] == 4'h1) begin
					tx_r <= dwdata;
				end
			end
		end
	end
	
	always @(posedge clk) begin
		// Prefer data access
		if (dvalid) begin
			dready_r <= 1;
			iready_r <= 0;
		end else if (ivalid) begin
			iready_r <= 1;
			dready_r <= 0;
		end else begin
			iready_r <= 0;
			dready_r <= 0;
		end
	end

	/****************************************************************
	 * Simple WB to storage bridge
	 ****************************************************************/
	reg[1:0] wb_bridge_state = 0;

	always @(posedge clk) begin
		if (rst == 1) begin
			wb_bridge_state <= 0;
		end else begin
			case (wb_bridge_state)
				0:
					if (wbs_cyc_i && wbs_stb_i) begin
						wb_bridge_state <= 1;
					end
				1:
					wb_bridge_state <= 2;
				2:
					wb_bridge_state <= 0;
				default:
					wb_bridge_state <= 0;
			endcase
		end
	end

	wire [31:0] storage_mgmt_addr    = wbs_adr_i; // [ADDRESS_WIDTH+(DATA_WIDTH/32):(DATA_WIDTH/32)+1];
	wire storage_mgmt_rd_en          = (wbs_cyc_i & wbs_stb_i & !wbs_we_i);
	wire storage_mgmt_wr_en          = (wbs_cyc_i & wbs_stb_i & wbs_we_i);
	wire [3:0] storage_mgmt_byte_en  = wbs_sel_i;
	wire [31:0] storage_mgmt_wr_dat  = wbs_dat_i;
	wire [31:0] storage_mgmt_rd_dat;
	
	assign wbs_dat_o = storage_mgmt_rd_dat;
	
	assign wbs_ack_o = (wb_bridge_state == 2);

	// TODO: allow to read 'ram' too
	assign storage_mgmt_rd_dat = rom[wbs_adr_i[13:2]];
	
	always @(posedge clk) begin
		if (storage_mgmt_wr_en) begin
			rom[storage_mgmt_addr[13:2]] <= storage_mgmt_wr_dat;
		end
	end	
	
	always @* begin
		if (addr_d[31:28] == 4'h8 && addr_d[15:12] == 4'h8) begin 
			drdata = {
					ram_3[addr_d[13:2]],
					ram_2[addr_d[13:2]],
					ram_1[addr_d[13:2]],
					ram_0[addr_d[13:2]]
				};
		end else begin
			drdata = rom[addr_d[13:2]];
		end
		
		if (addr_i[31:28] == 4'h8 && addr_i[15:12] == 4'h8) begin
			idata = {
					ram_3[addr_d[13:2]],
					ram_2[addr_d[13:2]],
					ram_1[addr_d[13:2]],
					ram_0[addr_d[13:2]]
				};
		end else begin
			idata = rom[addr_i[13:2]];
		end
	end	
	
	// Some form of general I/O
	// - GPIO?
	// - 
	
	// Some form of specific I/O
	// - UART?
	// - SPI?
	
	
endmodule


