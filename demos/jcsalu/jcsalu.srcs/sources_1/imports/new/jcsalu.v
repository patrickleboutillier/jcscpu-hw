`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: jcsdemo
// https://github.com/patrickleboutillier/jcscpu-hw/blob/master/jcsdemo/README.md
//////////////////////////////////////////////////////////////////////////////////


module jcsalu(
    input CLK, input [15:0] SW, input BTNU, input BTNL, input BTNC, input BTNR, input BTND,
    output reg [15:0] LED, output [6:0] SEG, output [3:0] AN, output DP) ;
    
	parameter 
	   FIRST=0, 
       ADDR=0, SHR=1, SHL=2, NOTR=3, ANDR=4, ORR=5, XORR=6, ZERO=7, BUS1=8, LAST=8 ;
    
    // Move to the next mode when nextmode is set.
	reg [5:0] mode = ADDR, nextmode = ADDR ;
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


    // Aliases for push buttons
    wire CI, EQI, ALI ;
    assign CI = BTNL ;
    assign ALI = BTNC ;
    assign EQI = BTNR ;

	reg [2:0] ops = 0 ;
	wire alu_co, alu_eqo, alu_alo, alu_z ;
	jALU x(SW[7:0], SW[15:8], CI, ops, LED[7:0], alu_co, alu_eqo, alu_alo, alu_z) ;


    // Drive the LEDs (output results), and the 7SD from the word reg.
    reg [31:0] word ;    
    seven_seg_word ssw(CLK, word, SEG, AN, DP) ;
    always @(*) begin
		ops = mode ;
		LED[15:12] = {alu_co, alu_eqo, alu_alo, alu_z} ;
		LED[11:9] = ops ;
		LED[8] = 0 ;
	    case (mode)
            ADDR: begin
                word = "addr" ;
            end
            SHR: begin
                word = " shr" ;
            end
            SHL: begin
                word = " shl" ;
            end
            NOTR: begin
                word = "notr" ;
            end
            ANDR: begin
                word = "andr" ;
            end
            ORR: begin
                word = " orr" ;
            end
            XORR: begin
                word = "xorr" ;
            end
            default: begin
                word = "    " ;
                LED = 0 ;
            end
        endcase
    end
endmodule
