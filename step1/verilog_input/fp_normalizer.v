module fp_normalizer (
  input [23:0] mantissa_temp,
  input [7:0] exp,
  output reg [23:0] normalized_mantissa,
  output reg [7:0] normalized_exp
);

  always @(mantissa_temp, exp) begin
    case (mantissa_temp)
      24'b1xxxxxxxxxxxxxxxxxxxxxx: begin
        normalized_mantissa = mantissa_temp;
        normalized_exp = exp;
      end
      24'b01xxxxxxxxxxxxxxxxxxxxx: begin
        normalized_mantissa = {mantissa_temp[22:0], 1'd0};
        normalized_exp = exp - 1;
      end
      24'b001xxxxxxxxxxxxxxxxxxxx: begin
        normalized_mantissa = {mantissa_temp[21:0], 2'd0};
        normalized_exp = exp - 2;
      end
      24'b0001xxxxxxxxxxxxxxxxxxx: begin
        normalized_mantissa = {mantissa_temp[20:0], 3'd0};
        normalized_exp = exp - 3;
      end
      24'b00001xxxxxxxxxxxxxxxxxx: begin
        normalized_mantissa = {mantissa_temp[19:0], 4'd0};
        normalized_exp = exp - 4;
      end
      24'b000001xxxxxxxxxxxxxxxxx: begin
        normalized_mantissa = {mantissa_temp[18:0], 5'd0};
        normalized_exp = exp - 5;
      end
      24'b0000001xxxxxxxxxxxxxxxx: begin
        normalized_mantissa = {mantissa_temp[17:0], 6'd0};
        normalized_exp = exp - 6;
      end
      24'b00000001xxxxxxxxxxxxxxx: begin
        normalized_mantissa = {mantissa_temp[16:0], 7'd0};
        normalized_exp = exp - 7;
      end
      24'b000000001xxxxxxxxxxxxxx: begin
        normalized_mantissa = {mantissa_temp[15:0], 8'd0};
        normalized_exp = exp - 8;
      end
      24'b0000000001xxxxxxxxxxxxx: begin
        normalized_mantissa = {mantissa_temp[14:0], 9'd0};
        normalized_exp = exp - 9;
      end
      24'b00000000001xxxxxxxxxxxx: begin
        normalized_mantissa = {mantissa_temp[13:0], 10'd0};
        normalized_exp = exp - 10;
      end
      24'b000000000001xxxxxxxxxxx: begin
        normalized_mantissa = {mantissa_temp[12:0], 11'd0};
        normalized_exp = exp - 11;
      end
      24'b0000000000001xxxxxxxxxx: begin
        normalized_mantissa = {mantissa_temp[11:0], 12'd0};
        normalized_exp = exp - 12;
      end
      24'b00000000000001xxxxxxxxx: begin
        normalized_mantissa = {mantissa_temp[10:0], 13'd0};
        normalized_exp = exp - 13;
      end
      24'b000000000000001xxxxxxxx: begin
        normalized_mantissa = {mantissa_temp[9:0], 14'd0};
        normalized_exp = exp - 14;
      end
      24'b0000000000000001xxxxxxx: begin
        normalized_mantissa = {mantissa_temp[8:0], 15'd0};
        normalized_exp = exp - 15;
      end
      24'b00000000000000001xxxxxx: begin
        normalized_mantissa = {mantissa_temp[7:0], 16'd0};
        normalized_exp = exp - 16;
      end
      24'b000000000000000001xxxxx: begin
        normalized_mantissa = {mantissa_temp[6:0], 17'd0};
        normalized_exp = exp - 17;
      end
      24'b0000000000000000001xxxx: begin
        normalized_mantissa = {mantissa_temp[5:0], 18'd0};
        normalized_exp = exp - 18;
      end
      24'b00000000000000000001xxx: begin
        normalized_mantissa = {mantissa_temp[4:0], 19'd0};
        normalized_exp = exp - 19;
      end
      24'b000000000000000000001xx: begin
        normalized_mantissa = {mantissa_temp[3:0], 20'd0};
        normalized_exp = exp - 20;
      end
      24'b0000000000000000000001x: begin
        normalized_mantissa = {mantissa_temp[2:0], 21'd0};
        normalized_exp = exp - 21;
      end
      24'b00000000000000000000001: begin
        normalized_mantissa = {mantissa_temp[1:0], 22'd0};
        normalized_exp = exp - 22;
      end
      24'b00000000000000000000000: begin
        normalized_mantissa = mantissa_temp;
        normalized_exp = exp;
      end
      //default:
      //begin
      //  normalized_mantissa = 24'b0000000000;
      //  normalized_exp = 8'd0;
      //end
    endcase
  end
      



endmodule
