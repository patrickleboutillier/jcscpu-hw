

module jshiftr (input [0:7] bis, input wci, output [0:7] bos, output wco) ;
	jbuf b0(wci, bos[0]) ;
	
	genvar j ;
	for (j = 1; j < 8 ; j = j + 1) begin
		jbuf bj(bis[j-1], bos[j]) ;
	end
	jbuf bn(bis[7], wco) ;
endmodule


module jshiftl (input [0:7] bis, input wci, output [0:7] bos, output wco) ;
	jbuf b0(bis[0], wco) ;
	
	genvar j ;
	for (j = 1; j < 8 ; j = j + 1) begin
		jbuf bj(bis[j], bos[j-1]) ;
	end
	jbuf bn(wci, bos[7]) ;
endmodule


module jnotter (input [7:0] bis, output [7:0] bos) ;
	genvar j ;
	for (j = 0; j < 8 ; j = j + 1) begin
		jnot nj(bis[j], bos[j]) ;
	end
endmodule


module jandder (input [7:0] bas, input [7:0] bbs, output [7:0] bcs) ;
	genvar j ;
	for (j = 0; j < 8 ; j = j + 1) begin
		jand nj(bas[j], bbs[j], bcs[j]) ;
	end
endmodule


module jorer (input [7:0] bas, input [7:0] bbs, output [7:0] bcs) ;
	genvar j ;
	for (j = 0; j < 8 ; j = j + 1) begin
		jor oj(bas[j], bbs[j], bcs[j]) ;
	end
endmodule


module jxorer (input [7:0] bas, input [7:0] bbs, output [7:0] bcs, output weqo, output walo) ;
	// Build the XORer circuit
	reg one = 1 ;
	reg zero = 0 ;
	wire [0:6] teqo, talo ;

	genvar j ;
	jcmp cmp0(bas[0], bbs[0], one, zero, bcs[0], teqo[0], talo[0]) ;
	for (j = 1; j < 7 ; j = j + 1) begin
		jcmp cmpj(bas[j], bbs[j], teqo[j-1], talo[j-1], bcs[j], teqo[j], talo[j]) ;
	end
	jcmp cmpn(bas[7], bbs[7], teqo[6], talo[6], bcs[7], weqo, walo) ;
endmodule


module jadder (input [7:0] bas, input [7:0] bbs, input wci, output [7:0] bcs, output wco) ;
	wire [0:6] tc ;

	genvar j ;
	jadd add0(bas[0], bbs[0], wci, bcs[0], tc[0]) ;
	for (j = 1; j < 7; j = j + 1) begin
		jadd addj(bas[j], bbs[j], tc[j-1], bcs[j], tc[j]) ;
	end
	jadd addn(bas[7], bbs[7], tc[6], bcs[7], wco) ;
endmodule


module jzero (input [7:0] bis, output wz) ;
	wire wi ;
	jorN #(8) orn(bis, wi) ;
	jnot n(wi, wz) ;
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
