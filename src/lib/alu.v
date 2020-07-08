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


module jandder (input [0:`ARCH_BITS-1] bas, input [0:`ARCH_BITS-1] bbs, output [0:`ARCH_BITS-1] bcs) ;
	genvar j ;
	for (j = 0; j < `ARCH_BITS ; j = j + 1) begin
		jand nj(bas[j], bbs[j], bcs[j]) ;
	end
endmodule


module jorer (input [0:`ARCH_BITS-1] bas, input [0:`ARCH_BITS-1] bbs, output [0:`ARCH_BITS-1] bcs) ;
	genvar j ;
	for (j = 0; j < `ARCH_BITS ; j = j + 1) begin
		jor oj(bas[j], bbs[j], bcs[j]) ;
	end
endmodule


module jzero (input [0:`ARCH_BITS-1] bis, output wz) ;
	wire wi ;
	jorN #(`ARCH_BITS) orn(bis, wi) ;
	jnot n(wi, wz) ;
endmodule


module jbus1 (input [0:`ARCH_BITS-1] bis, input wbit1, output [0:`ARCH_BITS-1] bos) ;
	wire wnbit1 ;
	jnot n(wbit1, wnbit1) ;

	genvar j ;
	for (j = 0 ; j < `ARCH_BITS ; j = j + 1) begin
		if (j < `ARCH_BITS-1) begin
			jand andj(bis[j], wnbit1, bos[j]) ;
		end else begin
			jor orj(bis[j], wbit1, bos[j]) ;
		end
	end
endmodule


/*


func NewADDer(bas *g.Bus, bbs *g.Bus, wci *g.Wire, bcs *g.Bus, wco *g.Wire) *ADDer {
	// Build the ADDer circuit
	twci := g.NewWire()
	twco := wco
	for j := 0; j < bas.GetSize(); j++ {
		tw := twci
		if j == (bas.GetSize() - 1) {
			tw = wci
		}
		g.NewADD(bas.GetWire(j), bbs.GetWire(j), tw, bcs.GetWire(j), twco)
		twco = twci
		twci = g.NewWire()
	}
	return &ADDer{bas, bbs, bcs, wci, wco}
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


*/
