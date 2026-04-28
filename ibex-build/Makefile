
IBEX_DIR    := $(CURDIR)/ibex
BUILD_DIR   := $(CURDIR)/build
SIM_DIR     := $(BUILD_DIR)/lowrisc_ibex_ibex_simple_system_0/sim-verilator
SIMULATOR   := $(SIM_DIR)/Vibex_simple_system
HELLO_DIR   := $(IBEX_DIR)/examples/sw/simple_system/hello_test
HELLO_ELF   := $(HELLO_DIR)/hello_test.elf

# Use riscv64 compiler with 32-bit target; newer GAS requires _zicsr for CSR ops
RISCV_CC    ?= riscv64-unknown-elf-gcc
ARCH        ?= rv32imc_zicsr
IBEX_CONFIG := small
IBEX_OPTS   := $(shell cd $(IBEX_DIR) && python3 util/ibex_config.py $(IBEX_CONFIG) fusesoc_opts)

.PHONY: test-base run clean harden

# Run the simple system hello_test simulation
test-base: run

run: $(SIMULATOR) $(HELLO_ELF)
	cd $(BUILD_DIR) && $(SIMULATOR) --meminit=ram,$(HELLO_ELF)

# Build Verilator simulator binary from fusesoc-generated project
$(SIMULATOR): $(SIM_DIR)/Makefile
	$(MAKE) -j$$(nproc) -C $(SIM_DIR)

# Set up project with fusesoc, then patch config.mk for Verilator 5.x
# (Verilator 5.x promotes UNOPTFLAT to error; suppress it explicitly)
$(SIM_DIR)/Makefile:
	fusesoc --cores-root=$(IBEX_DIR) run --target=sim --setup \
		--build-root=$(BUILD_DIR) lowrisc:ibex:ibex_simple_system $(IBEX_OPTS)
	sed -i 's/-Wall --unroll-count/-Wall -Wno-UNOPTFLAT --unroll-count/' \
		$(SIM_DIR)/config.mk

# Build hello_test RISC-V software
$(HELLO_ELF):
	$(MAKE) -C $(HELLO_DIR) CC=$(RISCV_CC) ARCH=$(ARCH)

harden:
	@echo "Running LibreLane for ibex-build macro..."
	@echo "TODO: Run librelane config.yaml"

clean:
	rm -rf $(BUILD_DIR)
	$(MAKE) -C $(HELLO_DIR) distclean 2>/dev/null || true
