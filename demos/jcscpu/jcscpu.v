`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: jcsdemo
// https://github.com/patrickleboutillier/jcscpu-hw/
//////////////////////////////////////////////////////////////////////////////////


module jcscpu(
    input CLK, input [15:0] SW, input BTNU, input BTNL, input BTNC, input BTNR, input BTND,
    output reg [15:0] LED, output [6:0] SEG, output [3:0] AN, output DP) ;

    // reset stuff, see jscclk
    
    wire CLK_clk, CLK_clkd, CLK_clke, CLK_clks ;
    jclock localclk(sclk, reset, CLK_clk, CLK_clkd, CLK_clke, CLK_clks) ;

    wire [0:5] STP_bus ;
    jstepperb STP(CLK_clk, reset, STP_bus) ;

reg [7:0] busi = 0 ;
wor [7:0] bus ;
always @(bus) begin
	if (^bus === 1'bx)
		busi <= 0 ;
	else
		busi <= bus ;
end

    wire r0_s, r0_e, r1_s, r1_e, r2_s, r2_e, r3_s, r3_e ;
    jregister r0(busi, reset | r0_s, r0_e, bus) ;
    jregister r1(busi, reset | r1_s, r1_e, bus) ;
    jregister r2(busi, reset | r2_s, r2_e, bus) ;
    jregister r3(busi, reset | r3_s, r3_e, bus) ;
    
    wire tmp_s, bus1_bit1 ;
    wire [7:0] tmp_bus, bus1_bus ;
    jregister tmp(busi, reset | tmp_s, 1'b1, tmp_bus) ;
    jbus1 bus1(tmp_bus, bus1_bit1, bus1_bus) ;
    
    wire [2:0] alu_op ;
    wire [7:0] alu_bus ;
    wire alu_ci, alu_co, alu_eqo, alu_alo, alu_z ;
    jALU alu(busi, bus1_bus, alu_ci, alu_op, alu_bus, alu_co, alu_eqo, alu_alo, alu_z) ;
    
    wire flags_s ;
    wire [7:0] flags_in, flags_bus ;
    assign flags_in = {alu_co, alu_alo, alu_eqo, alu_z, 4'b0000} ;
    jregister flags(flags_in, reset | flags_s, 1'b1, flags_bus) ;
    
    wire acc_s, acc_e ;
    jregister acc(alu_bus, reset | acc_s, acc_e, bus) ;
    
    wire alu_ena_ci, wco ;
    jmemory ctmp(flags_bus[7], reset | tmp_s, wco) ;
    jand cand(wco, alu_ena_ci, alu_ci) ;
    
    wire ram_mar_s, ram_s, ram_e ;
    // myRAM ram(bus, ram_mar_s, bus, ram_s, ram_e, bus) ;
    
    wire iar_s, iar_e, ir_s ;
    wire [7:0] ir_bus ;
    jregister iar(busi, reset | iar_s, iar_e, bus) ;
    jregister ir(busi, reset | ir_s, 1'b1, ir_bus) ;

    wire halt ;
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
    
    // Provide io_dev and io_data for caller.
    reg [7:0] io_dev, io_data ;
    reg [7:0] rng = 0 ;
    assign bus = rng ;
    always @(io_s or io_e or io_da or io_io) begin
        if (io_s && io_da && io_io)
            io_dev = bus ;
        if (io_s && !io_da && io_io)
            io_data = bus ;
        if (!io_s && !io_da && io_io)
            // Clear reg where s is done
            io_data = 0 ;
    
        if (io_e && !io_da && !io_io) begin
            if (io_dev == 1) 
                rng = $urandom_range(255, 0) ;
        end
        if (!io_e && !io_da && !io_io) begin
            if (io_dev == 1) 
                rng = 0 ;
        end
    end

	// Poor man's TTY. 
	always @(io_data) begin
		if (io_dev == 0 && io_data != 0)
			$write("%c", io_data) ;
		if (io_dev == 1 && io_data != 0)
			$write("%b", io_data) ;
	end
	
    // Add clock, stepper, RAM and CU here.
    // RAM
    wire [7:0] ram_bus ;
    jregister MAR(bus, ram_mar_s, 1'b1, ram_bus) ;
    reg [7:0] RAM[0:255] ;
    initial $readmemb("/tmp/mem", RAM) ;

    assign bus = (ram_e) ? RAM[ram_bus] : 0 ;
    always @(ram_s) begin
        if (ram_s)
            RAM[ram_bus] = bus ;
    end

endmodule