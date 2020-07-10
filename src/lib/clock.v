`include "src/defs.v"


module jclock (input ref_clk, input reset, output reg wclk, output wclke, output wclks) ;
	always @(posedge ref_clk) begin
		if (reset)
			wclk <= 1'b0 ;
		else
			wclk <= ~wclk ;
	end

	reg wclkd ;
	always @(negedge ref_clk) begin
		if (reset)
			wclkd <= 1'b0 ;
		else
			wclkd <= ~wclkd ;
	end

	jor or1(wclk, wclkd, wclke) ;
	jand and1(wclk, wclkd, wclks) ;
endmodule
