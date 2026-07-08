# RV32I SystemVerilog Soft Core (Ongoing)

![Status](https://img.shields.io/badge/Status-Work_In_Progress-orange)
![Language](https://img.shields.io/badge/Language-SystemVerilog-blue)
![Tools](https://img.shields.io/badge/Tools-Icarus_Verilog_%7C_GTKWave-lightgrey)

A 32-bit single-cycle microprocessor built from scratch in SystemVerilog, targeting full compliance with the RISC-V RV32I base integer instruction set.

This project is currently under active development. The primary goal is to build a fully synthesizable RTL core capable of executing bare-metal C binaries, prioritizing clean sequential logic and modular datapath design.

## 🛠️ Architecture Progress

**Execution Datapath:**
- [x] Arithmetic Logic Unit (ALU) - Supports all 10 base integer operations
- [x] Synchronous Register File (32x32-bit, `x0` hardwired to zero)
- [x] Immediate Generator (Decodes I, S, B, U, and J type instructions)
- [x] Program Counter (PC) & Branch Adder
- [x] Control Unit & ALU Decoder

**Memory & Interconnect:**
- [x] Instruction Memory (ROM)
- [ ] Data Memory (RAM)
- [ ] Top-Level CPU Wiring

## 💻 Toolchain & Simulation

This core is designed and verified using open-source EDA tools on Linux.

* **Simulator:** [Icarus Verilog](http://iverilog.icarus.com/) (`iverilog`)
* **Waveform Viewer:** [GTKWave](https://gtkwave.sourceforge.net/)

### Running the Testbenches

Each module is verified using a standalone testbench. To run a simulation (e.g., for the ALU):

```bash
# Compile the SystemVerilog files
iverilog -g2012 -o alu.out alu.sv alu_tb.sv

# Execute the simulation
vvp alu.out

# Open the waveform in GTKWave
gtkwave alu.vcd &
```
## 📝 Design Philosophy
- **Synthesizable RTL**: Strict adherence to synthesizable SystemVerilog constructs
- **Modularity**: The datapath is broken down into easily testable, isolated components before top-level integration
- **Specification Driven**: Architected directly from the official RISC-V Unprivileged ISA Specification