

module jCU (
	input CLK_clk, input CLK_clkd, input CLK_clke, input CLK_clks, input [0:5] STP_bus,
	input flags_co, flags_eqo, flags_alo, flags_z, 
	input [0:7] ir_bus,
	output alu_ci, output [2:0] alu_op, flags_s, tmp_s, tmp_e, bus1_bit1, acc_s, acc_e,
	output r0_s, r0_e, r1_s, r1_e, r2_s, r2_e, r3_s, r3_e, 
    output ram_mar_s, ram_s, ram_e,
	output iar_s, iar_e, ir_s
	) ;


	task inst_proc ; begin
		// ALL ENABLES	
		wor iar_ena_wor, ram_ena_wor, acc_ena_wor, bus1_bit1_wor ;
		jand iar_ena(CLK_clke, iar_ena_wor, iar_e) ;
		jand ram_ena(CLK_clke, ram_ena_wor, ram_e) ;
		jand acc_ena(CLK_clke, acc_ena_wor, acc_e) ;

		// ALL SETS
		wor ir_set_wor, ram_mar_set_wor, iar_set_wor, acc_set_wor, ram_set_wor, tmp_set_wor, flags_set_wor ;
		jand ir_set(CLK_clks, ir_set_wor, ir_s) ;
		jand ram_mar_set(CLK_clks, ram_mar_set_wor, ir_s) ;
		jand iar_set(CLK_clks, iar_set_wor, ir_s) ;
		jand acc_set(CLK_clks, acc_set_wor, ir_s) ;
		jand ram_set(CLK_clks, ram_set_wor, ir_s) ;
		jand tmp_set(CLK_clks, tmp_set_wor, ir_s) ;
		jand flags_set(CLK_clks, flags_set_wor, flags_s) ;

		// Hook up the circuit used to process the first 3 steps of each cycle (see page 108 in book), i.e
		// - Load IAR to MAR and increment IAR in AC
		// - Load the instruction from RAM into IR
		// - Increment the IAR from ACC
		assign bus1_bit1_wor = STP_bus[0] ;
		assign iar_ena_wor = STP_bus[0] ;
		assign ram_mar_set_wor = STP_bus[0] ;
		assign acc_set_wor = STP_bus[0] ;

		assign ram_ena_wor = STP_bus[1] ;
		assign ir_set_wor = STP_bus[1] ;

		assign acc_ena_wor = STP_bus[2] ;
		assign iar_set_wor = STP_bus[2] ;
	endtask


	task inst_impl ; begin
		// Then, we set up the parts that are required to actually implement instructions, i.e.
		// - Connect the decoders for the enable and set operations on R0-R3

		wire rega_e, regb_e, regb_s ;
		wor rega_ena_wor, regb_ena_wor, regb_set_wor ;

		// s side
		wire [0:3] sdeco ;
		jandN #(3) r0_regb_set({CLK_clks, regb_s, sdeco[0]}, r0_s) ;
		jandN #(3) r1_regb_set({CLK_clks, regb_s, sdeco[1]}, r1_s) ;
		jandN #(3) r2_regb_set({CLK_clks, regb_s, sdeco[2]}, r2_s) ;
		jandN #(3) r3_regb_set({CLK_clks, regb_s, sdeco[3]}, r3_s) ;
		jdecoder #(2, 4) regb_set_dec({ir_bus[6], ir_bus[7]}, sdeco) ;

		// e side
		wire [0:3] edecoa, edecob ;
		wire r0_wora, r0_worb ;
		jor(r0_wora, r0_worb, r0_e) ;
		jandN #(3) r0_rega_ena({CLK_clke, rega_e, edecoa[0]}, r0_wora) ;
		jandN #(3) r0_regb_ena({CLK_clke, regb_e, edecob[0]}, r0_worb) ;
		wire r1_wora, r1_worb ;
		jor(r1_wora, r1_worb, r1_e) ;
		jandN #(3) r1_rega_ena({CLK_clke, rega_e, edecoa[1]}, r1_wora) ;
		jandN #(3) r1_regb_ena({CLK_clke, regb_e, edecob[1]}, r1_worb) ;
		wire r2_wora, r2_worb ;
		jor(r2_wora, r2_worb, r2_e) ;
		jandN #(3) r2_rega_ena({CLK_clke, rega_e, edecoa[2]}, r2_wora) ;
		jandN #(3) r2_regb_ena({CLK_clke, regb_e, edecob[2]}, r2_worb) ;
		wire r3_wora, r3_worb ;
		jor(r3_wora, r3_worb, r3_e) ;
		jandN #(3) r3_rega_ena({CLK_clke, rega_e, edecoa[3]}, r3_wora) ;
		jandN #(3) r3_regb_ena({CLK_clke, regb_e, edecob[3]}, r3_worb) ;

		jdecoder #(2, 4) rega_ena_dec({ir_bus[4], ir_bus[5]}, edecoa) ;
		jdecoder #(2, 4) regb_ena_dec({ir_bus[6], ir_bus[7]}, edecob) ;


		// Finally, install the instruction decoder
		this.putBus("INST.bus", g.NewBus(8))
		notalu := g.NewWire()
		g.NewNOT(this.GetBus("IR.bus").GetWire(0), notalu)
		idecbus := g.NewBus(8)
		p.NewDecoder(g.WrapBusV(this.GetBus("IR.bus").GetWire(1), this.GetBus("IR.bus").GetWire(2), this.GetBus("IR.bus").GetWire(3)), idecbus)
		for j := 0; j < 8; j++ {
			g.NewAND(notalu, idecbus.GetWire(j), this.GetBus("INST.bus").GetWire(j))
		}

		// Now, setting up instruction circuits involves:
		// - Hook up to the proper wire of INST.bus
		// - Wire up the logical circuit and attach it to proper step wires
		// - Use the "elastic" OR gates (xxx.eor) to enable and set
	endtask


