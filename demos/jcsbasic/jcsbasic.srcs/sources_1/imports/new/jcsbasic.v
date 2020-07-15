`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: jcsdemo
// https://github.com/patrickleboutillier/jcscpu-hw/blob/master/jcsdemo/README.md
//////////////////////////////////////////////////////////////////////////////////


module jcsbasic(
    input CLK, input [15:0] SW, input BTNU, input BTNL, input BTNC, input BTNR, input BTND,
    output reg [15:0] LED, output [6:0] SEG, output [3:0] AN, output DP) ;
        
	parameter 
	   FIRST=0, 
	   STEP=0, CLOCK=1, REG=2, ENA=3, MEM=4,
	   BUF=5, NOT=6, NAND=7, AND=8, OR=9, XOR=10, ADD=11, CMP=12, DEC3=13, LAST=13 ;  
    
    
    // jclock frequency (per tick)
    localparam HZ = 2 ;
    
    // Power-on-reset lasts for 1 halfqtick, in order to initialize the stepper properly.
    reg reset = 1 ;
    integer count = 0 ;
    localparam halfqtick = (100000000 / HZ) / 2 ;
    localparam max = 3 * halfqtick ; 
    always @(posedge CLK) begin
        if (reset == 1 && count == max - 1) 
            reset <= 0 ;
        else
            count <= count + 1 ;
    end
    
    
    // Move to the next mode when nextmode is set.
	reg [3:0] mode = BUF, nextmode = BUF ;
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
    assign SET = BTNL ;
    assign ENA = BTNR ;
    
    // 1 HZ clock, slow so that we can see each tick with the LEDs
    wire clk_in ;
    genclock #(HZ) gc(CLK, clk_in) ;
       
    // clock
    wire clk_out, clkd_out, clke_out, clks_out ;
    jclock uclock(clk_in, reset, clk_out, clkd_out, clke_out, clks_out) ; 
    
    // step
    wire [0:5] stp_out ;
    jstepper ustepper(clk_out, 1'b0, stp_out) ; 

    // ena
    wire [7:0] ena_out ;
    jenabler uena(SW[7:0], ENA, ena_out) ;

    // reg
    wire [7:0] reg_out ;
    jregister ureg(SW[7:0], SET, ENA, reg_out) ;
    
    // mem
    wire mem_out ;
    jmemory umemory(SW[0], SET, mem_out) ;
             
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

	// dec3
	wire [7:0] dec3_out ;
	jdecoder #(3, 8) udec(SW[2:0], dec3_out) ;

    // Drive the LEDs (output results), and the 7SD from the word reg.
    reg [31:0] word ;    
    seven_seg_word ssw(CLK, word, SEG, AN, DP) ;
    always @(*) begin
        // word = text[mode] ;
        case (mode)
             STEP: begin
                word = "step" ;
                LED[15:10] = stp_out ;
                LED[9:4] = 0 ;
                LED[3:0] = {clk_out, clkd_out, clke_out, clks_out} ;
            end
            CLOCK: begin
                word = " clk" ;
                LED[15:4] = 0 ;
                LED[3:0] = {clk_out, clkd_out, clke_out, clks_out} ;
            end
            ENA: begin
                word = " ena" ;
                LED[15:8] = 0 ;
				LED[7:0] = ena_out ;
            end
            REG: begin
                word = " reg" ;
                LED[15:8] = 0 ;
                LED[7:0] = reg_out ;
            end
            MEM: begin
                word = " mem" ;
                LED[15:1] = 0 ;
                LED[0] = mem_out ;
            end
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
            DEC3: begin
                word = "dec3" ;
				LED[15:8] = 0 ;
				LED[7:0] = dec3_out ;
            end
            default: begin
                word = "    " ;
                LED = 0 ;
            end
        endcase
    end
endmodule
