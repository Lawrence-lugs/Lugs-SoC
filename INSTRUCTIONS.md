# Create a top-level padring flow.

Using the main config.yaml, create and test an ihp sg13g2 librelane flow that includes a padring.

[Reference full-chip config.yaml](https://github.com/IHP-GmbH/ihp-sg13g2-librelane-template/blob/main/librelane/config.yaml)

We'll have 24 pads in a square floorplan (6 each side).

Pads:
- 6 QSPI pads
- 4 JTAG pads
- 2 UART pads
- 2 (CLK, NRST) pads
- 2 (VDDIO, VDDC) pads
- A bunch of downbonded VSS pads
- The remaining are for now labelled GPIO

Inclusions:
- Include the SRAM macro in this top-level flow to test the ability to fit it into the flow. (this is just to test for now, later we'll have the lugs-soc.sv ingest the SRAM).
- A lugs-soc.sv module. Put only an ibex instantiation inside the module for now. (later to be filled with the bus, uDMA, the SRAM, and other additional good stuff).

Organization:
- The top-level chip instantiation should be in src/lugs-soc-chip.sv. This file should have the verilog pad instantiations along with the top-level instantiation of the internal portion (lugs-soc.sv). These are equivalent to [chip top](https://github.com/IHP-GmbH/ihp-sg13g2-librelane-template/blob/main/src/chip_top.sv) and [chip core](https://github.com/IHP-GmbH/ihp-sg13g2-librelane-template/blob/main/src/chip_core.sv).
- Update the makefile with this new top-level target (of course, this includes testing that the makefile works). The makefile should create an outputs/ folder that is included git so that later pulls of the repo do not accidentally redo the makes. 
- Update the [workflow](.github/workflows/main.yml) to account for the new top-level flow in the relevant position. That one should call the makefile target created above. It should be that the makefile setup will prevent the actions workflow from taking too much time, since outputs/ is already updated.

Rules:
- You can adopt any simplifications used by [greyhound](https://github.com/mole99/greyhound-ihp/blob/main/config.yaml). This includes the particular klayout DRC runset, disabling Magic DRC.
- Your scope is the physical design flow of the top-level project. Do NOT touch the macro block folders (sram, ibex-build, tpu-build). If the DRCs are internal to the lower macros, that is not part of your scope- it should be fixed when the task is to work with that specific block. 

Documentation:
- Update the README with a relevant single-header update (i.e. # Top-level)
- Add a picture of the final layout image. This image should be recreated everytime the flow is run.

## Post-run Instruction Rules

- Use sv2v before running librelane. Librelane's Yosys only supports `.v` fully. This is the typical setup.
- The subfolders typically have hardened, clean macros already. Check what they have to avoid accidentally redoing work. e.g. SRAM from the subfolder NOT the PDK folders.
- Do not just setup. Run the flow, iteratively fix until the flow is DRC/LVS clean.
- You can use (*keep*) and other similar attribute directives to force yosys not to touch things. This is a typical practice in the greyhound repo as well. Use this when yosys is simplifying away blocks we introduce that are still WIP.
- IHP's pads don't have the bondpads. You can obtain them from [Greyhound's repository](https://github.com/mole99/greyhound-ihp/tree/8ca2985146f2cbabf1cd058ba0eabb555bd09811/ip/bondpad_70x70).
- Make sure the floorplan is just big enough for the macros and the liquid pnr. A floorplan that's too big will take too long for the flow.