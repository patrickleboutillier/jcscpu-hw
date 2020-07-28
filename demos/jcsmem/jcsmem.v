`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: jcsdemo
// https://github.com/patrickleboutillier/jcscpu-hw/blob/master/jcsdemo/README.md
//////////////////////////////////////////////////////////////////////////////////


module jcsmem(
    input CLK, input [15:0] SW, input BTNU, input BTNL, input BTNC, input BTNR, input BTND,
    output reg [15:0] LED, output [6:0] SEG, output [3:0] AN, output DP) ;
    
	parameter 
	   FIRST=0, 
	   MEM=0, REG=1, RAM=2, LAST=2 ;
    
    // Move to the next mode when nextmode is set.
	reg [3:0] mode = MEM, nextmode = MEM ;
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
    assign SET = BTNR ;
    assign ENA = BTNL ;
	wire ena_deb, set_deb ;
	debounce setbtn(CLK, SET, set_deb) ;	
	debounce enabtn(CLK, ENA, ena_deb) ;	

    wire [15:0] set_dec, ena_dec ;
    decoder4x16 setdec(mode, set_deb, set_dec) ;		
    decoder4x16 enadec(mode, ena_deb, ena_dec) ;
    
    // mem
    wire mem_out ;
    jmemory umem(SW[0], set_dec[MEM], mem_out) ;

    // reg
    wire [7:0] reg_out ;
    jmregister ureg(SW[7:0], set_dec[REG], ena_dec[REG], reg_out) ;    

    // RAM
    wire [7:0] ram_out ;
    jRAM uram(SW[15:8], 1'b1, SW[7:0], set_dec[RAM], ena_dec[RAM], ram_out) ;   
        
    // Drive the LEDs (output results), and the 7SD from the word reg.
    reg [31:0] word ;    
    seven_seg_word ssw(CLK, word, SEG, AN, DP) ;
    always @(*) begin
        case (mode)
            MEM: begin
                LED[15:1] = 0 ;
                LED[0] = mem_out ;
                word = " mem" ;
            end
            REG: begin
                LED[15:8] = 0 ;
                LED[7:0] = reg_out ;
                word = " reg" ;
            end
            RAM: begin
                LED[15:8] = 0 ;
                LED[7:0] = ram_out ;
                word = " ram" ;
            end
        endcase
    end
endmodule

module decoder4x16 (input [3:0] in, input en, output [15:0] out) ;
    assign out = (en) ? (1 << in) : 16'b0 ;
endmodule
