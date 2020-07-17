`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: jcsdemo
// https://github.com/patrickleboutillier/jcscpu-hw/
//////////////////////////////////////////////////////////////////////////////////


module jcsbus(
    input CLK, input [15:0] SW, input BTNU, input BTNL, input BTNC, input BTNR, input BTND,
    output reg [15:0] LED, output [6:0] SEG, output [3:0] AN, output DP) ;
    
	parameter 
	   FIRST=0, 
	   DATA=0, R0=1, R1=2, R2=3, R3=4, TMP=5, BUS1=6, ACC=7, LAST=7 ;
    
    // Move to the next mode when nextmode is set.
	  reg [3:0] mode = ADDR, nextmode = ADDR ;
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
    wire ENA, SET ;
    assign ENA = BTNL ;
    assign SET = BTNR ;
    
    wire [7:0] bus ;
    reg [15:0] mdec_out ;
    jdecoder #(4, 16) mdec(mode, mdec_out) ;
    
    // data
    wire datae ;
    jenabler dataout(SW[7:0], datae, bus) ;
    jena dataena(ENA, mdec_out[0], datae) ;
    
    // r0
    wire r0e, r0s ;
    jregister r0(bus, r0s, r0e, bus) ;
    jena r0ena(ENA, mdec_out[1], r0e) ;
    jena r0set(SET, mdec_out[1], r0s) ;
    
    /*
    reg [2:0] ops = 0 ;
    wire [7:0] alu_out ;
    wire alu_co, alu_alo, alu_eqo, alu_z ;
    jALU ualu(SW[7:0], SW[15:8], CI, ops, alu_out, alu_co, alu_eqo, alu_alo, alu_z) ;
    */
    
    // Drive the LEDs (output results), and the 7SD from the word reg.
    reg [31:0] word ;    
    seven_seg_word ssw(CLK, word, SEG, AN, DP) ;
    always @(*) begin
        ops = mode ;
        // LED[15:12] = {alu_co, alu_alo, alu_eqo, alu_z} ;
        // LED[11] = 0 ;
        LED[10:8] = SW[10:8] ;
        LED[7:0] = bus ;
        case (mode)
            DATA: begin
                word = "data" ;
            end
            R0: begin
                word = "  r0" ;
            end
            default: begin
                word = "    " ;
                LED = 0 ;
            end
        endcase
    end
endmodule
