`include "src/defs.v"


module jshiftr (input [0:`ARCH_BITS-1] bis, input wci, output [0:`ARCH_BITS-1] bos, output wco) ;
	jbuf b0(wci, bos[0]) ;
	
	genvar j ;
	for (j = 1; j < `ARCH_BITS ; j = j + 1) begin
		jbuf bj(bis[j-1], bos[j]) ;
	end
	jbuf bn(bis[`ARCH_BITS-1], wco) ;
endmodule


module jshiftl (input [0:`ARCH_BITS-1] bis, input wci, output [0:`ARCH_BITS-1] bos, output wco) ;
	jbuf b0(bis[0], wco) ;
	
	genvar j ;
	for (j = 1; j < `ARCH_BITS ; j = j + 1) begin
		jbuf bj(bis[j], bos[j-1]) ;
	end
	jbuf bn(wci, bos[`ARCH_BITS-1]) ;
endmodule


module jnotter (input [0:`ARCH_BITS-1] bis, output [0:`ARCH_BITS-1] bos) ;
	genvar j ;
	for (j = 0; j < `ARCH_BITS ; j = j + 1) begin
		jnot nj(bis[j], bos[j]) ;
	end
endmodule


/*
func NewANDder(bas *g.Bus, bbs *g.Bus, bcs *g.Bus) *ANDder {
	this := &ANDder{bas, bbs, bcs}
	for j := 0; j < bas.GetSize(); j++ {
		g.NewAND(bas.GetWire(j), bbs.GetWire(j), bcs.GetWire(j))
	}
	return this
}

func NewORer(bas *g.Bus, bbs *g.Bus, bcs *g.Bus) *ORer {
	this := &ORer{bas, bbs, bcs}
	for j := 0; j < bas.GetSize(); j++ {
		g.NewOR(bas.GetWire(j), bbs.GetWire(j), bcs.GetWire(j))
	}
	return this
}

func NewXORer(bas *g.Bus, bbs *g.Bus, bcs *g.Bus, weqo *g.Wire, walo *g.Wire) *XORer {
	// Build the XORer circuit
	weqi := g.WireOn()
	wali := g.WireOff()
	for j := 0; j < bas.GetSize(); j++ {
		teqo := g.NewWire()
		talo := g.NewWire()
		te := teqo
		ta := talo
		if j == (bas.GetSize() - 1) {
			te = weqo
			ta = walo
		}
		g.NewCMP(bas.GetWire(j), bbs.GetWire(j), weqi, wali, bcs.GetWire(j), te, ta)
		weqi = teqo
		wali = talo
	}
	return &XORer{bas, bbs, bcs, weqo, walo}
}

func NewZero(bis *g.Bus, wz *g.Wire) *Zero {
	// Build the ZERO circuit
	wi := g.NewWire()
	g.NewORn(bis, wi)
	g.NewNOT(wi, wz)
	return &Zero{bis, wz}
}

func NewBus1(bis *g.Bus, wbit1 *g.Wire, bos *g.Bus) *Bus1 {
	// Build the BUS1 circuit
	wnbit1 := g.NewWire()
	g.NewNOT(wbit1, wnbit1)
	// Foreach AND circuit, connect to the wires.
	for j := 0; j < bis.GetSize(); j++ {
		if j < (bis.GetSize() - 1) {
			g.NewAND(bis.GetWire(j), wnbit1, bos.GetWire(j))
		} else {
			g.NewOR(bis.GetWire(j), wbit1, bos.GetWire(j))
		}
	}
	return &Bus1{bis, bos, wbit1}
}

*/
