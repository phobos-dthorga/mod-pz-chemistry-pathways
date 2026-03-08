#!/usr/bin/env python3
"""
generate_chewing_tobacco_icons.py
Generate 4 new icons for the v1.5.0 chewing tobacco redesign.

Usage:
    set OPENAI_API_KEY=sk-...
    py scripts/generate_chewing_tobacco_icons.py

    # Skip items that already have icons:
    py scripts/generate_chewing_tobacco_icons.py --skip-existing

    # Dry run (list items, don't generate):
    py scripts/generate_chewing_tobacco_icons.py --dry-run

    # Generate only specific items:
    py scripts/generate_chewing_tobacco_icons.py --items ChewingTobaccoMixRaw ChewingTobacco

Icons are saved to: 42/media/textures/Item_PCP_<ItemName>.png
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
TEXTURE_DIR = REPO_ROOT / "42" / "media" / "textures"
IMAGE_SIZE = "1024x1024"  # gpt-image-1 generates at this size; we resize to 128x128

# Base style prompt — identical to other PCP icon generation scripts
STYLE_PREFIX = (
    "A single item icon for a 2D top-down survival video game inventory. "
    "Isometric pixel-art style, 128x128 pixels, transparent background. "
    "Clean dark outlines, soft shading, item centered in frame with small padding. "
    "No text, no labels, no UI elements. Consistent with Project Zomboid art style. "
)

# ─── Item Definitions ──────────────────────────────────────────────────────
# Each tuple: (filename_stem, description_for_prompt)
ITEMS = [
    ("ChewingTobaccoMixRaw",
     "A small mound of moist dark brown tobacco mix on a surface. Coarsely "
     "chopped tobacco leaves blended with visible white salt crystals and "
     "yellowish sugar granules. Slightly glistening wet texture. Dark earthy "
     "brown tones with muted highlights. Chunky pixel-art with dark outlines."),

    ("SealedChewingTobaccoJar",
     "A glass mason jar with a metal screw-top lid, filled with dark brown "
     "moist tobacco mix. The jar is sealed and the contents are packed tightly. "
     "The glass shows the dark brown-black tobacco inside. Metal lid visible "
     "on top. Pixel-art style with dark outlines. No text, no labels."),

    ("CuredChewingTobaccoJar",
     "A glass mason jar with a metal screw-top lid, filled with very dark "
     "uniform blackish-brown cured tobacco. Darker and more uniform in colour "
     "than fresh mix — the curing process has darkened it considerably. "
     "The glass shows the nearly black tobacco inside. Metal lid on top. "
     "Pixel-art style with dark outlines. No text, no labels."),

    ("ChewingTobacco",
     "A loose plug or twist of dark moist chewing tobacco. Dark brown-black "
     "colour, slightly compressed and twisted. Resembles a small dense wad "
     "of cured tobacco leaves. Glistening wet surface. No container or "
     "packaging. Chunky pixel-art with dark outlines."),
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

        # gpt-image-1 returns base64 data
        image_data = base64.b64decode(result.data[0].b64_json)
        output_path.parent.mkdir(parents=True, exist_ok=True)
        output_path.write_bytes(image_data)

        # Resize to 128x128
        resize_to_128(output_path)

        return True

    except Exception as e:
        print(f"  ERROR generating {item_name}: {e}")
        return False


def main():
    parser = argparse.ArgumentParser(
        description="Generate icons for v1.5.0 chewing tobacco redesign"
    )
    parser.add_argument("--skip-existing", action="store_true",
                        help="Skip items that already have icons")
    parser.add_argument("--dry-run", action="store_true",
                        help="List items without generating")
    parser.add_argument("--items", nargs="*",
                        help="Generate only these items (by stem name)")
    args = parser.parse_args()

    api_key = os.environ.get("OPENAI_API_KEY")
    if not api_key and not args.dry_run:
        print("ERROR: OPENAI_API_KEY environment variable not set.")
        print("  set OPENAI_API_KEY=sk-...")
        sys.exit(1)

    # Filter items if requested
    items = ITEMS
    if args.items:
        name_set = set(args.items)
        items = [(n, d) for n, d in ITEMS if n in name_set]
        if not items:
            print(f"No matching items found. Available: {[n for n, _ in ITEMS]}")
            sys.exit(1)

    print(f"PCP Chewing Tobacco Icons (v1.5.0)")
    print(f"  Output: {TEXTURE_DIR}")
    print(f"  Items:  {len(items)}")
    print()

    if args.dry_run:
        for i, (name, desc) in enumerate(items, 1):
            path = TEXTURE_DIR / f"Item_PCP_{name}.png"
            exists = "EXISTS" if path.exists() else "MISSING"
            print(f"  {i:2d}. Item_PCP_{name}.png [{exists}]")
        return

    client = OpenAI(api_key=api_key)

    generated = 0
    skipped = 0
    failed = 0

    for i, (name, desc) in enumerate(items, 1):
        output_path = TEXTURE_DIR / f"Item_PCP_{name}.png"

        if args.skip_existing and output_path.exists():
            print(f"  [{i:2d}/{len(items)}] SKIP {name} (exists)")
            skipped += 1
            continue

        print(f"  [{i:2d}/{len(items)}] Generating {name}...", end=" ", flush=True)

        if generate_icon(client, name, desc, output_path):
            print(f"OK -> {output_path.name}")
            generated += 1
        else:
            failed += 1

        # Rate limit courtesy pause
        if i < len(items):
            time.sleep(2)

    print()
    print(f"Done: {generated} generated, {skipped} skipped, {failed} failed")


if __name__ == "__main__":
    main()
