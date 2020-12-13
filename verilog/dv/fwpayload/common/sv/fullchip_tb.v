
`ifndef TEST_FIRMWARE_HEX
`define TEST_FIRMWARE_HEX "firmware_missing.hex"
`endif

`ifdef IVERILOG
`timescale 1ns/1ns
`endif

/*
`include "caravel.v"
`include "spiflash.v"
`include "tbuart.v"
 */

module fullchip_tb(input clock);
	
`ifdef HAVE_HDL_CLOCKGEN
	reg clk_r = 0;
	initial begin
		forever begin
			#12.5;
			clk_r <= ~clk_r;
		end
	end
	assign clock = clk_r;
`endif
	
`ifdef IVERILOG
		// Icarus requires help with timeout 
		// and wave capture
		reg[31:0]               timeout;
		initial begin
			if ($test$plusargs("dumpvars")) begin
				$dumpfile("simx.vcd");
				$dumpvars(0, fullchip_tb);
			end
			if (!$value$plusargs("timeout=%d", timeout)) begin
				timeout=1000;
			end
			$display("--> Wait for timeout");
			# timeout;
			$display("<-- Wait for timeout");
			$finish();
		end		
`endif
    	reg RSTB;
	reg power1, power2 /*verilator public*/;

    	wire gpio;
	wire uart_tx;
    	wire [37:0] mprj_io;
	wire [15:0] checkbits;

	assign checkbits  = mprj_io[31:16];
	assign uart_tx = mprj_io[6];

//	always #12.5 clock <= (clock === 1'b0);

//	initial begin
//		clock = 0;
//	end

	initial begin
		RSTB <= 1'b0;
		#1000;
		RSTB <= 1'b1;	    // Release reset
		#2000;
	end

	initial begin		// Power-up sequence
		power1 <= 1'b0;
		power2 <= 1'b0;
		#200;
		power1 <= 1'b1;
		#200;
		power2 <= 1'b1;
	end

    wire flash_csb;
	wire flash_clk;
	wire flash_io0;
	wire flash_io1;

	wire VDD1V8;
    wire VDD3V3;
	wire VSS;
    
	assign VDD3V3 = power1;
	assign VDD1V8 = power2;
	assign VSS = 1'b0;

	caravel uut (
		.vddio	  (VDD3V3),
		.vssio	  (VSS),
		.vdda	  (VDD3V3),
		.vssa	  (VSS),
		.vccd	  (VDD1V8),
		.vssd	  (VSS),
		.vdda1    (VDD3V3),
		.vdda2    (VDD3V3),
		.vssa1	  (VSS),
		.vssa2	  (VSS),
		.vccd1	  (VDD1V8),
		.vccd2	  (VDD1V8),
		.vssd1	  (VSS),
		.vssd2	  (VSS),
		.clock	  (clock),
		.gpio     (gpio),
        	.mprj_io  (mprj_io),
		.flash_csb(flash_csb),
		.flash_clk(flash_clk),
		.flash_io0(flash_io0),
		.flash_io1(flash_io1),
		.resetb	  (RSTB)
	);

	spiflash #(
		.FILENAME(`TEST_FIRMWARE_HEX)
	) spiflash (
		.csb(flash_csb),
		.clk(flash_clk),
		.io0(flash_io0),
		.io1(flash_io1),
		.io2(),			// not used
		.io3()			// not used
	);

	// Testbench UART
	tbuart tbuart (
		.ser_rx(uart_tx)
	);

endmodule
