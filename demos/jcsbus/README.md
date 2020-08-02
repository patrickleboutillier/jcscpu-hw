# How to use the JCSCPU Basys-3 BUS Demo

The demo uses different modes to allow the user to transfer data to and from differents registers and components. 

# Reference

![](https://reference.digilentinc.com/_media/basys3_hardware_walkaround.png)

The following IO elements of the Basys-3 board are used in the demo:

## Seven-Segment Display (callout #4)
The seven-segment display shows the current demo mode. Here is the list of the demo modes:
* data
* r0
* r1
* r2
* r3
* tmp
* acc
* mar
* ram

## Push buttons (callout #7)
* _BTNU_: The top button is used to move to the previous demo mode. 
* _BTND_: The bottom button is used to move to the previous demo mode.
* _BTNL_: When pressed, sets the "enable" (_ENA_) input to 1 for the selected component.
* _BTNR_: When pressed, sets the "set" (_SET_) input to 1 for the selected component.

## Switches (_SW15_ through _SW0_) (callout #5)
Switches are used to specify the input bits for the DATA mode, and to indicate the desired mode for the ALU (_SW[15:13]_).

## LEDs (_LD15_ through _LD0_) (callout #6)
LEDs are used to indicate the output values for the various components.
* _LD15_: Always off.
* _LD14_: Turns on if the current register's _ENA_ input is on.
* _LD[13:11]_: Always off.
* _LD10_: Turns on if the current register's _SET_ input is on.
* _LD[9:8]_: Always off.
* _LD[7:0]_: The value on the BUS when the _ENA_ button is pressed.

# Modes

### data
"data" uses the _ENA_ button to enable the bits _SW[7:0]_ onto the BUS.
* e = _ENA_

### r0, r1, r2, r3
"rX" connects _ENA_ and _SET_ to the enable and set wire of the specified register.
* s = _SET_
* e = _ENA_

### tmp
"tmp" connects _SET_ to set wire of the TMP register.
* s = _SET_

### acc
"acc" connects _ENA_ and _SET_ to the enable and set wire of the ACC register.
* s = _SET_
* e = _ENA_

### mar
"mar" connects _SET_ to the set wire of the MAR register.
* s = _SET_

### ram
"ram" connects _ENA_ and _SET_ to the enable and set wire of the RAM module.
* s = _SET_
* e = _ENA_