/*
	// RAM
	this.putBus("DATA.bus", g.NewBus(bits))
	this.putWire("RAM.MAR.s", g.NewWire())
	this.putWire("RAM.s", g.NewWire())
	this.putWire("RAM.e", g.NewWire())
	this.RAM = p.NewRAM(
		this.GetBus("DATA.bus"),
		this.GetWire("RAM.MAR.s"),
		this.GetBus("DATA.bus"),
		this.GetWire("RAM.s"),
		this.GetWire("RAM.e"),
	)
	this.putReg("RAM.MAR", this.RAM.GetMAR())

	// REGISTERS
	this.putWire("R0.s", g.NewWire())
	this.putWire("R0.e", g.NewWire())
	this.putWire("R1.s", g.NewWire())
	this.putWire("R1.e", g.NewWire())
	this.putWire("R2.s", g.NewWire())
	this.putWire("R2.e", g.NewWire())
	this.putWire("R3.s", g.NewWire())
	this.putWire("R3.e", g.NewWire())
	this.putWire("TMP.s", g.NewWire())
	this.putWire("TMP.e", g.WireOn()) // TMP.e is always on
	this.putBus("TMP.bus", g.NewBus(bits))
	this.putWire("BUS1.bit1", g.NewWire())
	this.putBus("BUS1.bus", g.NewBus(bits))

	this.putReg("R0", p.NewRegister(this.GetBus("DATA.bus"), this.GetWire("R0.s"), this.GetWire("R0.e"), this.GetBus("DATA.bus"), "R0"))
	this.putReg("R1", p.NewRegister(this.GetBus("DATA.bus"), this.GetWire("R1.s"), this.GetWire("R1.e"), this.GetBus("DATA.bus"), "R1"))
	this.putReg("R2", p.NewRegister(this.GetBus("DATA.bus"), this.GetWire("R2.s"), this.GetWire("R2.e"), this.GetBus("DATA.bus"), "R2"))
	this.putReg("R3", p.NewRegister(this.GetBus("DATA.bus"), this.GetWire("R3.s"), this.GetWire("R3.e"), this.GetBus("DATA.bus"), "R3"))
	this.putReg("TMP", p.NewRegister(this.GetBus("DATA.bus"), this.GetWire("TMP.s"), this.GetWire("TMP.e"), this.GetBus("TMP.bus"), "TMP"))
	this.BUS1 = p.NewBus1(this.GetBus("TMP.bus"), this.GetWire("BUS1.bit1"), this.GetBus("BUS1.bus"))

	// ALU
	this.putWire("ACC.s", g.NewWire())
	this.putWire("ACC.e", g.NewWire())
	this.putBus("ALU.bus", g.NewBus(bits))
	this.putWire("ALU.ci", g.NewWire())
	this.putBus("ALU.op", g.NewBus(3))
	this.putWire("ALU.co", g.NewWire())
	this.putWire("ALU.eqo", g.NewWire())
	this.putWire("ALU.alo", g.NewWire())
	this.putWire("ALU.z", g.NewWire())
	this.putWire("FLAGS.e", g.WireOn()) // FLAGS.e is always on
	this.putWire("FLAGS.s", g.NewWire())

	this.putReg("ACC", p.NewRegister(this.GetBus("ALU.bus"), this.GetWire("ACC.s"), this.GetWire("ACC.e"), this.GetBus("DATA.bus"), "ACC"))
	this.ALU = p.NewALU(
		this.GetBus("DATA.bus"),
		this.GetBus("BUS1.bus"),
		this.GetWire("ALU.ci"),
		this.GetBus("ALU.op"),
		this.GetBus("ALU.bus"),
		this.GetWire("ALU.co"),
		this.GetWire("ALU.eqo"),
		this.GetWire("ALU.alo"),
		this.GetWire("ALU.z"),
	)
	this.putBus("FLAGS.in", g.WrapBusV(this.GetWire("ALU.co"), this.GetWire("ALU.alo"), this.GetWire("ALU.eqo"), this.GetWire("ALU.z"),
		g.WireOff(), g.WireOff(), g.WireOff(), g.WireOff()))
	this.putBus("FLAGS.bus", g.WrapBusV(g.NewWire(), g.NewWire(), g.NewWire(), g.NewWire(),
		g.WireOff(), g.WireOff(), g.WireOff(), g.WireOff()))
	this.putReg("FLAGS",
		p.NewRegister(
			this.GetBus("FLAGS.in"),
			this.GetWire("FLAGS.s"),
			this.GetWire("FLAGS.e"),
			// We DO NOT hook up the ALU carry in just yet, we will do that when we setup ALU instructions processing
			this.GetBus("FLAGS.bus"),
			"FLAGS",
		),
	)

	// CLOCK & STEPPER
	this.putWire("CLK.clk", g.NewWire())
	this.putWire("CLK.clke", g.NewWire())
	this.putWire("CLK.clks", g.NewWire())
	this.putBus("STP.bus", g.NewBus(7))
	this.CLK = p.NewClock(this.GetWire("CLK.clk"), this.GetWire("CLK.clke"), this.GetWire("CLK.clks"))
	this.putWire("CLK.clkd", this.CLK.Clkd())
	this.STP = p.NewStepper(this.GetWire("CLK.clk"), this.GetBus("STP.bus"))

	// I/O
	this.putWire("IO.clks", g.NewWire())
	this.putWire("IO.clke", g.NewWire())
	this.putWire("IO.da", g.NewWire())
	this.putWire("IO.io", g.NewWire())

	this.putBus("IO.bus", g.WrapBusV(this.GetWire("IO.clks"), this.GetWire("IO.clke"), this.GetWire("IO.da"), this.GetWire("IO.io")))

	// Hook up the FLAGS Register co output to the ALU ci, adding the AND gate described in the Errata #2
	// Errata stuff: http://www.buthowdoitknow.com/errata.html
	// Naively: new CONN($this.get("FLAGS").os().wire(0), $this.get("ALU").ci())
	weor := g.NewWire()
	wco := g.NewWire()
	this.Ctmp = p.NewNamedMemory(this.GetBus("FLAGS.bus").GetWire(0), this.GetWire("TMP.s"), wco, "Ctmp")
	g.NewAND(wco, weor, this.GetWire("ALU.ci"))
	this.putORe("ALU.ci.ena.eor", g.NewORe(weor))
 */

