#!/usr/bin/env python3
"""Render the top-level GDS layout to a PNG using KLayout.

Usage (inside klayout batch mode):
    klayout -b -r librelane/render_layout.py \
            -rd gds=outputs/lugs_soc_chip.gds \
            -rd png=outputs/layout.png
"""

import sys
import os

# When invoked via `klayout -b -r`, the `pya` module is available.
# When invoked as a standalone Python script (e.g. python3 render_layout.py),
# fall back to the `klayout.lay` API (headless).
try:
    import pya  # KLayout built-in module (available inside klayout -b)

    gds_path = pya.Application.instance().get_config("gds") if "gds" not in dir() else gds  # noqa
    png_path = pya.Application.instance().get_config("png") if "png" not in dir() else png  # noqa

    lv = pya.LayoutView.new(True)  # standalone view (headless)
    lv.load_layout(gds_path, 0)
    lv.max_hier()
    lv.zoom_fit()
    img = lv.get_image(2048, 2048)
    img.save(png_path)
    print(f"[render_layout] Saved layout image → {png_path}")

except Exception as exc:
    print(f"[render_layout] WARNING: layout image generation failed: {exc}",
          file=sys.stderr)
    sys.exit(0)   # non-fatal — the GDS is the primary deliverable
