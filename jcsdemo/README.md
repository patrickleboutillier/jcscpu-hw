# How to use the JCSCPU Basys-3 Demo

The demo uses different modes to allow the user to try out the different components that build up the CPU. 

## Reference

![](https://reference.digilentinc.com/_media/basys3_hardware_walkaround.png)

The following IO elements of the Basys-3 board are used in the demo:

### Seven Segment Display (#4)
The sevent segment display displays the current demo mode. Here is the lists of the demo modes:
* buf
* not
* nand
* and
* or
* xor
* add
* cmp

### Push buttons (#7)
* _BTNU_: The top button is used to toggle between the different demo modes.
* _BTNL_: When pressed, sets the "carry in" (_CI_) input to 1 for the various ALU components.
* _BTNC_: When pressed, sets the "equal in" (_EQI_) input to 1 for the various ALU components.
* _BTNR_: When pressed, sets the "a-larger in" (_ALI_) input to 1 for the various ALU components.

### Switches (_SW15_ through _SW0_) (#5)
Switches are used to control the input bits to the various components.

### LEDs (_LD15_ through _LD0_) (#6)
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
"add" connects the inputs and the output with a ADD circuit (page 80).
* a = _SW1_
* b = _SW0_
* ci = _CI_
* c = _LD0_
* co = _CO_

### cmp
"cmp" connects the inputs and the output with a CMP circuit (page 83).
* a = _SW1_
* b = _SW0_
* eqi = _EQI_
* ali = _ALI_
* c = _LD0_
* eqo = _EQO_
* alo = _ALO_
* co = _CO_
