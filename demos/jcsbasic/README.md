# How to use the JCSCPU Basys-3 Basic Demo

The basic demo uses different modes to allow the user to try out the components that build up the JCS CPU. 

# Reference

![](https://reference.digilentinc.com/_media/basys3_hardware_walkaround.png)

The following IO elements of the Basys-3 board are used in the demo:

## Seven-Segment Display (callout #4)
The seven-segment display shows the current demo mode. Here is the list of the demo modes:
* step
* clk
* reg
* mem
* **buf**
* not
* nand
* and
* or
* xor
* add
* cmp
* dec3

## Push buttons (callout #7)
* _BTNU_: The top button is used to move to the previous demo mode.* 
* _BTND_: The bottom button is used to move to the previous demo mode.
* _BTNL_: When pressed, sets the "carry in" (_CI_) input to 1 for the various circuits that use it. Also used as the _SET_ button for memories. 
* _BTNC_: When pressed, sets the "a-larger in" (_ALI_) input to 1 for the various circuits that use it.
* _BTNR_: When pressed, sets the "equal in" (_EQI_) input to 1 for the various circuits that use it. Also used as the _ENA_ button for registers.

## Switches (_SW15_ through _SW0_) (callout #5)
Switches are used to control the input bits to the various components. Most of the time, _SW[7:0]_ are used, with _SW[15:8]_ begin added if the circuit requires 2 bytes of inputs.

## LEDs (_LD15_ through _LD0_) (callout #6)
LEDs are used to indicate the output values for the various components.
* _LD15_: "carry out" (_CO_) flag.
* _LD14_: "equal out" (_EQO_) flag.
* _LD13_: "a-larger out" (_ALO_) flag.
* _LD[7:0]_: Output bits for the various components.

# Modes

## Simple gates and combinational circuits 

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

### dec3(I) => (O)
"dec3" connects the input and the outputs with a DECODER(3x8) circuit (page 48).
* I = _SW[2:0]_
* O = _LD[7:0]_


## Memory and sequantial circuits

### mem(i, s) => (o)
"mem" connects the inputs and the output with an MEMORY circuit (page 24).
* i = _SW1_
* s = _SW0_
* o = _LD0_

### reg(I, s, e) => (O)
"reg" connects the inputs and the output with a REGISTER circuit (page 41).
* I = _SW[7:0]_
* s = _SET_
* e = _ENA_
* O = _LD[7:0]_

### clk => (clk, clkd, clke, clks)
"clk" provides a CLOCK signal (page 96), sourced (and divided) using the onboard 100MHz clock.
* clk = _LD3_
* clkd = _LD2_
* clke = _LD1_
* clks = _LD0_

### step(clk) => (O)
"step" implements a STEPPER (page 102). The stepper uses latch-based memories as the power-on value must be initialized to 0.
* clk = _LD[3:0]_
* O = _LD[15:10]_
