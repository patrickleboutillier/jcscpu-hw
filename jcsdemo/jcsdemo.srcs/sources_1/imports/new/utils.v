`timescale 1ns / 1ps


module click(input clk, input pbi, output reg click);
    reg cur = 0 ;
    wire deb ;
    debounce debm(clk, pbi, deb) ;
    
    always @(posedge clk) begin
        cur <= deb ;
        if (deb == 0 && cur == 1)
            click <= 1 ;
        else
            click <= 0 ;
    end
endmodule


module debounce(input clk, input pbi, output reg pbo);
    parameter DEBOUNCE_LIMIT = 1000000 ;  // 10 ms at 100 MHz
   
    reg [19:0] count = 0 ;
    always @(posedge clk) begin
        // Switch input is different than internal switch value, so an input is
        // changing.  Increase the counter until it is stable for enough time.  
        if (pbi != pbo && count < DEBOUNCE_LIMIT)
            count <= count + 1 ;
 
        // End of counter reached, switch is stable, register it, reset counter
        else if (count == DEBOUNCE_LIMIT) begin
            pbo <= pbi ;
            count <= 0 ;
        end 
 
        // Switches are the same state, reset the counter
        else begin
            count <= 0 ;
        end
    end
endmodule


module seven_seg_word(input clk, input [31:0] word, output reg [6:0] sseg, output reg [3:0] an, output reg dp) ;
    reg [7:0] led_ascii ;
    reg [19:0] count = 0 ;
    
    always @(posedge clk) begin
        count <= count + 1 ;
    end
    
    wire [1:0] s ;
    assign s = count[19:18] ;
    
    always @(*) begin
        case(s)
            2'b00: begin
                an = 4'b0111 ; 
                led_ascii = word[31:24] ;
            end
            2'b01: begin
                an = 4'b1011 ; 
                led_ascii = word[23:16] ;
            end
            2'b10: begin
                an = 4'b1101 ; 
                led_ascii = word[15:8] ;
            end
            2'b11: begin
                an = 4'b1110 ; 
                led_ascii = word[7:0] ;
            end
        endcase
    end        

    always @(*) begin       
        dp = 1 ;
        case(led_ascii)
            "0":        sseg = 7'b1000000 ; 
            "a":        sseg = 7'b0100000 ; 
            "b":        sseg = 7'b0000011 ;
            "c":        sseg = 7'b0100111 ; 
            "d":        sseg = 7'b0100001 ; 
            "e":        sseg = 7'b0000110 ; 
            "f":        sseg = 7'b0001110 ;
            "h":        sseg = 7'b0001011 ;
            "l":        sseg = 7'b1001111 ; 
            "m":        sseg = 7'b0101010 ; 
            "n":        sseg = 7'b0101011 ; 
            "o":        sseg = 7'b0100011 ; 
            "p":        sseg = 7'b0001100 ; 
            "r":        sseg = 7'b0101111 ;
            "s":        sseg = 7'b0010010 ; 
            "t":        sseg = 7'b0000111 ;
            "u":        sseg = 7'b1100011 ;
            "x":        sseg = 7'b0001001 ; 
            "z":        sseg = 7'b0100100 ; 
            default:    sseg = 7'b1111111 ; // " "
        endcase
    end
endmodule 