#!/usr/bin/env python3
"""Assemble individual furniture sprite facings into a PZ tilesheet grid.

Reads furniture_items.json for item ordering, then combines the facing PNGs
from scripts/sprite_output/ into a single tilesheet grid image suitable for
PZ's tile system.

Generates both 1x and 2x resolution tilesheets.

Usage:
    py scripts/build_tilesheet.py              # Build tilesheets
    py scripts/build_tilesheet.py --dry-run    # Show layout without writing
"""

import argparse
import json
import sys
from pathlib import Path

from PIL import Image

# --- Paths ---
SCRIPT_DIR = Path(__file__).resolve().parent
CONFIG_PATH = SCRIPT_DIR / "furniture_items.json"
SPRITE_DIR = SCRIPT_DIR / "sprite_output"
# Output goes to common/media/ where PZ expects tilesheet sources
MEDIA_DIR = SCRIPT_DIR.parent / "common" / "media"

# --- Constants ---
GRID_COLUMNS = 8
CELL_1X = (128, 256)
CELL_2X = (256, 512)

# Facing order within a row (matches PZ convention: S, E, N, W)
FACING_ORDER = ["S", "E", "N", "W"]


def load_config() -> dict:
    """Load furniture_items.json."""
    with open(CONFIG_PATH, encoding="utf-8") as f:
        return json.load(f)


def get_grid_layout(items: list[dict]) -> list[list[tuple[str, str] | None]]:
    """Compute the grid layout: list of rows, each row is a list of
    (item_id, facing) tuples or None for empty cells.

    Items with 4 facings take 4 consecutive columns.
    Items with SINGLE facing take 1 column.
    Items are packed left-to-right, wrapping to next row when full.
    """
    rows: list[list[tuple[str, str] | None]] = []
    current_row: list[tuple[str, str] | None] = []

    for item in items:
        item_id = item["id"]
        facings = item["facings"]
        cells_needed = len(facings)

        # If this item won't fit on the current row, pad and start new row
        if len(current_row) + cells_needed > GRID_COLUMNS:
            # Pad remainder with None
            while len(current_row) < GRID_COLUMNS:
                current_row.append(None)
            rows.append(current_row)
            current_row = []

        # Place facings in order
        for facing in facings:
            # Normalize SINGLE to the standard order position
            current_row.append((item_id, facing))

    # Pad and append final row
    if current_row:
        while len(current_row) < GRID_COLUMNS:
            current_row.append(None)
        rows.append(current_row)

    return rows


def build_tilesheet(items: list[dict], resolution: str,
                    dry_run: bool = False) -> Path | None:
    """Build a tilesheet at the given resolution ('1x' or '2x').

    Returns the output path, or None on dry run.
    """
    cell_w, cell_h = CELL_1X if resolution == "1x" else CELL_2X
    suffix = f"_{resolution}"

    grid = get_grid_layout(items)
    num_rows = len(grid)
    sheet_w = GRID_COLUMNS * cell_w
    sheet_h = num_rows * cell_h

    tileset_name = load_config()["_tileset"]["name"]

    print(f"\n--- {resolution} Tilesheet ---")
    print(f"Grid: {GRID_COLUMNS} cols x {num_rows} rows")
    print(f"Sheet size: {sheet_w} x {sheet_h} px")
    print(f"Cell size: {cell_w} x {cell_h} px")

    # Print layout
    for row_idx, row in enumerate(grid):
        cells = []
        for cell in row:
            if cell is None:
                cells.append("  ---  ")
            else:
                item_id, facing = cell
                cells.append(f"{item_id[:5]}_{facing}")
        print(f"  Row {row_idx}: {' | '.join(cells)}")

    if dry_run:
        return None

    # Assemble the tilesheet
    sheet = Image.new("RGBA", (sheet_w, sheet_h), (0, 0, 0, 0))
    missing = []

    for row_idx, row in enumerate(grid):
        for col_idx, cell in enumerate(row):
            if cell is None:
                continue
            item_id, facing = cell
            sprite_path = SPRITE_DIR / item_id / f"{item_id}_{facing}{suffix}.png"

            if not sprite_path.exists():
                missing.append(str(sprite_path))
                continue

            sprite = Image.open(sprite_path).convert("RGBA")
            # Verify dimensions
            if sprite.size != (cell_w, cell_h):
                print(f"  WARNING: {sprite_path.name} is {sprite.size}, "
                      f"expected {cell_w}x{cell_h}. Resizing.")
                sprite = sprite.resize((cell_w, cell_h), Image.LANCZOS)

            x = col_idx * cell_w
            y = row_idx * cell_h
            sheet.paste(sprite, (x, y))

    if missing:
        print(f"\n  WARNING: {len(missing)} missing sprite(s):")
        for m in missing:
            print(f"    - {m}")

    # Save tilesheet
    # Output as source PNG alongside where .pack files would go
    output_dir = MEDIA_DIR / "texturepacks"
    output_dir.mkdir(parents=True, exist_ok=True)

    if resolution == "2x":
        out_name = f"{tileset_name}2x_src.png"
    else:
        out_name = f"{tileset_name}_src.png"

    output_path = output_dir / out_name
    sheet.save(output_path, "PNG")
    print(f"\n  Saved: {output_path}")
    print(f"  File size: {output_path.stat().st_size:,} bytes")

    return output_path


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Assemble furniture sprites into PZ tilesheet grid")
    parser.add_argument("--dry-run", action="store_true",
                        help="Show layout without writing files")
    args = parser.parse_args()

    config = load_config()
    items = config["items"]

    if not items:
        print("No items defined in furniture_items.json")
        sys.exit(1)

    print(f"Items: {len(items)}")
    total_sprites = sum(len(i['facings']) for i in items)
    print(f"Total sprites: {total_sprites}")

    # Build both resolutions
    for res in ("1x", "2x"):
        build_tilesheet(items, res, dry_run=args.dry_run)

    print("\nDone.")
    if not args.dry_run:
        print("\nNext steps:")
        print("  1. Run: py scripts/generate_tiles_txt.py")
        print("  2. If PZ requires .pack files, compile with TileZed")
        print("  3. Test in-game")


if __name__ == "__main__":
    main()
