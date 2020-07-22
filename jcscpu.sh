#!/bin/bash

usage() {
	echo "$0 CPU_FILE" >&2
	exit 1
}

FILE=$1
[ -z $FILE ] && usage
if [ ! -f "$FILE" ] ; then
	echo "Can't find CPU file '$FILE'!" >&2
	exit 1
fi

cat $FILE | sed 's/#/\/\//' > /tmp/mem
size=$(cat /tmp/mem | wc -l)
for (( i=$size ; i < 256 ; i++ )) ; do
	echo '01100001 // HALT' >> /tmp/mem
done


cat <<'V' > /tmp/v
`timescale 1ns / 1ps

module jcscpu() ;
    reg sclk, reset ;

	// generate system clock
	always begin
		sclk = 1 ;
		#50 ;
		sclk = 0 ;
		#200 ;
		sclk = 1 ;
		#150 ; // 400ns period
	end
V

cat src/main.v >> /tmp/v

cat <<'V' >> /tmp/v
	jclock localclk(sclk, reset, CLK_clk, CLK_clkd, CLK_clke, CLK_clks) ;
	jstepper STP(CLK_clk, reset, STP_bus) ;

	// RAM
    wire [7:0] ram_bus ;
    jregister MAR(bus, ram_mar_s, 1'b1, ram_bus) ;
    reg [7:0] RAM[0:255] ;
    initial $readmemb("/tmp/mem", RAM) ;

    assign bus = (ram_e) ? RAM[ram_bus] : 0 ;
    always @(ram_s) begin
        if (ram_s)
            RAM[ram_bus] = bus ;
    end

    jCU x(
      .CLK_clk(CLK_clk), .CLK_clkd(CLK_clkd), .CLK_clke(CLK_clke), .CLK_clks(CLK_clks), .STP_bus(STP_bus),
      .flags_co(flags_co), .flags_eqo(flags_eqo), .flags_alo(flags_alo), .flags_z(flags_z),
      .ir_bus(ir_bus),
      .alu_op(alu_op),
      .alu_ena_ci(alu_ena_ci), .flags_s(flags_s), .tmp_s(tmp_s), .bus1_bit1(bus1_bit1), .acc_s(acc_s), .acc_e(acc_e),
      .r0_s(r0_s), .r0_e(r0_e), .r1_s(r1_s), .r1_e(r1_e), .r2_s(r2_s), .r2_e(r2_e), .r3_s(r3_s), .r3_e(r3_e),
      .ram_mar_s(ram_mar_s), .ram_s(ram_s), .ram_e(ram_e),
      .iar_s(iar_s), .iar_e(iar_e), .ir_s(ir_s), .halt(halt),
      .io_s(io_s), .io_e(io_e), .io_da(io_da), .io_io(io_io)
    ) ;

	always @(*) begin
		if (halt) begin
			$display("System halted!") ;
			$finish ;
		end
	end

	// Poor man's TTY
	always @(io_data) begin
		if (io_dev == 0)
			$display("%c", io_data) ;
	end

	//initial $monitor("bus=%b", bus) ;
	//initial $monitor("io_s=%b, io_e=%b, io_da=%b, io_io=%b", io_s, io_e, io_da, io_io) ;
endmodule
V

iverilog -Wall -o /tmp/jcscpu.vvp src/lib/*.v /tmp/v && vvp /tmp/jcscpu.vvp
