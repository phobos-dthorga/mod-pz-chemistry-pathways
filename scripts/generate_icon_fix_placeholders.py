#!/usr/bin/env python3
"""
generate_icon_fix_placeholders.py
Generates 5 unique icons for PCP items that currently use shared or generic
vanilla icons, making them visually indistinguishable in-game.

Construction materials (4 items sharing PCP_ConstructionMix):
- MortarMix, StuccoMix, ReinforcedConcrete, Fireclay

Vanilla fallback (1 item using AnimalFeed):
- MineralFeedSupplement

Usage:
    set OPENAI_API_KEY=sk-...
    py scripts/generate_icon_fix_placeholders.py

    # Dry run:
    py scripts/generate_icon_fix_placeholders.py --dry-run

    # Generate specific items only:
    py scripts/generate_icon_fix_placeholders.py --items MortarMix Fireclay

    # Skip items that already have textures:
    py scripts/generate_icon_fix_placeholders.py --skip-existing

Icons are saved to: common/media/textures/Item_PCP_<ItemName>.png
Style: 128x128 RGBA PNG, isometric pixel art, transparent background.
"""

import os
import sys
import argparse
import base64
import time
from pathlib import Path

try:
    from openai import OpenAI
except ImportError:
    print("ERROR: openai package not found. Install with: pip install openai")
    sys.exit(1)

# ─── Configuration ─────────────────────────────────────────────────────────
REPO_ROOT = Path(__file__).resolve().parent.parent
TEXTURE_DIR = REPO_ROOT / "common" / "media" / "textures"
IMAGE_SIZE = "1024x1024"

# Base style prompt — consistent with art-style-guidelines.md
STYLE_PREFIX = (
    "A single item icon for a 2D top-down survival video game inventory. "
    "Isometric pixel-art style, 128x128 pixels, transparent background. "
    "Clean dark outlines, soft shading, item centered in frame with small padding. "
    "No text, no labels, no UI elements. Consistent with Project Zomboid art style. "
)

# ─── Item Definitions ──────────────────────────────────────────────────────
# Each tuple: (filename_stem, description_for_prompt)
ITEMS = [
    # ── Construction materials (4, replacing shared PCP_ConstructionMix) ──
    ("MortarMix",
     "A small pile of light grey powdery mortar mix with visible coarse sand "
     "grains mixed in. Cement-like dry powder, pale grey with a slight warm "
     "sandy tone. Traditional masonry mortar powder, finer than gravel but "
     "grittier than flour. Small pile sitting on the ground."),

    ("StuccoMix",
     "A small pile of off-white to cream-coloured stucco plaster powder. "
     "Very fine, smooth texture, lighter and whiter than concrete. Wall "
     "plaster or stucco finish material with an almost chalky, powdery "
     "appearance. Small neat pile."),

    ("ReinforcedConcrete",
     "A small rough concrete block or chunk with visible short rebar wire "
     "pieces embedded in it. Dark grey concrete with metallic reinforcement "
     "bars protruding at angles. Heavier and darker than plain mortar. "
     "Industrial construction look with steel and stone."),

    ("Fireclay",
     "A small pile of reddish-tan refractory clay powder. Warm terracotta "
     "colour, noticeably more orange-red than grey concrete mixes. "
     "Fire-resistant clay material with earthy warm tones. Small pile "
     "of fine-grained reddish-brown powder."),

    # ── Animal feed (1, replacing vanilla AnimalFeed icon) ──
    ("MineralFeedSupplement",
     "A small burlap sack or sandbag, partially open at the top, filled "
     "with brownish granular mineral feed supplement pellets. Earthy brown "
     "pellets visible spilling from the top. Rustic post-apocalyptic animal "
     "feed bag tied with twine."),
]


def resize_to_128(input_path: Path):
    """Resize a generated image down to 128x128 RGBA PNG."""
    try:
        from PIL import Image
        img = Image.open(input_path).convert("RGBA")
        img = img.resize((128, 128), Image.LANCZOS)
        img.save(input_path, "PNG")
        return True
    except ImportError:
        print("  WARNING: Pillow not installed — image saved at original size. "
              "Install with: pip install Pillow")
        return False


