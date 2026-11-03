# RV32I SystemVerilog Soft Core (Ongoing)

![Status](https://img.shields.io/badge/Status-Work_In_Progress-orange)
![Language](https://img.shields.io/badge/Language-SystemVerilog-blue)
![Tools](https://img.shields.io/badge/Tools-Icarus_Verilog_%7C_GTKWave-lightgrey)
![FPGA](https://img.shields.io/badge/FPGA-Artix--7%20xc7a35t-red)
![Synthesis](https://img.shields.io/badge/Vivado-2026.1-green)

A 32-bit pipelined microprocessor built from scratch in SystemVerilog, targeting full compliance with the RISC-V RV32I base integer instruction set.

The core implements a classic 5-stage RISC pipeline (IF, ID, EX, MEM, WB) featuring full hazard mitigation.

## Repository Structure

The project is organized as follows:
* **`src/`**: Synthesizable RTL and FPGA top-level wrapper
* **`ip/`**: Vivado Clocking Wizard IP (`clk_wiz_0.xci`)
* **`timing.xdc`**: Timing and pin load constraints
* **`reports/`**: Post-implementation timing, utilization, power, and DRC reports
* **`tb/`**: Component-level unit tests and top-level integration testbenches
* **`programs/`**: Assembly source files, compiled `.hex`, and `.mem` memory initialization files
* **`scripts/`**: Automation scripts for simulation and test execution

## Architecture Progress

**Pipelined Datapath & Hazard Unit:**
- [x] Classic 5-Stage Pipeline Registers (IF/ID, ID/EX, EX/MEM, MEM/WB)
- [x] Forwarding Unit
- [x] Hazard Detection Unit
- [x] Control Hazard Unit
- [x] Internal Register File write-through forwarding

**Core Execution & Storage:**
- [x] Arithmetic Logic Unit (ALU) - Supports all 10 base integer operations
- [x] Synchronous Register File (32x32-bit, `x0` hardwired to zero)
- [x] Immediate Generator (Decodes I, S, B, U, and J type instructions)
- [x] Instruction Memory (ROM) & Data Memory (RAM)
- [x] Top-Level CPU Integration & Wiring

**FPGA Synthesis & Implementation:**
- [x] Top-level FPGA wrapper (`fpga_top`) with MMCM clock generation and reset synchronization
- [x] Timing closure achieved on AMD Xilinx Artix-7 @ 50 MHz

---

## FPGA Implementation & Synthesis

The core has been synthesized and implemented using **AMD Vivado**, targeting a **Xilinx Artix-7** (`xc7a35tcsg324-1`).

* **Operating Clock:** 50.0 MHz (derived from 100 MHz board clock via MMCM `clk_wiz_0`)
* **Timing:** **MET** (WNS: **+8.043 ns**, theoretical $F_{\max} \approx 83.6\text{ MHz}$)
* **Resource Utilization:** **570 Slice LUTs** (2.74%), **271 Registers** (0.65%), **155 Slices**, **0.5 BRAM** Tile
* **Total On-Chip Power:** **0.179 W** (108 mW dynamic, 70 mW device static)

The top-level wrapper is located in [`src/fpga.sv`](src/fpga.sv) and constraints in [`timing.xdc`](timing.xdc). Full post-route utilization, timing summary, power, and DRC reports are available in the [`reports/`](reports/) directory.

---

## Toolchain & Simulation

This core is designed and verified using open-source EDA tools on Linux.

* **Simulator:** [Icarus Verilog](http://iverilog.icarus.com/) (`iverilog`)
* **Waveform Viewer:** [GTKWave](https://gtkwave.sourceforge.net/)

### Quick Start: Fibonacci Sequence

The core has been verified by executing a custom assembly program that calculates the first 10 numbers of the Fibonacci sequence and stores them in memory.

To run the top-level integration test yourself:
```bash
# 1. Compile the main datapath and testbench
iverilog -g2012 -o core.out src/control/*.sv src/decode/*.sv src/execute/*.sv src/fetch/*.sv src/memory/*.sv src/core.sv tb/core_tb.sv

# 2. Execute the simulation
vvp core.out

# 3. View the results in GTKWave
gtkwave core.vcd
```

### Quick Start: Pipeline Integration Test

The core is verified with a pipeline hazard test suite exercising RAW forwarding, memory store-to-load dependencies, load-use interlocks, and branch squashing.

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
    tb/core_tb.sv

# 2. Execute the simulation
vvp core.out

# 3. View the results
gtkwave core.vcd
```

### Automated Tests

The Tcl runner compiles and executes the integration and component testbenches with Icarus Verilog. Run the complete suite from the repository root:

```bash
tclsh scripts/run_tests.tcl
```

Run one or more selected tests:

```bash
tclsh scripts/run_tests.tcl core alu
```

Compiled simulation binaries are written to `build/tcl/`. Each testbench contains its own `$fatal` assertions, so a test passes when compilation and simulation exit successfully. Assertion failures propagate as a nonzero simulation exit status and fail the Tcl run.
