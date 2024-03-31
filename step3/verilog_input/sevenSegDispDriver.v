`timescale 1ns/1ps

//LED Decoder: 4-bit LED decoder used to decode each digit to 
//8 signals controlling each segment of the display (+ the decimal point)
module LEDdecoder(char, LED);

input [3:0] char;
output reg [6:0] LED;

always @(char)
begin
    case (char)        
        4'b0000: LED = 7'b1111110;     // 0
        4'b0001: LED = 7'b0110000;     // 1
        4'b0010: LED = 7'b1101101;     // 2   
        4'b0011: LED = 7'b1111001;     // 3
        4'b0100: LED = 7'b0110011;     // 4
        4'b0101: LED = 7'b1011011;     // 5
        4'b0110: LED = 7'b1011111;     // 6
        4'b0111: LED = 7'b1110000;     // 7
        4'b1000: LED = 7'b1111111;     // 8
        4'b1001: LED = 7'b1111011;     // 9
        4'b1010: LED = 7'b1110111;     // A
        4'b1011: LED = 7'b0011111;     // b
        4'b1100: LED = 7'b1001110;     // C
        4'b1101: LED = 7'b0111101;     // d
        4'b1110: LED = 7'b1001111;     // E
        4'b1111: LED = 7'b1000111;     // F
    endcase
end
endmodule

module sevenSegDispDriver(char, an0, an1, LED);

input [7:0] char;
input an0, an1;
output reg [6:0] LED;

wire [6:0] digit1, digit2;
wire [3:0] char0, char1;

assign char0 = char[7:4];
assign char1 = char[3:0];

LEDdecoder LEDdecoder0(char0, digit1);
LEDdecoder LEDdecoder1(char1, digit2);

always @(an0 or an1 or digit1 or digit2)
begin
    if (an0 == 0)
        LED = digit1;
    else if (an1 == 0)
        LED = digit2;
    else
        LED = 7'b1111111;
end
endmodule

