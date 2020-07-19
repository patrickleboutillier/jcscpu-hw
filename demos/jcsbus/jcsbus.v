`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: jcsdemo
// https://github.com/patrickleboutillier/jcscpu-hw/
//////////////////////////////////////////////////////////////////////////////////


module jcsbus(
    input CLK, input [15:0] SW, input BTNU, input BTNL, input BTNC, input BTNR, input BTND,
    output reg [15:0] LED, output [6:0] SEG, output [3:0] AN, output DP) ;
    
	parameter 
	   FIRST=1, 
	   DATA=1, R0=2, R1=3, R2=4, R3=5, TMP=6, ACC=7, LAST=7 ;
    
    // Move to the next mode when nextmode is set.
    reg [3:0] mode = DATA, nextmode = DATA ;
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
    
    assign SET = BTNR ;
    
	reg [3:0] enas ;
	wire ena_click, set_deb ;
	click enabtn(CLK, BTNL, ena_click) ;
	debounce setbtn(CLK, BTNR, set_deb) ;	
	always @(posedge CLK) begin
		if (ena_click) 
			enas <= mode ;
	end

	
	// The decoders for ena and set will send the signal to the right component.
	// Using a case-based decoder (instead of a jdecoder) helps the tool figure out what we are trying to do. 
	wire [15:0] ena_dec, set_dec ;
	decoder4x16 enadec(enas, 1'b1, ena_dec) ;
	decoder4x16 setdec(mode, set_deb, set_dec) ;

    wor [7:0] bus ;
	wire [7:0] acc_bus, tmp_bus, bus1_bus ;
	
    // data
	jenabler dataout(SW[7:0], ena_dec[DATA], bus) ;
    
    // r0, r1, r2, r3
	jregister r0(bus, set_dec[R0], ena_dec[R0], bus) ;
	jregister r1(bus, set_dec[R1], ena_dec[R1], bus) ;
	jregister r2(bus, set_dec[R2], ena_dec[R2], bus) ;
	jregister r3(bus, set_dec[R3], ena_dec[R3], bus) ;
    
	// tmp
	jregister tmp(bus, set_dec[TMP], 1'b1, tmp_bus) ;
	
	// bus1
	jbus1 bus1(tmp_bus, 1'b0, bus1_bus) ;	
	
	// alu
    wire alu_co, alu_alo, alu_eqo, alu_z ;
	jALU ualu(bus, bus1_bus, 1'b0, SW[15:13], acc_bus, alu_co, alu_eqo, alu_alo, alu_z) ;
    
	// acc
	jregister acc(acc_bus, set_dec[ACC], ena_dec[ACC], bus) ;
	
    // Drive the LEDs (output results), and the 7SD from the word reg.
    reg [31:0] word ;    
    seven_seg_word ssw(CLK, word, SEG, AN, DP) ;
    always @(*) begin
        LED[15] = 0 ;
        LED[13:11] = 0 ;
        LED[9:8] = 0 ;
        LED[7:0] = bus ;
        case (mode)
            DATA: begin
                word = "data" ;
                LED[14] = ena_dec[DATA] ;
                LED[10] = set_dec[DATA] ;
            end
            R0: begin
                word = "  r0" ;
                LED[14] = ena_dec[R0] ;
                LED[10] = set_dec[R0] ;
            end
            R1: begin
                word = "  r1" ;
                LED[14] = ena_dec[R1] ;
                LED[10] = set_dec[R1] ;
            end
            R2: begin
                word = "  r2" ;
                LED[14] = ena_dec[R2] ;
                LED[10] = set_dec[R2] ;
            end
            R3: begin
                word = "  r3" ;
                LED[14] = ena_dec[R3] ;
                LED[10] = set_dec[R3] ;
            end
            TMP: begin
                word = " tmp" ;
                LED[14] = ena_dec[TMP] ;
                LED[10] = set_dec[TMP] ;
            end
            ACC: begin
                word = " acc" ;
                LED[10] = ena_dec[ACC] ;
                LED[10] = set_dec[ACC] ;
            end
            default: begin
                word = "    " ;
                LED = 0 ;
            end
        endcase
    end
endmodule


module decoder4x16 (input [3:0] in, input en, output [15:0] out) ;
    assign out = (en) ? (1 << in) : 16'b0 ;
endmodule