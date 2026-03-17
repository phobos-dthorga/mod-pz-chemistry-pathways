#!/usr/bin/env python3
"""Compile PCP tilesheet assets into PZ-compatible binary formats.

Generates:
  1. Binary .tiles file (tdef format) from .tiles.txt
  2. Binary .pack file (texture atlas) from tilesheet source PNG

Both files are required by PZ's tile loading system. The .tiles.txt is
human-readable source; PZ loads the binary .tiles at runtime.

Usage:
    py scripts/compile_tilepack.py              # Compile both .tiles and .pack
    py scripts/compile_tilepack.py --tiles-only # Compile only .tiles
    py scripts/compile_tilepack.py --pack-only  # Compile only .pack
    py scripts/compile_tilepack.py --dry-run    # Show what would be generated
"""

import argparse
import json
import struct
import sys
from pathlib import Path

from PIL import Image

# --- Paths ---
SCRIPT_DIR = Path(__file__).resolve().parent
CONFIG_PATH = SCRIPT_DIR / "furniture_items.json"
MEDIA_DIR = SCRIPT_DIR.parent / "common" / "media"
PACK_DIR = MEDIA_DIR / "texturepacks"

# --- Constants ---
TILES_MAGIC = b"tdef"
TILES_VERSION = 1
PACK_VERSION = 1

CELL_1X = (128, 256)
CELL_2X = (256, 512)
FACING_ORDER = ["S", "E", "N", "W"]


def load_config() -> dict:
    with open(CONFIG_PATH, encoding="utf-8") as f:
        return json.load(f)


# ─────────────────────────────────────────────────────────────
# Binary .tiles compiler
# ─────────────────────────────────────────────────────────────
# Format (reverse-engineered from ZVV's demonius_vaccine.tiles):
#   magic: "tdef" (4 bytes ASCII)
#   version: int32 LE (1)
#   num_tilesets: int32 LE
#   For each tileset:
#     tileset_name: NL-terminated string
#     png_filename: NL-terminated string
#     grid_cols: int32 LE
#     grid_rows: int32 LE
#     tileset_id: int32 LE
#     num_tiles: int32 LE
#     For each tile:
#       num_properties: int32 LE
#       For each property:
#         key: NL-terminated string
#         value: NL-terminated string


def write_nl_string(buf: bytearray, s: str) -> None:
    """Append a newline-terminated ASCII string to buffer."""
    buf.extend(s.encode("ascii"))
    buf.append(0x0A)  # newline


def compile_tiles(config: dict, dry_run: bool = False) -> Path | None:
    """Compile furniture_items.json into a binary .tiles file."""
    tileset = config["_tileset"]
    items = config["items"]
    ts_name = tileset["name"]
    ts_id = tileset["id"]
    grid_cols = tileset["grid_columns"]

    # Calculate grid rows
    col = 0
    row = 0
    tiles = []  # (item, facing, x, y)
    for item in items:
        facings = item["facings"]
        if col + len(facings) > grid_cols:
            col = 0
            row += 1
        for facing in facings:
            tiles.append((item, facing, col, row))
            col += 1
        if col >= grid_cols:
            col = 0
            row += 1
    grid_rows = (row + 1) if tiles else 1

    print(f"Binary .tiles: {ts_name}, {grid_cols}x{grid_rows}, ID={ts_id}, {len(tiles)} tiles")

    if dry_run:
        return None

    buf = bytearray()

    # Header
    buf.extend(TILES_MAGIC)
    buf.extend(struct.pack("<I", TILES_VERSION))
    buf.extend(struct.pack("<I", 1))  # num_tilesets = 1

    # Tileset header
    write_nl_string(buf, ts_name)
    write_nl_string(buf, f"{ts_name}.png")
    buf.extend(struct.pack("<I", grid_cols))
    buf.extend(struct.pack("<I", grid_rows))
    buf.extend(struct.pack("<I", ts_id))
    buf.extend(struct.pack("<I", len(tiles)))

    # Tile entries
    for item, facing, x, y in tiles:
        props = []
        if item.get("blocks_placement", False):
            props.append(("BlocksPlacement", ""))
        props.append(("CustomName", item["custom_name"]))
        props.append(("Facing", facing))
        props.append(("GroupName", tileset.get("group", "PCP")))
        if item.get("is_moveable", True):
            props.append(("IsMoveAble", ""))
        if item.get("is_surface", False):
            props.append(("IsTableTop", ""))
            props.append(("Surface", "34"))
        props.append(("PickUpWeight", str(item["pickup_weight"])))

        buf.extend(struct.pack("<I", len(props)))
        for key, val in props:
            write_nl_string(buf, key)
            write_nl_string(buf, val)

    # Write
    output_path = MEDIA_DIR / "pcp_tiles.tiles"
    output_path.write_bytes(bytes(buf))
    print(f"  Written: {output_path} ({len(buf):,} bytes)")
    return output_path


