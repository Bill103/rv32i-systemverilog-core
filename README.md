# RV32I SystemVerilog Soft Core (Ongoing)

![Status](https://img.shields.io/badge/Status-Work_In_Progress-orange)
![Language](https://img.shields.io/badge/Language-SystemVerilog-blue)
![Tools](https://img.shields.io/badge/Tools-Icarus_Verilog_%7C_GTKWave-lightgrey)

A 32-bit pipelined microprocessor built from scratch in SystemVerilog, targeting full compliance with the RISC-V RV32I base integer instruction set.

The core implements a classic 5-stage RISC pipeline (IF, ID, EX, MEM, WB) featuring full hazard mitigation.

## Repository Structure

The project is organized as follows:
* **`src/`**: Synthesizable RTL (Fetch, Decode, Execute, Memory, Control)
* **`tb/`**: Component-level unit tests and top-level integration testbenches
* **`programs/`**: Assembly sources files and compiled `.hex` machine code

## Architecture Progress

**Pipelined Datapath & Hazard Unit**
- [x] Classic 5-Stage Pipeline Registers (IF/ID, ID/EX, EX/MEM, MEM/WB)
- [x] Forwarding Unit
- [x] Hazard Detection Unit
- [x] Control Hazard Unit
- [x] Internal Register File write-through forwarding

**Core Execution & Storage:**
- [x] Arithmetic Logic Unit (ALU) - Supports all 10 base integer operations
- [x] Synchronous Register File (32x32-bit, `x0` hardwired to zero)
- [x] Immediate Generator (Decodes I, S, B, U, and J type instructions)
- [x] Intruction Memory (ROM) & Data Memory (RAM)
- [x] Top-Level CPU Integration & Wiring

## Toolchain & Simulation

This core is designed and verified using open-source EDA tools on Linux.

* **Simulator:** [Icarus Verilog](http://iverilog.icarus.com/) (`iverilog`)
* **Waveform Viewer:** [GTKWave](https://gtkwave.sourceforge.net/)

### Quick Start: Fibonacci Sequence

The core has been verified by executing a custom assembly program that calculates the first 10 number of the Fibonacci sequence and stores them in memory.

To run the top-leven integration test yourself:
```bash
#1. Compile the main datapath and testbench
iverlog -g2012 -o core.out src/control/*.sv src/decode/*.sv src/execute/*.sv src/fetch/*.sv src/memory/*.sv src/core.sv tb/core_tb.sv

#2. Execute the simultation
vvp core.out

#3. View the results in GTKWave
gtkwave core.vcd
```

### Quick Start: Pipeline Integration Test

The core is verified with a pipeline hazard test suite exercising RAW forwarding, memory store-to-load dependencies, load-use interlocks and branch squashing.

To run the top-level integration test:

```bash
# 1. Compile the pipelined core and testbench
iverilog -g2012 -o core.out \
    src/fetch/*.sv \
    src/decode/*.sv \
    src/execute/*.sv \
    src/memory/*.sv \
    src/control/*.sv \
    src/pipeline/*.sv \
    src/core.sv \
    src/tb/core_tb.sv

# 2. Execute the simulation
vvp core.out

# 3. View the results
gtkwave core.vcd
```