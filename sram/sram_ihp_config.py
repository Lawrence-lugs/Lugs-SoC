# OpenRAM SRAM configuration for IHP SG13G2.
#
# Can be invoked directly once OpenRAM and the IHP tech directory are in place:
#
#   export OPENRAM_HOME=$(python -c "import openram, pathlib; print(pathlib.Path(openram.__file__).parent)")
#   export OPENRAM_TECHDIR=/path/to/sram/build/openram_tech
#   python -m openram sram_ihp_config.py
#
# Alternatively, use compile_sram.py which handles all setup automatically.
#
# Macro:  sram_1rw_32_1024
# Config: 1024 words × 32 bits = 32 KiB, byte-write mask, single read-write port.

# ---------- Technology ----------
tech_name = "ihp-sg13g2"

# ---------- SRAM dimensions ----------
word_size  = 32    # bits per word
num_words  = 1024  # number of words  →  32 KiB total
write_size = 8     # byte-granularity write mask (wmask[3:0])

# ---------- Port configuration (single-port 1RW) ----------
num_rw_ports = 1
num_r_ports  = 0
num_w_ports  = 0

# ---------- Yield margin ----------
num_spare_rows = 1
num_spare_cols = 1

# ---------- Output ----------
output_name = "sram_1rw_32_1024"
output_path = "build/openram_out"

# ---------- Verification ----------
check_lvsdrc     = False   # run DRC/LVS via LibreLane instead
analytical_delay = False

# ---------- PVT corners ----------
corner          = ["TT", "FF", "SS"]
process_corners = ["TT", "FF", "SS"]
supply_voltages = [1.2, 1.32, 1.08]
temperatures    = [25, -55, 125]
