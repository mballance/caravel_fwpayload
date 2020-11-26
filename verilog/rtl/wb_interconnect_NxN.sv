/****************************************************************************
 * ${NAME}.sv
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
		input										clk,
		input										rst,
		input[WB_ADDR_WIDTH*N_INITIATORS-1:0]		ADR,
		input[WB_DATA_WIDTH*N_INITIATORS-1:0]		DAT_W,
		output[WB_DATA_WIDTH*N_INITIATORS-1:0]		DAT_R,
		input[N_INITIATORS-1:0]						CYC,
		output[N_INITIATORS-1:0]					ERR,
		input[(WB_DATA_WIDTH/8)*N_INITIATORS-1:0]	SEL,
		input[N_INITIATORS-1:0]						STB,
		output[N_INITIATORS-1:0]					ACK,
		input[N_INITIATORS-1:0]						WE,

		output[WB_ADDR_WIDTH*(N_TARGETS+1)-1:0]		TADR,
		output[WB_DATA_WIDTH*(N_TARGETS+1)-1:0]		TDAT_W,
		input[WB_DATA_WIDTH*(N_TARGETS+1)-1:0]		TDAT_R,
		output[N_TARGETS:0]							TCYC,
		input[N_TARGETS:0]							TERR,
		output[(WB_DATA_WIDTH/8)*(N_TARGETS+1)-1:0]	TSEL,
		output[N_TARGETS:0]							TSTB,
		input[N_TARGETS:0]							TACK,
		output[N_TARGETS:0]							TWE
		);
	
	localparam WB_DATA_MSB = (WB_DATA_WIDTH-1);
	localparam N_INIT_ID_BITS = (N_INITIATORS>1)?$clog2(N_INITIATORS):1;
	localparam N_TARG_ID_BITS = $clog2(N_TARGETS+1);
	localparam NO_TARGET  = {(N_TARG_ID_BITS+1){1'b1}};
	localparam NO_INITIATOR = {(N_INIT_ID_BITS+1){1'b1}};
	
	// Interface to the decode-fail target
//	wb_if				TERR();

	function reg[N_TARG_ID_BITS:0] addr2targ_id(
		input reg[N_INIT_ID_BITS-1:0]		initiator,
		input reg[WB_ADDR_WIDTH-1:0] 		addr
		);
		integer i;
		begin
		addr2targ_id = N_TARGETS;
//		$display("addr2targ_id: 'h%08h 'h%08h", addr, ADDR_RANGES);
		for (i=0; i<N_TARGETS; i+=1) begin
//			$display("Address Range: %0d 'h%08h..'h%08h", i, 
//					ADDR_RANGES[(WB_ADDR_WIDTH*(i+2)-1)-:WB_ADDR_WIDTH],
//					ADDR_RANGES[(WB_ADDR_WIDTH*(i+1)-1)-:WB_ADDR_WIDTH]);
//			$display("  %0d %0d", (WB_ADDR_WIDTH*(i+2)-1), (WB_ADDR_WIDTH*(i+1)-1));
			if (
					(addr&I_ADR_MASK[(WB_ADDR_WIDTH*(i+1))-1-:WB_ADDR_WIDTH]) == 
					(T_ADR[(WB_ADDR_WIDTH*(i+1))-1-:WB_ADDR_WIDTH])) begin
				$display("Address 'h%08h: range=%0d", addr, N_TARGETS-1);
				addr2targ_id = N_TARGETS-1;
			end
		end
		end
	endfunction
	
// Read request state machine

	// Initiator state machine
	reg[2:0]							initiator_state[N_INITIATORS-1:0];
	reg[N_TARG_ID_BITS:0]				initiator_selected_target[N_INITIATORS-1:0];
	wire								initiator_gnt[N_TARGETS:0];
	wire[$clog2(N_INITIATORS)-1:0]		initiator_gnt_id[N_TARGETS:0];
	wire[N_INITIATORS-1:0]				initiator_target_req[N_TARGETS:0];
	
	generate
		genvar m_i;
		for (m_i=0; m_i<N_INITIATORS; m_i=m_i+1) begin : block_m_i
			always @(posedge clk) begin
				if (rst == 1) begin
					initiator_state[m_i] <= 0;
					initiator_selected_target[m_i] <= NO_TARGET;
				end else begin
					case (initiator_state[m_i])
						0: begin
							if (CYC[m_i] && STB[m_i]) begin
								initiator_state[m_i] <= 1;
								initiator_selected_target[m_i] <= addr2targ_id(
										m_i, 
										ADR[WB_ADDR_WIDTH*m_i+:WB_ADDR_WIDTH]
										);
//								$display("Master %0d => Slave %0d", m_i, addr2targ_id(m_i, ADR[m_i]));
							end
						end
						
						1: begin
							// Wait for the addressed target to acknowledge
							if (CYC[m_i] && STB[m_i] && ACK[m_i]) begin
								initiator_state[m_i] <= 0;
								initiator_selected_target[m_i] <= NO_TARGET;
							end
						end
					endcase
				end
			end
		end
	endgenerate

	// Build the req vector for each target
	generate
		genvar m_req_i, m_req_j;

		for (m_req_i=0; m_req_i <(N_TARGETS+1); m_req_i=m_req_i+1) begin : block_m_req_i
			for (m_req_j=0; m_req_j < N_INITIATORS; m_req_j=m_req_j+1) begin : block_m_req_j
				assign initiator_target_req[m_req_i][m_req_j] = (initiator_selected_target[m_req_j] == m_req_i);
			end
		end
	endgenerate

	generate
		genvar s_arb_i;
		
		for (s_arb_i=0; s_arb_i<(N_TARGETS+1); s_arb_i=s_arb_i+1) begin : s_arb
			wb_NxN_arbiter #(
				.N_REQ  (N_INITIATORS)
				) 
				aw_arb (
					.clk    (clk   ), 
					.rst    (rst  ), 
					.req    (initiator_target_req[s_arb_i]), 
					.gnt    (initiator_gnt[s_arb_i]),
					.gnt_id	(initiator_gnt_id[s_arb_i])
				);
		end
	endgenerate

	wire[N_INIT_ID_BITS:0]					target_active_initiator[N_TARGETS:0];

	generate
		genvar s_am_i;
		
		for (s_am_i=0; s_am_i<(N_TARGETS+1); s_am_i=s_am_i+1) begin : block_s_am_i
			assign target_active_initiator[s_am_i] =
				(initiator_gnt[s_am_i])?initiator_gnt_id[s_am_i]:NO_INITIATOR;
		end
	endgenerate
	
	// WB signals from target back to initiator
	generate
		genvar s2m_i;
		
		for (s2m_i=0; s2m_i<N_INITIATORS; s2m_i=s2m_i+1) begin : block_s2m_i
			assign DAT_R[WB_DATA_WIDTH*s2m_i+:WB_DATA_WIDTH] = 
				(initiator_selected_target[s2m_i] != NO_TARGET && 
						initiator_gnt[initiator_selected_target[s2m_i]] && 
						initiator_gnt_id[initiator_selected_target[s2m_i]] == s2m_i)?
					TDAT_R[WB_DATA_WIDTH*initiator_selected_target[s2m_i]+:WB_DATA_WIDTH]:0;
			assign ERR[s2m_i] = (initiator_selected_target[s2m_i] != NO_TARGET && 
										initiator_gnt[initiator_selected_target[s2m_i]] && 
										initiator_gnt_id[initiator_selected_target[s2m_i]] == s2m_i)?
										TERR[initiator_selected_target[s2m_i]]:0;
			assign ACK[s2m_i] = (initiator_selected_target[s2m_i] != NO_TARGET && 
										initiator_gnt[initiator_selected_target[s2m_i]] && 
										initiator_gnt_id[initiator_selected_target[s2m_i]] == s2m_i)?
										TACK[initiator_selected_target[s2m_i]]:0;
		end
	endgenerate

	// WB signals to target mux
	generate
		genvar m2s_i;
		for(m2s_i=0; m2s_i<(N_TARGETS+1); m2s_i=m2s_i+1) begin : WB_M2S_assign
			assign TADR[WB_ADDR_WIDTH*m2s_i+:WB_ADDR_WIDTH] = 
				(target_active_initiator[m2s_i] == NO_INITIATOR)?0:ADR[WB_ADDR_WIDTH*target_active_initiator[m2s_i]+:WB_ADDR_WIDTH];
			assign TDAT_W[WB_DATA_WIDTH*m2s_i+:WB_DATA_WIDTH] = 
				(target_active_initiator[m2s_i] == NO_INITIATOR)?0:DAT_W[WB_DATA_WIDTH*target_active_initiator[m2s_i]+:WB_DATA_WIDTH];
			assign TCYC[m2s_i] = (target_active_initiator[m2s_i] == NO_INITIATOR)?0:CYC[target_active_initiator[m2s_i]];
			assign TSEL[(WB_DATA_WIDTH/8)*m2s_i+:(WB_DATA_WIDTH/8)] = 
				(target_active_initiator[m2s_i] == NO_INITIATOR)?0:
				SEL[(WB_DATA_WIDTH/8)*target_active_initiator[m2s_i]+:(WB_DATA_WIDTH/8)];
			assign TSTB[m2s_i] = (target_active_initiator[m2s_i] == NO_INITIATOR)?0:STB[target_active_initiator[m2s_i]];
			assign TWE[m2s_i] = (target_active_initiator[m2s_i] == NO_INITIATOR)?0:WE[target_active_initiator[m2s_i]];
		end
	endgenerate
	
	// Error target
	reg err_req;
	always @(posedge clk) begin
		if (rst == 1) begin
			err_req <= 0;
		end else begin
			if (TSTB[N_TARGETS] && TCYC[N_TARGETS] && !err_req) begin
				err_req <= 1;
			end else begin
				err_req <= 0;
			end
		end
	end
endmodule

module wb_NxN_arbiter #(
		parameter 					N_REQ=2
		) (
		input						clk,
		input						rst,
		input[N_REQ-1:0]			req,
		output						gnt,
		output[$clog2(N_REQ)-1:0]	gnt_id
		);
	
	reg state;
	
	reg [N_REQ-1:0]	gnt_o = 0;
	reg [N_REQ-1:0]	last_gnt = 0;
	reg [$clog2(N_REQ)-1:0] gnt_id_o = 0;
	assign gnt = |gnt_o;
	assign gnt_id = gnt_id_o;
	
	wire[N_REQ-1:0] gnt_ppc;
	wire[N_REQ-1:0]	gnt_ppc_next;

	generate
		if (N_REQ > 1) begin
			assign gnt_ppc_next = {gnt_ppc[N_REQ-2:0], 1'b0};
		end else begin
			assign gnt_ppc_next = gnt_ppc;
		end
	endgenerate

	generate
		genvar gnt_ppc_i;
		
	for (gnt_ppc_i=N_REQ-1; gnt_ppc_i>=0; gnt_ppc_i=gnt_ppc_i-1) begin : block_gnt_ppc_i
		if (gnt_ppc_i == 0) begin
			assign gnt_ppc[gnt_ppc_i] = last_gnt[0];
		end else begin
			assign gnt_ppc[gnt_ppc_i] = |last_gnt[gnt_ppc_i-1:0];
		end
	end
	endgenerate
	
		wire[N_REQ-1:0]		unmasked_gnt;
	generate
		genvar unmasked_gnt_i;
		
	for (unmasked_gnt_i=0; unmasked_gnt_i<N_REQ; unmasked_gnt_i=unmasked_gnt_i+1) begin : block_unmasked_gnt_i
		// Prioritized unmasked grant vector. Grant to the lowest active grant
		if (unmasked_gnt_i == 0) begin
			assign unmasked_gnt[unmasked_gnt_i] = req[unmasked_gnt_i];
		end else begin
			assign unmasked_gnt[unmasked_gnt_i] = (req[unmasked_gnt_i] & ~(|req[unmasked_gnt_i-1:0]));
		end
	end
	endgenerate
	
		wire[N_REQ-1:0]		masked_gnt;
	generate
		genvar masked_gnt_i;
		
	for (masked_gnt_i=0; masked_gnt_i<N_REQ; masked_gnt_i=masked_gnt_i+1) begin : block_masked_gnt_i
		if (masked_gnt_i == 0) begin
			assign masked_gnt[masked_gnt_i] = (gnt_ppc_next[masked_gnt_i] & req[masked_gnt_i]);
		end else begin
			// Select first request above the last grant
			assign masked_gnt[masked_gnt_i] = (gnt_ppc_next[masked_gnt_i] & req[masked_gnt_i] & 
					~(|(gnt_ppc_next[masked_gnt_i-1:0] & req[masked_gnt_i-1:0])));
		end
	end
	endgenerate
	
		wire[N_REQ-1:0] prioritized_gnt;

	// Give priority to the 'next' request
	assign prioritized_gnt = (|masked_gnt)?masked_gnt:unmasked_gnt;
	
	always @(posedge clk) begin
		if (rst == 1) begin
			state <= 0;
			last_gnt <= 0;
			gnt_o <= 0;
			gnt_id_o <= 0;
		end else begin
			case (state) 
				0: begin
					if (|prioritized_gnt) begin
						state <= 1;
						gnt_o <= prioritized_gnt;
						last_gnt <= prioritized_gnt;
						gnt_id_o <= gnt2id(prioritized_gnt);
					end
				end
				
				1: begin
					if ((gnt_o & req) == 0) begin
						state <= 0;
						gnt_o <= 0;
					end
				end
			endcase
		end
	end

	function reg[$clog2(N_REQ)-1:0] gnt2id(input reg[N_REQ-1:0] gnt);
		integer i;
		begin
//		reg[$clog2(N_REQ)-1:0] result;
		
		gnt2id = 0;
		
		for (i=0; i<N_REQ; i++) begin
			if (gnt[i]) begin
				gnt2id |= i;
			end
		end
	
		end
	endfunction

endmodule
