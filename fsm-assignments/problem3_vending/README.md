# Vending Machine FSM (Mealy) – Verilog Project

## Overview

This project implements a **Mealy-type Finite State Machine (FSM)** in Verilog to model the logic of a vending machine that accepts coins and dispenses a product when a total of **20 units** or more is reached. It also returns **5 units as change** if more than 20 units are inserted.

A testbench is provided to simulate the behavior with various coin input sequences. The simulation generates a waveform file viewable with GTKWave.

---

## Files

- `vending_mealy.v`: Verilog module implementing the vending FSM.
- `tb_vending_mealy.v`: Testbench to test the vending machine behavior.
- `vending_mealy_wave.vcd`: Simulation waveform file (generated during testbench run).

---

## Design Details

### Module: `vending_mealy`

#### Ports

| Name       | Direction | Width | Description                           |
|------------|-----------|-------|---------------------------------------|
| `clk`      | Input     | 1     | Clock signal                          |
| `rst`      | Input     | 1     | Synchronous active-high reset         |
| `coin`     | Input     | 2     | Coin input: `00` = none, `01` = 5, `10` = 10 |
| `dispense` | Output    | 1     | High when product is dispensed        |
| `chg5`     | Output    | 1     | High when 5 units of change are returned |

#### State Encoding

| State  | Value | Meaning           |
|--------|-------|-------------------|
| `S0`   | 00    | Total = 0         |
| `S5`   | 01    | Total = 5         |
| `S10`  | 10    | Total = 10        |
| `S15`  | 11    | Total = 15        |

#### Behavior

- Accepts coins of value `5` and `10` units.
- When total reaches `20` or more:
  - Dispense product.
  - If total > 20 (i.e., 25), return `chg5 = 1`.
- Operates as a **Mealy machine**: output depends on **state and input**.
- Returns to `S0` after dispensing.

---

## 🔍 Why Mealy?

 - Mealy FSM generates outputs based on present state + input.

 - This allows vend and chg5 signals to be triggered immediately in the same cycle when the required total is reached, instead of waiting for a state transition (like in Moore).

 - This ensures faster response when the target value is hit.

## Testbench: `tb_vending_mealy`

- Applies different coin input sequences to test normal and edge cases.
- Uses a simulated clock with a 10 ns period.
- Dumps simulation data into `vending_mealy_wave.vcd`.

### Coin Input Encoding

| Binary | Value |
|--------|--------|
| `00`   | No coin (idle) |
| `01`   | 5 units        |
| `10`   | 10 units       |

### Simulated Scenarios

- 5 + 10 + 5 = 20 → dispense
- 10 + 10 = 20 → dispense
- 10 + 10 + 5 = 25 → dispense + change
- 5 + 10 + 10 = 25 → dispense + change

---

## How to Simulate(Using Iverilog)

```bash
iverilog -o vending_mealy.vvp vending_mealy.v tb_vending_mealy.v
vvp vending_mealy.vvp
gtkwave vending_mealy_wave.vcd
