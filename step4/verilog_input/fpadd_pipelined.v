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
	reg sign_A, sign_B, reg_sign_A, reg_sign_B;	// Sign bits
	reg [7:0] exp_A, exp_B, exp, reg_exp_A, reg_exp_B;	// Exponent bits
	reg [22:0] temp_mantissa_A, temp_mantissa_B;	// Mantissa bits
	reg [24:0] mantissa_temp, mantissa_A, mantissa_B, mantissa_B_shifted, reg_mantissa_A, reg_mantissa_B_shifted;	// New mantissas
	reg [7:0] temp_exp_A, temp_exp_B;	// Temporary variables
	
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
	always@ (A or B)
		begin
			temp_exp_A = A[30:23];
			temp_exp_B = B[30:23];
	        temp_mantissa_A = A[22:0];
		    temp_mantissa_B = B[22:0];
			// Find the larger number and extract sign, exponent and mantissa for A and B
			if (temp_exp_A > temp_exp_B || (temp_exp_A == temp_exp_B && temp_mantissa_A >= temp_mantissa_B)) begin	// A >= B
				sign_A = A[31];
				sign_B = B[31];
				exp_A = A[30:23];
				exp_B = B[30:23];
				mantissa_A = {2'b01, A[22:0]};
				mantissa_B = {2'b01, B[22:0]};
			end
			else begin																							// B > A
				sign_A = B[31];
				sign_B = A[31];
				exp_A = B[30:23];
				exp_B = A[30:23];
				mantissa_A = {2'b01, B[22:0]};
				mantissa_B = {2'b01, A[22:0]};
			end
		end
	
	// Adjust the mantissas
	always @(mantissa_B or exp_A or exp_B)
	begin
		mantissa_B_shifted = (mantissa_B >> (exp_A - exp_B));
	end

	always @(posedge clk or posedge reset) begin
		if(reset) begin
			reg_mantissa_A <= 0;
			reg_mantissa_B_shifted <= 0;
			reg_exp_A <= 0;
			reg_exp_B <= 0;
			reg_sign_A <= 0;
			reg_sign_B <= 0;
		end
		else begin
			reg_mantissa_A <= mantissa_A;
			reg_mantissa_B_shifted <= mantissa_B_shifted;
			reg_exp_A <= exp_A;
			reg_exp_B <= exp_B;
			reg_sign_A <= sign_A;
			reg_sign_B <= sign_B;
		end
		
	end

	// Add the mantissas 
	always @(reg_mantissa_A or reg_mantissa_B_shifted or reg_sign_A or reg_sign_B)
		begin
			if (reg_sign_A == reg_sign_B)
				mantissa_temp = reg_mantissa_A + reg_mantissa_B_shifted;
			else
				mantissa_temp = reg_mantissa_A - reg_mantissa_B_shifted;
		end
	
	// ???
	always @(reg_exp_A or reg_exp_B or mantissa_temp or reg_sign_A or reg_sign_B)
	begin
		if (reg_exp_A == reg_exp_B && mantissa_temp == 0 && reg_sign_A != reg_sign_B)
			exp = 8'b00000000;
		else
			exp = reg_exp_A;
	end

	// Normalize pipelined
	always @(posedge clk or posedge reset) begin
		if (reset == 1'b1) begin
			NORMMEM_mantissa_temp <= 25'b0;
			NORMMEM_exp <= 8'b0;
		end
		else begin
			NORMMEM_mantissa_temp <= mantissa_temp;
			NORMMEM_exp <= exp;
		end
	end

	wire [7:0] normalized_exp;
	wire [22:0] normalized_mantissa;
	fp_normalizer fp_normalizer(.mantissa_temp(mantissa_temp),
								.exp(exp),
								.normalized_mantissa(normalized_mantissa),
								.normalized_exp(normalized_exp));

	// Combine the sign, exponent, and mantissa to form the result
	always @(normalized_exp or normalized_mantissa or A or B or mantissa_temp or exp or reg_sign_A)
	begin
		if (A == 32'b0)
			result = B;
		else if (B == 32'b0)
			result = A;
		else if (mantissa_temp == 0 && exp == 0)
			result = 32'b0;
		else
			result = {reg_sign_A, normalized_exp, normalized_mantissa};
	end

endmodule