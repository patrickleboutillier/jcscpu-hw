
	reg [31:0] tv, errors ; // bookkeeping variables
	reg [0:`OUTLEN+`INLEN-1] tvs[0:`NBLINES-1] ; // array of testvectors

	initial begin // Will execute at the beginning once
		$dumpfile(`DUMPFILE) ;
		$dumpvars ;
		$readmemb(`TVFILE, tvs) ; // Read vectors
		tv = 0; errors = 0; // Initialize
		reset = 1; #970; reset = 0; 
	end

	// generate test clock
	reg tclk ;
	always begin 
		tclk = 1; #100; tclk = 0; #100; // 200ns period
	end

	// generate system clock
	always begin
		sclk = 1 ;
		#50 ;
		sclk = 0 ;
		#200 ;
		sclk = 1 ;
		#150 ; // 400ns period
	end

	// apply test vectors on rising edge of tclk
	reg [0:`OUTLEN-1] expected ;
	always @(posedge tclk) begin
		if (~reset) begin
			#10; {in[0:`INLEN-1], expected[0:`OUTLEN-1]} = tvs[tv] ;
		end
	end

	// check results on falling edge of tclk
	reg [3*8:0] bang ;
	always @(negedge tclk)
		if (~reset) begin
			if (`VERBOSE == 1) begin
				$display("inputs = %b, outputs = %b (%b expected)", 
					in[0:`INLEN-1], out[0:`OUTLEN-1], expected[0:`OUTLEN-1]) ;
			end
			if (out[0:`OUTLEN-1] !== expected[0:`OUTLEN-1]) begin
				$display("Error: line = %d, inputs = %b, outputs = %b (%b expected)", tv+1, 
					in[0:`INLEN-1], out[0:`OUTLEN-1], expected[0:`OUTLEN-1]) ;
				errors = errors + 1 ;
			end

			// increment array index and read next testvector
			tv = tv + 1 ;
			if (tvs[tv][0] === 1'bx) begin
				bang = (errors == 0) ? "" : "!!!" ;
				$display("%d/%d tests completed with %d errors %s", tv, `NBLINES, errors, bang) ;
				$finish; // End simulation
			end
		end
endmodule
