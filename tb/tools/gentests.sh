#!/bin/bash

if [ -n "$VERBOSE" ] ; then
	VERBOSE=1
else 
	VERBOSE=0
fi

for f in tb/tv/*.tv ; do
	g=`basename $f .tv`
	{
		echo '`timescale 1ns / 1ps'
		echo 
		echo 
		echo "module test() ;"
		echo
		echo '    `define VERBOSE '$VERBOSE
		echo '    `define TVFILE "'$f'"'
		echo '    `define DUMPFILE "'tb/out/${g}.vcd'"'
		NBLINES=$(grep ^[01xz] $f | wc -l)
		echo '    `define NBLINES '$NBLINES
		echo
		echo '    reg sclk, reset ;'
		echo
		cat $f | grep ^// | sed 's/^\/\//   /'
		echo
    	echo '    reg [0:`INLEN-1] in = 0 ;'
	    echo '    wire [0:`OUTLEN-1] out ;'
		echo
		cat tb/tools/template.v

		if [ -f ${f}_mod ] ; then
			cat ${f}_mod 
		fi
	} > tb/out/${g}.v
	if [ -f ${f}_src ] ; then
		cp ${f}_src tb/out/${g}.v_src
	fi
done