# ─────────────────────────────────────────────────────────────
# Binary .pack compiler (PZPK format)
# ─────────────────────────────────────────────────────────────
# Format from TileZed source (texturepackfile.cpp):
#   Magic: 'P','Z','P','K' (4 × uint8)
#   Version: int32 LE (1)
#   Num pages: int32 LE
#   For each page:
#     Page name: SaveString (int32 length + ASCII bytes)
#     Num entries: int32 LE
#     Mask flag: int32 LE (1)
#     For each entry:
#       Entry name: SaveString (int32 length + ASCII bytes)
#       x: int32 LE (position in atlas)
#       y: int32 LE
#       w: int32 LE (cropped sprite width)
#       h: int32 LE (cropped sprite height)
#       ox: int32 LE (offset from cell origin X)
#       oy: int32 LE (offset from cell origin Y)
#       fx: int32 LE (full cell width)
#       fy: int32 LE (full cell height)
#     PNG data length: int32 LE
#     Raw PNG bytes

PACK_MAGIC = b"PZPK"


def save_string(buf: bytearray, s: str) -> None:
    """Write a TileZed SaveString: int32 length + ASCII bytes."""
    encoded = s.encode("ascii")
    buf.extend(struct.pack("<i", len(encoded)))
    buf.extend(encoded)


def crop_sprite_bounds(img: Image.Image, x: int, y: int,
                       cell_w: int, cell_h: int) -> tuple:
    """Get the tight bounding box of a sprite within its cell.
    Returns (crop_x, crop_y, crop_w, crop_h, offset_x, offset_y)."""
    cell = img.crop((x, y, x + cell_w, y + cell_h))
    bbox = cell.getbbox()
    if bbox is None:
        # Empty cell — 1x1 transparent pixel at origin
        return (0, 0, 1, 1, 0, 0)
    left, top, right, bottom = bbox
    return (left, top, right - left, bottom - top, left, top)


