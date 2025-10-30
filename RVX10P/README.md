# RISC-V Pipeline CPU Project

## Overview
This project implements a simple 5-stage pipelined RISC-V processor in SystemVerilog. It includes key pipeline components such as instruction fetch, decode, execute, memory access, and write-back stages. The design supports hazard detection, forwarding to resolve data hazards, and control signals generation for correct pipeline operation.

---

The project consists of the following main modules:
- `datapath.sv`: The core datapath implementing the pipeline stages.
- `controller.sv`: Generates control signals from the instruction opcode.
- `forwarding_unit.sv`: Resolves data hazards through forwarding.
- `hazard_unit.sv`: Detects load-use hazards and inserts stalls.
- `riscvpipeline.sv`: Top-level wrapper connecting datapath and pipeline control.
- `tb.sv`: Testbench module to simulate and verify the processor functionality.

---

## Design Features
- 5-stage pipeline: IF, ID, EX, MEM, WB.
- Data forwarding to minimize stalls.
- Hazard detection unit to handle load-use hazards.
- Branch and jump control to manage pipeline flushing.
- Immediate value extraction and decoding.
- Register file with synchronous writes in WB stage.
- Performance counters tracking cycle count, stalls, and flushes.

## File Descriptions
| File               | Description                                      |
|--------------------|------------------------------------------------|
| datapath.sv        | Implements the pipelined datapath and registers. |
| controller.sv      | Generates control signals based on opcodes.    |
| forwarding_unit.sv | Data forwarding logic to prevent hazards.      |
| hazard_unit.sv     | Detects hazards and stalls pipeline as needed. |
| riscvpipeline.sv   | Top-level pipeline integration wrapper.        |
| tb.sv              | Testbench for simulation and verification.     |

---

## Usage Instructions
### Compilation and Simulation (Icarus Verilog)
``iverilog -g2012 -o pipeline_tb.vvp tb.sv riscvpipeline.sv datapath.sv controller.sv forwarding_unit.sv hazard_unit.sv``
``vvp pipeline_tb.vvp``
### Waveform

![Waveform](RVX10P/images/waveform.png)

---


## Design Plan

### Pipeline Stages
- **Instruction Fetch (IF):** Fetches instruction from instruction memory based on PC.
- **Instruction Decode (ID):** Decodes instruction opcode, reads registers, extracts immediate values, and generates control signals.
- **Execute (EX):** Performs ALU operations and branch/jump target calculations. Handles data forwarding and hazard stalling.
- **Memory (MEM):** Performs memory read/write operations.
- **Write-Back (WB):** Writes results back to the register file.

### Hazard Handling
- Forwarding unit to resolve data hazards by selecting latest data from pipeline registers.
- Hazard unit to stall pipeline for load-use hazards by inserting bubbles.
- Flush logic on branch and jump to clear instructions in the pipeline.

### Control Signals
- Generated in controller based on opcode.
- Signals include RegWrite, MemWrite, MemToReg, ALUSrc, Branch, Jump, ALUOp, ImmSrc, and ResultSrc.

### Testbench
- Provides clock and reset signals.
- Monitors MemWrite signals for writeback verification.
- Displays success/failure messages based on expected output values.

---
