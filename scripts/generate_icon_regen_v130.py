#!/usr/bin/env python3
"""
generate_icon_regen_v130.py
Regenerates 15 non-conforming icons for PCP v1.3.0 audit using OpenAI gpt-image-1.

These icons were identified as not matching the current PZ isometric pixel art style:
- 9 photorealistic/white-bg biodiesel pathway icons
- 2 placeholder profession icons
- 4 additional style mismatches (book, plastic, fiber, chemical)

Usage:
    set OPENAI_API_KEY=sk-...
    py scripts/generate_icon_regen_v130.py

    # Generate only missing/specific icons:
    py scripts/generate_icon_regen_v130.py --items CrudeBiodiesel Glycerol

    # Dry run (list items, don't generate):
    py scripts/generate_icon_regen_v130.py --dry-run

Icons are saved to: 42/media/textures/<filename>.png
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

# Base style prompt applied to all item icons
ITEM_STYLE_PREFIX = (
    "A single item icon for a 2D top-down survival video game inventory. "
    "Isometric pixel-art style, 128x128 pixels, transparent background. "
    "Clean dark outlines, soft shading, item centered in frame with small padding. "
    "No text, no labels, no UI elements. Consistent with Project Zomboid art style. "
)

# Profession icons get a slightly different style prefix
PROFESSION_STYLE_PREFIX = (
    "A character portrait icon for a 2D survival video game profession select screen. "
    "Isometric pixel-art style, 128x128 pixels, transparent background. "
    "Clean dark outlines, soft shading, character bust centered. "
    "No text, no labels, no UI elements. Consistent with Project Zomboid art style. "
    "Post-apocalyptic appearance, muted colour palette. "
)

# ─── Item Definitions ──────────────────────────────────────────────────────
# Each tuple: (filename (without path), description, is_profession)
ITEMS = [
    # --- Biodiesel Pathway (9 icons) ---
    ("Item_PCP_CrudeBiodiesel.png",
     "A glass mason jar filled with cloudy golden-brown liquid with visible "
     "sediment and impurities at the bottom. Homemade biodiesel appearance. "
     "Metal screw-top lid.",
     False),

    ("Item_PCP_CrudeVegetableOil.png",
     "A glass mason jar filled with pale yellow vegetable oil. Slightly "
     "cloudy, unrefined cooking oil. Metal screw-top lid. Warm golden tones.",
     False),

    ("Item_PCP_Glycerol.png",
     "A small glass bottle with thick, clear, slightly viscous glycerol "
     "liquid. Cork stopper. The liquid has a faint yellowish tint and appears "
     "syrupy. Chemistry reagent bottle.",
     False),

    ("Item_PCP_EmptyRefinedBiodieselCan.png",
     "An empty metal jerry can fuel container with a screw cap on top. "
     "Silver-grey industrial metal with slight dents and scratches. "
     "The can is clearly empty and lightweight-looking.",
     False),

    ("Item_PCP_HalfFilledRefinedBiodieselCan.png",
     "A metal jerry can fuel container half-filled with amber-golden "
     "biodiesel fuel visible through a transparent side strip. Silver-grey "
     "industrial metal with a screw cap. Half-full appearance.",
     False),

    ("Item_PCP_RefinedBiodieselCan.png",
     "A full metal jerry can filled to the brim with amber-golden biodiesel "
     "fuel. Silver-grey industrial metal with a screw cap. Heavy, full "
     "appearance. Clean industrial fuel container.",
     False),

    ("Item_PCP_WashedBiodiesel.png",
     "A glass mason jar filled with cleaner golden-amber liquid that is "
     "noticeably less cloudy than crude biodiesel. Washed and purified "
     "appearance. Metal screw-top lid.",
     False),

    ("Item_PCP_WashedBiodiesel2.png",
     "A glass mason jar filled with golden biodiesel liquid with a piece "
     "of cheesecloth or filter fabric draped over the top of the jar. "
     "Filtering in progress appearance. Metal lid resting beside the cloth.",
     False),

    ("Item_PCP_RenderedFat.png",
     "A glass mason jar filled with pale white-yellow solidified rendered "
     "animal fat or tallow. The fat appears semi-solid and waxy inside the "
     "jar. Metal screw-top lid. Slightly greasy appearance.",
     False),

    # --- Profession Icons (2 icons) ---
    ("profession_pcp_chemist.png",
     "A scientist character holding a small Erlenmeyer flask containing "
     "bright green liquid. Wearing a stained white lab coat and safety "
     "goggles pushed up on forehead. Determined expression. Visible chemical "
     "stains on coat.",
     True),

    ("profession_pcp_pharmacist.png",
     "A pharmacist character holding a mortar and pestle, grinding herbs. "
     "Wearing a practical apron over rolled-up sleeves. Herbal and chemistry "
     "hybrid appearance — dried plant bundles visible in a belt pouch. "
     "Thoughtful expression.",
     True),

    # --- Additional Style Mismatches (4 icons) ---
    ("Item_PCP_BkChemistryPathways.png",
     "A thick hardcover chemistry textbook. Dark blue-green cover with a "
     "faint embossed molecular diagram or beaker symbol on the front. Worn "
     "and dog-eared pages, post-apocalyptic condition. Visible bookmarks.",
     False),

    ("Item_PCP_PlasticScrap.png",
     "Irregular broken pieces and shards of mixed plastic scrap piled "
     "together. Dull, faded colours — grey, off-white, washed-out blue. "
     "Salvaged junk appearance, rough broken edges. Recycling material.",
     False),

    ("Item_PCP_HempBastFiber.png",
     "Long, pale golden-tan plant fibers in a loose bundle. Silky, "
     "strong-looking natural textile fibers stripped from a hemp stalk. "
     "Clean, separated fibers with slight natural sheen.",
     False),

    ("Item_PCP_PotassiumHydroxide.png",
     "Small pile of white caustic crystalline flakes and pellets. Chemical "
     "reagent appearance, slightly waxy lustre. Dangerous chemical. Clean "
     "pile on surface.",
     False),
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
        print("  WARNING: Pillow not installed — image saved at original size.")
        return False


def generate_icon(client, filename: str, description: str, is_profession: bool, output_path: Path) -> bool:
    """Generate a single icon via OpenAI gpt-image-1 and save to output_path."""
    prefix = PROFESSION_STYLE_PREFIX if is_profession else ITEM_STYLE_PREFIX
    prompt = prefix + description

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

        return True

    except Exception as e:
        print(f"  ERROR generating {filename}: {e}")
        return False


def main():
    parser = argparse.ArgumentParser(
        description="Regenerate non-conforming PCP icons via OpenAI gpt-image-1"
    )
    parser.add_argument("--dry-run", action="store_true",
                        help="List items without generating")
    parser.add_argument("--items", nargs="*",
                        help="Generate only these items (by stem name, e.g. CrudeBiodiesel)")
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
        items = [
            (f, d, p) for f, d, p in ITEMS
            if any(n in f for n in name_set)
        ]
        if not items:
            all_names = [f.replace(".png", "") for f, _, _ in ITEMS]
            print(f"No matching items found. Available:\n  " +
                  "\n  ".join(all_names))
            sys.exit(1)

    print(f"PCP v1.3.0 Icon Regeneration")
    print(f"  Output: {TEXTURE_DIR}")
    print(f"  Items:  {len(items)}")
    print()

    if args.dry_run:
        for i, (filename, desc, is_prof) in enumerate(items, 1):
            path = TEXTURE_DIR / filename
            status = "EXISTS (will be REPLACED)" if path.exists() else "NEW"
            tag = "[PROFESSION]" if is_prof else "[ITEM]"
            print(f"  {i:2d}. {filename} {tag} [{status}]")
        return

    client = OpenAI(api_key=api_key)

    generated = 0
    failed = 0

    for i, (filename, desc, is_prof) in enumerate(items, 1):
        output_path = TEXTURE_DIR / filename
        tag = "PROF" if is_prof else "ITEM"

        print(f"  [{i:2d}/{len(items)}] [{tag}] Generating {filename}...",
              end=" ", flush=True)

        if generate_icon(client, filename, desc, is_prof, output_path):
            print(f"OK")
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
