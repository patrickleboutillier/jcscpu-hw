# How to use the JCSCPU Basys-3 ALU Demo

The demo uses different modes to allow the user to try out the differents operations of the ALU. 

# Reference

![](https://reference.digilentinc.com/_media/basys3_hardware_walkaround.png)

The following IO elements of the Basys-3 board are used in the demo:

## Seven-Segment Display (callout #4)
The seven-segment display shows the current demo mode. Here is the list of the demo modes:
* addr
* shr
* shl
* notr
* andr
* orr
* xorr

## Push buttons (callout #7)
* _BTNU_: The top button is used to move to the previous demo mode. 
* _BTND_: The bottom button is used to move to the previous demo mode.
* _BTNL_: When pressed, sets the "carry in" (_CI_) input to 1 for the various ALU components.

## Switches (_SW15_ through _SW0_) (callout #5)
Switches are used to control the input bits to the ALU. Byte A is _SW[7:0]_ and byte B is _SW[15:8]_.

## LEDs (_LD15_ through _LD0_) (callout #6)
LEDs are used to indicate the output values for the various components.
* _LD15_: "carry out" (_CO_) flag.
* _LD14_: "equal out" (_EQO_) flag.
* _LD13_: "a-larger out" (_ALO_) flag.
* _LD12_: "zero" (_Z_) flag.
* _lD11_: 0
* _LD[10:8]_: The operation mode of the ALU (binary values 000 through 110).
* _LD[7:0]_: Byte C, the output of the ALU.

# Modes

### addr(A, B, ci) => (C, co)
"addr" connects the inputs and the outputs with an ADDER circuit (page 79).
* A = _SW[15:8]_
* B = _SW[7:0]_
* ci => _CI_
* C = _LD[7:0]_
* co => _CO_

### shr(A, si) => (B, so)
"shr" connects the inputs and the outputs with a SHIFTR circuit (page 73).
* A = _SW[7:0]_
* B = _LD[7:0]_
* si = _CI_
* so = _CO_

### shl(A, si) => (B, so)
"shl" connects the inputs and the outputs with a SHIFTL circuit (page XX).
* A = _SW[7:0]_
* B = _LD[7:0]_
* si = _CI_
* so = _CO_

### notr(A) => (B)
"notrr" connects the inputs and the output with an NOTTER circuit (page 75).
* A = _SW[7:0]_
* B = _LD[7:0]_

### andr(A, B) => (C)
"andr" connects the inputs and the output with an ANDDER circuit (page 76).
* A = _SW[15:8]_
* B = _SW[7:0]_
* C = _LD[7:0]_

### orr(A, B) => (C)
"orr" connects the inputs and the output with an ORER circuit (page 77).
* A = _SW[15:8]_
* B = _SW[7:0]_
* C = _LD[7:0]_

### xorr(A, B) => (C, eqo, alo)
"xorr" connects the inputs and the outputs with an XORER (actually a comparator) circuit (page 78, 80).
* A = _SW[15:8]_
* B = _SW[7:0]_
* C = _LD[7:0]_
* eqo = _EQO_
* alo = _ALO_
