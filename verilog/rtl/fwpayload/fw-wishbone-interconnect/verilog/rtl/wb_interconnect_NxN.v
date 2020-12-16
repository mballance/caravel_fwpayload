/****************************************************************************
 * wb_interconnect_NxN.sv
 * 
 * Completely-combinatorial  Wishbone interconnect
 ****************************************************************************/

/**
 * Module: wb_interconnect_NxN
 * 
 * TODO: Add module documentation
 */
module wb_interconnect_NxN #(
		parameter 									WB_ADDR_WIDTH=32,
		parameter 									WB_DATA_WIDTH=32,
		parameter 									N_INITIATORS=1,
		parameter 									N_TARGETS=1,
		parameter [N_INITIATORS*WB_ADDR_WIDTH-1:0] 	I_ADR_MASK = {
			{8'hFF, {24{1'b0}} }
		},
		parameter [N_TARGETS*WB_ADDR_WIDTH-1:0] 		T_ADR = {
			{ 32'h2800_0000 }
		}
		) (
		input										clock,
		input										reset,
		
		// Target ports into the interconnect
		input[(N_INITIATORS*WB_ADDR_WIDTH)-1:0]			adr, 
		input[(N_INITIATORS*WB_DATA_WIDTH)-1:0]			dat_w, 
		output reg[(N_INITIATORS*WB_DATA_WIDTH)-1:0]	dat_r, 
		input[N_INITIATORS-1:0]							cyc, 
		output[N_INITIATORS-1:0]						err, 
		input[N_INITIATORS*(WB_DATA_WIDTH/8)-1:0]		sel, 
		input[N_INITIATORS-1:0]							stb, 
		output reg[N_INITIATORS-1:0]					ack, 
		input[N_INITIATORS-1:0]							we,
		
		
		// Initiator ports out of the interconnect
		output reg[(N_TARGETS*WB_ADDR_WIDTH)-1:0]	tadr,
		output reg[(N_TARGETS*WB_DATA_WIDTH)-1:0]	tdat_w,
		input[(N_TARGETS*WB_DATA_WIDTH)-1:0]		tdat_r,
		output[N_TARGETS-1:0]						tcyc,
		input[N_TARGETS-1:0]						terr,
		output reg[N_TARGETS*(WB_DATA_WIDTH/8)-1:0]	tsel,
		output[N_TARGETS-1:0]						tstb,
		input[N_TARGETS-1:0]						tack,
		output[N_TARGETS-1:0]						twe
		);
	
	localparam WB_DATA_MSB = (WB_DATA_WIDTH-1);
	localparam N_INIT_ID_BITS = (N_INITIATORS>1)?$clog2(N_INITIATORS):1;
	localparam N_TARG_ID_BITS = $clog2(N_TARGETS+1);
	localparam NO_TARGET  = {(N_TARG_ID_BITS+1){1'b1}};
	localparam NO_INITIATOR = {(N_INIT_ID_BITS+1){1'b1}};
	
	// Each initiator has a request vector -> Which target is desired
	//
	// Each target has an arbiter -> Which initiator has access
	//
	// When the two match, the initiator and target are connected
	//
	//
	
	// Decode logic
	// This vector contains an element for each initiator and target,
	// and are one-hot encoded. 
	//
	// target_initiator_sel - per-target request vector. Sent to target arbiters. 
	//                        Consists of a vector of initiators wishing to access the target
	// initiator_target_sel - per-initator request vector. 
	//                        Consists of a vector representing the target an initiator is accessing
	wire[N_TARGETS-1:0]	      initiator_target_sel[N_INITIATORS-1:0];
	wire[N_INITIATORS-1:0]    target_initiator_sel[N_TARGETS-1:0];
	generate
		genvar md_i, md_t_i;
		for (md_i=0; md_i<N_INITIATORS; md_i=md_i+1) begin : block_md_i
			for (md_t_i=0; md_t_i<N_TARGETS; md_t_i=md_t_i+1) begin : block_md_t_i
				assign target_initiator_sel[N_TARGETS-md_t_i-1][md_i] = 
					((adr[WB_ADDR_WIDTH*md_i+:WB_ADDR_WIDTH]&I_ADR_MASK[WB_ADDR_WIDTH*md_i+:WB_ADDR_WIDTH])
						== T_ADR[WB_ADDR_WIDTH*md_t_i+:WB_ADDR_WIDTH]) && (cyc[md_i] && stb[md_i]);
				assign initiator_target_sel[md_i][md_t_i] = target_initiator_sel[md_t_i][md_i];
			end
		end
	endgenerate

	// Per-target grant vector
	wire[N_INITIATORS-1:0]				initiator_gnt[N_TARGETS-1:0];

	generate
		genvar t_arb_i;
		
		for (t_arb_i=0; t_arb_i<N_TARGETS; t_arb_i=t_arb_i+1) begin : s_arb
			wb_interconnect_arb #(
				.N_REQ  (N_INITIATORS)
				) 
				aw_arb (
					.clock    (clock   ), 
					.reset    (reset  ), 
					// Request vector
					.req    (target_initiator_sel[t_arb_i]),
					// One-hot grant vector
					.gnt    (initiator_gnt[t_arb_i])
				);
		end
	endgenerate

	reg[N_INIT_ID_BITS:0]					target_active_initiator[N_TARGETS-1:0];
	generate
		// For each target, determine which initiator is connected
		genvar t_ai_i;
		integer t_ai_ii;
		for (t_ai_i=0; t_ai_i<N_TARGETS; t_ai_i=t_ai_i+1) begin : block_t_ai
			always @* begin
				target_active_initiator[t_ai_i] = NO_INITIATOR;
				for (t_ai_ii=0; t_ai_ii<N_INITIATORS; t_ai_ii=t_ai_ii+1) begin
					if (initiator_gnt[t_ai_i][t_ai_ii]) begin
						target_active_initiator[t_ai_i] = t_ai_ii;
					end
				end
			end
		end
	endgenerate
	
	// Per-initiator id of the selected target
	// Controls response-path muxing
	reg[N_TARG_ID_BITS-1:0]				initiator_active_target[N_INITIATORS-1:0];
	generate
		// For each initiator, determine which target is selected and granted
		genvar i_at_i;
		integer i_at_ii;
		for (i_at_i=0; i_at_i<N_INITIATORS; i_at_i=i_at_i+1) begin : block_i_at
			always @* begin
				initiator_active_target[i_at_i] = NO_TARGET;
				for (i_at_ii=0; i_at_ii<N_TARGETS; i_at_ii=i_at_ii+1) begin
					// TODO: 
					if (initiator_target_sel[i_at_i][i_at_ii]) begin
						initiator_active_target[i_at_i] = i_at_ii;
					end
				end
			end
		end
	endgenerate
			
	
//	reg[N_INIT_ID_BITS:0]					target_active_initiator[N_TARGETS:0];
//	generate
//	// For each target, determine which initiator is connected
//		genvar t_ai_i;
//		integer t_ai_ii;
//		for (t_ai_i=0; t_ai_i<N_TARGETS; t_ai_i=t_am_i+1) begin : block_t_ai
//			always @* begin
//				target_active_initiator[t_ai_i] = NO_INITIATOR;
//				for (t_ai_ii=0; t_ai_ii<N_INITIATORS; t_ai_ii=t_ai_ii+1) begin
//					if (initiator_gnt[t_ai_i][t_ai_ii]) begin
//						target_active_initiator[t_ai_i] = t_ai_ii;
//					end
//				end
//			end
//		end
//	endgenerate	
	
	// WB signals from target back to initiator
	generate
		genvar t2i_i, t2i_j;
		integer t2i_ii;
			
		
		for (t2i_i=0; t2i_i<N_INITIATORS; t2i_i=t2i_i+1) begin : block_t2i_i
			always @* begin
				dat_r[WB_DATA_WIDTH*t2i_i+:WB_DATA_WIDTH] = {WB_DATA_WIDTH{1'b0}};
				ack[t2i_i] = 1'b0;
				for (t2i_ii=0; t2i_ii<N_TARGETS; t2i_ii=t2i_ii+1) begin
					if (initiator_active_target[t2i_i] == t2i_ii) begin
						dat_r[WB_DATA_WIDTH*t2i_i+:WB_DATA_WIDTH] = 
							tdat_r[WB_DATA_WIDTH*t2i_ii+:WB_DATA_WIDTH];
						ack[t2i_i] = tack[t2i_ii];
					end else if (initiator_active_target[t2i_i] == {N_TARG_ID_BITS{1'b1}}) begin
						ack[t2i_i] = (cyc[t2i_i] & stb[t2i_i]);
					end
				end
			end
			assign err[t2i_i] = (initiator_active_target[t2i_i] != {N_TARG_ID_BITS{1'b1}})?
					terr[initiator_active_target[t2i_i]]:(cyc[t2i_i] & stb[t2i_i]);
		end
	endgenerate

	// Initiator to target mux
	generate
		genvar i2t_mux_i;
		integer i2t_mux_ii;
		for (i2t_mux_i=0; i2t_mux_i<N_TARGETS; i2t_mux_i=i2t_mux_i+1) begin : i2t_mux
			always @* begin
				tadr[WB_ADDR_WIDTH*i2t_mux_i+:WB_ADDR_WIDTH] = {WB_ADDR_WIDTH{1'b0}};
				tdat_w[WB_DATA_WIDTH*i2t_mux_i+:WB_DATA_WIDTH] = {WB_DATA_WIDTH{1'b0}};
				tsel[(WB_DATA_WIDTH/8)*i2t_mux_i+:(WB_DATA_WIDTH/8)] = {(WB_DATA_WIDTH/8){1'b0}};
				for (i2t_mux_ii=0; i2t_mux_ii<N_INITIATORS; i2t_mux_ii=i2t_mux_ii+1) begin
					if (target_active_initiator[i2t_mux_i] == i2t_mux_ii) begin
						tadr[WB_ADDR_WIDTH*i2t_mux_i+:WB_ADDR_WIDTH] = 
							adr[WB_ADDR_WIDTH*i2t_mux_ii+:WB_ADDR_WIDTH];
						tdat_w[WB_DATA_WIDTH*i2t_mux_i+:WB_DATA_WIDTH] = 
							dat_w[WB_DATA_WIDTH*i2t_mux_ii+:WB_DATA_WIDTH];
						tsel[(WB_DATA_WIDTH/8)*i2t_mux_i+:(WB_DATA_WIDTH/8)] = 
							sel[(WB_DATA_WIDTH/8)*i2t_mux_ii+:(WB_DATA_WIDTH/8)];
					end
				end
			end
				/*
			assign tadr[WB_ADDR_WIDTH*i2t_mux_i+:WB_ADDR_WIDTH] = 
				(target_active_initiator[i2t_mux_i] == NO_INITIATOR)?{WB_ADDR_WIDTH{1'b0}}:
					adr[{target_active_initiator[i2t_mux_i], 2'b00}+:WB_ADDR_WIDTH];
			assign tadr[WB_ADDR_WIDTH*i2t_mux_i+:WB_ADDR_WIDTH] = 
				(target_active_initiator[i2t_mux_i] == NO_INITIATOR)?{WB_ADDR_WIDTH{1'b0}}:
					adr[WB_ADDR_WIDTH*target_active_initiator[i2t_mux_i]+:WB_ADDR_WIDTH];
				 */
				/*
			assign tdat_w[WB_DATA_WIDTH*i2t_mux_i+:WB_DATA_WIDTH] = 
				(target_active_initiator[i2t_mux_i] == NO_INITIATOR)?{WB_DATA_WIDTH{1'b0}}:
					dat_w[WB_DATA_WIDTH*target_active_initiator[i2t_mux_i]+:WB_DATA_WIDTH];
				 */
			assign tcyc[i2t_mux_i] = 
				(target_active_initiator[i2t_mux_i] == NO_INITIATOR)?1'b0:
					cyc[target_active_initiator[i2t_mux_i]];
				/*
			assign tsel[(WB_DATA_WIDTH/8)*i2t_mux_i+:(WB_DATA_WIDTH/8)] = 
				(target_active_initiator[i2t_mux_i] == NO_INITIATOR)?{(WB_DATA_WIDTH/8){1'b0}}:
				sel[(WB_DATA_WIDTH/8)*target_active_initiator[i2t_mux_i]+:(WB_DATA_WIDTH/8)];
			 */
			assign tstb[i2t_mux_i] = 
				(target_active_initiator[i2t_mux_i] == NO_INITIATOR)?1'b0:
					stb[target_active_initiator[i2t_mux_i]];
			assign twe[i2t_mux_i] = 
				(target_active_initiator[i2t_mux_i] == NO_INITIATOR)?1'b0:
					we[target_active_initiator[i2t_mux_i]];
		end
	endgenerate
	
//	// Error target
//	reg err_req;
//	always @(posedge clock) begin
//		if (reset == 1) begin
//			err_req <= 0;
//		end else begin
//			if (tstb[N_TARGETS] && tcyc[N_TARGETS] && !err_req) begin
//				err_req <= 1;
//			end else begin
//				err_req <= 0;
//			end
//		end
//	end
endmodule

