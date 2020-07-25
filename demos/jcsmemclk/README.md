# How to use the JCSCPU Basys-3 MEmory & Clock Demo

The memory and clock demo uses different modes to allow the user to try out the memory and clock components that build up the JCS CPU. 

# Reference

![](https://reference.digilentinc.com/_media/basys3_hardware_walkaround.png)

The following IO elements of the Basys-3 board are used in the demo:

## Seven-Segment Display (callout #4)
The seven-segment display shows the current demo mode. Here is the list of the demo modes:
* mem
* reg
* clk
* step

## Push buttons (callout #7)
* _BTNU_: The top button is used to move to the previous demo mode.
* _BTND_: The bottom button is used to move to the previous demo mode.
* _BTNL_: When pressed, sets the "enable" (_ENA_) input to 1 for the various circuits that use it.
* _BTNR_: When pressed, sets the "set" (_SET_) input to 1 for the various circuits that use it.

## Switches (_SW15_ through _SW0_) (callout #5)
Switches are used to control the input bits to the various components. Only _SW[7:0]_ are used in this demo.

## LEDs (_LD15_ through _LD0_) (callout #6)
LEDs are used to indicate the output values for the various components.

# Modes

### mem(i, s) => (o)
"mem" connects the inputs and the output with an MEM circuit (page 26).
* i = _SW0_
* s = _SET_
* o = _LD0_

### reg(I, s, e) => (O)
* i = _SW[7:0]_
* s = _SET_
* e = _ENA_
* o = _LD[7:0]_

### clk => (clk, clkd, clke, clks)
"clk" provide the clock for the system. It is seeded with the FPGA system clockconnects the inputs and the outputs with a ADD circuit (page 80).
* clk = _LD3_
* clkd = _LD2_
* clke = _LD1_
* clks = _LD0_

### step => (O)
"step" connects the inputs and the outputs with a CMP circuit (page 83).
* O = _LD[15:10]_
