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

	reg [31:0] A, B;	// Inputs
	reg [31:0] result;	// Output
	reg sign_max, sign_min, reg_sign_max, reg_sign_min;	// Sign bits
	reg [7:0] exp_max, exp_min, exp, reg_exp_max, reg_exp_min;	// Exponent bits
	reg [22:0] temp_mantissa_A, temp_mantissa_B;	// Mantissa bits
	reg [24:0] mantissa_temp, mantissa_max, mantissa_min, mantissa_min_shifted, reg_mantissa_max, reg_mantissa_min_shifted;	// New mantissas
	reg [7:0] temp_exp_A, temp_exp_B;
	reg reg_max_is_zero, reg_min_is_zero;

	wire [7:0] normalized_exp;
	wire [22:0] normalized_mantissa;
	wire max_is_zero, min_is_zero;
	
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
	
	always @(*) begin
		temp_exp_A = A[30:23];
		temp_exp_B = B[30:23];
		temp_mantissa_A = A[22:0];
		temp_mantissa_B = B[22:0];
	end
	
	always@ (*) begin
		// Find the larger number and extract sign, exponent and mantissa for A and B
		if (temp_exp_A > temp_exp_B || (temp_exp_A == temp_exp_B && temp_mantissa_A >= temp_mantissa_B)) begin	// |A| >= |B|
			sign_max = A[31];
			sign_min = B[31];
			exp_max = A[30:23];
			exp_min = B[30:23];
			mantissa_max = {2'b01, A[22:0]};
			mantissa_min = {2'b01, B[22:0]};
		end
		else begin																							// |B| > |A|
			sign_max = B[31];
			sign_min = A[31];
			exp_max = B[30:23];
			exp_min = A[30:23];
			mantissa_max = {2'b01, B[22:0]};
			mantissa_min = {2'b01, A[22:0]};
		end
	end

	assign min_is_zero = ( (exp_min == 0) && (mantissa_min[22:0] == 0) );	// Important flag to ignore concatenated 1 in mantissas
	assign max_is_zero = ( (exp_max == 0) && (mantissa_max[22:0] == 0) );	// For this to be true, min_is_zero is also true (since 0 has the smallest possible absolute value)

	// Adjust the mantissas
	always @(*) begin
		mantissa_min_shifted = (mantissa_min >> (exp_max - exp_min));
	end

	/****************** PIPELINE ******************/
	always @(posedge clk or posedge reset) begin
		if(reset) begin
			reg_mantissa_max <= 0;
			reg_mantissa_min_shifted <= 0;
			reg_exp_max <= 0;
			reg_exp_min <= 0;
			reg_sign_max <= 0;
			reg_sign_min <= 0;
			reg_max_is_zero <= 1'b0;
			reg_min_is_zero <= 1'b0;
		end
		else begin
			reg_mantissa_max <= mantissa_max;
			reg_mantissa_min_shifted <= mantissa_min_shifted;
			reg_exp_max <= exp_max;
			reg_exp_min <= exp_min;
			reg_sign_max <= sign_max;
			reg_sign_min <= sign_min;
			reg_max_is_zero <= max_is_zero;
			reg_min_is_zero <= min_is_zero;
		end
	end

	// Add the mantissas
	always @(*) begin
		if(reg_min_is_zero)	// min zero means mantissa 
			mantissa_temp = reg_mantissa_max;
		else if (reg_sign_max == reg_sign_min)
			mantissa_temp = reg_mantissa_max + reg_mantissa_min_shifted;
		else
			mantissa_temp = reg_mantissa_max - reg_mantissa_min_shifted;
	end

	// Handle exp result
	always @(*) begin
		if (reg_exp_max == reg_exp_min && mantissa_temp == 0) //&& reg_sign_max != reg_sign_min)
			exp = 8'b00000000;
		else
			exp = reg_exp_max;
	end

	// Normalize final number
	fp_normalizer fp_normalizer(.mantissa_temp(mantissa_temp),
								.exp(exp),
								.normalized_mantissa(normalized_mantissa),
								.normalized_exp(normalized_exp));

	// Combine the sign, exponent, and mantissa to form the result
	always @(*)	begin
		if (reg_min_is_zero)
			result = {reg_sign_max, reg_exp_max, reg_mantissa_max[22:0]};
		//else if (reg_max_is_zero)
		//	result = {reg_sign_min, reg_exp_min, reg_mantissa_min_shifted}; 
		else if (mantissa_temp == 0 && exp == 0)
			result = 32'b0;
		else
			result = {reg_sign_max, normalized_exp, normalized_mantissa};
	end

endmodule