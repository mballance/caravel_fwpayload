/****************************************************************************
 * sdram_macros.svh
 * 
 * Macros for declaring and connecting SDRAM interfaces
 ****************************************************************************/
 
`define SDRAM_TARGET_PORT(PREFIX,ADDR_WIDTH,DATA_WIDTH,BANKSEL_WIDTH) \
input[ADDR_WIDTH-1:0]		PREFIX``addr, \
input[BANKSEL_WIDTH-1:0]	PREFIX``bs, \
inout[DATA_WIDTH-1:0]		PREFIX``dq, \
input						PREFIX``cs_n, \
input						PREFIX``ras_n, \
input						PREFIX``cas_n, \
input						PREFIX``we_n, \
input[DATA_WIDTH/8-1:0]		PREFIX``dqm, \
input						PREFIX``cke

`define SDRAM_INITIATOR_PORT(PREFIX,ADDR_WIDTH,DATA_WIDTH,BANKSEL_WIDTH) \
output[ADDR_WIDTH-1:0]		PREFIX``addr, \
output[BANKSEL_WIDTH-1:0]	PREFIX``bs, \
inout[DATA_WIDTH-1:0]		PREFIX``dq, \
output						PREFIX``cs_n, \
output						PREFIX``ras_n, \
output						PREFIX``cas_n, \
output						PREFIX``we_n, \
output[DATA_WIDTH/8-1:0]	PREFIX``dqm, \
output						PREFIX``cke

`define SDRAM_MONITOR_PORT(PREFIX,ADDR_WIDTH,DATA_WIDTH,BANKSEL_WIDTH) \
input[ADDR_WIDTH-1:0]		PREFIX``addr, \
input[BANKSEL_WIDTH-1:0]	PREFIX``bs, \
input[DATA_WIDTH-1:0]		PREFIX``dq, \
input						PREFIX``cs_n, \
input						PREFIX``ras_n, \
input						PREFIX``cas_n, \
input						PREFIX``we_n, \
input[DATA_WIDTH/8-1:0]		PREFIX``dqm, \
input						PREFIX``cke

`define SDRAM_WIRES(PREFIX,ADDR_WIDTH,DATA_WIDTH,BANKSEL_WIDTH) \
wire[ADDR_WIDTH-1:0]		PREFIX``addr; \
wire[BANKSEL_WIDTH-1:0]		PREFIX``bs; \
wire[DATA_WIDTH-1:0]		PREFIX``dq; \
wire						PREFIX``cs_n; \
wire						PREFIX``ras_n; \
wire						PREFIX``cas_n; \
wire						PREFIX``we_n; \
wire[DATA_WIDTH/8-1:0]		PREFIX``dqm; \
wire						PREFIX``cke

`define SDRAM_CONNECT(P_PREFIX,W_PREFIX) \
.P_PREFIX``addr(W_PREFIX``addr), \
.P_PREFIX``bs(W_PREFIX``bs), \
.P_PREFIX``dq(W_PREFIX``dq), \
.P_PREFIX``cs_n(W_PREFIX``cs_n), \
.P_PREFIX``ras_n(W_PREFIX``ras_n), \
.P_PREFIX``cas_n(W_PREFIX``cas_n), \
.P_PREFIX``we_n(W_PREFIX``we_n), \
.P_PREFIX``dqm(W_PREFIX``dqm), \
.P_PREFIX``cke(W_PREFIX``cke)

