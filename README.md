## Goal

SoC with

- an RV32I core (for now, `ibex`)
- OpenRAM SRAM peripheral
- TPU accelerator peripheral
- Use PULP's uDMA

implemented with librelane all the way to pads.

We also want to see if a pure github-hosted physical design flow is an option.
We run the librelane flow locally only once for each module.
Then, we setup the github actions workflow that triggers on push and verifies the operation.

## Bus

`ibex` already uses the TCDM bus for memory by default, so let's just use that one internally.
Then, we use APB to communicate with the uDMA, which itself is connected to the TCDM.

> This style looks exactly like Pulpissimo, and that's fine for now.

## Packaging and Pins

Depending on how big the chip is, we can likely get away with just a VDDIO, VDDC, and a bunch of downbonded VSSC.

Assuming a QFN16, we can use pins like:
- QSPI Flash - 6 pins
- UART - 2 pins
- CLK, NRST - 2 pins
- VDDIO, VDDC - 2 pins
Total of 12 pins so far...

![](bonding-diagram.png)