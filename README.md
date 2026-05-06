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

# Top-level

The top-level LibreLane **Chip** (padring) flow targets IHP SG13G2 and produces a
full-chip GDS with wire-bondable IO pads.

## Pad layout — 24 pads (6 per side)

| Side  | Pads |
|-------|------|
| South | `clk`, `nrst`, `uart_rx`, `uart_tx`, `gpio[0]`, `gpio[1]` |
| East  | `qspi_sck`, `qspi_cs`, `qspi_io[0..3]` |
| North | `jtag_tck`, `jtag_tms`, `jtag_tdi`, `jtag_tdo`, `gpio[2]`, `gpio[3]` |
| West  | `VDDIO`, `VDDC`, `VSS×4` (downbonded) |

## Source files

| File | Purpose |
|------|---------|
| `src/lugs-soc-chip.sv` | Padring — 24 IHP IO pad instantiations + SoC core |
| `src/lugs-soc.sv` | Internal SoC — ibex CPU + SRAM macro (stub peripherals) |
| `config.yaml` | LibreLane Chip flow configuration |
| `librelane/chip_top.sdc` | SDC timing constraints |
| `librelane/pdn_cfg.tcl` | Power distribution network config |

## Running the flow

```bash
make harden          # run LibreLane (skipped if outputs/.harden_done exists)
make clean           # remove runs/ and outputs/
```

The Makefile checks for `outputs/.harden_done`; if the stamp is present (committed
after a successful local run) CI will skip the expensive LibreLane step.

## Layout

The final layout image is generated automatically after each successful flow run
and saved to `outputs/layout.png`.

![Layout](https://lawrence-lugs.github.io/lugs-soc/layout.png)
