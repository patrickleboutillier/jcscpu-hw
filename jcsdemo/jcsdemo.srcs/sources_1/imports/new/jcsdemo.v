`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: jcsdemo
// https://github.com/patrickleboutillier/jcscpu-hw/blob/master/jcsdemo/README.md
//////////////////////////////////////////////////////////////////////////////////


module jcsdemo(
    input CLK, input [15:0] SW, input BTNU, input BTNL, input BTNC, input BTNR,
    output [15:0] LED, output [6:0] SEG, output [3:0] AN, output DP) ;
    
    reg [31:0] text[5:0] ;
	parameter BUF=0, NOT=1, NAND=2, AND=3, OR=4, XOR=5, ADD=6, CMP=7, END=8 ;  
	initial begin
		text[BUF]     = " buf" ;
		text[NOT]     = " not" ;
		text[NAND]    = "nand" ;
		text[AND]     = " and" ;
		text[OR]      = "  or" ;
		text[XOR]     = " xor" ;
		text[ADD]     = " add" ;
		text[CMP]     = " cmp" ;
	end
	
	reg [5:0] mode = 0, nextmode = 0 ;
    always @(posedge CLK) begin
        mode <= nextmode ;
    end
    
    // Each click moves to the next mode. The name of the mode is displayed on the 7SD.
    wire mbtn_click ;
    click cmbtn(CLK, BTNU, mbtn_click) ;
    always @(posedge CLK) begin
        if (mbtn_click) begin
        	nextmode = mode + 1 ;
            if (nextmode == END) begin
                nextmode = 0 ;
            end
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


    // Drive the LEDs (output results) from the r_led array. 
    reg [15:0] r_led = 0 ;
    assign LED = r_led ;
    // Drive 7SD from word.
    reg [31:0] word ;    
    seven_seg_word ssw(CLK, word, SEG, AN, DP) ;
    always @(mode) begin
        word = text[mode] ;
        case (mode)
            BUF: begin
                r_led[15:1] = 0 ;
                r_led[0] = buf_out ;
            end
            NOT: begin
                r_led[15:1] = 0 ;
                r_led[0] = not_out ;
            end
            NAND: begin
                r_led[15:1] = 0 ;
                r_led[0] = nand_out ;
            end
            AND: begin
                r_led[15:1] = 0 ;
                r_led[0] = and_out ;
            end
            OR: begin
                r_led[15:1] = 0 ;
                r_led[0] = or_out ;
            end
            XOR: begin
                r_led[15:1] = 0 ;
                r_led[0] = xor_out ;
            end
            ADD: begin
                r_led[15:12] = {add_co, 3'b000} ;
                r_led[11:1] = 0 ;
                r_led[0] = add_out ;
            end
            CMP: begin
                r_led[15:12] = {1'b0, cmp_alo, cmp_eqo, 1'b0} ;
                r_led[11:1] = 0 ;
                r_led[0] = cmp_out ;
            end
            default: begin
                r_led = 0 ;
            end
        endcase
    end
endmodule
