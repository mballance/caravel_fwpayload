/****************************************************************************
 * spram_32x256.sv
 ****************************************************************************/

/**
 * Module: spram_32x512
 * 
 * TODO: Add module documentation
 */
module spram_32x512(
		input				clock,
		input  [8-1:0]		a_adr,
		input  [32-1:0]		a_dat_i,
		output [32-1:0]		a_dat_o,
		input				a_we,
		input  [32/8-1:0]	a_sel);

	spram_byte_en #(
			.ADDR_BITS(9),
			.DATA_BITS(32)
			) u_sram (
			.clock(clock),
			.a_adr(a_adr),
			.a_dat_i(a_dat_i),
			.a_dat_o(a_dat_o),
			.a_we(a_we),
			.a_sel(a_sel));

endmodule


