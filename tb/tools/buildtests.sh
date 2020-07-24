#!/bin/bash

for f in tb/out/*.v ; do
	[ -f $f ] || continue
	SRC=
	[ -f ${f}_src ] && source ${f}_src
	iverilog -Wall -o tb/out/`basename $f .v`.vvp src/lib/*.v $SRC $f || exit 1
done
