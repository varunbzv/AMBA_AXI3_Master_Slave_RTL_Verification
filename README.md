# AMBA_AXI3_Master_Slave_RTL_Verification\
## Description
Implemented and verified an AXI3 master–slave interface in SystemVerilog supporting single fixed-burst read/write transactions using QuestaSim.
Developed RTL for master and slave modules, created a SystemVerilog testbench, and successfully validated protocol-compliant data transfer and handshaking.


## Overview

This project implements a simplified AXI3 (Advanced eXtensible Interface 3) protocol in SystemVerilog, including both AXI Master and AXI Slave modules. The design currently supports single non-cacheable, non-bufferable transactions using Fixed Burst mode.

A self-checking SystemVerilog verification environment has been developed to validate read and write functionality through directed and constrained-random test cases.


## Features


- AXI3 Master RTL
- AXI3 Slave RTL
- Fixed Burst transaction support
- Single-beat read/write transfers
- Non-cacheable, non-bufferable transactions
- Finite State Machine (FSM) based implementation
- Self-checking verification testbench
- Directed and random verification
- Scoreboard-based data checking
- `randc` based constrained-random stimulus generation

---

## Verification Features

The verification environment includes:

- Reset verification
- Directed write/read transactions
- Multiple address verification
- Different data pattern testing
- Overwrite verification
- Sequential transaction testing
- Constrained-random (`randc`) testing
- Automatic PASS/FAIL reporting
- Scoreboard-based data comparison


## Project Structure

```
src/
    axi/
        axi_master.sv
        axi_master_wr.sv
        axi_master_rd.sv
        axi_slave.sv
    defines/
        define.sv

simulation/
        axi_tb.sv
        run.do

```
## Tools Used

- SystemVerilog
- QuestaSim 2024.1

---

## Current Status

- RTL implementation completed for Fixed Burst single transactions.
- Verification environment developed using SystemVerilog.
- Directed and constrained-random verification completed successfully.

---

## Future Improvements

- Increment Burst support
- Wrap Burst support
- Multi-beat burst transactions
- Multiple outstanding transactions
- Functional coverage
- SystemVerilog Assertions (SVA)
- UVM-based verification
