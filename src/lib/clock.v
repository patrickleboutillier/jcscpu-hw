`timescale 1ns / 1ps


/*
    The clock is a bit tricky as it must start high and kick off the stepper at a very specific place.
*/
module jclock (input clk, input reset, output wclk, output wclkd, output wclke, output wclks) ;
	reg settling = 1 ;
	reg rclk = 1 ;
	reg rclkd = 0 ;
	assign wclk = rclk ;
	assign wclkd = rclkd ;
	
	always @(posedge clk) begin
		if (reset) begin
			rclk <= 1 ;
		end else if (! settling) begin
			rclk <= ~rclk ;
		end
	end

	always @(negedge clk) begin
		if (reset) begin
			rclkd <= 0 ;
			settling <= 1 ;
		end else if (settling) begin
			settling <= 0 ;
			rclkd <= 1 ;
		end else begin
			rclkd <= ~rclkd ;
		end
	end

	jor or1(wclk, wclkd, wclke) ;
	jand and1(wclk, wclkd, wclks) ;
endmodule


`define SMEM jmemory
module jstepper (input clk, input reset, output [0:5] bos) ;
	wire wrst, bos6 ;

	// Loop around to wrst
	assign wrst = bos6 ;

	wire wnrm1, wnco1, wmsn, wmsnn ;
	jnot not1(wrst, wnrm1) ;
	jnot not2(clk, wnco1) ;
	//jor or1(wrst, wnco1, wmsn) ;
	assign #1 wmsn = wrst | wnco1 ;
	jor or2(wrst, clk, wmsnn) ;

	// M1
	wire wn12b, wm112 ;
	jor s1(wrst, wn12b, bos[0]) ;
	`SMEM m1(reset ? 1'b0 : wnrm1, reset | wmsn, wm112) ;

	// M12
	wire wn12a ;
	jnot not12(wn12a, wn12b) ;
	`SMEM m12(reset ? 1'b0 : wm112, reset | wmsnn, wn12a) ;

	// M2
	wire wn23b, wm223 ;
	jand s2(wn12a, wn23b, bos[1]) ;
	`SMEM m2(reset ? 1'b0 : wn12a, reset | wmsn, wm223) ;

	// M23
	wire wn23a ;
	jnot not23(wn23a, wn23b) ;
	`SMEM m23(reset ? 1'b0 : wm223, reset | wmsnn, wn23a) ;

	// M3
	wire wn34b, wm334 ;
	jand s3(wn23a, wn34b, bos[2]) ;
	`SMEM m3(reset ? 1'b0 : wn23a, reset | wmsn, wm334) ;

	// M34
	wire wn34a ;
	jnot not34(wn34a, wn34b) ;
	`SMEM m34(reset ? 1'b0 : wm334, reset | wmsnn, wn34a) ;

	// M4
	wire wn45b, wm445 ;
	jand s4(wn34a, wn45b, bos[3]) ;
	`SMEM m4(reset ? 1'b0 : wn34a, reset | wmsn, wm445) ;

	// M45
	wire wn45a ;
	jnot not45(wn45a, wn45b) ;
	`SMEM m45(reset ? 1'b0 : wm445, reset | wmsnn, wn45a) ;

	// M5
	wire wn56b, wm556 ;
	jand s5(wn45a, wn56b, bos[4]) ;
	`SMEM m5(reset ? 1'b0 : wn45a, reset | wmsn, wm556) ;

	// M56
	wire wn56a ;
	jnot not56(wn56a, wn56b) ;
	`SMEM m56(reset ? 1'b0 : wm556, reset | wmsnn, wn56a) ;

	// M6
	wire wn67b, wm667 ;
	jand s6(wn56a, wn67b, bos[5]) ;
	`SMEM m6(reset ? 1'b0 : wn56a, reset | wmsn, wm667) ;

	// M67
	jnot not67(bos6, wn67b) ;
	`SMEM m67(reset ? 1'b0 : wm667, reset | wmsnn, bos6) ;
endmodule


// Latch-based memory, which can yield a predictable output value.
module jlatch(input reset, input wi, input ws, output reg wo) ;
    always @(wi or ws) begin
        if (reset)
            wo <= 0 ;
        else if (ws)
            wo <= #5 wi ;
    end
endmodule


module jstepcnt (input clk, input reset, output reg [0:5] bos) ;
    always @(posedge clk) begin
        if (reset || bos == 6'b000001)
            bos <= 6'b100000 ;
        else 
            bos <= bos >> 1 ;
    end
endmodule
