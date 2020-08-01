`timescale 1ns / 1ps


// Gate-based memory as shown in the book 
module jmemory(input wi, input ws, output wo) ;
	wire wa, wb, wc ;
 	jnand nand1(wi, ws, wa) ;
	jnand nand2(wa, ws, wb) ;
	jnand nand3(wa, wc, wo) ;
	jnand nand4(wo, wb, wc) ;
endmodule


module jbyte(input [7:0] bis, input ws, output [7:0] bos) ;
	genvar j ;
	generate
		for (j = 0; j < 8 ; j = j + 1) begin
			jmemory mem(bis[j], ws, bos[j]) ;
		end
	endgenerate
endmodule


module jregister(input [7:0] bis, input ws, input we, output [7:0] bos) ;
	wire [7:0] bus ;
	jbyte byte(bis, ws, bus) ;
	jenabler enabler(bus, we, bos) ;
endmodule
