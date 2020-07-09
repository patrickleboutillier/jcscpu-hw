`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: jcsdemo
// https://github.com/patrickleboutillier/jcscpu-hw/blob/master/jcsdemo/README.md
//////////////////////////////////////////////////////////////////////////////////


module jcsdemo(
    input CLK, input [15:0] SW, input BTNU, input BTNL, input BTNC, input BTNR, input BTND,
    output reg [15:0] LED, output [6:0] SEG, output [3:0] AN, output DP) ;
    
	parameter 
	   FIRST=10, 
	   BUF=10, NOT=11, NAND=12, AND=13, OR=14, XOR=15, ADD=16, CMP=17, SHR=18, SHL=19, LAST=19 ;  
    
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
         
    // buf
    wire buf_out ;
    jbuf ubuf(SW[0], buf_out) ;
    
    // not
    wire not_out ;
    jnot unot(SW[0], not_out) ;

    // nand
    wire nand_out ;
    jnand unand(SW[1], SW[0], nand_out) ;
 
    // and
    wire and_out ;
    jand uand(SW[1], SW[0], and_out) ;

    // or
    wire or_out ;
    jor uor(SW[1], SW[0], or_out) ;
    
    // xor
    wire xor_out ;
    jxor uxor(SW[1], SW[0], xor_out) ;

    // add
    wire add_out, add_co ;
    jadd uadd(SW[1], SW[0], CI, add_out, add_co) ;

    // cmp
    wire cmp_out, cmp_eqo, cmp_alo ;
    jcmp ucmp(SW[1], SW[0], EQI, ALI, cmp_out, cmp_eqo, cmp_alo) ;

    // shr
    wire [7:0] shr_out ;
    wire shr_co ;
    jshiftr ushr(SW[7:0], CI, shr_out, shr_co) ;

    // shl
    wire [7:0] shl_out ;
    wire shl_co ;
    jshiftl ushl(SW[7:0], CI, shl_out, shl_co) ;
        
    // Drive the LEDs (output results), and the 7SD from the word reg.
    reg [31:0] word ;    
    seven_seg_word ssw(CLK, word, SEG, AN, DP) ;
    always @(*) begin
        // word = text[mode] ;
        case (mode)
            BUF: begin
                word = " buf" ;
                LED[15:1] = 0 ;
                LED[0] = buf_out ;
            end
            NOT: begin
                word = " not" ;
                LED[15:1] = 0 ;
                LED[0] = not_out ;
            end
            NAND: begin
                 word = "nand" ;
                LED[15:1] = 0 ;
                LED[0] = nand_out ;
            end
            AND: begin
                word = " and" ;
                LED[15:1] = 0 ;
                LED[0] = and_out ;
            end
            OR: begin
                word = "  or" ;
                LED[15:1] = 0 ;
                LED[0] = or_out ;
            end
            XOR: begin
                word = " xor" ;
                LED[15:1] = 0 ;
                LED[0] = xor_out ;
            end
            ADD: begin
                word = " add" ;
                LED[15:12] = {add_co, 3'b000} ;
                LED[11:1] = 0 ;
                LED[0] = add_out ;
            end
            CMP: begin
                word = " cmp" ;
                LED[15:12] = {1'b0, cmp_alo, cmp_eqo, 1'b0} ;
                LED[11:1] = 0 ;
                LED[0] = cmp_out ;
            end
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
            default: begin
                word = "    " ;
                LED = 0 ;
            end
        endcase
    end
endmodule
