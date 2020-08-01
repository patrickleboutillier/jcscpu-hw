`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: jcsdemo
// https://github.com/patrickleboutillier/jcscpu-hw/
//////////////////////////////////////////////////////////////////////////////////


module jcscpu(
    input CLK, input [15:0] SW, input BTNU, input BTNL, input BTNC, input BTNR, input BTND,
    output reg [15:0] LED, output [6:0] SEG, output [3:0] AN, output DP) ;

    reg reset = 1 ;
	wire halt ;
    wire sclk, CLK_clk, CLK_clkd, CLK_clke, CLK_clks ;
    genclock #(2) clkHZ(CLK, sclk) ;
    jclock clk(sclk, reset, CLK_clk, CLK_clkd, CLK_clke, CLK_clks) ;
    always @(posedge sclk)
        if (reset == 1)
            reset <= 0 ;

    wire [0:5] STP_bus ;
    jstepcnt stp(CLK_clk, reset, 1'b0, STP_bus) ;

    wor [7:0] bus ;
 
    wire r0_s, r0_e, r1_s, r1_e, r2_s, r2_e, r3_s, r3_e ;
    jregister r0(bus, r0_s, r0_e, bus) ;
    jregister r1(bus, r1_s, r1_e, bus) ;
    jregister r2(bus, r2_s, r2_e, bus) ;
    jregister r3(bus, r3_s, r3_e, bus) ;
    
    wire tmp_s, bus1_bit1 ;
    wire [7:0] tmp_bus, bus1_bus ;
    jregister tmp(bus, tmp_s, 1'b1, tmp_bus) ;
    jbus1 bus1(tmp_bus, bus1_bit1, bus1_bus) ;
    
    wire [2:0] alu_op ;
    wire [7:0] alu_bus ;
    wire alu_ci, alu_co, alu_eqo, alu_alo, alu_z ;
    jALU alu(bus, bus1_bus, alu_ci, alu_op, alu_bus, alu_co, alu_eqo, alu_alo, alu_z) ;
    
    wire flags_s ;
    wire [7:0] flags_in, flags_bus ;
    assign flags_in = {alu_co, alu_alo, alu_eqo, alu_z, 4'b0000} ;
    jregister flags(flags_in, flags_s, 1'b1, flags_bus) ;
    
    wire acc_s, acc_e ;
    jregister acc(alu_bus, acc_s, acc_e, bus) ;
    
    wire alu_ena_ci, wco ;
    jmemory ctmp(flags_bus[7], tmp_s, wco) ;
    jand cand(wco, alu_ena_ci, alu_ci) ;
    
    wire ram_mar_s, ram_s, ram_e ;
	// See below for RAM definition
    
    wire iar_s, iar_e, ir_s ;
    wire [7:0] ir_bus ;
    jregister iar(bus, iar_s, iar_e, bus) ;
    jregister ir(bus, ir_s, 1'b1, ir_bus) ;

    wire io_s, io_e, io_da, io_io ;

    jCU x(
      .CLK_clk(CLK_clk), .CLK_clkd(CLK_clkd), .CLK_clke(CLK_clke), .CLK_clks(CLK_clks), .STP_bus(STP_bus),
      .flags_bus(flags_bus[7:4]),
      .ir_bus(ir_bus),
      .alu_op(alu_op),
      .alu_ena_ci(alu_ena_ci), .flags_s(flags_s), .tmp_s(tmp_s), .bus1_bit1(bus1_bit1), .acc_s(acc_s), .acc_e(acc_e),
      .r0_s(r0_s), .r0_e(r0_e), .r1_s(r1_s), .r1_e(r1_e), .r2_s(r2_s), .r2_e(r2_e), .r3_s(r3_s), .r3_e(r3_e),
      .ram_mar_s(ram_mar_s), .ram_s(ram_s), .ram_e(ram_e),
      .iar_s(iar_s), .iar_e(iar_e), .ir_s(ir_s), .halt(halt),
      .io_s(io_s), .io_e(io_e), .io_da(io_da), .io_io(io_io)
    ) ;
   
 
    // Rudimentary IO handling for TTY
    reg [7:0] io_dev, num = 0 ;
    always @(io_s or io_e or io_da or io_io or bus) begin
        if (io_s && io_da && io_io) begin
            // Select IO address
            io_dev = bus ;
        end
        if (io_s && !io_da && io_io) begin
            if (io_dev == 0) 
                // TTY
                num = bus ;
        end
    end

	
    // RAM
    wire [7:0] ram_bus ;
    jregister MAR(bus, ram_mar_s, 1'b1, ram_bus) ;
    reg [7:0] RAM[0:255] ;
    assign bus = (ram_e) ? RAM[ram_bus] : 0 ;
    always @(ram_s or bus or ram_bus) begin
        if (ram_s)
            RAM[ram_bus] = bus ;
    end
    // Initialize RAM
    initial begin
        prog_42() ;
    end
   
    
    seven_seg_dec ssd(CLK, num, SEG, AN, DP) ;
    always @(*) begin
        LED[15:14] = {CLK_clke, CLK_clks} ;
        LED[13:8] = STP_bus ;
		LED[7:0] = bus ;
    end

    // Program 20 + 22 = 42 ;
    task prog_42 ; 
        begin
            RAM[0]  = 8'b00100000 ;
            RAM[1]  = 8'b00010100 ;
            RAM[2]  = 8'b00100001 ;
            RAM[3]  = 8'b00010110 ;
            RAM[4]  = 8'b01100000 ; // CLF because FLAGS is not properly initialized
            RAM[5]  = 8'b10000001 ;
            RAM[6]  = 8'b00100000 ;
            RAM[7]  = 8'b00000000 ;
            RAM[8]  = 8'b01111100 ;
            RAM[9]  = 8'b01111001 ;
            RAM[10] = 8'b01100001 ;
        end
    endtask
endmodule
