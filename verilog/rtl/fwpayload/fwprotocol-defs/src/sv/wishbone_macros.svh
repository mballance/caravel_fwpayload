
`ifndef INCLDUDED_WISHBONE_MACROS_SVH
`define INCLDUDED_WISHBONE_MACROS_SVH

`define WB_INITIATOR_PORT(PREFIX,ADDR_WIDTH,DATA_WIDTH) \
	output[ADDR_WIDTH-1:0]				PREFIX``adr, \
	output[DATA_WIDTH-1:0]				PREFIX``dat_w, \
	input[DATA_WIDTH-1:0]				PREFIX``dat_r, \
	output								PREFIX``cyc, \
	input								PREFIX``err, \
	output[DATA_WIDTH/8-1:0]			PREFIX``sel, \
	output								PREFIX``stb, \
	input								PREFIX``ack, \
	output								PREFIX``we
	
`define WB_INITIATOR_PORT_ARR(PREFIX,ADDR_WIDTH,DATA_WIDTH,SIZE) \
	output[(SIZE*ADDR_WIDTH)-1:0]		PREFIX``adr, \
	output[(SIZE*DATA_WIDTH)-1:0]		PREFIX``dat_w, \
	input[(SIZE*DATA_WIDTH)-1:0]		PREFIX``dat_r, \
	output[SIZE-1:0]					PREFIX``cyc, \
	input[SIZE-1:0]						PREFIX``err, \
	output[SIZE*(DATA_WIDTH/8)-1:0]		PREFIX``sel, \
	output[SIZE-1:0]					PREFIX``stb, \
	input[SIZE-1:0]						PREFIX``ack, \
	output[SIZE-1:0]					PREFIX``we

`define WB_TARGET_PORT(PREFIX,ADDR_WIDTH,DATA_WIDTH) \
	input[ADDR_WIDTH-1:0]			PREFIX``adr, \
	input[DATA_WIDTH-1:0]			PREFIX``dat_w, \
	output[DATA_WIDTH-1:0]			PREFIX``dat_r, \
	input							PREFIX``cyc, \
	output							PREFIX``err, \
	input[DATA_WIDTH/8-1:0]			PREFIX``sel, \
	input							PREFIX``stb, \
	output							PREFIX``ack, \
	input							PREFIX``we

`define WB_TARGET_PORT_ARR(PREFIX,ADDR_WIDTH,DATA_WIDTH,SIZE) \
	input[(SIZE*ADDR_WIDTH)-1:0]	PREFIX``adr, \
	input[(SIZE*DATA_WIDTH)-1:0]	PREFIX``dat_w, \
	output[(SIZE*DATA_WIDTH)-1:0]	PREFIX``dat_r, \
	input[SIZE-1:0]					PREFIX``cyc, \
	output[SIZE-1:0]				PREFIX``err, \
	input[SIZE*(DATA_WIDTH/8)-1:0]	PREFIX``sel, \
	input[SIZE-1:0]					PREFIX``stb, \
	output[SIZE-1:0]				PREFIX``ack, \
	input[SIZE-1:0]					PREFIX``we

`define WB_WIRES(PREFIX,ADDR_WIDTH,DATA_WIDTH) \
	wire[ADDR_WIDTH-1:0]			PREFIX``adr, \
	wire[DATA_WIDTH-1:0]			PREFIX``dat_w, \
	wire[DATA_WIDTH-1:0]			PREFIX``dat_r, \
	wire							PREFIX``cyc, \
	wire							PREFIX``err, \
	wire[DATA_WIDTH/8-1:0]			PREFIX``sel, \
	wire							PREFIX``stb, \
	wire							PREFIX``ack, \
	wire							PREFIX``we

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
	
`define WB_INDEX_ARR(PREFIX,FIELD,WIDTH,INDEX) \
	PREFIX``FIELD``[(INDEX)*(WIDTH)+:(WIDTH)]

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
	
`endif /* INCLDUDED_WISHBONE_MACROS_SVH */