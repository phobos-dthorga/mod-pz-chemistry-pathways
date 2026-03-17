#!/usr/bin/env python3
"""Generate a PZ .tiles.txt tile definition file from furniture_items.json.

Produces common/media/pcp_tiles.tiles.txt in the format expected by PZ's
tile loading system (matching ZVV's demonius_vaccine.tiles.txt structure).

Usage:
    py scripts/generate_tiles_txt.py              # Generate .tiles.txt
    py scripts/generate_tiles_txt.py --dry-run    # Preview to stdout only
"""

import argparse
import json
import sys
from pathlib import Path

# --- Paths ---
SCRIPT_DIR = Path(__file__).resolve().parent
CONFIG_PATH = SCRIPT_DIR / "furniture_items.json"
MEDIA_DIR = SCRIPT_DIR.parent / "common" / "media"

# --- Constants ---
FACING_ORDER = ["S", "E", "N", "W"]


def load_config() -> dict:
    """Load furniture_items.json."""
    with open(CONFIG_PATH, encoding="utf-8") as f:
        return json.load(f)


def compute_grid_positions(items: list[dict], grid_cols: int
                           ) -> list[tuple[dict, str, int, int]]:
    """Compute (item, facing, x, y) for each tile in the grid.

    Returns list of (item_dict, facing_str, grid_x, grid_y) tuples.
    """
    positions = []
    col = 0
    row = 0

    for item in items:
        facings = item["facings"]
        cells_needed = len(facings)

        # Wrap to next row if needed
        if col + cells_needed > grid_cols:
            col = 0
            row += 1

        for facing in facings:
            positions.append((item, facing, col, row))
            col += 1

        # If we've exactly filled a row, advance
        if col >= grid_cols:
            col = 0
            row += 1

    return positions


def generate_tile_block(item: dict, facing: str, x: int, y: int) -> str:
    """Generate a single tile {} block."""
    lines = []
    lines.append("    tile")
    lines.append("    {")
    lines.append(f"        xy = {x},{y}")

    if item.get("blocks_placement", False):
        lines.append("        BlocksPlacement =")

    lines.append(f"        CustomName = {item['custom_name']}")
    lines.append(f"        Facing = {facing}")
    lines.append(f"        GroupName = PCP")

    if item.get("is_moveable", True):
        lines.append("        IsMoveAble =")

    if item.get("is_surface", False):
        lines.append("        IsTableTop =")
        lines.append("        Surface = 34")

    lines.append(f"        PickUpWeight = {item['pickup_weight']}")
    lines.append("    }")

    return "\n".join(lines)


def generate_tiles_txt(config: dict) -> str:
    """Generate the full .tiles.txt content."""
    tileset = config["_tileset"]
    items = config["items"]
    grid_cols = tileset["grid_columns"]

    positions = compute_grid_positions(items, grid_cols)

    # Calculate grid rows needed
    if positions:
        max_row = max(y for _, _, _, y in positions)
        grid_rows = max_row + 1
    else:
        grid_rows = 1

    lines = []
    lines.append("version = 1")
    lines.append("")
    lines.append("tileset")
    lines.append("{")
    lines.append(f"    file = {tileset['name']}")
    lines.append(f"    size = {grid_cols},{grid_rows}")
    lines.append(f"    id = {tileset['id']}")
    lines.append("")

    for item, facing, x, y in positions:
        lines.append(generate_tile_block(item, facing, x, y))
        lines.append("")

    lines.append("}")
    lines.append("")

    return "\n".join(lines)


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Generate PZ .tiles.txt from furniture_items.json")
    parser.add_argument("--dry-run", action="store_true",
                        help="Preview to stdout without writing file")
    args = parser.parse_args()

    config = load_config()
    content = generate_tiles_txt(config)

    if args.dry_run:
        print(content)
        print(f"\n--- {len(config['items'])} item(s), "
              f"{sum(len(i['facings']) for i in config['items'])} tile(s) ---")
        return

    output_path = MEDIA_DIR / "pcp_tiles.tiles.txt"
    output_path.parent.mkdir(parents=True, exist_ok=True)
    output_path.write_text(content, encoding="utf-8")

    print(f"Generated: {output_path}")
    print(f"Items: {len(config['items'])}")
    total = sum(len(i['facings']) for i in config['items'])
    print(f"Tiles: {total}")
    print(f"Tileset: {config['_tileset']['name']} (id={config['_tileset']['id']})")

    # Also print the sprite name mapping for entity definitions
    grid_cols = config["_tileset"]["grid_columns"]
    positions = compute_grid_positions(config["items"], grid_cols)
    tileset_name = config["_tileset"]["name"]

    print(f"\nSprite name mapping (for entity SpriteConfig):")
    for item, facing, x, y in positions:
        idx = y * grid_cols + x
        sprite_name = f"{tileset_name}_{idx}"
        print(f"  {item['id']:20s} {facing:6s} -> {sprite_name}")


if __name__ == "__main__":
    main()
