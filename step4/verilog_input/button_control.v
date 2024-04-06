module button_control (clk, reset, noisy_level, button_out);

input clk, reset, noisy_level;
output reg button_out;

reg [1:0] next_state, current_state;    // 2-bit state register
reg [23:0] counter;                     // 24-bit counter
reg l2p_in;                             // Level to pulse converter input

parameter [1:0] idle = 2'b00,           // FSM states definitions
                pressed = 2'b01,
                button_high = 2'b10;

// Debouncer: Count 0.1sec each time the button is pressed.
//            If 0.1sec are reached while button is pressed 
//            the debouncer will set its output high until 
//            the button is released 
always @(posedge clk or posedge reset) 
    begin
        if (reset) 
            counter <= 24'b0;        
        else if(noisy_level) 
            begin
                if(counter == 24'd10000000)
                    counter <= 24'd10000000;
                else
                    counter <= counter + 1;
            end
        else
            counter <= 24'b0;
    end

always @(*) begin
    if(counter == 24'd10000000)
        l2p_in = 1'b1;
    else
        l2p_in = 1'b0;
end

// Level to pulse converter: convert debouncer's output to a 
//                           single pulse
always @(posedge clk or posedge reset) begin
    if (reset) 
        current_state <= idle;
    else 
        current_state <= next_state;
end

always @(*) 
    begin
        case (current_state)
        idle: 
            begin
                button_out = 1'b0;
                if (l2p_in == 1'b1) 
                    next_state = pressed;
                else 
                    next_state = idle;
            end
        pressed: 
            begin
                button_out = 1'b1;
                if (l2p_in == 1'b1) 
                    next_state = button_high;
                else 
                    next_state = idle;
            end
        button_high: 
            begin 
                button_out = 1'b0;
                if (l2p_in == 1'b1) 
                    next_state = button_high;
                else 
                    next_state = idle;
            end
        2'b11: 
            begin    //default case
                button_out = 1'b0;
                next_state = idle;
            end
        endcase
    end
endmodule