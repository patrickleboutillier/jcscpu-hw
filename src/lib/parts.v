
// Gate-based memory as shown in the book 
module jmemory(input wi, input ws, output wo) ;
	wire wa, wb, wc ;
 	jnand nand1(wi, ws, wa) ;
	jnand nand2(wa, ws, wb) ;
	jnand nand3(wa, wc, wo) ;
	jnand nand4(wo, wb, wc) ;
endmodule


// Latch-based memory, which can yield a predictable output value.
module jlatch(input wi, input ws, output wo) ;
	reg ro = 0 ;
	assign wo = ro ;
    always @(wi or ws) begin
        if (ws)
            ro <= wi ;
    end
endmodule


// Flip-flop based memory, which is more commonly used in FPGAs.
module jrmem(input clk, input wi, input ws, output reg wo) ;
	always @(posedge clk) begin
		if (ws)
			wo <= wi ;
	end
endmodule


module jbyte(input [7:0] bis, input ws, output [7:0] bos) ;
	genvar j ;
	generate
		for (j = 0; j < 8 ; j = j + 1) begin
			jmemory mem(bis[j], ws, bos[j]) ;
		end
	endgenerate
endmodule


module jrbyte(input clk, input [7:0] bis, input ws, output [7:0] bos) ;
	genvar j ;
	generate
		for (j = 0; j < 8 ; j = j + 1) begin
			jrmem mem(clk, bis[j], ws, bos[j]) ;
		end
	endgenerate
endmodule


module jregister(input [7:0] bis, input ws, input we, inout [7:0] bos) ;
	wire [7:0] bus ;
	jbyte byte(bis, ws, bus) ;
	jenabler enabler(bus, we, bos) ;
endmodule


module jrreg(input clk, input [7:0] bis, input ws, input we, inout [7:0] bos) ;
	wire [7:0] bus ;
	jrbyte byte(clk, bis, ws, bus) ;
	jenabler enabler(bus, we, bos) ;
endmodule


module jena(input wi, input we, inout wo) ;
	wire out ;
	jand a(wi, we, out) ;
	assign wo = (we) ? out : 1'bz ;
endmodule


module jenabler(input [7:0] bis, input we, inout [7:0] bos) ;
	genvar j ;
	generate
		for (j = 0; j < 8 ; j = j + 1) begin
			wire out ;
			jand a(bis[j], we, out) ;
			assign bos[j] = (we) ? out : 1'bz ;
		end
	endgenerate
endmodule


module jdecoder #(parameter N=2, N2=4) (input [N-1:0] bis, output [N2-1:0] bos) ;
    wire [1:0] wmap[N-1:0] ;

	// Create our wire map
    genvar j ;
    generate
        for (j = 0; j < N ; j = j + 1) begin
			jnot notj(bis[j], wmap[j][0]) ;
			assign wmap[j][1] = bis[j] ;
        end
    endgenerate

    genvar k ;
    generate
        for (j = 0; j < N2 ; j = j + 1) begin
			wire [N-1:0] wos ;
        	for (k = 0; k < N ; k = k + 1) begin
				assign wos[k] = wmap[k][j[k]] ;
			end
			jandN #(N) andNj(wos, bos[j]) ;
        end
    endgenerate
endmodule


module jbus1 (input [7:0] bis, input wbit1, output [7:0] bos) ;
	wire wnbit1 ;
	jnot n(wbit1, wnbit1) ;

	genvar j ;
	for (j = 0 ; j < 8 ; j = j + 1) begin
		if (j > 0) begin
			jand andj(bis[j], wnbit1, bos[j]) ;
		end else begin
			jor orj(bis[j], wbit1, bos[j]) ;
		end
	end
endmodule