def compile_pack(config: dict, resolution: str = "1x",
                 dry_run: bool = False) -> Path | None:
    """Compile tilesheet source PNG into a PZPK .pack binary."""
    tileset = config["_tileset"]
    items = config["items"]
    ts_name = tileset["name"]
    grid_cols = tileset["grid_columns"]

    cell_w, cell_h = CELL_1X if resolution == "1x" else CELL_2X

    # Determine source and output paths
    if resolution == "2x":
        src_path = PACK_DIR / f"{ts_name}2x_src.png"
        out_path = PACK_DIR / f"pcp_tiles2x.pack"
        page_name = f"pcp_tiles2x"
    else:
        src_path = PACK_DIR / f"{ts_name}_src.png"
        out_path = PACK_DIR / f"pcp_tiles.pack"
        page_name = f"pcp_tiles"

    if not src_path.exists():
        print(f"  ERROR: Source tilesheet not found: {src_path}")
        print(f"  Run: py scripts/build_tilesheet.py")
        return None

    # Build entry list
    entries = []
    col = 0
    row = 0
    for item in items:
        facings = item["facings"]
        if col + len(facings) > grid_cols:
            col = 0
            row += 1
        for facing in facings:
            idx = row * grid_cols + col
            sprite_name = f"{ts_name}_{idx}"
            entries.append((sprite_name, col, row))
            col += 1
        if col >= grid_cols:
            col = 0
            row += 1

    print(f"\n.pack ({resolution}): {page_name}, {len(entries)} entries")

    if dry_run:
        for name, c, r in entries:
            print(f"  {name} @ col={c}, row={r}")
        return None

    # Load source image
    img = Image.open(src_path).convert("RGBA")
    print(f"  Source: {src_path.name} ({img.width}x{img.height})")

    # Encode atlas PNG data
    import io
    atlas_buf = io.BytesIO()
    img.save(atlas_buf, "PNG")
    atlas_data = atlas_buf.getvalue()

    # Build the PZPK binary
    buf = bytearray()

    # Header
    buf.extend(PACK_MAGIC)                          # 'PZPK'
    buf.extend(struct.pack("<i", PACK_VERSION))     # version = 1
    buf.extend(struct.pack("<i", 1))                # num_pages = 1

    # Page
    save_string(buf, page_name)                     # page name
    buf.extend(struct.pack("<i", len(entries)))      # num entries
    buf.extend(struct.pack("<i", 1))                 # mask flag

    # Entries
    for sprite_name, c, r in entries:
        px = c * cell_w
        py = r * cell_h

        # Get tight crop bounds within cell
        crop_x, crop_y, crop_w, crop_h, off_x, off_y = crop_sprite_bounds(
            img, px, py, cell_w, cell_h)

        save_string(buf, sprite_name)

        # Atlas position (absolute in atlas image)
        abs_x = px + crop_x
        abs_y = py + crop_y
        buf.extend(struct.pack("<i", abs_x))        # x
        buf.extend(struct.pack("<i", abs_y))        # y
        buf.extend(struct.pack("<i", crop_w))       # w
        buf.extend(struct.pack("<i", crop_h))       # h

        # Offset within original cell
        buf.extend(struct.pack("<i", off_x))        # ox
        buf.extend(struct.pack("<i", off_y))        # oy

        # Full cell dimensions
        buf.extend(struct.pack("<i", cell_w))       # fx
        buf.extend(struct.pack("<i", cell_h))       # fy

        print(f"  {sprite_name}: atlas({abs_x},{abs_y}) size({crop_w}x{crop_h}) "
              f"offset({off_x},{off_y}) cell({cell_w}x{cell_h})")

    # PNG data with length prefix
    buf.extend(struct.pack("<i", len(atlas_data)))
    buf.extend(atlas_data)

    # Write
    out_path.parent.mkdir(parents=True, exist_ok=True)
    out_path.write_bytes(bytes(buf))
    print(f"  Written: {out_path} ({len(buf):,} bytes)")
    return out_path


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Compile PCP tilesheet into PZ binary .tiles + .pack")
    parser.add_argument("--tiles-only", action="store_true",
                        help="Only compile binary .tiles")
    parser.add_argument("--pack-only", action="store_true",
                        help="Only compile .pack atlas")
    parser.add_argument("--dry-run", action="store_true",
                        help="Show what would be generated")
    args = parser.parse_args()

    config = load_config()
    do_tiles = not args.pack_only
    do_pack = not args.tiles_only

    if do_tiles:
        compile_tiles(config, dry_run=args.dry_run)

    if do_pack:
        compile_pack(config, "1x", dry_run=args.dry_run)
        compile_pack(config, "2x", dry_run=args.dry_run)

    if not args.dry_run:
        print("\nDone. Add to mod.info if not already present:")
        print("  tiledef=pcp_tiles 4200")
        print("  pack=pcp_tiles")
        print("  pack=pcp_tiles2x")


if __name__ == "__main__":
    main()
