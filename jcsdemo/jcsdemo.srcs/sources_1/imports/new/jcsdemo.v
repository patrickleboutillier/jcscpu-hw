`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: jcsdemo
// https://github.com/patrickleboutillier/jcscpu-hw/blob/master/jcsdemo/README.md
//////////////////////////////////////////////////////////////////////////////////


module jcsdemo(
    input CLK, input [15:0] SW, input BTNU, input BTNL, input BTNC, input BTNR, input BTND,
    output reg [15:0] LED, output [6:0] SEG, output [3:0] AN, output DP) ;
    
	parameter 
	   FIRST=6, 
	   CLOCK=6, RAM=7, REG=8, MEM=9,
	   BUF=10, NOT=11, NAND=12, AND=13, OR=14, XOR=15, ADD=16, CMP=17, 
       SHR=18, SHL=19, NOTR=20, ANDR=21, ORR=22, XORR=23, 
	   ADDR=24, ZERO=25, BUS1=26, LAST=26 ;  
    
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
    assign SET = BTNL ;
    assign SETA = BTNC ;
    assign ENA = BTNR ;
    
    // 1 HZ clock, slow so that we can see each tick with the LEDs
    wire clk_in ;
    genclock #(1) gc(CLK, clk_in) ;
    
    // clock
    wire clk_out, clkd_out, clke_out, clks_out ;
    jclock uclock(clk_in, clk_out, clkd_out, clke_out, clks_out) ; 
    
    // RAM
    wire [7:0] ram_io, ram_out ;
    reg [7:0] ram_in ;
    assign ram_out = ram_io ;
    assign ram_io = (SET) ? SW[7:0] : 8'bzzzzzzzz ;
    jRAM uram(SW[15:8], SETA, ram_io, SET, ENA) ;

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

    // shr
    wire [7:0] shr_out ;
    wire shr_co ;
    jshiftr ushr(SW[7:0], CI, shr_out, shr_co) ;

    // shl
    wire [7:0] shl_out ;
    wire shl_co ;
    jshiftl ushl(SW[7:0], CI, shl_out, shl_co) ;

    // notr
    wire [7:0] notr_out ;
    jnotter unotter(SW[7:0], notr_out) ;
    
    // andr
    wire [7:0] andr_out ;
    jandder uandder(SW[15:8], SW[7:0], andr_out) ;

    // orr
    wire [7:0] orr_out ;
    jorer uorer(SW[15:8], SW[7:0], orr_out) ;

    // xorr
    wire [7:0] xorr_out ;
	wire xorr_eqo, xorr_alo ;
    jxorer uxorer(SW[15:8], SW[7:0], xorr_out, xorr_eqo, xorr_alo) ;
        
    // addr
    wire [7:0] addr_out ;
	wire addr_co ;
    jadder uadder(SW[15:8], SW[7:0], CI, addr_out, addr_co) ;

    // zero
	wire zero_out ;
    jzero uzero(SW[7:0], zero_out) ;

    // zero
	wire [7:0] bus1_out ;
    jbus1 ubus1(SW[7:0], CI, bus1_out) ;

    // Drive the LEDs (output results), and the 7SD from the word reg.
    reg [31:0] word ;    
    seven_seg_word ssw(CLK, word, SEG, AN, DP) ;
    always @(*) begin
        // word = text[mode] ;
        case (mode)
            RAM: begin
                word = " ram" ;
                LED[15:8] = 0 ;
                LED[7:0] = ram_out ;
            end
            CLOCK: begin
                word = " clk" ;
                LED[15:4] = 0 ;
                LED[3:0] = {clk_out, clkd_out, clke_out, clks_out} ;
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
            NOTR: begin
                word = "notr" ;
                LED[15:8] = 0 ;
                LED[7:0] = notr_out ;
            end
            ANDR: begin
                word = "andr" ;
                LED[15:8] = 0 ;
                LED[7:0] = andr_out ;
            end
            ORR: begin
                word = " orr" ;
                LED[15:8] = 0 ;
                LED[7:0] = orr_out ;
            end
            XORR: begin
                word = "xorr" ;
                LED[15:12] = {1'b0, xorr_alo, xorr_eqo, 1'b0} ;
                LED[11:8] = 0 ;
                LED[7:0] = xorr_out ;
            end
            ADDR: begin
                word = "addr" ;
                LED[15:12] = {addr_co, 3'b000} ;
                LED[11:8] = 0 ;
                LED[7:0] = addr_out ;
            end
            ZERO: begin
                word = "zero" ;
                LED[15:12] = {3'b000, zero_out} ;
                LED[11:0] = 0 ;
            end
            BUS1: begin
                word = "bus1" ;
                LED[15:8] = 0 ;
                LED[7:0] = bus1_out ;
            end
            default: begin
                word = "    " ;
                LED = 0 ;
            end
        endcase
    end
endmodule
