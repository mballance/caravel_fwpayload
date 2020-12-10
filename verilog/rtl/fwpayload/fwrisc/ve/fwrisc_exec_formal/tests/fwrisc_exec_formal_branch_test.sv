
`include "fwrisc_exec_formal_defines.svh"


module fwrisc_exec_formal_branch_test(
		input					clock,
		input					reset,
		output 					decode_valid,
		input	 				instr_complete,
		
		input[31:0]				pc,

		// Indicates whether the instruction is compressed
		output reg				instr_c,

		output reg[4:0]			op_type,
		
		output reg[31:0]		op_a,
		output reg[31:0]		op_b,
		output reg[5:0]			op,
		output reg[31:0]		op_c,
		output reg[5:0]			rd,
		output reg[31:0]		mtvec,
		input					dvalid,
		output reg[31:0]		drdata,
		output reg				dready
		
		);
	`include "fwrisc_op_type.svh"
	`include "fwrisc_alu_op.svh"

	reg[1:0]		state;
	reg				cond;
	wire[1:0]		op_w = `anyconst;
	wire[31:0]		value = `anyconst;
	wire[11:0]		branch = `anyconst;
	
	reg decode_valid_r;
	
	assign decode_valid = (decode_valid_r && !instr_complete);
	
	always @(posedge clock) begin
		if (reset) begin
			state <= 0;
			instr_c <= 0;
			op_type <= OP_TYPE_BRANCH;
			op_a <= 0;
			op_b <= 0;
			op <= 0;
			op_c <= 0;
			rd <= 0;
			decode_valid_r <= 0;
			mtvec <= 0;
		end else begin
			case (state)
				0: begin
					// Send out a new instruction
					decode_valid_r <= 1;
					// EQ, LT, LTU
					op_c <= (branch)?branch:1;
					case (op_w%3)
						0: begin // OP_EQ
							op <= OP_EQ;
							`cover(cond==0);
							`cover(cond==1);
							if (cond) begin
								op_a <= value;
								op_b <= value;
							end else begin
								op_a <= value;
								op_b <= ~value;
							end
						end
						1: begin
							op <= OP_LT;
							`cover(cond==0);
							`cover(cond==1);
							if (cond) begin
								op_a <= value;
								op_b <= $signed(value) + 1;
							end else begin
								op_a <= value;
								op_b <= value;
							end
						end
						2: begin
							op <= OP_LTU;
							`cover(cond==0);
							`cover(cond==1);
							if (cond) begin
								op_a <= value;
								op_b <= value + 1;
							end else begin
								op_a <= value;
								op_b <= value;
							end
						end
					endcase
					state <= 1;
				end
				1: begin
					if (instr_complete) begin
						decode_valid_r <= 0;
						state <= 0;
					end
				end
			endcase
			
`ifdef FORMAL
			assert(s_eventually instr_complete);
`endif
//			cover(instr_complete==1);
		end
	end
	
	

endmodule