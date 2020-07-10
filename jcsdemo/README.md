# How to use the JCSCPU Basys-3 Demo

The demo uses different modes to allow the user to try out the components that build up the JCS CPU. 

## Reference

![](https://reference.digilentinc.com/_media/basys3_hardware_walkaround.png)

The following IO elements of the Basys-3 board are used in the demo:

### Seven Segment Display (callout #4)
The sevent segment display displays the current demo mode. Here is the lists of the demo modes:
* buf
* not
* nand
* and
* or
* xor
* add
* cmp
* shr
* shl
* andr
* orr
* xorr
* addr
* zero
* bus1

### Push buttons (callout #7)
* _BTNU_: The top button is used to mode the previous demo mode.* 
* _BTND_: The bottom button is used to mode the previous demo mode.
* _BTNL_: When pressed, sets the "carry in" (_CI_) input to 1 for the various ALU components. Also used for the "bit1" signal of the BUS1 circuit. 
* _BTNC_: When pressed, sets the "a-larger in" (_ALI_) input to 1 for the various ALU components.
* _BTNR_: When pressed, sets the "equal in" (_EQI_) input to 1 for the various ALU components.


### Switches (_SW15_ through _SW0_) (callout #5)
Switches are used to control the input bits to the various components.

### LEDs (_LD15_ through _LD0_) (callout #6)
LEDs are used to indicate the output values for the various components.
* _LD15_: "carry out" (_CO_) flag.
* _LD14_: "equal out" (_EQO_) flag.
* _LD13_: "a-larger out" (_ALO_) flag.
* _LD12_: "zero" (_Z_) flag.
* _LD[7:0]_: Output bits for the various components.

## Modes

### buf(a) => (b)
"buf" simply connects the input to the output (not in book, but is the inverse of NOT).
* a = _SW0_
* b = _LD0_

### not(a) => (b)
"not" connects the input and the output with a NOT circuit (page 18).
* a = _SW0_
* b = _LD0_

### nand(a, b) => (c)
"nand" connects the inputs and the output with a NAND gate (page 16).
* a = _SW1_
* b = _SW0_
* c = _LD0_

### and(a, b) => (c)
"and" connects the inputs and the output with an AND circuit (pge 19).
* a = _SW1_
* b = _SW0_
* c = _LD0_

### or(a, b) => (c)
"or" connects the inputs and the output with an OR circuit (page 69).
* a = _SW1_
* b = _SW0_
* c = _LD0_

### xor(a, b) => (c)
"xor" connects the inputs and the output with a XOR circuit (page 70).
* a = _SW1_
* b = _SW0_
* c = _LD0_

### add(a, b, ci) => (c, co)
"add" connects the inputs and the outputs with a ADD circuit (page 80).
* a = _SW1_
* b = _SW0_
* ci = _CI_
* c = _LD0_
* co = _CO_

### cmp(a, b, eqi, ali) => (c, eqo, alo, co)
"cmp" connects the inputs and the outputs with a CMP circuit (page 83).
* a = _SW1_
* b = _SW0_
* eqi = _EQI_
* ali = _ALI_
* c = _LD0_
* eqo = _EQO_
* alo = _ALO_
* co = _CO_

### shr(A, si) => (B, so)
"shr" connects the inputs and the outputs with a SHIFTR circuit (page XX).
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

### andr(A, B) => (C)
"andr" connects the inputs and the output with an ANDDER circuit (page XX).
* A = _SW[15:8]_
* B = _SW[7:0]_
* C = _LD[7:0]_

### orr(A, B) => (C)
"orr" connects the inputs and the output with an ORER circuit (page XX).
* A = _SW[15:8]_
* B = _SW[7:0]_
* C = _LD[7:0]_

### xorr(A, B) => (C, eqo, alo)
"xorr" connects the inputs and the outputs with an XORER circuit (page XX).
* A = _SW[15:8]_
* B = _SW[7:0]_
* C = _LD[7:0]_
* eqo = _EQO_
* alo = _ALO_

### addr(A, B, ci) => (C, co)
"addr" connects the inputs and the outputs with an AADDER circuit (page XX).
* A = _SW[15:8]_
* B = _SW[7:0]_
* ci => _CI_
* C = _LD[7:0]_
* co => _CO_

### zero(A) => (zero)
"zero" connects the inputs and the outputs with an ZERO circuit (page XX).
* A = _SW[7:0]_
* zero = _Z_

### bus1(A, bit1) => (B)
"bus1" connects the inputs and the output with an BUS1 circuit (page XX).
* A = _SW[7:0]_
* bit1 => _CI_
* B => _LD[7:0]_
