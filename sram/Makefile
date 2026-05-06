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
#
# outputs/ is committed to git so that the top-level flow (and CI) can
# consume the SRAM macro collateral (GDS, LEF, LIB, etc.) without
# re-running the LibreLane hardening.  The stamp file (outputs/.harden_done)
# acts as the make target; delete it (or the whole outputs/ dir) to force
# a re-run.

DESIGN   := sram_1rw_32_1024_wrapper
PYTHON   ?= python
PDK_ROOT ?= /foss/pdks
PDK      ?= ihp-sg13g2

# LibreLane is installed under the system Python 3.12 (/usr/local/).
# EDA tools live in /foss/tools/bin and /foss/tools/klayout.
# Miniforge Python 3.14 is deliberately excluded to avoid _thread conflicts.
SYS_PATH := /foss/tools/bin:/foss/tools/klayout:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# KLayout technology search path — set explicitly so it is available even in
# non-login CI shells that do not source /etc/profile.d/iic-osic-tools-setup.sh.
PDKPATH      := $(PDK_ROOT)/$(PDK)
KLAYOUT_PATH := /headless/.klayout:$(PDKPATH)/libs.tech/klayout:$(PDKPATH)/libs.tech/klayout/tech

OUTPUTS_DIR := outputs
STAMP       := $(OUTPUTS_DIR)/.harden_done

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
#
# --save-views-to copies the final views (GDS, LEF, LIB, SPEF, VH, NL …)
# into outputs/ mirroring the 'final/' directory structure.  This is
# LibreLane's built-in mechanism; no manual cp required.
harden: $(STAMP)

$(STAMP):
	mkdir -p $(OUTPUTS_DIR)
	env -u PYTHONPATH PATH=$(SYS_PATH) PDK_ROOT=$(PDK_ROOT) PDK=$(PDK) \
	    PDKPATH=$(PDKPATH) KLAYOUT_PATH=$(KLAYOUT_PATH) \
	    /usr/local/bin/librelane --manual-pdk \
	    --run-tag ci --overwrite \
	    --save-views-to $(OUTPUTS_DIR) \
	    config.yaml
	touch $@
	@echo "==> Hardening complete. Results in $(OUTPUTS_DIR)/"

# -- DRC (post-harden) ----------------------------------------------------
DRC_GDS := $(OUTPUTS_DIR)/$(DESIGN).gds
DRC_DIR := drc_reports
DRC_PY  := $(PDK_ROOT)/$(PDK)/libs.tech/klayout/tech/drc/run_drc.py

drc: $(DRC_GDS)
	@mkdir -p $(DRC_DIR)
	env -u PYTHONPATH PATH=$(SYS_PATH) python3 $(DRC_PY) \
	    --path $(DRC_GDS) \
	    --topcell $(DESIGN) \
	    --run_mode deep \
	    --mp $(shell nproc) \
	    --run_dir $(DRC_DIR)/nodensity \
	    --no_density \
	    --disable_extra_rules \
	    --no_recommended
.PHONY: drc

# -- Housekeeping ---------------------------------------------------------
clean:
	rm -rf build runs $(OUTPUTS_DIR) $(DRC_DIR)

test-base:
	@echo "Running SRAM base tests..."
	@echo "TODO: Add SRAM simulation tests here"