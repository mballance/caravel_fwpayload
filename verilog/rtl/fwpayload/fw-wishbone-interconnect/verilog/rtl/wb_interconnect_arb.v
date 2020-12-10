
/****************************************************************************
 * wb_interconnect_arb.sv
 ****************************************************************************/

  
/**
 * Module: wb_interconnect_arb
 * 
 * TODO: Add module documentation
 */
module wb_interconnect_arb #(
		parameter 					N_REQ=2
		) (
		input						clock,
		input						reset,
		input[N_REQ-1:0]			req,
		output[N_REQ-1:0]			gnt
		);
	
	reg state;
	
	reg [N_REQ-1:0]	last_gnt = 0;
	
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
	
		// The gnt_ppc vector has 0 bits leading up to the fireset request
		for (gnt_ppc_i=N_REQ-1; gnt_ppc_i>=0; gnt_ppc_i=gnt_ppc_i-1) begin : block_gnt_ppc_i
			if (|gnt_ppc_i) begin
				assign gnt_ppc[gnt_ppc_i] = |last_gnt[gnt_ppc_i-1:0];
			end else begin
				assign gnt_ppc[gnt_ppc_i] = last_gnt[0];
			end
			//			if (gnt_ppc_i == 0) begin
			//				assign gnt_ppc[gnt_ppc_i] = last_gnt[0];
			//			end else begin
			//				assign gnt_ppc[gnt_ppc_i] = |last_gnt[gnt_ppc_i-1:0];
			//			end
		end
	endgenerate
	
	wire[N_REQ-1:0]		unmasked_gnt;
	generate
		genvar unmasked_gnt_i;
	
		// The unmasked_gnt vector grants to the lowest active request
		for (unmasked_gnt_i=0; unmasked_gnt_i<N_REQ; unmasked_gnt_i=unmasked_gnt_i+1) begin : block_unmasked_gnt_i
			if (|unmasked_gnt_i) begin
				assign unmasked_gnt[unmasked_gnt_i] = (req[unmasked_gnt_i] & ~(|req[unmasked_gnt_i-1:0]));
			end else begin
				assign unmasked_gnt[unmasked_gnt_i] = req[0];
			end
			// Prioritized unmasked grant vector. Grant to the lowest active grant
			//			if (unmasked_gnt_i == 0) begin
			//				assign unmasked_gnt[unmasked_gnt_i] = req[unmasked_gnt_i];
			//			end else begin
			//				assign unmasked_gnt[unmasked_gnt_i] = (req[unmasked_gnt_i] & ~(|req[unmasked_gnt_i-1:0]));
			//			end
		end
	endgenerate
	
	wire[N_REQ-1:0]		masked_gnt;
	generate
		genvar masked_gnt_i;
	
		// The masked_gnt vector selects the fireset active request
		// above the last grant
		for (masked_gnt_i=0; masked_gnt_i<N_REQ; masked_gnt_i=masked_gnt_i+1) begin : block_masked_gnt_i
			if (|masked_gnt_i) begin
				assign masked_gnt[masked_gnt_i] = 
					(gnt_ppc_next[masked_gnt_i] 
						& req[masked_gnt_i] 
						& ~(|(gnt_ppc_next[masked_gnt_i-1:0] & req[masked_gnt_i-1:0])));
			end else begin
				assign masked_gnt[masked_gnt_i] = (gnt_ppc_next[0] & req[0]);
			end
				
			//			if (masked_gnt_i == 0) begin
			//				assign masked_gnt[masked_gnt_i] = (gnt_ppc_next[masked_gnt_i] & req[masked_gnt_i]);
			//			end else begin
			//				// Select fireset request above the last grant
			//				assign masked_gnt[masked_gnt_i] = (gnt_ppc_next[masked_gnt_i] & req[masked_gnt_i] & 
			//						~(|(gnt_ppc_next[masked_gnt_i-1:0] & req[masked_gnt_i-1:0])));
			//			end
		end
	endgenerate
	
	wire[N_REQ-1:0] prioritized_gnt;

	// Give priority to the 'next' request
	assign prioritized_gnt = (|masked_gnt)?masked_gnt:unmasked_gnt;
	assign gnt = prioritized_gnt;
	
	always @(posedge clock) begin
		if (reset == 1) begin
			state <= 0;
			last_gnt <= 0;
		end else begin
			case (state) 
				0: begin
					if (|prioritized_gnt) begin
						state <= 1;
						last_gnt <= prioritized_gnt;
					end
				end
				
				1: begin
					// Next arbitration happens when 
					// the currently-granted request is dropped
					if ((gnt & req) == 0) begin
						state <= 0;
					end
				end
			endcase
		end
	end

endmodule
 