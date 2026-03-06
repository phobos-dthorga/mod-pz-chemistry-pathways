#!/usr/bin/env python3
"""
generate_icon_audit_fix.py
Generates 6 new icons for PCP items identified in the v1.3.0 icon audit as having
wrong-product-identity icons (sharing icons with unrelated items).

High priority (5 items with wrong product identity):
- BrineJar: was using CrudeVegetableOil icon
- BrineConcentrate: was using raw_potash icon
- CoarseSalt: was using raw_potash icon
- ActivatedCarbon: was using purified_charcoal icon
- BoneMeal: was using BoneChar icon

Medium priority (4 items sharing Calcite icon → 1 shared construction-mix icon):
- MortarMix, StuccoMix, ReinforcedConcrete, Fireclay: all using Calcite icon

Usage:
    set OPENAI_API_KEY=sk-...
    py scripts/generate_icon_audit_fix.py

    # Dry run:
    py scripts/generate_icon_audit_fix.py --dry-run

    # Generate specific items only:
    py scripts/generate_icon_audit_fix.py --items BrineJar CoarseSalt

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
    # ── High Priority: Wrong product identity (5) ──
    ("BrineJar",
     "A glass mason jar filled with cloudy, slightly yellowish saline water. "
     "Fine white salt crystals visible settling at the bottom. Metal screw-top lid. "
     "Brine / salt water appearance, distinctly different from cooking oil."),

    ("BrineConcentrate",
     "A small ceramic bowl or shallow dish containing a thick, cloudy white-grey "
     "crystallizing salt slurry. Wet salt crystals forming at the edges. "
     "Evaporating brine concentrate appearance."),

    ("CoarseSalt",
     "A small pile of coarse white and off-white salt crystals. Rough, irregular "
     "granules, clearly visible individual grains. Natural sea salt or rock salt "
     "appearance. Clean pile on surface."),

    ("ActivatedCarbon",
     "A small pile of fine black granular activated carbon pellets or granules. "
     "Darker and more uniformly processed than raw charcoal. Very fine, rounded "
     "granules with a slightly glossy appearance. Chemical filtering material. "
     "Distinct from coarse charcoal chunks."),

    ("BoneMeal",
     "A small pile of fine, pale white-grey powder. Bone meal fertilizer appearance. "
     "Very fine ground texture, lighter in colour than charcoal. Powdery consistency, "
     "slightly off-white with a hint of cream."),

    # ── Medium Priority: Construction mix (1 shared icon) ──
    ("ConstructionMix",
     "A small pile of grey-tan dry construction powder mix. Cement-like appearance "
     "with fine sandy texture. Muted grey with slight beige undertones. Could be "
     "mortar mix, stucco, or concrete powder. Construction material pile."),
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
        description="Generate PCP icons for items with wrong-identity shared icons"
    )
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

    print(f"PCP Icon Audit Fix — Generation")
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
    print(f"Done: {generated} generated, {failed} failed")

    if failed > 0:
        print("\nFailed items can be retried with --items <name>")
        sys.exit(1)


if __name__ == "__main__":
    main()
