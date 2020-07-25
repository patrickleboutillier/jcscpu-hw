`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: jcsdemo
// https://github.com/patrickleboutillier/jcscpu-hw/
//////////////////////////////////////////////////////////////////////////////////


module jcsbasic(
    input CLK, input [15:0] SW, input BTNU, input BTNL, input BTNC, input BTNR, input BTND,
    output reg [15:0] LED, output [6:0] SEG, output [3:0] AN, output DP) ;
        
	parameter 
	   FIRST=0, 
	   NAND=0, NOT=1, AND=2, OR=3, XOR=4, DEC3=5, ENABLE=6, BUS1=7, LAST=7 ;  
   
        
    // Move to the next mode when nextmode is set.
	reg [3:0] mode = NAND, nextmode = NAND ;
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
    wire BIT1, ENA ;
    assign ENA = BTNL ;
    assign BIT1 = BTNL ;
    
             
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

	// dec3
	wire [7:0] dec3_out ;
	jdecoder #(3, 8) udec(SW[2:0], dec3_out) ;
	
	// ena
	wire [7:0] ena_out ;
	jenabler uenabler(SW[7:0], ENA, ena_out) ;
	
	// bus1
	wire [7:0] bus1_out ;
	jbus1 ubus1(SW[7:0], BIT1, bus1_out) ;

    // Drive the LEDs (output results), and the 7SD from the word reg.
    reg [31:0] word ;    
    seven_seg_word ssw(CLK, word, SEG, AN, DP) ;
    always @(*) begin
        LED[15:8] = 0 ;
        case (mode)
            NAND: begin
                 word = "nand" ;
                LED[7:1] = 0 ;
                LED[0] = nand_out ;
            end
            NOT: begin
                word = " not" ;
                LED[7:1] = 0 ;
                LED[0] = not_out ;
            end
            AND: begin
                word = " and" ;
                LED[7:1] = 0 ;
                LED[0] = and_out ;
            end
            OR: begin
                word = "  or" ;
                LED[7:1] = 0 ;
                LED[0] = or_out ;
            end
            XOR: begin
                word = " xor" ;
                LED[7:1] = 0 ;
                LED[0] = xor_out ;
            end
            DEC3: begin
                word = "dec3" ;
				LED[7:0] = dec3_out ;
            end
            ENABLE: begin
                word = " ena" ;
				LED[7:0] = ena_out ;
            end
            BUS1: begin
                word = "bus1" ;
				LED[7:0] = bus1_out ;
            end
            default: begin
                word = "    " ;
                LED = 0 ;
            end
        endcase
    end
endmodule
