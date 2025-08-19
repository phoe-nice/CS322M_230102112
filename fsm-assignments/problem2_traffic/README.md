# Traffic Light Controller – Verilog Project

## Overview

This project implements a **Moore-type Finite State Machine (FSM)** in Verilog to control a traffic light system. The system manages two directions: **North-South (NS)** and **East-West (EW)**, with proper green, yellow, and red light phases.

A testbench is provided to simulate the controller operation using a simplified clock and tick generator. The output is viewable using waveform tools like **GTKWave**.

---

## Files

- `traffic_light.v`: Verilog module implementing the traffic light controller.
- `tb_traffic_light.v`: Testbench for simulating the controller.
- `traffic_light.vcd`: VCD waveform file generated during simulation.

---

## Design Details

### Module: `traffic_light`

#### Ports

| Name     | Direction | Description                             |
|----------|-----------|-----------------------------------------|
| `clk`    | Input     | Clock signal (positive edge triggered)  |
| `rst`    | Input     | Synchronous, active-high reset          |
| `tick`   | Input     | One pulse per second (for timing FSM)   |
| `ns_g`   | Output    | North-South Green light                 |
| `ns_y`   | Output    | North-South Yellow light                |
| `ns_r`   | Output    | North-South Red light                   |
| `ew_g`   | Output    | East-West Green light                   |
| `ew_y`   | Output    | East-West Yellow light                  |
| `ew_r`   | Output    | East-West Red light                     |

---

## FSM State Diagram

The FSM uses 4 states to control the lights:

| State     | Meaning                 | Duration (in ticks) |
|-----------|--------------------------|---------------------|
| `S_NS_G`  | NS Green, EW Red         | 5 ticks             |
| `S_NS_Y`  | NS Yellow, EW Red        | 2 ticks             |
| `S_EW_G`  | EW Green, NS Red         | 5 ticks             |
| `S_EW_Y`  | EW Yellow, NS Red        | 2 ticks             |

The FSM transitions from one state to another based on the number of ticks elapsed in the current state.

#### Tick Counter

- A 3-bit counter is used to count ticks in each state.
- Transitions occur only when the tick count reaches the defined threshold per state.

---

## Output Logic

This is a **Moore FSM**, meaning the outputs depend **only on the current state**:

| State     | NS Lights      | EW Lights      |
|-----------|----------------|----------------|
| `S_NS_G`  | Green          | Red            |
| `S_NS_Y`  | Yellow         | Red            |
| `S_EW_G`  | Red            | Green          |
| `S_EW_Y`  | Red            | Yellow         |

All outputs are mutually exclusive and follow correct traffic light rules.

---

![State Diagram](/waves/additional_images/state_diagram_png)

## Testbench: `tb_traffic_light`

### Features

- Generates a 100 MHz clock (10 ns period).
- Simulates a `tick` pulse every 20 clock cycles (~0.2 µs simulated second).
- Resets the system initially.
- Runs for enough cycles to simulate **4 full traffic light cycles**.

### Tick Generator

```tick_reg <= (cyc % 5 == 0); // 1 tick every 20 cycles```

This simulates a 1 Hz tick in faster time for simulation purposes.

### Waveform Generation

- Dumps simulation data into `traffic_light.vcd` for viewing in GTKWave.

---

## How to Simulate(Using Iverilog)

   ```bash
   iverilog -o traffic_light.vvp traffic_light.v tb_traffic_light.v
   vvp traffic_light.vvp
   gtkwave traffic_light.vcd
