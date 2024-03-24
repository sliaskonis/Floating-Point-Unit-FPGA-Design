`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: UTH
// 
// Design Name: 
// Module Name:   fpadd_single 
// Project Name: 32 bit Floating Point Unit - Add
// Target Devices: Zedboard
// Tool versions: Vivado 2020.2
//
// Description: 32-bit FP adder with a single pipeline stage (everything happens in one cycle)
//  The module does not check the input for subnormal and NaN numbers, 
//  and assumes that the two inputs are normal FP32 numbers with 0<exp<255.
//  We also assume that the output does not overflow or undeflow, so there is no need to check for these conditions.
//  An FP32 number has 1 sign bit, 8 exponent bits(biased by 127), and 23 mantissa bits.
//////////////////////////////////////////////////////////////////////////////////
module fpadd_single (input clk,
                     input reset,
                     input [31:0]reg_A, 
                     input [31:0]reg_B,  
		     output reg[31:0] out);
				     	
	// Register the two inputs, and use A and B in the combinational logic. 
	always @ (posedge clk or posedge reset)
		begin
			if (reset == 1'b1)
				out <= 32'b0;
			else
				begin
					A <= reg_A;
					B <= reg_B;
					out <= result;
				end
		end
	//Combinational Logic to (a) compare and adjust the exponents, 
	//                       (b) shift appropriately the mantissa if necessary, 
	//                       (c) add the two mantissas, and
	//                       (d) perform post-normalization. 
	//                           Make sure to check explicitly for zero output. 

	reg [31:0] A, B;
	reg sign_A, sign_B;
	reg [7:0] exp_A, exp_B;
	reg [23:0] mantissa_A, mantissa_B;
	reg [24:0] sum;
	reg [31:0] result;

	wire max_sign = (exp_A > exp_B) ? sign_A :
					(mantissa_A > mantissa_B) ? sign_A :
					sign_B;

	wire max_exp = (exp_A > exp_B) ? exp_A : exp_B;

	always@ (*)
	begin
		// Extract the sign, exponent, and mantissa of A and B
		// Sign
		sign_A = A[31];
		sign_B = B[31];
		// Exponent
		exp_A = A[30:23];
		exp_B = B[30:23];
		// Mantissa
		mantissa_A = {1'b1, A[22:0]};
		mantissa_B = {1'b1, B[22:0]};
	end

	always @(*) 
	begin
		mantissa_A_shifted = (exp_A < exp_B) ? mantissa_A : mantissa_A >> (exp_B - exp_A);
		mantissa_B_shifted = (exp_A > exp_B) ? mantissa_B : mantissa_B >> (exp_A - exp_B);
		new_exp = (exp_A > exp_B) ? sign_A : sign_B;
	end

	always @(*)
	begin
		sum = (sign_A ^ sign_B)    ? mantissa_A_shifted + mantissa_B_shifted :
			  (sign_A & (~sign_B)) ? mantissa_A_shifted - mantissa_B_shifted :
			  (~(sign_A) & sign_B) ? mantissa_B_shifted - mantissa_A_shifted ;
	end

	always @(*)
	begin
		if(sum[24])
		begin
			result = {max_sign, max_exp, sum[23:1]};
		end
		else
		begin
			result = {max_sign, max_exp, sum[22:0]};
		end
	end

endmodule
