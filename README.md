# FPGA Design of a Floating Point Unit (FPU)

## Introduction
The objective of this project is to design, simulate, and implement a Floating Point Unit on a Zedboard FPGA.

## Lab Steps
The lab consists of the following steps:

1. **Design and behavioral simulation of a single cycle FP Adder:** Design a single-cycle Floating Point Adder and verify its functionality using a Verilog testbench.
2. **Design and behavioral simulation of a pipelined FP Adder:** Pipeline the FP Adder design into two stages for improved performance.
3. **FP Adder in FPGA with 7 segment display output:** Implement the 2-stage FP Adder on the Zedboard and display the results using the onboard LEDs and a 7-segment display module.
4. **Use Buttons to provide multiple inputs to the FP Adder:** Add a Data Memory module to store multiple inputs for the FP Adder. Use the Zedboard buttons to cycle through the inputs and display the corresponding outputs.

## Repository Contents
* **fpadd_single.v:** Verilog code for the single-cycle FP Adder.
* **fpadd_pipeline.v:** Verilog code for the pipelined FP Adder.
* **SevenSegmentDisplay.v:** Verilog code for the 7-segment display module.
* **DataMemory.v:** Verilog code for the Data Memory module.
* **fpadd_system.v:** Top-level Verilog file instantiating the FP Adder, 7-segment displays, and Data Memory.
* **fp_add.xdc:** Xilinx Design Constraints file for specifying pin assignments and timing constraints.
* ***.hex:** Test files containing input and expected output data.

## Getting Started
1. Download and install the Xilinx Vivado toolset.
2. Clone this repository to your local machine.
3. Open the Vivado project file for the desired lab step.
4. Follow the instructions in the lab manual to complete the design, simulation, and implementation steps.

## Additional Notes
* The lab manual provides detailed instructions on each step of the lab, including how to use the Vivado tools.
* The XDC file contains pin assignments for the Zedboard. If you are using a different FPGA board, you will need to modify the pin assignments accordingly.
