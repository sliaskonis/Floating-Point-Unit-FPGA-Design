`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: UTH
// Design Name: 
// Module Name:    testbench
// Project Name: Floating Point Adder- testbench
// Target Devices: Zedboard 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
`define CYCLE 20

module testbench;
parameter NUM = 10;  // This is the number of entries in the input file: number of FP additions 
reg	clk,rst;
wire [7:0] out;
wire an0, a0, b0, c0, d0, e0, f0, g0, fp0;
wire an1, a1, b1, c1, d1, e1, f1, g1, fp1;

	initial
		begin
			clk=0;
			rst=0;
			#(`CYCLE) rst = 1;
			#(`CYCLE) rst = 0;
            $display("Starting testbench");
            #(`CYCLE) $display("LED values: %b %b %b %b %b %b %b %b", DUT2.a0, DUT2.b0, DUT2.c0, DUT2.d0, DUT2.e0, DUT2.f0, DUT2.g0);
            $display("LED values: %b", out);
            #(`CYCLE*NUM) $finish;
		end
        
	always
		begin
			#(`CYCLE/2) clk=~clk;
		end
		
		// Instantiate the FP Adder System
		fpadd_system DUT2(.clk(clk), .rst(rst), .leds(out), .an0, .a0, .b0, .c0, .d0, .e0, .f0, .g0, .an1, .a1, .b1, .c1, .d1, .e1, .f1, .g1);
endmodule
