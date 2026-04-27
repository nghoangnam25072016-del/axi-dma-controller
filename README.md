# AXI DMA Controller (SystemVerilog)


🚀 A modular AXI4 DMA engine supporting multi-transfer read-to-write data movement with randomized verification.

## Overview
Designed a multi-transfer AXI DMA engine supporting read-to-write data movement.

[Architecture](docs/architecture.png)

## Features
- AXI4 Read & Write Channels
- FSM-based Control (dma_ctrl)
- Multi-transfer support (length parameter)
- Address auto-increment
- Modular design (read/write/control separation)

## Verification
- Self-checking testbench
- Randomized AXI handshake timing
- Multi-transaction support

## Results
- Successfully simulated end-to-end DMA transfers
- PASS/FAIL verification messages


## Waveform
Multi-transfer AXI DMA operation showing correct address increment and data movement.
![Waveform](sim/waveform.png)


## Key Highlights
- Designed end-to-end AXI DMA data path (read → buffer → write)
- Implemented FSM-based control with multi-transfer support
- Verified using randomized AXI handshake timing
- Achieved correct data transfer across multiple transactions
