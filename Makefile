# Top-level Makefile — LUGS SoC
# Runs the LibreLane Chip (padring) flow for lugs_soc_chip.
#
# outputs/ is committed to git so that CI skips the expensive LibreLane run
# when the results are already up-to-date.  The stamp file (outputs/.harden_done)
# acts as the make target; delete it (or the whole outputs/ dir) to force a
# re-run.

DESIGN   := lugs_soc_chip
PDK_ROOT ?= /foss/pdks
PDK      ?= ihp-sg13g2

SYS_PATH := /foss/tools/bin:/foss/tools/klayout:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

OUTPUTS_DIR := outputs
STAMP       := $(OUTPUTS_DIR)/.harden_done
SV2V_OUT    := build/sv2v/design.v

# Source files — changes here invalidate the stamp and trigger a re-run.
SV_SOURCES := src/lugs-soc-chip.sv \
              src/lugs-soc.sv \
              ibex-build/ibex/rtl/ibex_pkg.sv \
              ibex-build/ibex/rtl/ibex_core.sv

SOURCES := config.yaml \
           $(SV2V_OUT) \
           librelane/chip_top.sdc \
           librelane/pdn_cfg.tcl

# sv2v include directories
SV2V_INCDIRS := \
  -I ibex-build/ibex/vendor/lowrisc_ip/ip/prim/rtl \
  -I ibex-build/ibex/vendor/lowrisc_ip/dv/sv/dv_utils

# All SV files to convert, in dependency order (packages first)
SV2V_FILES := \
  ibex-build/ibex/vendor/lowrisc_ip/ip/prim/rtl/prim_cipher_pkg.sv \
  ibex-build/ibex/vendor/lowrisc_ip/ip/prim/rtl/prim_secded_pkg.sv \
  ibex-build/ibex/rtl/ibex_pkg.sv \
  ibex-build/ibex/vendor/lowrisc_ip/ip/prim/rtl/prim_lfsr.sv \
  ibex-build/ibex/vendor/lowrisc_ip/ip/prim/rtl/prim_secded_inv_39_32_enc.sv \
  ibex-build/ibex/vendor/lowrisc_ip/ip/prim/rtl/prim_secded_inv_39_32_dec.sv \
  ibex-build/ibex/vendor/lowrisc_ip/ip/prim/rtl/prim_secded_inv_28_22_enc.sv \
  ibex-build/ibex/vendor/lowrisc_ip/ip/prim/rtl/prim_secded_inv_28_22_dec.sv \
  ibex-build/ibex/vendor/lowrisc_ip/ip/prim_generic/rtl/prim_buf.sv \
  ibex-build/ibex/rtl/ibex_alu.sv \
  ibex-build/ibex/rtl/ibex_branch_predict.sv \
  ibex-build/ibex/rtl/ibex_compressed_decoder.sv \
  ibex-build/ibex/rtl/ibex_controller.sv \
  ibex-build/ibex/rtl/ibex_counter.sv \
  ibex-build/ibex/rtl/ibex_cs_registers.sv \
  ibex-build/ibex/rtl/ibex_csr.sv \
  ibex-build/ibex/rtl/ibex_decoder.sv \
  ibex-build/ibex/rtl/ibex_dummy_instr.sv \
  ibex-build/ibex/rtl/ibex_ex_block.sv \
  ibex-build/ibex/rtl/ibex_fetch_fifo.sv \
  ibex-build/ibex/rtl/ibex_icache.sv \
  ibex-build/ibex/rtl/ibex_id_stage.sv \
  ibex-build/ibex/rtl/ibex_if_stage.sv \
  ibex-build/ibex/rtl/ibex_load_store_unit.sv \
  ibex-build/ibex/rtl/ibex_multdiv_fast.sv \
  ibex-build/ibex/rtl/ibex_multdiv_slow.sv \
  ibex-build/ibex/rtl/ibex_pmp.sv \
  ibex-build/ibex/rtl/ibex_prefetch_buffer.sv \
  ibex-build/ibex/rtl/ibex_register_file_ff.sv \
  ibex-build/ibex/rtl/ibex_wb_stage.sv \
  ibex-build/ibex/rtl/ibex_core.sv \
  src/lugs-soc.sv \
  src/lugs-soc-chip.sv

.PHONY: harden sv2v test-rtl clean

# ── sv2v pre-processing ───────────────────────────────────────────────────────
# Converts all SystemVerilog sources to plain Verilog so Yosys can parse them.
sv2v: $(SV2V_OUT)

$(SV2V_OUT): $(SV2V_FILES)
	@mkdir -p build/sv2v
	@echo "==> Running sv2v..."
	PATH=$(SYS_PATH) sv2v -D SYNTHESIS $(SV2V_INCDIRS) $(SV2V_FILES) -w $(SV2V_OUT)
	@echo "==> sv2v done: $(SV2V_OUT)"

# ── Top-level hardening ───────────────────────────────────────────────────────
harden: $(STAMP)

$(STAMP): $(SOURCES)
	@mkdir -p $(OUTPUTS_DIR)
	@echo "==> Running LibreLane Chip flow for $(DESIGN)..."
	env -u PYTHONPATH PATH=$(SYS_PATH) PDK_ROOT=$(PDK_ROOT) PDK=$(PDK) \
	    /usr/local/bin/librelane --manual-pdk \
	    --save-views-to $(OUTPUTS_DIR) \
	    config.yaml
	@# Generate layout image (non-fatal if KLayout rendering fails)
	@echo "==> Rendering layout image..."
	env -u PYTHONPATH PATH=$(SYS_PATH) klayout -b \
	    -r librelane/render_layout.py \
	    -rd gds=$(OUTPUTS_DIR)/$(DESIGN).gds \
	    -rd png=$(OUTPUTS_DIR)/layout.png || \
	    echo "WARNING: layout image rendering failed (non-fatal)"
	touch $@
	@echo "==> Hardening complete. Results in $(OUTPUTS_DIR)/"

# ── DRC (post-harden, standalone) ────────────────────────────────────────────
# Uses run_drc.py from the PDK directly, bypassing LibreLane's checker gate.
# GDS source: outputs/$(DESIGN).gds (copied there by the harden target).
# Reports land in drc_reports/<variant>/.

DRC_GDS := outputs/$(DESIGN).gds
DRC_DIR := drc_reports
DRC_PY  := $(PDK_ROOT)/$(PDK)/libs.tech/klayout/tech/drc/run_drc.py

# Fast: skip density + extra/maximal rules.  Good for iterative checking.
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

# Full: all rules including density and maximal rule set (slow).
drc-full: $(DRC_GDS)
	@mkdir -p $(DRC_DIR)
	env -u PYTHONPATH PATH=$(SYS_PATH) python3 $(DRC_PY) \
	    --path $(DRC_GDS) \
	    --topcell $(DESIGN) \
	    --run_mode deep \
	    --mp $(shell nproc) \
	    --run_dir $(DRC_DIR)/full
.PHONY: drc-full

# ── RTL lint / tests ──────────────────────────────────────────────────────────
test-rtl:
	@echo "Running RTL tests..."
	@echo "TODO: Add RTL lint / simulation tests here"

# ── Housekeeping ──────────────────────────────────────────────────────────────
clean:
	rm -rf runs build $(OUTPUTS_DIR)
