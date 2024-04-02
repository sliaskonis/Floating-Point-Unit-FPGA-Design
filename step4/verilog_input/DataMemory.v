module DataMemory(clk, rst, button, out_a, out_b);

input clk, rst;
input button;
output wire [31:0] out_a, out_b;

parameter NUM = 10;

reg [3:0] count;
reg [NUM-1:0] mem [63:0];

// Memory
always @(posedge clk or posedge rst) begin
    if(rst) begin
        mem[0] <= 64'h3f800000_40000000;
        mem[1] <= 64'hbf800000_3f800000;
        mem[2] <= 64'hc2de8000_45155e00;
        mem[3] <= 64'h6b64b235_6ac49214;
        mem[4] <= 64'h2ac49214_6ac49214;
        mem[5] <= 64'hbfc66666_3fc7ae14;
        mem[6] <= 64'hc565ee8b_4565ee8a;
        mem[7] <= 64'h447a4efa_c47a1ccd;
        mem[8] <= 64'h00000000_00000000;
        mem[9] <= 64'h38108900_bb908900;
    end
end

// Counter
always @(posedge clk or posedge rst) begin
    if(rst)
        count <= 4'b0000;
    else if(button) begin
        if(count == NUM-1)
            count <= 4'b0000;
        else
            count <= count + 4'b0001;
    end
end

assign out_a = mem[count][63:32];
assign out_a = mem[count][31:0];

endmodule