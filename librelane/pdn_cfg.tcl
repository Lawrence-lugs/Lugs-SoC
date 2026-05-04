# PDN configuration for lugs_soc_chip (padring flow) — IHP SG13G2
#
# Adapted from the IHP SG13G2 LibreLane template pdn_cfg.tcl.
# Copyright 2025 LibreLane Contributors / adapted for LUGS SoC
# SPDX-License-Identifier: Apache-2.0

source $::env(SCRIPTS_DIR)/openroad/common/io.tcl
source $::env(SCRIPTS_DIR)/openroad/common/set_global_connections.tcl
set_global_connections

# ---------------------------------------------------------------------------
# Voltage domain
# ---------------------------------------------------------------------------
set secondary []
foreach vdd $::env(VDD_NETS) gnd $::env(GND_NETS) {
    if { $vdd ne $::env(VDD_NET) } {
        lappend secondary $vdd
        set db_net [[ord::get_db_block] findNet $vdd]
        if { $db_net eq "NULL" } {
            set net [odb::dbNet_create [ord::get_db_block] $vdd]
            $net setSpecial
            $net setSigType "POWER"
        }
    }
    if { $gnd ne $::env(GND_NET) } {
        lappend secondary $gnd
        set db_net [[ord::get_db_block] findNet $gnd]
        if { $db_net eq "NULL" } {
            set net [odb::dbNet_create [ord::get_db_block] $gnd]
            $net setSpecial
            $net setSigType "GROUND"
        }
    }
}

set_voltage_domain -name CORE \
    -power $::env(VDD_NET) \
    -ground $::env(GND_NET) \
    -secondary_power $secondary

# ---------------------------------------------------------------------------
# Standard-cell grid (TopMetal1 vertical, TopMetal2 horizontal)
# ---------------------------------------------------------------------------
define_pdn_grid \
    -name stdcell_grid \
    -starts_with POWER \
    -voltage_domain CORE

add_pdn_stripe \
    -grid stdcell_grid \
    -layer TopMetal1 \
    -width $::env(PDN_VWIDTH) \
    -pitch $::env(PDN_VPITCH) \
    -offset $::env(PDN_VOFFSET) \
    -starts_with POWER

add_pdn_stripe \
    -grid stdcell_grid \
    -layer TopMetal2 \
    -width $::env(PDN_HWIDTH) \
    -pitch $::env(PDN_HPITCH) \
    -offset $::env(PDN_HOFFSET) \
    -starts_with POWER

add_pdn_connect \
    -grid stdcell_grid \
    -layers "TopMetal1 TopMetal2"

# Standard-cell rails (Metal1)
add_pdn_stripe \
    -grid stdcell_grid \
    -layer Metal1 \
    -width $::env(PDN_RAIL_WIDTH) \
    -followpins

add_pdn_connect \
    -grid stdcell_grid \
    -layers "Metal1 TopMetal1"

# ---------------------------------------------------------------------------
# Core power ring (connects to pad power rails)
# ---------------------------------------------------------------------------
if { $::env(PDN_CORE_RING) == 1 } {
    add_pdn_ring \
        -grid stdcell_grid \
        -layers "TopMetal1 TopMetal2" \
        -widths  "$::env(PDN_CORE_RING_VWIDTH) $::env(PDN_CORE_RING_HWIDTH)" \
        -spacings "$::env(PDN_CORE_RING_VSPACING) $::env(PDN_CORE_RING_HSPACING)" \
        -core_offset "$::env(PDN_CORE_RING_VOFFSET) $::env(PDN_CORE_RING_HOFFSET)" \
        -connect_to_pads
}

# ---------------------------------------------------------------------------
# Default macro grid (for general hard macros)
# ---------------------------------------------------------------------------
define_pdn_grid \
    -macro \
    -default \
    -name macro \
    -starts_with POWER \
    -halo "$::env(PDN_HORIZONTAL_HALO) $::env(PDN_VERTICAL_HALO)"

add_pdn_connect \
    -grid macro \
    -layers "TopMetal1 TopMetal2"

# The SRAM wrapper already exposes VPWR/VGND on TopMetal1,
# so the global stdcell_grid TopMetal1 stripes connect to it directly.
# No custom macro PDN grid needed for the SRAM.
