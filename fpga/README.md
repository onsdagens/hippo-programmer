# Minimal FPGA example

This example assumes a Digilent Arty A7 dev board.

It instantiates a memory, and a simple interface using buttons and LEDs.

The current memory address starts at 0, and can be incremented by 1 by pressing button 0.
The current memory address can be reset back to 0 by pressing button 1.

The value of the byte under the current memory address is displayed using the RGB LEDs as a bit display.
For instance bit 0 of current memory output corresponds to the red channel of LED 0, and bit 4 corresponds to the blue channel of the same LED.

The memory can be programmed (in tests we use [ftdaye](https://github.com/onsdagens/ftdaye), you can refer to example `ftdaye_mpsse`, for an idea on how to work with this.).

By pressing button 2, the byte 'hA7 is written to the current memory location.

Since programming is bytewise, to test the word-wide interface, the memory can also be "defaced" via the button interface.
By pressing button 3, 'h0DEFACED is written to the current memory address.

We intend to eventually extend upon `ftdaye` to make it more usable, for now this is future work.

## Building
By running
```
bender update
vivado -mode tcl -source init_project.tcl
```
a synthesizeable Vivado 2023.2 project is expected to be created.
