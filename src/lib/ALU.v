

module jALU (input [7:0] bas, input [7:0] bbs, input wci, input [2:0] bops, 
	output [7:0] bcs, output wco, output weqo, output walo, output wz) ;
	// Build the ALU circuit
	wire [7:0] bdec ;
	jdecoder #(3, 8) dec(bops, bdec) ;
	reg gnd ;
	assign bdec[7] = gnd ;

	wire [7:0] bxor, bor, band, bnot, bshl, bshr ;

	jxorer xorer(bas, bbs, bxor, weqo, walo) ;
	jena xore(1'b0, bdec[6], wco) ;
	jenabler enaxor(bxor, bdec[6], bcs) ;

	jorer orer(bas, bbs, bor) ;
	jena ore(1'b0, bdec[5], wco) ;
	jenabler enaor(bor, bdec[5], bcs) ;

	jandder andder(bas, bbs, band) ;
	jena ande(1'b0, bdec[4], wco) ;
	jenabler enaand(band, bdec[4], bcs) ;

	jnotter n(bas, bnot) ;
	jena note(1'b0, bdec[3], wco) ;
	jenabler enanot(bnot, bdec[3], bcs) ;

	wire woshl ;
	jshiftl shitfl(bas, wci, bshl, woshl) ;
	jena sle(woshl, bdec[2], wco) ;
	jenabler enashl(bshl, bdec[2], bcs) ;

	wire woshr ;
	jshiftr shiftr(bas, wci, bshr, woshr) ;
	jena sre(woshr, bdec[1], wco) ;
	jenabler enashr(bshr, bdec[1], bcs) ;

	wire aco ;
	wire [7:0] acs ;
	jadder adder(bas, bbs, wci, acs, aco) ;
	jena adde(aco, bdec[0], wco) ;
	jenabler enaadd(acs, bdec[0], bcs) ;

	jzero z(bcs, wz) ;
endmodule


/*
func NewALU(bas *g.Bus, bbs *g.Bus, wci *g.Wire, bops *g.Bus, bcs *g.Bus, wco *g.Wire, weqo *g.Wire, walo *g.Wire, wz *g.Wire) *ALU {
	// Build the ALU circuit
	bdec := g.NewBus(8)
	NewDecoder(bops, bdec)
	bdec.GetWire(7).SetPower(false)
	bdec.GetWire(7).SetTerminal()

	bxor := g.NewBus(bas.GetSize())
	NewXORer(bas, bbs, bxor, weqo, walo)
	NewEnabler(bxor, bdec.GetWire(6), bcs)

	bor := g.NewBus(bas.GetSize())
	NewORer(bas, bbs, bor)
	NewEnabler(bor, bdec.GetWire(5), bcs)

	band := g.NewBus(bas.GetSize())
	NewANDder(bas, bbs, band)
	NewEnabler(band, bdec.GetWire(4), bcs)

	bnot := g.NewBus(bas.GetSize())
	NewNOTter(bas, bnot)
	NewEnabler(bnot, bdec.GetWire(3), bcs)

	bshl := g.NewBus(bas.GetSize())
	woshl := g.NewWire()
	NewShiftLeft(bas, wci, bshl, woshl)
	g.NewAND(woshl, bdec.GetWire(2), wco)
	NewEnabler(bshl, bdec.GetWire(2), bcs)

	bshr := g.NewBus(bas.GetSize())
	woshr := g.NewWire()
	NewShiftRight(bas, wci, bshr, woshr)
	g.NewAND(woshr, bdec.GetWire(1), wco)
	NewEnabler(bshr, bdec.GetWire(1), bcs)

	add := NewADDer(bas, bbs, wci, g.NewBus(bas.GetSize()), g.NewWire())
	g.NewAND(add.co, bdec.GetWire(0), wco)
	NewEnabler(add.cs, bdec.GetWire(0), bcs)

	NewZero(bcs, wz)
*/
