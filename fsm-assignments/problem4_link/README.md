## State Diagram

![State Diagram](waves/additional_images/state_diagram.png)

---

## How to Simulate(Using Iverilog)

   ```bash
   iverilog -o traffic_light.vvp traffic_light.v tb_traffic_light.v
   vvp traffic_light.vvp
   gtkwave traffic_light.vcd
