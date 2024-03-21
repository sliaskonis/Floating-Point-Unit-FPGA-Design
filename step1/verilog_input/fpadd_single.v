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
	always@ (*)
		begin
			// Extract the sign, exponent, and mantissa of A and B
			// Sign
			assign sign_A = A[31];
			assign sign_B = B[31];
			// Exponent
			assign exp_A = A[30:23];
			assign exp_B = B[30:23];
			// Mantissa
			assign mantissa_A = A[22:0];
			assign mantissa_B = B[22:0];
			
			assign final_mantissa_A = (sign_A == 1'b1) ? -mantissa_A : mantissa_A;
			assign final_mantissa_B = (sign_B == 1'b1) ? -mantissa_B : mantissa_B;

			if (exp_A > exp_B)
				begin
					// Shift the mantissa of B to the right by exp_A-exp_B bits
					assign mantissa_B_shifted = final_mantissa_B >> (exp_A - exp_B);
					// The new exponent is the same as the larger exponent
					assign new_exp = exp_A;
					// The new mantissa is the sum of the two mantissas 
					assign sum = final_mantissa_A + mantissa_B_shifted;		
				end				
			else if (exp_A < exp_B)
				begin
					// Shift the mantissa of A to the right by exp_B-exp_A bits
					assign mantissa_A_shifted = final_mantissa_A >> (exp_B - exp_A);
					// The new exponent is the same as the larger exponent
					assign new_exp = exp_B;
					// The new mantissa is the sum of the two mantissas
					assign sum = mantissa_A_shifted + final_mantissa_B;		
				end
			else
				begin
					// The new exponent is the same as the larger exponent
					assign new_exp = exp_A;
					// The new mantissa is the sum of the two mantissas
					assign sum = final_mantissa_A + final_mantissa_B;		
				end

				
		end


endmodule
