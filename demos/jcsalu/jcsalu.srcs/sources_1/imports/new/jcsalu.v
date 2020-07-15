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
	   STEP=0, CLOCK=1, REG=2, MEM=3,
	   BUF=4, NOT=5, NAND=6, AND=7, OR=8, XOR=9, ADD=10, CMP=11, LAST=11 ;  
    
    // Move to the next mode when nextmode is set.
	reg [5:0] mode = BUF, nextmode = BUF ;
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
    
    // shr
    wire [7:0] shr_out ;
    wire shr_co ;
    jshiftr ushr(SW[7:0], CI, shr_out, shr_co) ;

    // shl
    wire [7:0] shl_out ;
    wire shl_co ;
    jshiftl ushl(SW[7:0], CI, shl_out, shl_co) ;

    // notr
    wire [7:0] notr_out ;
    jnotter unotter(SW[7:0], notr_out) ;
    
    // andr
    wire [7:0] andr_out ;
    jandder uandder(SW[15:8], SW[7:0], andr_out) ;

    // orr
    wire [7:0] orr_out ;
    jorer uorer(SW[15:8], SW[7:0], orr_out) ;

    // xorr
    wire [7:0] xorr_out ;
	wire xorr_eqo, xorr_alo ;
    jxorer uxorer(SW[15:8], SW[7:0], xorr_out, xorr_eqo, xorr_alo) ;
        
    // addr
    wire [7:0] addr_out ;
	wire addr_co ;
    jadder uadder(SW[15:8], SW[7:0], CI, addr_out, addr_co) ;

    // zero
	wire zero_out ;
    jzero uzero(SW[7:0], zero_out) ;

    // bus1
	wire [7:0] bus1_out ;
    jbus1 ubus1(SW[7:0], CI, bus1_out) ;

    // Drive the LEDs (output results), and the 7SD from the word reg.
    reg [31:0] word ;    
    seven_seg_word ssw(CLK, word, SEG, AN, DP) ;
    always @(*) begin
        // word = text[mode] ;
        case (mode)
            SHR: begin
                word = " shr" ;
                LED[15] = shr_co ;
                LED[14:8] = 0 ;
                LED[7:0] = shr_out ;
            end
            SHL: begin
                word = " shl" ;
                LED[15] = shl_co ;
                LED[14:8] = 0 ;
                LED[7:0] = shl_out ;
            end
            NOTR: begin
                word = "notr" ;
                LED[15:8] = 0 ;
                LED[7:0] = notr_out ;
            end
            ANDR: begin
                word = "andr" ;
                LED[15:8] = 0 ;
                LED[7:0] = andr_out ;
            end
            ORR: begin
                word = " orr" ;
                LED[15:8] = 0 ;
                LED[7:0] = orr_out ;
            end
            XORR: begin
                word = "xorr" ;
                LED[15:12] = {1'b0, xorr_alo, xorr_eqo, 1'b0} ;
                LED[11:8] = 0 ;
                LED[7:0] = xorr_out ;
            end
            ADDR: begin
                word = "addr" ;
                LED[15:12] = {addr_co, 3'b000} ;
                LED[11:8] = 0 ;
                LED[7:0] = addr_out ;
            end
            ZERO: begin
                word = "zero" ;
                LED[15:12] = {3'b000, zero_out} ;
                LED[11:0] = 0 ;
            end
            BUS1: begin
                word = "bus1" ;
                LED[15:8] = 0 ;
                LED[7:0] = bus1_out ;
            end
            default: begin
                word = "    " ;
                LED = 0 ;
            end
        endcase
    end
endmodule
