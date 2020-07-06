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


    // reg r_btnc = 0 ;

    //wire btnc_deb ;
    //debounce debc(CLK, BTNC, btnc_deb) ;

    //always @(posedge CLK) begin
    //    r_btnc <= btnc_deb ;
    //    if (btnc_deb == 0 && r_btnc == 1) begin
    //        r_led[0] <= ~r_led[0] ;
    //    end
    //end
    
    reg [15:0] r_led = 16'b0 ;
	reg [5:0] mode = 0 ;
	reg [31:0] modes[5:0] ;
    reg [31:0] word ;
	initial begin
		modes[0] = "nand" ;
		modes[1] = " not" ;
		modes[2] = " and" ;
		modes[3] = "----" ;
	end

    wire btnc_click ;
    always @(posedge CLK) begin
        if (btnc_click) begin
        	mode = mode + 1 ;
            if (modes[mode] == "----") begin
                mode = 0 ;
            end
			            
            //if (r_led[0] == 0) begin
               // r_led[0] = 1 ;
                //word <= "   1" ;
            //end else begin
               // r_led[0] = 0 ;
                //word <= "   0" ;
            //end
		end
		word = modes[mode] ;
    end

    // 0, nand
    wire nand_out ;
    // jnand unand(SW[1], SW[0], and_out) ;
    
    always @(posedge CLK) begin
        case (mode)
            0: begin
                r_led[15:1] = 15'b0 ;
                r_led[0] = ! (SW[0] & SW[1]) ; // and_out ;
            end
            1: begin
                r_led[15:1] = 15'b0 ;
                r_led[0] = ! SW[0] ;
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
