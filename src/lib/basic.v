`timescale 1ns / 1ps


module jnand(input wa, input wb, output wc) ;
	nand #1 x(wc, wa, wb) ;
endmodule


module jnot(input wa, output wb) ;
	jnand x(wa, wa, wb) ;
endmodule


module jand(input wa, input wb, output wc) ;
	wire w ;
	jnand x(wa, wb, w) ;
	jnot y(w, wc) ;
endmodule


module jor(input wa, input wb, output wc) ;
	wire wic, wid ;
	jnot n1(wa, wic) ;
	jnot n2(wb, wid) ;
	jnand x(wic, wid, wc) ;
endmodule


module jxor(input wa, input wb, output wc) ;
	wire wic, wid, wie, wif ;
	jnot not1(wa, wic) ;
	jnot not2(wb, wid) ;
	jnand nand1(wic, wb, wie) ;
	jnand nand2(wa, wid, wif) ;
	jnand nand3(wie, wif, wc) ;
endmodule


module jbuf(input wa, output wb) ;
	jand x(wa, wa, wb) ;
endmodule


module jandN #(parameter N=2) (input [N-1:0] bis, output wo) ;
	wire [N-2:0] os ;
	
	jand and0(bis[0], bis[1], os[0]) ;

	genvar j ;
	generate
	    for (j = 0; j < (N - 2); j = j + 1) begin
	        jand andj(os[j], bis[j+2], os[j+1]) ;
	    end
	endgenerate

	assign wo = os[N-2] ;
endmodule


module jorN #(parameter N=2) (input [N-1:0] bis, output wo) ;
	wire [N-2:0] os ;
	
	jor or0(bis[0], bis[1], os[0]) ;

	genvar j ;
	generate
	    for (j = 0; j < (N - 2); j = j + 1) begin
	        jor orj(os[j], bis[j+2], os[j+1]) ;
	    end
	endgenerate

	assign wo = os[N-2] ;
endmodule


module jenabler(input [7:0] bis, input we, output [7:0] bos) ;
	genvar j ;
	generate
	    for (j = 0; j < 8 ; j = j + 1) begin
	        jand a(bis[j], we, bos[j]) ;
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
    generate
	for (j = 0 ; j < 8 ; j = j + 1) begin
	    if (j > 0) begin
	        jand andj(bis[j], wnbit1, bos[j]) ;
	    end else begin
	        jor orj(bis[j], wbit1, bos[j]) ;
	    end
	end
    endgenerate
endmodule
