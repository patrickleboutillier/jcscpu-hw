

module jclock (input clk, output reg wclk, output reg wclkd, output wclke, output wclks) ;
	always @(posedge clk) begin
		wclk <= ~wclk ;
	end

	always @(negedge clk) begin
		wclkd <= ~wclkd ;
	end

	jor or1(wclk, wclkd, wclke) ;
	jand and1(wclk, wclkd, wclks) ;
endmodule


module jstepper (input clk, output [0:6] bos) ;
	wire wrst, wnrm1, wncol, wmsn, wmsnn ;
	jnot not1(wrst, wnrm1) ;
	jnot not2(wclk, wnco1) ;
	jor or1(wrst, wnco1, wmsn) ;
	jor or2(wrst, wclk, wmsnn) ;

	// M1
	wire wn12b, wm112 ;
	jor s1(wrst, wn12b, bos[0]) ;
	jmemory m1(wnrm1, wmsn, wm112) ;

	// M12
	wire wn12a ;
	jnot not12(wn12a, wn12b) ;
	jmemory m12(wm112, wmsnn, wn12a) ;

	// M2
	wire wn23b, wm223 ;
	jand s2(wn12a, wn23b, bos[1]) ;
	jmemory m2(wn12a, wmsn, wm223) ;

	// M23
	wire wn23a ;
	jnot not23(wn23a, wn23b) ;
	jmemory m23(wm223, wmsnn, wn23a) ;

    /*
	// M3
	wn34b := g.NewWire()
	s3 := g.NewAND(wn23a, wn34b, bos[2])
	wm334 := g.NewWire()
	m3 := NewNamedMemory(wn23a, wmsn, wm334, " 3")

	// M34
	wn34a := g.NewWire()
	g.NewNOT(wn34a, wn34b)
	m34 := NewNamedMemory(wm334, wmsnn, wn34a, "34")

	// M4
	wn45b := g.NewWire()
	s4 := g.NewAND(wn34a, wn45b, bos[3])
	wm445 := g.NewWire()
	m4 := NewNamedMemory(wn34a, wmsn, wm445, " 4")

	// M45
	wn45a := g.NewWire()
	g.NewNOT(wn45a, wn45b)
	m45 := NewNamedMemory(wm445, wmsnn, wn45a, "45")

	// M5
	wn56b := g.NewWire()
	s5 := g.NewAND(wn45a, wn56b, bos[4])
	wm556 := g.NewWire()
	m5 := NewNamedMemory(wn45a, wmsn, wm556, " 5")

	// M56
	wn56a := g.NewWire()
	g.NewNOT(wn56a, wn56b)
	m56 := NewNamedMemory(wm556, wmsnn, wn56a, "56")

	// M6
	wn67b := g.NewWire()
	s6 := g.NewAND(wn56a, wn67b, bos[5])
	wm667 := g.NewWire()
	m6 := NewNamedMemory(wn56a, wmsn, wm667, " 6")

	// M67
	g.NewNOT(bos.GetWire(6), wn67b)
	m67 := NewNamedMemory(wm667, wmsnn, bos.GetWire(6), "67")
	s7 := bos.GetWire(6) ;
	*/
	
	// Finally, loop step 7 to the reset Wire.
	jbuf rloop(bos[6], wrst) ;

endmodule