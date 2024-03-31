`timescale 1ns/1ps

//LED Decoder: 4-bit LED decoder used to decode each digit to 
//8 signals controlling each segment of the display (+ the decimal point)
module LEDdecoder(char, LED);

input [3:0] char;
output reg [7:0] LED;

always @(char)
begin
    case (char)        
        4'b0000: LED = 8'b11111100;     // 0
        4'b0001: LED = 8'b01100000;     // 1
        4'b0010: LED = 8'b11011010;     // 2   
        4'b0011: LED = 8'b11110010;     // 3
        4'b0100: LED = 8'b01100110;     // 4
        4'b0101: LED = 8'b10110110;     // 5
        4'b0110: LED = 8'b10111110;     // 6
        4'b0111: LED = 8'b11100000;     // 7
        4'b1000: LED = 8'b11111110;     // 8
        4'b1001: LED = 8'b11110110;     // 9
        4'b1010: LED = 8'b11101110;     // A
        4'b1011: LED = 8'b00111110;     // b
        4'b1100: LED = 8'b10011100;     // C
        4'b1101: LED = 8'b01111010;     // d
        4'b1110: LED = 8'b10011110;     // E
        4'b1111: LED = 8'b10001110;     // F
    endcase
end
endmodule

module sevenSegDispDriver(char, an0, an1, LED);

input [7:0] char;
input an0, an1;
output reg [7:0] LED;

wire [7:0] digit1, digit2;
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
        LED = 8'b11111111;
end
endmodule

