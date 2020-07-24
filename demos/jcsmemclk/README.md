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
* stp

## Push buttons (callout #7)
* _BTNU_: The top button is used to move to the previous demo mode.
* _BTND_: The bottom button is used to move to the previous demo mode.
* _BTNL_: When pressed, sets the "enable" (_ENA_) input to 1 for the various circuits that use it.
* _BTNR_: When pressed, sets the "set" (_SET_) input to 1 for the various circuits that use it.

## Switches (_SW15_ through _SW0_) (callout #5)
Switches are used to control the input bits to the various components. Only _SW[7:0]_ are used in this demo.

## LEDs (_LD15_ through _LD0_) (callout #6)
LEDs are used to indicate the output values for the various components.
* _LD[15:14]_: clee and clks signals of the clk.
* _LD[13:8]_: Steps of the stepper.
* _LD[7:0]_: Output bits for the various components.

# Modes
