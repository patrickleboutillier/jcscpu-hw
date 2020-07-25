/*
	Include file for creating a top module
*/

wire CLK_clk, CLK_clkd, CLK_clke, CLK_clks ;
// jclock localclk(sclk, reset, CLK_clk, CLK_clkd, CLK_clke, CLK_clks) ;

wire [0:5] STP_bus ;
// jstepper STP(CLK_clk, reset, STP_bus) ;

wor [7:0] bus ;

wire r0_s, r0_e, r1_s, r1_e, r2_s, r2_e, r3_s, r3_e ;
jlregister r0(bus, r0_s, r0_e, bus) ;
jlregister r1(bus, r1_s, r1_e, bus) ;
jlregister r2(bus, r2_s, r2_e, bus) ;
jlregister r3(bus, r3_s, r3_e, bus) ;

wire tmp_s, bus1_bit1 ;
wire [7:0] tmp_bus, bus1_bus ;
jlregister tmp(bus, tmp_s, 1'b1, tmp_bus) ;
jbus1 bus1(tmp_bus, bus1_bit1, bus1_bus) ;

wire [2:0] alu_op ;
wire [7:0] alu_bus ;
wire alu_ci, alu_co, alu_eqo, alu_alo, alu_z ;
jALU alu(bus, bus1_bus, alu_ci, alu_op, alu_bus, alu_co, alu_eqo, alu_alo, alu_z) ;

wire flags_s ;
wire [7:0] flags_in, flags_bus ;
assign flags_in = {alu_co, alu_alo, alu_eqo, alu_z, 4'b0000} ;
jlregister flags(flags_in, flags_s, 1'b1, flags_bus) ;

wire acc_s, acc_e ;
jlregister acc(alu_bus, acc_s, acc_e, bus) ;

wire alu_ena_ci, wco ;
jlatch ctmp(flags_bus[7], tmp_s, wco) ;
jand cand(wco, alu_ena_ci, alu_ci) ;

wire ram_mar_s, ram_s, ram_e ;
// myRAM ram(bus, ram_mar_s, bus, ram_s, ram_e, bus) ;

wire iar_s, iar_e, ir_s ;
wire [7:0] ir_bus ;
jlregister iar(bus, iar_s, iar_e, bus) ;
jlregister ir(bus, ir_s, 1'b1, ir_bus) ;

wire halt ;
wire io_s, io_e, io_da, io_io ;

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


// For test suite
// assign out[0:2] = alu_op ;
// assign out[3] = alu_ci ;
// assign out[4] = flags_s ;
// assign out[5] = tmp_s ;
// assign out[6] = bus1_bit1 ;
// assign out[7] = acc_s ;
// assign out[8] = acc_e ;
// assign out[9] = r0_s ;
// assign out[10] = r0_e ;
// assign out[11] = r1_s ;
// assign out[12] = r1_e ;
// assign out[13] = r2_s ;
// assign out[14] = r2_e ;
// assign out[15] = r3_s ;
// assign out[16] = r3_e ;
// assign out[17] = ram_mar_s ;
// assign out[18] = ram_s ;
// assign out[19] = ram_e ;
// assign out[20] = iar_s ;
// assign out[21] = iar_e ;
// assign out[22] = ir_s ;
wire [0:22] CU_state = { alu_op, alu_ci, flags_s, tmp_s, bus1_bit1, acc_s, acc_e, 
	r0_s, r0_e, r1_s, r1_e, r2_s, r2_e, r3_s, r3_e,
	ram_mar_s, ram_s, ram_e, iar_s, iar_e, ir_s} ;

// Add clock, stepper, RAM and CU here.
