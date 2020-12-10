
module spram_byte_en #(
	parameter ADDR_BITS = 9, // 8=1KB 9=2KB 10=4KB
	parameter DATA_BITS = 32
	) (
	input				clock,
	// Port A
	input  [ADDR_BITS-1:0]		a_adr,
	input  [DATA_BITS-1:0]		a_dat_i,
	output reg [DATA_BITS-1:0]	a_dat_o,
	input						a_we,
	input  [DATA_BITS/8-1:0]	a_sel);

	reg[7:0]		ram_0[(1 << ADDR_BITS)-1:0];
	reg[7:0]		ram_1[(1 << ADDR_BITS)-1:0];
	reg[7:0]		ram_2[(1 << ADDR_BITS)-1:0];
	reg[7:0]		ram_3[(1 << ADDR_BITS)-1:0];

	always @(posedge clock) begin
		if (a_we) begin
			if (a_sel[0]) ram_0[a_adr[ADDR_BITS-1:2]] <= a_dat_i[7:0];
			if (a_sel[1]) ram_1[a_adr[ADDR_BITS-1:2]] <= a_dat_i[15:8];
			if (a_sel[2]) ram_2[a_adr[ADDR_BITS-1:2]] <= a_dat_i[23:16];
			if (a_sel[3]) ram_3[a_adr[ADDR_BITS-1:2]] <= a_dat_i[31:24];
		end
		a_dat_o[7:0]   <= ram_0[a_adr[ADDR_BITS-1:2]];
		a_dat_o[15:8]  <= ram_1[a_adr[ADDR_BITS-1:2]];
		a_dat_o[23:16] <= ram_2[a_adr[ADDR_BITS-1:2]];
		a_dat_o[31:24] <= ram_3[a_adr[ADDR_BITS-1:2]];
	end

endmodule

