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
* bus1
* acc
* mar
* ram

## Push buttons (callout #7)
* _BTNU_: The top button is used to move to the previous demo mode. 
* _BTND_: The bottom button is used to move to the previous demo mode.
* _BTNL_: When pressed, sets the "enable" (_ENA_) input to 1 for the selected component. Also used as the _BIT1_ button for the bus1 circuit.
* _BTNR_: When pressed, sets the "set" (_SET_) input to 1 for the selected component.

## Switches (_SW15_ through _SW0_) (callout #5)
Switches are used to specify the input bits for the DATA mode, and to indicate the desired mode for the ALU.

## LEDs (_LD15_ through _LD0_) (callout #6)
LEDs are used to indicate the output values for the various components.
* _LD15_: "carry out" (_CO_) flag.
* _LD14_: "equal out" (_EQO_) flag.
* _LD13_: "a-larger out" (_ALO_) flag.
* _LD12_: "zero" (_Z_) flag.
* _lD11_: Always 0.
* _LD[10:8]_: The operation mode of the ALU (binary values 000 through 110).
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
"tmp" connects _SET_ to set wire of the specified TMP register.
* s = _SET_

### bus1
"bus1" uses the _ENA_ button to enable the BIT1 bit of the BUS1 circuit.
* e = _ENA_

### acc
"acc" connects _ENA_ and _SET_ to the enable and set wire of the specified register.
* s = _SET_
* e = _ENA_
