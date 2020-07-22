`timescale 1ns / 1ps


module jCU (
	input CLK_clk, input CLK_clkd, input CLK_clke, input CLK_clks, input [0:5] STP_bus,
	input [3:0] flags_bus, 
	input [0:7] ir_bus,
	output [0:2] alu_op,
	output alu_ena_ci, flags_s, tmp_s, bus1_bit1, acc_s, acc_e,
	output r0_s, r0_e, r1_s, r1_e, r2_s, r2_e, r3_s, r3_e, 
    output ram_mar_s, ram_s, ram_e,
	output iar_s, iar_e, ir_s,
	output halt,
	output io_s, io_e, io_io, io_da
	) ;


	wire [0:7] inst_bus ;

	// ALL ENABLES	
	wor iar_ena_wor, ram_ena_wor, acc_ena_wor, bus1_bit1_wor ;
	jand iar_ena(CLK_clke, iar_ena_wor, iar_e) ;
	jand ram_ena(CLK_clke, ram_ena_wor, ram_e) ;
	jand acc_ena(CLK_clke, acc_ena_wor, acc_e) ;

	// ALL SETS
	wor ir_set_wor, ram_mar_set_wor, iar_set_wor, acc_set_wor, ram_set_wor, tmp_set_wor, flags_set_wor ;
	jand ir_set(CLK_clks, ir_set_wor, ir_s) ;
	jand ram_mar_set(CLK_clks, ram_mar_set_wor, ram_mar_s) ;
	jand iar_set(CLK_clks, iar_set_wor, iar_s) ;
	jand acc_set(CLK_clks, acc_set_wor, acc_s) ;
	jand ram_set(CLK_clks, ram_set_wor, ram_s) ;
	jand tmp_set(CLK_clks, tmp_set_wor, tmp_s) ;
	jand flags_set(CLK_clks, flags_set_wor, flags_s) ;

	// Hook up the circuit used to process the first 3 steps of each cycle (see page 108 in book), i.e
	// - Load IAR to MAR and increment IAR in AC
	// - Load the instruction from RAM into IR
	// - Increment the IAR from ACC
	assign bus1_bit1_wor = STP_bus[0] ;
	assign bus1_bit1 = bus1_bit1_wor ;
	assign iar_ena_wor = STP_bus[0] ;
	assign ram_mar_set_wor = STP_bus[0] ;
	assign acc_set_wor = STP_bus[0] ;

	assign ram_ena_wor = STP_bus[1] ;
	assign ir_set_wor = STP_bus[1] ;

	assign acc_ena_wor = STP_bus[2] ;
	assign iar_set_wor = STP_bus[2] ;


	// Then, we set up the parts that are required to actually implement instructions, i.e.
	// - Connect the decoders for the enable and set operations on R0-R3

	wire rega_e, regb_e, regb_s ;
	wor rega_ena_wor, regb_ena_wor, regb_set_wor ;
	assign rega_e = rega_ena_wor ;
	assign regb_e = regb_ena_wor ;
	assign regb_s = regb_set_wor ;

		
	// s side
	wire [3:0] sdeco ;
	jandN #(3) r0_regb_set({CLK_clks, regb_s, sdeco[0]}, r0_s) ;
	jandN #(3) r1_regb_set({CLK_clks, regb_s, sdeco[1]}, r1_s) ;
	jandN #(3) r2_regb_set({CLK_clks, regb_s, sdeco[2]}, r2_s) ;
	jandN #(3) r3_regb_set({CLK_clks, regb_s, sdeco[3]}, r3_s) ;
	jdecoder #(2, 4) regb_set_dec({ir_bus[6], ir_bus[7]}, sdeco) ;

	// e side
	wire [3:0] edecoa, edecob ;
	wire r0_wora, r0_worb ;
	jor r0_wor(r0_wora, r0_worb, r0_e) ;
	jandN #(3) r0_rega_ena({CLK_clke, rega_e, edecoa[0]}, r0_wora) ;
	jandN #(3) r0_regb_ena({CLK_clke, regb_e, edecob[0]}, r0_worb) ;
	wire r1_wora, r1_worb ;
	jor r1_wor(r1_wora, r1_worb, r1_e) ;
	jandN #(3) r1_rega_ena({CLK_clke, rega_e, edecoa[1]}, r1_wora) ;
	jandN #(3) r1_regb_ena({CLK_clke, regb_e, edecob[1]}, r1_worb) ;
	wire r2_wora, r2_worb ;
	jor r2_wor(r2_wora, r2_worb, r2_e) ;
	jandN #(3) r2_rega_ena({CLK_clke, rega_e, edecoa[2]}, r2_wora) ;
	jandN #(3) r2_regb_ena({CLK_clke, regb_e, edecob[2]}, r2_worb) ;
	wire r3_wora, r3_worb ;
	jor r3_wor(r3_wora, r3_worb, r3_e) ;
	jandN #(3) r3_rega_ena({CLK_clke, rega_e, edecoa[3]}, r3_wora) ;
	jandN #(3) r3_regb_ena({CLK_clke, regb_e, edecob[3]}, r3_worb) ;

	jdecoder #(2, 4) rega_ena_dec({ir_bus[4], ir_bus[5]}, edecoa) ;
	jdecoder #(2, 4) regb_ena_dec({ir_bus[6], ir_bus[7]}, edecob) ;

	// Finally, install the instruction decoder
	wire notalu ;
	jnot nalu(ir_bus[0], notalu) ;
	wire [7:0] idecbus ;
	jdecoder #(3, 8) inst_dec(ir_bus[1:3], idecbus) ;
	genvar j ;
	for (j = 0 ; j < 8 ; j = j + 1) begin
		jand iandj(notalu, idecbus[j], inst_bus[j]) ;
	end

	// Now, setting up instruction circuits involves:
	// - Hook up to the proper wire of INST.bus
	// - Wire up the logical circuit and attach it to proper step wires
	// - Use the "elastic" OR gates (xxx.eor) to enable and set


	// ALU INSTRUCTIONS
	wire aa1 ;
	jand alu1(STP_bus[3], ir_bus[0], aa1) ;
	assign regb_ena_wor = aa1 ;
	assign tmp_set_wor = aa1 ;

	wire aa2 ;
	jand alu2(STP_bus[4], ir_bus[0], aa2) ;
	assign rega_ena_wor = aa2 ;
	assign alu_ena_ci = aa2 ;
	assign acc_set_wor = aa2 ;
	assign flags_set_wor = aa2 ;

	wire wnotcmp, aa3 ;
	jandN #(3) alu3({STP_bus[5], ir_bus[0], wnotcmp}, aa3) ;
	assign acc_ena_wor = aa3 ;
	assign regb_set_wor = aa3 ;

	// Operation selector
	wire walu ;
	jnot walunot(walu, wnotcmp) ;
	wire [0:2] cmpbus ;
	assign cmpbus = ir_bus[1:3] ;
	jandN #(3) ncmpbus(cmpbus, walu) ;
	jandN #(3) aluopand1({STP_bus[4], ir_bus[0], cmpbus[0]}, alu_op[0]) ;
	jandN #(3) aluopand2({STP_bus[4], ir_bus[0], cmpbus[1]}, alu_op[1]) ;
	jandN #(3) aluopand3({STP_bus[4], ir_bus[0], cmpbus[2]}, alu_op[2]) ;


	// LOAD AND STORE INSTRUCTIONS
	wire l1 ;
	jand l1and(STP_bus[3], inst_bus[0], l1) ;
	assign rega_ena_wor = l1 ;
	assign ram_mar_set_wor = l1 ;

	wire l2 ;
	jand l2and(STP_bus[4], inst_bus[0], l2) ;
	assign ram_ena_wor = l2 ;
	assign regb_set_wor = l2 ;

	wire s1 ;
	jand s1and(STP_bus[3], inst_bus[1], s1) ;
	assign rega_ena_wor = s1 ;
	assign ram_mar_set_wor = s1 ;

	wire s2 ;
	jand s2and(STP_bus[4], inst_bus[1], s2) ;
	assign regb_ena_wor = s2 ;
	assign ram_set_wor = s2 ;
	

	// DATA INSTRUCTIONS
	wire d1 ;
	jand d1and(STP_bus[3], inst_bus[2], d1) ;
	assign bus1_bit1_wor = d1 ;
	assign iar_ena_wor = d1 ;
	assign ram_mar_set_wor = d1 ;
	assign acc_set_wor = d1 ;

	wire d2 ;
	jand d2and(STP_bus[4], inst_bus[2], d2) ;
	assign ram_ena_wor = d2 ;
	assign regb_set_wor = d2 ;

	wire d3 ;
	jand d3and(STP_bus[5], inst_bus[2], d3) ;
	assign acc_ena_wor = d3 ;
	assign iar_set_wor = d3 ;


	// CLF INSTRUCTIONS
	wire [3:0] clbreg ;
	assign clbreg = { ir_bus[4:7] } ;
	wire [15:0] clbinst ;
	jdecoder #(4, 16) clfdec(clbreg, clbinst) ;

	// CLF, 01100000
	wire cl1 ;
	jandN #(3) cland1({inst_bus[6], STP_bus[3], clbinst[0]}, cl1) ;
	assign bus1_bit1_wor = cl1 ;
	assign flags_set_wor = cl1 ;

	// HALT, 01100001
	jandN #(3) hltand1({inst_bus[6], STP_bus[5], clbinst[1]}, halt) ;


	// IO INSTRUCTIONS
	wire io1 ;
	jandN #(3) ioand1({STP_bus[3], inst_bus[7], ir_bus[4]}, io1) ;
	assign regb_ena_wor = io1 ;

	wire ion4, io2 ;
	jnot ionot1(ir_bus[4], ion4) ;
	jandN #(3) ioand2({STP_bus[4], inst_bus[7], ion4}, io2) ;
	assign regb_set_wor = io2 ;

	jand ios(CLK_clks, io1, io_s) ;
	jand ioe(CLK_clke, io2, io_e) ;
	assign io_io = ir_bus[4] ;
	assign io_da = ir_bus[5] ;


	// JUMP INSTRUCTIONS
	// JUMPR
	wire jr1 ;
	jand jrand(STP_bus[3], inst_bus[3], jr1) ;
	assign regb_ena_wor = jr1 ;
	assign iar_set_wor = jr1 ;

	// JUMP
	wire j1 ;
	jand jand1(STP_bus[3], inst_bus[4], j1) ;
	assign iar_ena_wor = j1 ;
	assign ram_mar_set_wor = j1 ;

	wire j2 ;
	jand jand2(STP_bus[4], inst_bus[4], j2) ;
	assign ram_ena_wor = j2 ;
	assign iar_set_wor = j2 ;

	// JUMPIF
	wire ji1 ;
	jand jiand1(STP_bus[3], inst_bus[5], ji1) ;
	assign bus1_bit1_wor = ji1 ;
	assign iar_ena_wor = ji1 ;
	assign ram_mar_set_wor = ji1 ;
	assign acc_set_wor = ji1 ;

	wire ji2 ;
	jand jiand2(STP_bus[4], inst_bus[5], ji2) ;
	assign acc_ena_wor = ji2 ;
	assign iar_set_wor = ji2 ;

	wire ji3, jflago ;
	jandN #(3) jiand3({STP_bus[5], inst_bus[5], jflago}, ji3) ;
	assign ram_ena_wor = ji3 ;
	assign iar_set_wor = ji3 ;

	wire [0:3] jfbus ;
	jand jfand1(flags_bus[3], ir_bus[4], jfbus[0]) ;
	jand jfand2(flags_bus[2], ir_bus[5], jfbus[1]) ;
	jand jfand3(flags_bus[1], ir_bus[6], jfbus[2]) ;
	jand jfand4(flags_bus[0], ir_bus[7], jfbus[3]) ;
	jorN #(4) jfor1(jfbus, jflago) ;
endmodule

/*
func CLFInstructions(BB *Breadboard) {
	// DEBUG3,2,1,0, 011010[00,01,10,11]
	for j := 0; j < 4; j++ {
		dbg := g.NewWire()
		g.NewANDn(g.WrapBusV(BB.GetBus("INST.bus").GetWire(6), BB.GetBus("STP.bus").GetWire(3), binst.GetWire(8+j)), dbg)
		d := j
		dbg.AddPrehook(func(v bool) {
			if v {
				BB._debug(d)
			}
		})
	}

	// DUMP (dump RAM)
	dmp1 := g.NewWire()
	g.NewANDn(g.WrapBusV(BB.GetBus("INST.bus").GetWire(6), BB.GetBus("STP.bus").GetWire(3), binst.GetWire(14)), dmp1)
	dmp1.AddPrehook(func(v bool) {
		if v {
			BB.Dump()
		}
	})
}
*/
