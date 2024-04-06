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
module fpadd_pipelined (input clk,
                     input reset,
                     input [31:0]reg_A, 
                     input [31:0]reg_B,  
		     output reg[31:0] out);

	reg [31:0] A, B, result;						// Inputs and output
	reg max_num_sign, min_num_sign;					// Sign bits
	reg [7:0] temp_exp_A, temp_exp_B;				// Temp vars for exponent bits
	reg [7:0] max_num_exp, min_num_exp, exp;		// Exponent bits
	reg [22:0] temp_mantissa_A, temp_mantissa_B;	// Temp vars for mantissa bits
	reg [24:0] mantissa_temp, max_num_mantissa, min_num_mantissa, mantissa_B_shifted;	// New mantissas
	
	// Pipeline registers
	reg [31:0] pipeline_A, pipeline_B;						// Inputs and output
	reg pipeline_max_num_sign, pipeline_min_num_sign;		// Sign bits
	reg [7:0] pipeline_max_num_exp, pipeline_min_num_exp;	// Exponent bits
	reg [24:0] pipeline_mantissa_B_shifted, pipeline_max_num_mantissa;
	
	wire [22:0] normalized_mantissa;
	wire [7:0] normalized_exp;
	
	// Register the two inputs, and use A and B in the combinational logic. 
	always @ (posedge clk or posedge reset)
		begin
			if (reset == 1'b1)
				begin
					A <= 32'b0;
					B <= 32'b0;
					out <= 32'b0;
				end
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
	
	// Compare the two numbers and determine which one is the maximum and which one is the minimum
	always@ (*)
		begin

			// Store numbers in temporary variables
			temp_exp_A = A[30:23];
			temp_exp_B = B[30:23];
	        temp_mantissa_A = A[22:0];
		    temp_mantissa_B = B[22:0];

			if (temp_exp_A > temp_exp_B || (temp_exp_A == temp_exp_B && temp_mantissa_A >= temp_mantissa_B)) 
				begin	// A >= B
					max_num_sign = A[31];
					min_num_sign = B[31];
					max_num_exp = A[30:23];
					min_num_exp = B[30:23];
					max_num_mantissa = {2'b01, A[22:0]};
					min_num_mantissa = {2'b01, B[22:0]};
				end
			else 
				begin																							// B > A
					max_num_sign = B[31];
					min_num_sign = A[31];
					max_num_exp = B[30:23];
					min_num_exp = A[30:23];
					max_num_mantissa = {2'b01, B[22:0]};
					min_num_mantissa = {2'b01, A[22:0]};
				end
		end
	
	// Adjust the mantissas based on the difference in exponents (of the bigger number)
	always @(*)
		begin
			mantissa_B_shifted = (min_num_mantissa >> (max_num_exp - min_num_exp));
		end

	/******************** PIPELINE STAGE ********************/
	always @(posedge clk or posedge reset)
		begin
			if (reset == 1'b1)
				begin
					pipeline_A <= 32'b0;
					pipeline_B <= 32'b0;
					pipeline_mantissa_B_shifted <= 25'b0;
					pipeline_max_num_mantissa <= 25'b0;
					pipeline_max_num_sign <= 1'b0;
					pipeline_min_num_sign <= 1'b0;
					pipeline_max_num_exp <= 8'b0;
					pipeline_min_num_exp <= 8'b0;
				end
			else
				begin
					pipeline_A <= A;
					pipeline_B <= B;
					pipeline_mantissa_B_shifted <= mantissa_B_shifted;
					pipeline_max_num_mantissa <= max_num_mantissa;
					pipeline_max_num_sign <= max_num_sign;
					pipeline_min_num_sign <= min_num_sign;
					pipeline_max_num_exp <= max_num_exp;
					pipeline_min_num_exp <= min_num_exp;
				end
		end

	// Addition 
	always @(*)
		begin
			if (max_num_sign == min_num_sign)
				mantissa_temp = pipeline_max_num_mantissa + pipeline_mantissa_B_shifted;
			else
				mantissa_temp = pipeline_max_num_mantissa - pipeline_mantissa_B_shifted;
		end

	// Fp_normalized: module that checks and normalizes 
	//                the result if necessary
	fp_normalizer fp_normalizer(.mantissa_temp(mantissa_temp),
								.exp(pipeline_max_num_exp),
								.normalized_mantissa(normalized_mantissa),
								.normalized_exp(normalized_exp));

	// Combine the sign, exponent, and mantissa to form the final result
	always @(*)
		begin
		 	if ((!pipeline_A && !pipeline_B) || (pipeline_max_num_exp == pipeline_min_num_exp && mantissa_temp == 0 && pipeline_max_num_sign != pipeline_min_num_sign))  // Both numbers 0 or the result is 0
				result = 32'b0;
			else
				result = {pipeline_max_num_sign, normalized_exp, normalized_mantissa};
		end

endmodule