/*
func InstProc(this *Breadboard) {
	// Add instruction related registers
	this.putWire("IAR.s", g.NewWire())
	this.putWire("IAR.e", g.NewWire())
	this.putWire("IR.s", g.NewWire())
	this.putWire("IR.e", g.WireOn()) // IR.e is always on
	this.putBus("IR.bus", g.NewBus(8))

	this.putReg("IAR", p.NewRegister(this.GetBus("DATA.bus"), this.GetWire("IAR.s"), this.GetWire("IAR.e"), this.GetBus("DATA.bus"), "IAR"))
	// IR uses only the first 8 bits of the DATA.bus
	dbs := g.WrapBus(this.GetBus("DATA.bus").GetWires()[this.GetBus("DATA.bus").GetSize()-8:])
	this.putReg("IR", p.NewRegister(dbs, this.GetWire("IR.s"), this.GetWire("IR.e"), this.GetBus("IR.bus"), "IR"))

	// ALL ENABLES
	for _, e := range []string{"IAR", "RAM", "ACC"} {
		w := g.NewWire()
		g.NewAND(this.GetWire("CLK.clke"), w, this.GetWire(fmt.Sprintf("%s.e", e)))
		this.putORe(fmt.Sprintf("%s.ena.eor", e), g.NewORe(w))
	}
	this.putORe("BUS1.bit1.eor", g.NewORe(this.GetWire("BUS1.bit1")))

	// ALL SETS
	for _, s := range []string{"IR", "RAM.MAR", "IAR", "ACC", "RAM", "TMP", "FLAGS"} {
		w := g.NewWire()
		g.NewAND(this.GetWire("CLK.clks"), w, this.GetWire(fmt.Sprintf("%s.s", s)))
		this.putORe(fmt.Sprintf("%s.set.eor", s), g.NewORe(w))
	}

	// Hook up the circuit used to process the first 3 steps of each cycle (see page 108 in book), i.e
	// - Load IAR to MAR and increment IAR in AC
	// - Load the instruction from RAM into IR
	// - Increment the IAR from ACC
	this.GetORe("BUS1.bit1.eor").AddWire(this.GetBus("STP.bus").GetWire(0))
	this.GetORe("IAR.ena.eor").AddWire(this.GetBus("STP.bus").GetWire(0))
	this.GetORe("RAM.MAR.set.eor").AddWire(this.GetBus("STP.bus").GetWire(0))
	this.GetORe("ACC.set.eor").AddWire(this.GetBus("STP.bus").GetWire(0))

	this.GetORe("RAM.ena.eor").AddWire(this.GetBus("STP.bus").GetWire(1))
	this.GetORe("IR.set.eor").AddWire(this.GetBus("STP.bus").GetWire(1))

	this.GetORe("ACC.ena.eor").AddWire(this.GetBus("STP.bus").GetWire(2))
	this.GetORe("IAR.set.eor").AddWire(this.GetBus("STP.bus").GetWire(2))
}

func InstImpl(this *Breadboard) {
	// Then, we set up the parts that are required to actually implement instructions, i.e.
	// - Connect the decoders for the enable and set operations on R0-R3

	this.putWire("REGA.e", g.NewWire())
	this.putWire("REGB.e", g.NewWire())
	this.putWire("REGB.s", g.NewWire())

	this.putORe("REGA.ena.eor", g.NewORe(this.GetWire("REGA.e")))
	this.putORe("REGB.ena.eor", g.NewORe(this.GetWire("REGB.e")))
	this.putORe("REGB.set.eor", g.NewORe(this.GetWire("REGB.s")))

	// s side
	sdeco := make([]*g.Wire, 4, 4)
	for i, s := range []string{"R0", "R1", "R2", "R3"} {
		w := g.NewWire()
		g.NewANDn(g.WrapBusV(this.GetWire("CLK.clks"), this.GetWire("REGB.s"), w), this.GetWire(fmt.Sprintf("%s.s", s)))
		sdeco[i] = w
	}
	sdecbus := g.WrapBus(sdeco)
	this.putBus("REGB.s.dec.bus", sdecbus)
	p.NewDecoder(g.WrapBusV(this.GetBus("IR.bus").GetWire(6), this.GetBus("IR.bus").GetWire(7)), sdecbus)

	// e side
	edecoa := make([]*g.Wire, 4, 4)
	edecob := make([]*g.Wire, 4, 4)
	for i, e := range []string{"R0", "R1", "R2", "R3"} {
		wora := g.NewWire()
		worb := g.NewWire()
		g.NewOR(wora, worb, this.GetWire(fmt.Sprintf("%s.e", e)))

		wa := g.NewWire()
		g.NewANDn(g.WrapBusV(this.GetWire("CLK.clke"), this.GetWire("REGA.e"), wa), wora)
		edecoa[i] = wa
		wb := g.NewWire()
		g.NewANDn(g.WrapBusV(this.GetWire("CLK.clke"), this.GetWire("REGB.e"), wb), worb)
		edecob[i] = wb
	}
	edecbusa := g.WrapBus(edecoa)
	edecbusb := g.WrapBus(edecob)
	this.putBus("REGA.e.dec.bus", edecbusa)
	this.putBus("REGB.e.dec.bus", edecbusb)
	p.NewDecoder(g.WrapBusV(this.GetBus("IR.bus").GetWire(4), this.GetBus("IR.bus").GetWire(5)), edecbusa)
	p.NewDecoder(g.WrapBusV(this.GetBus("IR.bus").GetWire(6), this.GetBus("IR.bus").GetWire(7)), edecbusb)

	// Finally, install the instruction decoder
	this.putBus("INST.bus", g.NewBus(8))
	notalu := g.NewWire()
	g.NewNOT(this.GetBus("IR.bus").GetWire(0), notalu)
	idecbus := g.NewBus(8)
	p.NewDecoder(g.WrapBusV(this.GetBus("IR.bus").GetWire(1), this.GetBus("IR.bus").GetWire(2), this.GetBus("IR.bus").GetWire(3)), idecbus)
	for j := 0; j < 8; j++ {
		g.NewAND(notalu, idecbus.GetWire(j), this.GetBus("INST.bus").GetWire(j))
	}

	// Now, setting up instruction circuits involves:
	// - Hook up to the proper wire of INST.bus
	// - Wire up the logical circuit and attach it to proper step wires
	// - Use the "elastic" OR gates (xxx.eor) to enable and set
}
*/

