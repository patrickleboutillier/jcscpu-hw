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

	reg [3:0] enas, sets ;
	wire ena_click, set_click ;
	click enabtn(CLK, BTNL, ena_click) ;
	click setbtn(CLK, BTNR, set_click) ;	

	always @(posedge CLK) begin
		if (ena_click) 
			enas <= mode ;
		if (set_click) ;
			sets <= mode ;
	end

	
	// The decoders for ena and set will send the signal to the right component
	reg [15:0] ena_dec, set_dec ;
	jdecoder #(4, 16) enadec(enas, ena_dec) ;
	jdecoder #(4, 16) setdec(sets, set_dec) ;

	wire [7:0] bus, acc_bus, tmp_bus, bus1_bus ;
	
    // data
	jenabler dataout(SW[7:0], enadec[0], bus) ;
    
    // r0, r1, r2, r3
	jregister r0(bus, setdec[1], enadec[1], bus) ;
	jregister r1(bus, setdec[2], enadec[2], bus) ;
	jregister r2(bus, setdec[3], enadec[3], bus) ;
	jregister r3(bus, setdec[4], enadec[4], bus) ;
    
	// tmp
	jregister tmp(bus, setdec[5], enadec[5], bus) ;
	
	// bus1
	jbus1 ubus1(tmp_bus, enadec[6], bus1_out) ;	
	
	// alu
    wire alu_co, alu_alo, alu_eqo, alu_z ;
	jALU ualu(bus, bus1_bus, 1'b0, SW[10:8], acc_bus, alu_co, alu_eqo, alu_alo, alu_z) ;
    
	// acc
	jregister acc(acc_bus, setdec[7], enadec[7], bus) ;
	
    // Drive the LEDs (output results), and the 7SD from the word reg.
    reg [31:0] word ;    
    seven_seg_word ssw(CLK, word, SEG, AN, DP) ;
    always @(*) begin
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
