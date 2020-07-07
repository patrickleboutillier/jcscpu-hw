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
    input CLK, input [15:0] SW, input BTNC,
    output [15:0] LED, output [6:0] SEG, output [3:0] AN, output DP) ;
    
    reg [15:0] r_led = 16'b0 ;
	reg [5:0] mode = 0 ;
	reg [31:0] modes[5:0] ;
    reg [31:0] word ;
	initial begin
		modes[0] = "nand" ;
		modes[1] = " not" ;
		modes[2] = " buf" ;
		modes[3] = " and" ;
		modes[4] = "----" ;
	end

    wire btnc_click ;
    always @(posedge CLK) begin
        if (btnc_click) begin
        	mode = mode + 1 ;
            if (modes[mode] == "----") begin
                mode = 0 ;
            end
		end
		word = modes[mode] ;
    end

    // 0, nand
    wire nand_out ;
    jnand unand(SW[1], SW[0], nand_out) ;
    
    // 1, not
    wire not_out ;
    jnot unot(SW[0], not_out) ;
 
    // 2, buf
    wire buf_out ;
    jbuf ubuf(SW[0], buf_out) ;
 
    // 3, and
    wire and_out ;
    jand uand(SW[1], SW[0], and_out) ;
              
    always @(posedge CLK) begin
        case (mode)
            0: begin
                r_led[15:1] = 15'b0 ;
                r_led[0] = nand_out ;
            end
            1: begin
                r_led[15:1] = 15'b0 ;
                r_led[0] = not_out ;
            end
            2: begin
                r_led[15:1] = 15'b0 ;
                r_led[0] = buf_out ;
            end
            3: begin
                r_led[15:1] = 15'b0 ;
                r_led[0] = and_out ;
            end
            default: begin
                r_led[15:0] = 16'b0 ;
            end
        endcase
    end
    
    assign LED[15:0] = r_led[15:0] ;
    click cbtnc(CLK, BTNC, btnc_click) ;
    seven_seg_word ssw(CLK, word, SEG, AN, DP) ;
    
endmodule
