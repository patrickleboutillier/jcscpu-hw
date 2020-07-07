`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/05/2020 08:56:31 PM
// Design Name: 
// Module Name: jcsdemo
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module jcsdemo(
    input CLK, input [15:0] SW, input BTNU, input BTNL, input BTNC, input BTNR,
    output [15:0] LED, output [6:0] SEG, output [3:0] AN, output DP) ;
    
    reg [15:0] r_led = 16'b0 ;
	reg [5:0] mode = 0 ;
	reg [31:0] modes[5:0] ;
    reg [31:0] word ;
	initial begin
		modes[0] = " buf" ;
		modes[1] = " not" ;
		modes[2] = "nand" ;
		modes[3] = " and" ;
		modes[4] = "  or" ;
		modes[5] = " xor" ;
		modes[6] = " add" ;
		modes[7] = " cmp" ;
		modes[8] = "----" ;
	end

    wire mbtn_click ;
    always @(posedge CLK) begin
        if (mbtn_click) begin
        	mode = mode + 1 ;
            if (modes[mode] == "----") begin
                mode = 0 ;
            end
		end
		word = modes[mode] ;
    end

    wire co, eqo, alo, zo ; 
    
    wire ci, eqi, ali ;
    assign ci = BTNL ;
    assign eqi = BTNC ;
    assign ali = BTNR ;
         
    // 0, buf
    wire buf_out ;
    jbuf ubuf(SW[0], buf_out) ;
    
    // 1, not
    wire not_out ;
    jnot unot(SW[0], not_out) ;

    // 2, nand
    wire nand_out ;
    jnand unand(SW[1], SW[0], nand_out) ;
 
    // 3, and
    wire and_out ;
    jand uand(SW[1], SW[0], and_out) ;

    // 4, or
    wire or_out ;
    jor uor(SW[1], SW[0], or_out) ;
    
    // 5, xor
    wire xor_out ;
    jxor uxor(SW[1], SW[0], xor_out) ;

    // 6, add
    wire add_out, add_co ;
    jadd uadd(SW[1], SW[0], ci, add_out, add_co) ;
                 
    always @(posedge CLK) begin
        case (mode)
            0: begin
                r_led[15:1] = 15'b0 ;
                r_led[0] = buf_out ;
            end
            1: begin
                r_led[15:1] = 15'b0 ;
                r_led[0] = not_out ;
            end
            2: begin
                r_led[15:1] = 15'b0 ;
                r_led[0] = nand_out ;
            end
            3: begin
                r_led[15:1] = 15'b0 ;
                r_led[0] = and_out ;
            end
            4: begin
                r_led[15:1] = 15'b0 ;
                r_led[0] = or_out ;
            end
            5: begin
                r_led[15:1] = 15'b0 ;
                r_led[0] = xor_out ;
            end
            6: begin
                r_led[14:1] = 14'b0 ;
                r_led[0] = add_out ;
                r_led[15] = add_co ;
            end
            default: begin
                r_led[15:0] = 16'b0 ;
            end
        endcase
    end
    
    assign LED[15:0] = r_led[15:0] ;
    click cmbtn(CLK, BTNU, mbtn_click) ;
    seven_seg_word ssw(CLK, word, SEG, AN, DP) ;
    
endmodule
