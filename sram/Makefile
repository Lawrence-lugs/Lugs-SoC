# sram/Makefile
# Validate SRAM PDK collateral and harden the wrapper with LibreLane.
#
# Background:
#   OpenRAM does NOT support IHP SG13G2 (no tech files in IHP-Open-PDK).
#   IHP ships pre-compiled SRAM macros in libs.ref/sg13g2_sram/ instead.
#   compile_sram.py validates that those PDK files are present.
#
# Targets:
#   make / make all  - validate then harden
#   make prep        - validate PDK SRAM collateral
#   make harden      - run LibreLane Classic flow on the SRAM wrapper
#   make clean       - remove all build artefacts

PYTHON   ?= python
PDK_ROOT ?= /foss/pdks
PDK      ?= ihp-sg13g2

# LibreLane is installed under the system Python 3.12 (/usr/local/).
# EDA tools live in /foss/tools/bin and /foss/tools/klayout.
# Miniforge Python 3.14 is deliberately excluded to avoid _thread conflicts.
SYS_PATH := /foss/tools/bin:/foss/tools/klayout:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

.PHONY: all prep harden clean

all: prep harden

# -- Step 1: Validate PDK SRAM collateral ---------------------------------
prep:
	$(PYTHON) compile_sram.py

# -- Step 2: LibreLane macro hardening ------------------------------------
# Invoke /usr/local/bin/librelane directly (NOT the /foss/tools/bin/librelane
# wrapper) to prevent the wrapper's "export PATH=openroad-librelane/bin:$PATH"
# from prepending OpenSTA 2.6.0 ahead of the system OpenSTA 2.7.0.
# The wrapper also forces --manual-pdk, which we set explicitly here.
harden:
	mkdir -p build
	env -u PYTHONPATH PATH=$(SYS_PATH) PDK_ROOT=$(PDK_ROOT) PDK=$(PDK) \
	    /usr/local/bin/librelane --manual-pdk config.yaml

# -- Housekeeping ---------------------------------------------------------
clean:
	rm -rf build

test-base:
	@echo "Running SRAM base tests..."
	@echo "TODO: Add SRAM simulation tests here"