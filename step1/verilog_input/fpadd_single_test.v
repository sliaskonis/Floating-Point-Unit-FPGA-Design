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

	reg [31:0] A, B;	// Inputs
	reg [31:0] result;	// Output
	reg sign_A, sign_B;	// Sign bits
	reg [7:0] exp_A, exp_B, diff_exp, exp, final_exp;	// Exponent bits
	wire [22:0] temp_mantissa_A, temp_mantissa_B;	// Mantissa bits
	reg [24:0] newMantissaA, newMantissaB, mantissa_temp, mantissa_final, mantissa_A, mantissa_B, mantissa_B_shifted;	// New mantissas
	wire [7:0] temp_exp_A, temp_exp_B;	// Temporary variables
	
	// Register the two inputs, and use A and B in the combinational logic. 
	always @ (posedge clk or posedge reset)
		begin
			if (reset == 1'b1)
			begin
				A <= 32'b0;
				B <= 32'b0;
				out <= 32'b0;
			end
			else begin
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
	assign temp_exp_A = A[30:23];
	assign temp_exp_B = B[30:23];
	assign temp_mantissa_A = A[22:0];
	assign temp_mantissa_B = B[22:0];
	
	always@ (*)
		begin
			// Find the larger number and extract sign, exponent and mantissa for A and B
			if (temp_exp_A > temp_exp_B || (temp_exp_A == temp_exp_B && temp_mantissa_A >= temp_mantissa_B)) begin	// A >= B
				sign_A = A[31];
				sign_B = B[31];
				exp_A = A[30:23];
				exp_B = B[30:23];
				mantissa_A = {2'b01, A[22:0]};
				mantissa_B = {2'b01, B[22:0]};
			end
			else begin																								// B > A
				sign_A = B[31];
				sign_B = A[31];
				exp_A = B[30:23];
				exp_B = A[30:23];
				mantissa_A = {2'b01, B[22:0]};
				mantissa_B = {2'b01, A[22:0]};
			end
		end
	
	always @(*)
	begin
		// Compare and adjust the exponents, mantissa
		mantissa_B_shifted = (mantissa_B >> (exp_A - exp_B));
	end

	// Add the mantissas 
	always @(mantissa_A or mantissa_B_shifted or sign_A or sign_B or exp_A or exp_B)
		begin
			// Add the mantissas
			if (sign_A == sign_B) begin
				mantissa_temp = mantissa_A + mantissa_B_shifted;
			end
			else begin
				mantissa_temp = mantissa_A - mantissa_B_shifted;
			end
		end
	
	always @(exp_A or exp_B or mantissa_temp)
	begin
		if (exp_A == exp_B && mantissa_temp == 0 && sign_A != sign_B)
			exp = 8'b00000000;
		else
			exp = exp_A;
	end


	wire [7:0] normalized_exp;
	wire [22:0] normalized_mantissa;
	fp_normalizer fp_normalizer(.mantissa_temp(mantissa_temp),
								.exp(exp),
								.normalized_mantissa(normalized_mantissa),
								.normalized_exp(normalized_exp));

	// Post-normalization and output
	// always @(*)
	// 	begin
	// 		if (mantissa_temp[24] == 1) begin
	// 			mantissa_final = mantissa_temp >> 1;
	// 			final_exp = exp + 1;
	// 		end
	// 		else begin
	// 			final_exp = exp;
	// 			mantissa_final = mantissa_temp;
	// 			while (mantissa_final[23] == 0 && mantissa_final != 0) begin
	// 				mantissa_final = mantissa_final << 1;
	// 				final_exp = final_exp - 1;
	// 			end
	// 			// final_exp = normalized_exp;
	// 			// mantissa_final = normalized_mantissa;
	// 		end
	// 	end

		always @(normalized_exp or normalized_mantissa)
		begin
			if (A == 32'b0)
				result = B;
			else if (B == 32'b0)
				result = A;
			else if (mantissa_temp == 0 && exp == 0)
				result = 32'b0;
			else
				result = {sign_A, normalized_exp, normalized_mantissa};
		end

endmodule
