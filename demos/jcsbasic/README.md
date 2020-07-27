# How to use the JCSCPU Basys-3 Basic Demo

The basic demo uses different modes to allow the user to try out the components that build up the JCS CPU. 

# Reference

![](https://reference.digilentinc.com/_media/basys3_hardware_walkaround.png)

The following IO elements of the Basys-3 board are used in the demo:

## Seven-Segment Display (callout #4)
The seven-segment display shows the current demo mode. Here is the list of the demo modes:

* nand
* not
* and
* or
* xor
* dec3
* ena
* bus1

## Push buttons (callout #7)
* _BTNU_: The top button is used to move to the previous demo mode.* 
* _BTND_: The bottom button is used to move to the previous demo mode.
* _BTNL_: When pressed, sets the "enable" (_ENA_) input to 1 for the various circuits that use it. Also used as the _BIT1_ button for the bus1 circuit. 

## Switches (_SW15_ through _SW0_) (callout #5)
Switches are used to control the input bits to the various components. Most of the time, _SW[7:0]_ are used, with _SW[15:8]_ begin added if the circuit requires 2 bytes of inputs.

## LEDs (_LD15_ through _LD0_) (callout #6)
LEDs are used to indicate the output values for the various components.
* _LD[7:0]_: Output bits for the various components.

# Modes

## Simple gates

### nand(a, b) => (c)
"nand" connects the inputs and the output with a NAND gate (page 16).
* a = _SW1_
* b = _SW0_
* c = _LD0_

### not(a) => (b)
"not" connects the input and the output with a NOT circuit (page 18).
* a = _SW0_
* b = _LD0_

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


## Simple combinational circuits 

### dec3(I) => (O)
"dec3" connects the input and the outputs with a DECODER(3x8) circuit (page 48).
* I = _SW[2:0]_
* O = _LD[7:0]_

### ena(I, e) => (O)
"ena" connects the inputs and the output with a ENABLER circuit (page 40).
* I = _SW[7:0]_
* e = _ENA_
* O = _LD[7:0]_

### bus1(I, bit1) => (O)
"bus1" connects the inputs and the output with a BUS1 circuit (page 40).
* I = _SW[7:0]_
* bit1 = _ENA_
* O = _LD[7:0]_

