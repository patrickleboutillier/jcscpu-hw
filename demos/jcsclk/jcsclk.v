`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: jcsdemo
// https://github.com/patrickleboutillier/jcscpu-hw/blob/master/jcsdemo/README.md
//////////////////////////////////////////////////////////////////////////////////


module jcsclk(
    input CLK, input [15:0] SW, input BTNU, input BTNL, input BTNC, input BTNR, input BTND,
    output reg [15:0] LED, output [6:0] SEG, output [3:0] AN, output DP) ;
    
	parameter 
	   FIRST=0, 
	   CLOCK=0, STEP=1, LAST=1 ;
    
    // Move to the next mode when nextmode is set.
	reg [5:0] mode = CLOCK, nextmode = CLOCK ;
    always @(posedge CLK) begin
        mode <= nextmode ;
    end
    
    // Each click moves to the next mode. The name of the mode is displayed on the 7SD.
    wire nmbtn_click, pmbtn_click ;
    click cpmbtn(CLK, BTNU, pmbtn_click) ;
    click cnmbtn(CLK, BTND, nmbtn_click) ;
    always @(posedge CLK) begin
        if (pmbtn_click && (mode > FIRST)) begin
            nextmode <= mode - 1 ;
        end else if (nmbtn_click && (mode < LAST)) begin
        	nextmode <= mode + 1 ;
		end 
    end
  

    // clk
    wire sclk, clk, clkd, clke, clks ;
    genclock #(2) clkHZ(CLK, sclk) ;
    jclock localclk(sclk, 1'b0, clk, clkd, clke, clks) ;
    
    // step
    wire [0:5] step_out ;
    jstepper ustepper(clk, 1'b0, step_out) ;
        
    // Drive the LEDs (output results), and the 7SD from the word reg.
    reg [31:0] word ;    
    seven_seg_word ssw(CLK, word, SEG, AN, DP) ;
    always @(*) begin
        case (mode)
            CLOCK: begin
                LED[15:4] = 0 ;
                LED[3:0] = {clk, clkd, clke, clks} ;
                word = " clk" ;
            end
            STEP: begin
                LED[15:10] = step_out ;
                LED[9:4] = 0 ;
                LED[3:0] = {clk, clkd, clke, clks} ;
                word = "step" ;
            end
            default: begin
                word = "    " ;
                LED = 0 ;
            end
        endcase
    end
endmodule
