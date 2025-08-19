## State Diagram

![State Diagram](waves/additional_images/state_diagram.jpg)

---

## How to Simulate(Using Iverilog)

   ```bash
   iverilog -o link.vvp tb_link_top.v link_top.v master_fsm.v slave_fsm.v
   vvp link.vvp
   gtkwave link.vcd
