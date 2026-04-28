#!/usr/bin/env python3
"""SRAM collateral preparation script for IHP SG13G2.

NOTE: OpenRAM does not support IHP SG13G2.
  The OpenRAM pip package (1.2.48) ships technology files only for:
    sky130, gf180mcu, freepdk45, scn3me_subm, scn4m_subm
  The IHP-Open-PDK repo has no openram/ directory under libs.tech/.
  IHP ships pre-compiled SRAM macros instead.

This script validates that the required PDK SRAM collateral is present for:
  RM_IHPSG13_1P_1024x32_c2_bm_bist  (1024 words x 32 bits, single-port)

The LibreLane config.yaml references these files directly by absolute path.

Usage:
    python compile_sram.py
"""

from pathlib import Path

PDK_SRAM = Path("/foss/pdks/ihp-sg13g2/libs.ref/sg13g2_sram")
MACRO    = "RM_IHPSG13_1P_1024x32_c2_bm_bist"

REQUIRED = {
    "GDS":      PDK_SRAM / "gds"    / f"{MACRO}.gds",
    "LEF":      PDK_SRAM / "lef"    / f"{MACRO}.lef",
    "Verilog":  PDK_SRAM / "verilog"/ f"{MACRO}.v",
    "CDL":      PDK_SRAM / "cdl"    / f"{MACRO}.cdl",
    "LIB (TT)": PDK_SRAM / "lib"   / f"{MACRO}_typ_1p20V_25C.lib",
    "LIB (FF)": PDK_SRAM / "lib"   / f"{MACRO}_fast_1p32V_m55C.lib",
    "LIB (SS)": PDK_SRAM / "lib"   / f"{MACRO}_slow_1p08V_125C.lib",
}


def main() -> None:
    print(f"Checking PDK SRAM collateral for: {MACRO}\n")
    all_ok = True
    for label, path in REQUIRED.items():
        ok = path.exists()
        status = "OK" if ok else "MISSING"
        print(f"  [{status}] {label}: {path}")
        if not ok:
            all_ok = False

    print()
    if all_ok:
        print("All required SRAM collateral files are present.")
        print("LibreLane hardening can proceed: cd sram && make harden")
    else:
        print("ERROR: Missing files above. Check PDK installation at:")
        print(f"  {PDK_SRAM}")
        raise SystemExit(1)


if __name__ == "__main__":
    main()
