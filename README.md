# MIPS32 Single-Cycle & Pipelined Processors

VHDL implementations of a 32-bit single-cycle processor and a five-stage pipelined processor.

**Development period:** March – June 2026

## Project Overview

The project explores two processor architectures through RTL implementation, FPGA synthesis and hardware experimentation.

### Single-Cycle Processor

- 32-bit MIPS-based datapath
- Instruction fetch and decode units
- Arithmetic logic unit (ALU)
- Main control unit
- 32-register register file
- Instruction and data memory
- Branch and jump control
- Register write-back

### Pipelined Processor

Five-stage processor architecture:

- Instruction Fetch (IF)
- Instruction Decode (ID)
- Execution (EX)
- Memory Access (MEM)
- Write Back (WB)

The implementation integrates four intermediate pipeline registers: IF/ID, ID/EX, EX/MEM and MEM/WB.

Data and control hazards are addressed through manual instruction scheduling and NOP insertion.

## Technologies

- VHDL
- Xilinx Vivado
- Nexys A7-100T
- Xilinx Artix-7 FPGA

## Hardware Interface

The processor designs include push-button-controlled execution and seven-segment display output for inspecting internal processor signals.

## Repository Structure

- `single-cycle/` — Single-cycle processor source code and documentation.
- `pipelined/` — Pipelined processor source code and documentation.

Each directory contains the corresponding VHDL modules and synthesized schematic.

## Documentation

- [Single-Cycle Schematic](single-cycle/schematic.pdf)
- [Pipelined Schematic](pipelined/MipsPipelineSchematic.pdf)
