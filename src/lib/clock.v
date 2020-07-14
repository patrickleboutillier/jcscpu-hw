

module jclock (input clk, input reset, output reg wclk, output reg wclkd, output wclke, output wclks) ;
	always @(posedge clk) begin
		if (reset)
			wclk <= 0 ;
		else
			wclk <= ~wclk ;
	end

	always @(negedge clk) begin
		if (reset)
			wclkd <= 0 ;
		else
			wclkd <= ~wclkd ;
	end

	jor or1(wclk, wclkd, wclke) ;
	jand and1(wclk, wclkd, wclks) ;
endmodule


// Flip-flop based memory, which is more commonly used in FPGAs.
module rmem(input reset, input wi, input ws, output wo) ;
	jlatch l(wi, ws, wo) ;
	//jmemory l(wi, ws, wo) ;
endmodule


module jstepper (input clk, input reset, output [0:6] bos, output [0:6] more) ;
	reg wrst = 0 ;
	// Loop around to wrst
	// assign wrst = bos[6] ;

	wire wnrm1, wnco1, wmsn, wmsnn ;
	jnot not1(wrst, wnrm1) ;
	jnot not2(clk, wnco1) ;
	jor or1(wrst, wnco1, wmsn) ;
	jor or2(wrst, clk, wmsnn) ;

	// M1
	wire wn12b, wm112 ;
	jor s1(wrst, wn12b, bos[0]) ;
	rmem m1(reset, wnrm1, wmsn, wm112) ;

	// M12
	wire wn12a ;
	jnot not12(wn12a, wn12b) ;
	rmem m12(reset, wm112, wmsnn, wn12a) ;

	assign more[0:5] = {wrst, wnrm1, wmsn, wm112, wmsnn, wn12a} ;

	// M2
	wire wn23b, wm223 ;
	jand s2(wn12a, wn23b, bos[1]) ;
	rmem m2(reset, wn12a, wmsn, wm223) ;

	// M23
	wire wn23a ;
	jnot not23(wn23a, wn23b) ;
	rmem m23(reset, wm223, wmsnn, wn23a) ;

	/*
	// M3
	wire wn34b, wm334 ;
	jand s3(wn23a, wn34b, bos[2]) ;
	rmem m3(sclk, reset, wn23a, wmsn, wm334) ;

	// M34
	wire wn34a ;
	jnot not34(wn34a, wn34b) ;
	rmem m34(sclk, reset, wm334, wmsnn, wn34a) ;

	// M4
	wire wn45b, wm445 ;
	jand s4(wn34a, wn45b, bos[3]) ;
	rmem m4(sclk, reset, wn34a, wmsn, wm445) ;

	// M45
	wire wn45a ;
	jnot not45(wn45a, wn45b) ;
	rmem m45(sclk, reset, wm445, wmsnn, wn45a) ;

	// M5
	wire wn56b, wm556 ;
	jand s5(wn45a, wn56b, bos[4]) ;
	rmem m5(sclk, reset, wn45a, wmsn, wm556) ;

	// M56
	wire wn56a ;
	jnot not56(wn56a, wn56b) ;
	rmem m56(sclk, reset, wm556, wmsnn, wn56a) ;

	// M6
	wire wn67b, wm667 ;
	jand s6(wn56a, wn67b, bos[5]) ;
	rmem m6(sclk, reset, wn56a, wmsn, wm667) ;

	// M67
	jnot not67(bos[6], wn67b) ;
	rmem m67(sclk, reset, wm667, wmsnn, bos[6]) ;
	*/

	//jbuf rloop(bos[6], wrst) ;
endmodule


