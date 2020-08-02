# How to use the JCSCPU Basys-3 Clock & Stepper Demo

The clock and stepper demo uses different modes to allow the user to try out the clock and stepper components that build up the JCS CPU. 

# Reference

![](https://reference.digilentinc.com/_media/basys3_hardware_walkaround.png)

The following IO elements of the Basys-3 board are used in the demo:

## Seven-Segment Display (callout #4)
The seven-segment display shows the current demo mode. Here is the list of the demo modes:
* clk
* step

## Push buttons (callout #7)
* _BTNU_: The top button is used to move to the previous demo mode.
* _BTND_: The bottom button is used to move to the previous demo mode.

## Switches (_SW15_ through _SW0_) (callout #5)
Not used in this demo.

## LEDs (_LD15_ through _LD0_) (callout #6)
LEDs are used to indicate the output values for the various components.

# Modes

### clk => (clk, clkd, clke, clks)
"clk" provide the clock for the system. It is seeded with the FPGA system clockconnects the inputs and the outputs with a ADD circuit (page 80).
* clk = _LD3_
* clkd = _LD2_
* clke = _LD1_
* clks = _LD0_


### step => (O)
"step" connects the inputs and the outputs with a CMP circuit (page 83). _clke_ and _clks_ are visible at _LD[15:14]_.
* O = _LD[13:8]_
