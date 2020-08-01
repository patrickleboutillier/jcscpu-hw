`timescale 1ns / 1ps


module jRAM (input [7:0] bas, input wsa, input [7:0] bis, input ws, input we, output wor [7:0] bos) ;
	wire [7:0] busd ;
	jregister MAR(bas, wsa,  1'b1, busd) ;

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

				jregister regxy(bis, wso, weo, bos) ;
			end
		end
	endgenerate
endmodule


module jRAMBlock (input [7:0] bas, input wsa, input [7:0] bis, input ws, input we, output wor [7:0] bos) ;
	wire [7:0] busd ;
	jregister MAR(bas, wsa, 1'b1, busd) ;

	reg [7:0] RAM[0:255] ;
	assign bos = (we) ? RAM[busd] : 0 ;
	always @(ws or busd or bis) begin
		if (ws)
			RAM[busd] = bis ;
	end
endmodule
