`timescale 1ns / 1ps


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
            ro <= #5 wi ;
    end
endmodule


module jlbyte(input [7:0] bis, input ws, output [7:0] bos) ;
	genvar j ;
	generate
		for (j = 0; j < 8 ; j = j + 1) begin
			jlatch mem(bis[j], ws, bos[j]) ;
		end
	endgenerate
endmodule


module jmbyte(input [7:0] bis, input ws, output [7:0] bos) ;
	genvar j ;
	generate
		for (j = 0; j < 8 ; j = j + 1) begin
			jmemory mem(bis[j], ws, bos[j]) ;
		end
	endgenerate
endmodule


module jlregister(input [7:0] bis, input ws, input we, output [7:0] bos) ;
	wire [7:0] bus ;
	jlbyte byte(bis, ws, bus) ;
	jenabler enabler(bus, we, bos) ;
endmodule


module jmregister(input [7:0] bis, input ws, input we, output [7:0] bos) ;
	wire [7:0] bus ;
	jmbyte byte(bis, ws, bus) ;
	jenabler enabler(bus, we, bos) ;
endmodule