def verify_icon(path: Path) -> bool:
    """Verify the icon has non-transparent content (not blank)."""
    try:
        from PIL import Image
        img = Image.open(path).convert("RGBA")
        pixels = img.getdata()
        non_transparent = sum(1 for r, g, b, a in pixels if a > 0)
        total = img.width * img.height
        fill_pct = non_transparent / total * 100
        if fill_pct < 1.0:
            print(f"  WARNING: Only {fill_pct:.1f}% non-transparent pixels — likely blank!")
            return False
        print(f"  Verified: {fill_pct:.1f}% fill, {path.stat().st_size:,} bytes")
        return True
    except ImportError:
        print(f"  Size: {path.stat().st_size:,} bytes (Pillow not available for verification)")
        return path.stat().st_size > 500


def generate_icon(client, item_name: str, description: str, output_path: Path) -> bool:
    """Generate a single icon via OpenAI gpt-image-1 and save to output_path."""
    prompt = STYLE_PREFIX + description

    try:
        result = client.images.generate(
            model="gpt-image-1",
            prompt=prompt,
            n=1,
            size=IMAGE_SIZE,
            quality="high",
            background="transparent",
        )

        image_data = base64.b64decode(result.data[0].b64_json)
        output_path.parent.mkdir(parents=True, exist_ok=True)
        output_path.write_bytes(image_data)

        # Resize to 128x128
        resize_to_128(output_path)

        # Verify non-blank
        return verify_icon(output_path)

    except Exception as e:
        print(f"  ERROR generating {item_name}: {e}")
        return False


def main():
    parser = argparse.ArgumentParser(
        description="Generate PCP icons for items with shared/generic placeholder icons"
    )
    parser.add_argument("--dry-run", action="store_true",
                        help="List items without generating")
    parser.add_argument("--items", nargs="*",
                        help="Generate only these items (by stem name)")
    parser.add_argument("--skip-existing", action="store_true",
                        help="Skip items that already have textures")
    args = parser.parse_args()

    api_key = os.environ.get("OPENAI_API_KEY")
    if not api_key and not args.dry_run:
        print("ERROR: OPENAI_API_KEY environment variable not set.")
        print("  set OPENAI_API_KEY=sk-...")
        sys.exit(1)

    # Filter items if requested
    items = list(ITEMS)
    if args.items:
        name_set = set(args.items)
        items = [(n, d) for n, d in ITEMS if n in name_set]
        if not items:
            print(f"No matching items found. Available: {[n for n, _ in ITEMS]}")
            sys.exit(1)

    if args.skip_existing:
        items = [(n, d) for n, d in items
                 if not (TEXTURE_DIR / f"Item_PCP_{n}.png").exists()]

    print(f"PCP Icon Placeholder Fix — Generation")
    print(f"  Output: {TEXTURE_DIR}")
    print(f"  Items:  {len(items)}")
    print()

    if args.dry_run:
        for i, (name, desc) in enumerate(items, 1):
            path = TEXTURE_DIR / f"Item_PCP_{name}.png"
            exists = "EXISTS (will be REPLACED)" if path.exists() else "NEW"
            print(f"  {i:2d}. Item_PCP_{name}.png [{exists}]")
        return

    client = OpenAI(api_key=api_key)

    generated = 0
    failed = 0

    for i, (name, desc) in enumerate(items, 1):
        output_path = TEXTURE_DIR / f"Item_PCP_{name}.png"

        print(f"  [{i:2d}/{len(items)}] Generating {name}...", flush=True)

        if generate_icon(client, name, desc, output_path):
            print(f"    OK -> {output_path.name}")
            generated += 1
        else:
            failed += 1

        # Rate limit courtesy pause
        if i < len(items):
            time.sleep(2)

    print()
    print(f"Done: {generated} generated, {failed} failed")
    est_cost = (generated + failed) * 0.18
    print(f"Estimated cost: ~${est_cost:.2f}")

    if failed > 0:
        print("\nFailed items can be retried with --items <name>")
        sys.exit(1)


if __name__ == "__main__":
    main()
