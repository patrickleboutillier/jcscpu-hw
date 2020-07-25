`timescale 1ns / 1ps


module jRAM (input [7:0] bas, input wsa, input [7:0] bis, input ws, input we, output wor [7:0] bos) ;
	wire [7:0] busd ;
	reg on = 1 ;
	jmregister MAR(bas, wsa, on, busd) ;

	localparam n = 4 ;
	localparam n2 = 16 ;
	wire [15:0] wxs, wys ;
	jdecoder #(4, 16) decx(busd[7:4], wxs) ;
	jdecoder #(4, 16) decy(busd[3:0], wys) ;

	genvar x, y ;
	generate
		for (x = 0 ; x < n2 ; x = x + 1) begin
			for (y = 0 ; y < n2 ; y = y + 1) begin
				wire wxo, wso, weo ;
				jand and1(wxs[x], wys[y], wxo) ;
				jand and2(wxo, ws, wso) ;
				jand and3(wxo, we, weo) ;

				jmregister regxy(bis, wso, weo, bos) ;
			end
		end
	endgenerate
endmodule


module jRAMBlock (input [7:0] bas, input wsa, input [7:0] bis, input ws, input we, output wor [7:0] bos) ;
	wire [7:0] busd ;
	jmregister MAR(bas, wsa, 1'b1, busd) ;

	reg [7:0] RAM[0:255] ;
	assign bos = (we) ? RAM[busd] : 0 ;
	always @(ws) begin
		if (ws)
			RAM[busd] = bis ;
	end
endmodule


/*
func NewRAMClassic(bas *g.Bus, wsa *g.Wire, bio *g.Bus, ws *g.Wire, we *g.Wire) *RAM {
	// Build the RAM circuit
	on := g.WireOn()
	busd := g.NewBus(bas.GetSize())
	mar := NewRegister(bas, wsa, on, busd, "MAR")

	n := bas.GetSize() / 2
	n2 := 1 << n
	wxs := g.NewBus(n2)
	wys := g.NewBus(n2)
	NewDecoder(g.WrapBus(busd.GetWires()[0:n]), wxs)
	NewDecoder(g.WrapBus(busd.GetWires()[n:busd.GetSize()]), wys)

	// Now we create the circuit
	cells := make([]*Register, n2*n2, n2*n2)
	for x := 0; x < n2; x++ {
		for y := 0; y < n2; y++ {
			// Create the subcircuit to be used at each location
			wxo := g.NewWire()
			wso := g.NewWire()
			weo := g.NewWire()
			g.NewAND(wxs.GetWire(x), wys.GetWire(y), wxo)
			g.NewAND(wxo, ws, wso)
			g.NewAND(wxo, we, weo)
			idx := (x * n2) + y

			cells[idx] = NewRegister(bio, wso, weo, bio, fmt.Sprintf("RAM[%d]", idx))
		}
	}

	this := &RAM{bas, bio, wsa, ws, we, mar, cells, n2 * n2, false, -1, nil}

	return this
}
*/