/*
func ALUInstructions(BB *Breadboard) {
	aa1 := g.NewWire()
	g.NewAND(BB.GetBus("STP.bus").GetWire(3), BB.GetBus("IR.bus").GetWire(0), aa1)
	BB.GetORe("REGB.ena.eor").AddWire(aa1)
	BB.GetORe("TMP.set.eor").AddWire(aa1)

	aa2 := g.NewWire()
	g.NewAND(BB.GetBus("STP.bus").GetWire(4), BB.GetBus("IR.bus").GetWire(0), aa2)
	BB.GetORe("REGA.ena.eor").AddWire(aa2)
	BB.GetORe("ALU.ci.ena.eor").AddWire(aa2) // Errata #2
	BB.GetORe("ACC.set.eor").AddWire(aa2)
	BB.GetORe("FLAGS.set.eor").AddWire(aa2)

	wnotcmp := g.NewWire()
	aa3 := g.NewWire()
	g.NewANDn(g.WrapBusV(BB.GetBus("STP.bus").GetWire(5), BB.GetBus("IR.bus").GetWire(0), wnotcmp), aa3)
	BB.GetORe("ACC.ena.eor").AddWire(aa3)
	BB.GetORe("REGB.set.eor").AddWire(aa3)

	// Operation selector
	w := g.NewWire()
	g.NewNOT(w, wnotcmp)
	cmpbus := g.WrapBusV(BB.GetBus("IR.bus").GetWire(1), BB.GetBus("IR.bus").GetWire(2), BB.GetBus("IR.bus").GetWire(3))
	g.NewANDn(cmpbus, w)

	for j := 0; j < 3; j++ {
		g.NewANDn(g.WrapBusV(BB.GetBus("STP.bus").GetWire(4), BB.GetBus("IR.bus").GetWire(0), cmpbus.GetWire(j)), BB.GetBus("ALU.op").GetWire(j))
	}
}

func LDSTInstructions(BB *Breadboard) {
	l1 := g.NewWire()
	g.NewAND(BB.GetBus("STP.bus").GetWire(3), BB.GetBus("INST.bus").GetWire(0), l1)
	BB.GetORe("REGA.ena.eor").AddWire(l1)
	BB.GetORe("RAM.MAR.set.eor").AddWire(l1)

	l2 := g.NewWire()
	g.NewAND(BB.GetBus("STP.bus").GetWire(4), BB.GetBus("INST.bus").GetWire(0), l2)
	BB.GetORe("RAM.ena.eor").AddWire(l2)
	BB.GetORe("REGB.set.eor").AddWire(l2)

	s1 := g.NewWire()
	g.NewAND(BB.GetBus("STP.bus").GetWire(3), BB.GetBus("INST.bus").GetWire(1), s1)
	BB.GetORe("REGA.ena.eor").AddWire(s1)
	BB.GetORe("RAM.MAR.set.eor").AddWire(s1)

	s2 := g.NewWire()
	g.NewAND(BB.GetBus("STP.bus").GetWire(4), BB.GetBus("INST.bus").GetWire(1), s2)
	BB.GetORe("REGB.ena.eor").AddWire(s2)
	BB.GetORe("RAM.set.eor").AddWire(s2)
}

func DATAInstructions(BB *Breadboard) {
	d1 := g.NewWire()
	g.NewAND(BB.GetBus("STP.bus").GetWire(3), BB.GetBus("INST.bus").GetWire(2), d1)
	BB.GetORe("BUS1.bit1.eor").AddWire(d1)
	BB.GetORe("IAR.ena.eor").AddWire(d1)
	BB.GetORe("RAM.MAR.set.eor").AddWire(d1)
	BB.GetORe("ACC.set.eor").AddWire(d1)

	d2 := g.NewWire()
	g.NewAND(BB.GetBus("STP.bus").GetWire(4), BB.GetBus("INST.bus").GetWire(2), d2)
	BB.GetORe("RAM.ena.eor").AddWire(d2)
	BB.GetORe("REGB.set.eor").AddWire(d2)

	d3 := g.NewWire()
	g.NewAND(BB.GetBus("STP.bus").GetWire(5), BB.GetBus("INST.bus").GetWire(2), d3)
	BB.GetORe("ACC.ena.eor").AddWire(d3)
	BB.GetORe("IAR.set.eor").AddWire(d3)
}

func JUMPInstructions(BB *Breadboard) {
	// JUMPR
	jr1 := g.NewWire()
	g.NewAND(BB.GetBus("STP.bus").GetWire(3), BB.GetBus("INST.bus").GetWire(3), jr1)
	BB.GetORe("REGB.ena.eor").AddWire(jr1)
	BB.GetORe("IAR.set.eor").AddWire(jr1)

	// JUMP
	j1 := g.NewWire()
	g.NewAND(BB.GetBus("STP.bus").GetWire(3), BB.GetBus("INST.bus").GetWire(4), j1)
	BB.GetORe("IAR.ena.eor").AddWire(j1)
	BB.GetORe("RAM.MAR.set.eor").AddWire(j1)

	j2 := g.NewWire()
	g.NewAND(BB.GetBus("STP.bus").GetWire(4), BB.GetBus("INST.bus").GetWire(4), j2)
	BB.GetORe("RAM.ena.eor").AddWire(j2)
	BB.GetORe("IAR.set.eor").AddWire(j2)

	// JUMPIF
	ji1 := g.NewWire()
	g.NewAND(BB.GetBus("STP.bus").GetWire(3), BB.GetBus("INST.bus").GetWire(5), ji1)
	BB.GetORe("BUS1.bit1.eor").AddWire(ji1)
	BB.GetORe("IAR.ena.eor").AddWire(ji1)
	BB.GetORe("RAM.MAR.set.eor").AddWire(ji1)
	BB.GetORe("ACC.set.eor").AddWire(ji1)

	ji2 := g.NewWire()
	g.NewAND(BB.GetBus("STP.bus").GetWire(4), BB.GetBus("INST.bus").GetWire(5), ji2)
	BB.GetORe("ACC.ena.eor").AddWire(ji2)
	BB.GetORe("IAR.set.eor").AddWire(ji2)

	ji3 := g.NewWire()
	flago := g.NewWire()
	g.NewANDn(g.WrapBusV(BB.GetBus("STP.bus").GetWire(5), BB.GetBus("INST.bus").GetWire(5), flago), ji3)
	BB.GetORe("RAM.ena.eor").AddWire(ji3)
	BB.GetORe("IAR.set.eor").AddWire(ji3)

	fbus := g.NewBus(4)
	for j := 0; j < 4; j++ {
		g.NewAND(BB.GetBus("FLAGS.bus").GetWire(j), BB.GetBus("IR.bus").GetWire(j+4), fbus.GetWire(j))
	}
	g.NewORn(fbus, flago)
}

func CLFInstructions(BB *Breadboard) {
	// Use the last 4 bits of the CLF instruction for control instructions.
	breg := g.WrapBusV(BB.GetBus("IR.bus").GetWire(4), BB.GetBus("IR.bus").GetWire(5), BB.GetBus("IR.bus").GetWire(6), BB.GetBus("IR.bus").GetWire(7))
	binst := g.NewBus(16)
	p.NewDecoder(breg, binst)

	// CLF, 01100000
	cl1 := g.NewWire()
	g.NewANDn(g.WrapBusV(BB.GetBus("INST.bus").GetWire(6), BB.GetBus("STP.bus").GetWire(3), binst.GetWire(0)), cl1)
	BB.GetORe("BUS1.bit1.eor").AddWire(cl1)
	BB.GetORe("FLAGS.set.eor").AddWire(cl1)

	// HALT, 01100001
	hlt1 := g.NewWire()
	g.NewANDn(g.WrapBusV(BB.GetBus("INST.bus").GetWire(6), BB.GetBus("STP.bus").GetWire(5), binst.GetWire(1)), hlt1)
	hlt1.AddPrehook(func(v bool) {
		if v {
			// Make sure we complete the instruction before halting.
			BB.CLK.StopIn(1)
		}
	})

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

func IOInstructions(BB *Breadboard) {
	// IO
	io1 := g.NewWire()
	g.NewANDn(g.WrapBusV(BB.GetBus("STP.bus").GetWire(3), BB.GetBus("INST.bus").GetWire(7), BB.GetBus("IR.bus").GetWire(4)), io1)
	BB.GetORe("REGB.ena.eor").AddWire(io1)

	ion4 := g.NewWire()
	g.NewNOT(BB.GetBus("IR.bus").GetWire(4), ion4)
	io2 := g.NewWire()
	g.NewANDn(g.WrapBusV(BB.GetBus("STP.bus").GetWire(4), BB.GetBus("INST.bus").GetWire(7), ion4), io2)
	BB.GetORe("REGB.set.eor").AddWire(io2)

	g.NewAND(BB.GetWire("CLK.clks"), io1, BB.GetWire("IO.clks"))
	g.NewAND(BB.GetWire("CLK.clke"), io2, BB.GetWire("IO.clke"))
	g.NewCONN(BB.GetBus("IR.bus").GetWire(4), BB.GetWire("IO.io"))
	g.NewCONN(BB.GetBus("IR.bus").GetWire(5), BB.GetWire("IO.da"))
|
*/


endmodule
