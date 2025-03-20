# Lab 3

**Prerequisites**:
- Mono Pulse Generator
- Seven Segment Display
- A Top-Level Module where the above two are declared + instantiated along with the input + output ports from the schematic below
- MOST IMPORTANT: **An understanding of how to analyze and put schematics to code**

## Main Test Environment (Top Level Module)
![Test Env](./README/test_env.svg)

All of the exercises (necessary components) below will go into the "Black Box" section of the schematic.  

_Remember_: **UNLESS EXPLICITELY STATED, DO NOT CREATE ADDITIONAL FILES FOR COMPONENTS, JUST DIRECLTY IMPLEMENT IN THE TOP-LEVEL MODULE**  

Once you're ready with a certain assignment, then please raise your hand and show your implementation to the teacher. If everything is alright, then please upload your code to the repo before proceeding to another assignment.

## Exercise 1 - Const val to 7SD
![Ex 1](./README/2025-ex1.svg)

## Exercise 2 - Counter to 7SD
![Ex 2](./README/2025-ex2.svg)

## Exercise 3 - ALU
![Ex 3](./README/2025-ex3.svg)

## Read Only Memory
![ROM](./README/Lab3-ROM.svg)

## Register File
**IMPORTANT**: The _Reg File_ must be a separate entity (implement in its own file and then declare + instantiate in the top-level module)
![RegFile](./README/Lab3-RF.svg)

## Random Access Memory
**IMPORTANT**: The _RAM_ must be a separate entity (implement in its own file and then declare + instantiate in the top-level module)
![RAM](./README/Lab3-RAM.svg)

Please be aware that the RAM must be implemented using **WRITE-FIRST** mode. For reference, please have a look at the _Language Templates_ (the light bulb icon) and then  
`VHDL` --> `Synthesis Constructs` --> `Coding Examples` --> `RAM` --> `Block RAM` --> `Single Port` --> `Write First Mode`

![WFLangTemp](./README/ram_lang_temp.png)
