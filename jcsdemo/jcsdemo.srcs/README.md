# How to use the JSCCPU Basys-3 Demo

The demo uses different modes to allow the user to try out the different components that build up the CPU. The following IO elements of the Basys-3 board are used in the demo:

### Seven Segment Display
The sevent segment display displays the current demo mode. Here is the lists of the demo modes:
* buf
* not
* nand
* and
* or
* xor
* add
* cmp

### Push buttons
* BTNU: The top button is used to toggle between the different demo modes.
* BTNL: When pressed, sets the "carry in" (CI) input to 1 for the various ALU components.
* BTNC: When pressed, sets the "equal in" (EQI) input to 1 for the various ALU components.
* BTNR: When pressed, sets the "A-larger in" (ALI) input to 1 for the various ALU components.

### Switches (SW15 through SW0)

### LEDs (LD15 through LD0)

## Modes

### buf(a) => (b)
"buf" simply connects the input to the output
* a = SW0
* b = LD0
