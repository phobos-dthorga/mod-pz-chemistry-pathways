#!/usr/bin/env python3
"""
generate_horticulture_icons.py
Generates 31 horticulture item icons for PCP using OpenAI gpt-image-1.

Usage:
    set OPENAI_API_KEY=sk-...
    py scripts/generate_horticulture_icons.py

    # Generate only missing icons:
    py scripts/generate_horticulture_icons.py --skip-existing

    # Dry run (list items, don't generate):
    py scripts/generate_horticulture_icons.py --dry-run

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

# Base style prompt applied to all icons
STYLE_PREFIX = (
    "A single item icon for a 2D top-down survival video game inventory. "
    "Isometric pixel-art style, 128x128 pixels, transparent background. "
    "Clean dark outlines, soft shading, item centered in frame with small padding. "
    "No text, no labels, no UI elements. Consistent with Project Zomboid art style. "
)

# ─── Item Definitions ──────────────────────────────────────────────────────
# Each tuple: (filename_stem, description_for_prompt)
ITEMS = [
    # ── Tobacco (4) ──
    ("TobaccoWet", "A bundle of freshly harvested wet green tobacco leaves, tied loosely with string. Bright green with moisture droplets."),
    ("ChewingTobaccoTin", "A small round tin can filled with shredded dark brown chewing tobacco. The tin lid is partially open showing the tobacco inside."),
    ("ChewingTobaccoWaterTin", "A small sealed cylindrical water ration tin repurposed to hold chewing tobacco. Olive-green military-style tin with a slight tobacco leaf visible."),
    ("ChewingTobaccoJar", "A glass mason jar filled with dark brown shredded chewing tobacco. The jar has a metal screw-top lid. Warm brown tones."),

    # ── Hemp Buds (8) ──
    ("HempBuds", "A small cluster of fresh green hemp flower buds. Bright green with tiny leaf structures and trichomes visible. Natural and organic appearance."),
    ("HempBudsCured", "A cluster of dried and cured hemp buds, amber-brown in colour with a slightly compressed appearance. Dried and darker than fresh buds."),
    ("HempBudsDecarbed", "A cluster of decarboxylated hemp buds that have been heated. Dark brown, slightly crumbly appearance, toasted-looking."),
    ("CannedHempBuds", "A sealed tin can containing hemp buds. Standard silver-gray tin can with a slightly green tint visible through the top. Sealed and intact."),
    ("CannedHempBudsCured", "A sealed tin can containing cured hemp buds. Silver tin can with an amber-brown tint, slightly aged appearance. Label reads nothing."),
    ("CannedHempBudsDecarbed", "A sealed tin can containing decarboxylated hemp buds. Silver tin can with a dark brown appearance, toasted label colouring."),
    ("CannedHempBudsOpen", "An opened tin can with the lid peeled back, revealing green hemp buds inside. The jagged metal lid curls upward."),
    ("CannedHempBudsDecarbedOpen", "An opened tin can with the lid peeled back, revealing dark brown decarboxylated hemp buds inside. The jagged metal lid curls upward."),

    # ── Drainable (1) ──
    ("HempLoose", "A small pile of finely ground loose green-brown hemp material. Resembles ground herbs or tea leaves. Crumbly texture in a small mound."),

    # ── Papermaking (5) ──
    ("PaperPulpPot", "A cooking pot filled with wet, mushy grey-green paper pulp slurry. Water and hemp fiber visible as a thick paste inside an iron pot."),
    ("PaperPulpPotForged", "A hand-forged iron cooking pot filled with wet paper pulp. Darker, rougher pot with thick walls, containing grey-green pulp slurry inside."),
    ("MouldAndDeckle", "A simple rectangular wooden frame (mould and deckle) used for papermaking. Two flat wooden frames joined together with a fine mesh screen between them."),
    ("MouldAndDecklePaperSheet", "A wooden mould and deckle frame with a wet, thin, off-white paper sheet draped across the screen surface. The paper is translucent and damp."),
    ("RollingPapers", "A small booklet of thin, translucent hemp rolling papers. Light tan papers stacked neatly in a small packet with the top paper slightly lifted."),

    # ── Smoking (10) ──
    ("SmokingPipeGlass", "A small glass smoking pipe, transparent with a slight blue-green tint. Curved bowl shape with a straight stem. Clean and empty."),
    ("SmokingPipeHemp", "A wooden smoking pipe (briar-style) packed with green-brown hemp in the bowl. Wisps of smoke rising from the packed bowl. Warm brown wood."),
    ("SmokingPipeGlassHemp", "A glass smoking pipe packed with green-brown hemp in the bowl. Transparent glass with visible herb inside. Slight smoke wisps."),
    ("SmokingPipeGlassTobacco", "A glass smoking pipe packed with dark brown tobacco in the bowl. Transparent glass with visible brown tobacco shreds inside."),
    ("CanPipeHemp", "A makeshift smoking pipe made from a crushed aluminium soda can, packed with green-brown hemp. Crude DIY construction, silvery aluminium."),
    ("CigarHemp", "A hand-rolled hemp cigar wrapped in a hemp cloth wrapper. Thick, short cigar shape, green-brown with a natural fiber texture."),
    ("CigarRolled", "A hand-rolled tobacco cigar wrapped in rough cloth strips. Brown tobacco filling visible at the ends. Rustic, imperfect shape."),
    ("CigaretteHemp", "A single hand-rolled hemp cigarette. Thin, white rolling paper with green-brown hemp visible at the tip. Slightly irregular hand-rolled shape."),
    ("CigarettePackHemp", "A small bundle of hand-rolled hemp cigarettes wrapped together with a strip of hemp paper. 5-6 thin cigarettes bundled neatly."),
    ("CigarettePackRolled", "A small bundle of hand-rolled tobacco cigarettes wrapped together with paper. 5-6 thin cigarettes with brown tobacco tips, bundled neatly."),

    # ── Cooking (3) ──
    ("SaucepanSyrup", "A small saucepan filled with golden-amber sugar syrup. Shiny, viscous liquid in a metal saucepan with a long handle. Warm golden tones."),
    ("SaucepanCopperSyrup", "A copper saucepan filled with golden-amber sugar syrup. Reddish-copper pan with a long handle, containing shiny golden liquid."),
    ("SimpleSugarSyrup", "A glass jar filled with clear golden sugar syrup. The syrup is translucent amber with a slight golden glow. Mason jar with metal lid."),
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
        print("  WARNING: Pillow not installed — image saved at original size. Install with: pip install Pillow")
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
    parser = argparse.ArgumentParser(description="Generate PCP horticulture icons via OpenAI gpt-image-1")
    parser.add_argument("--skip-existing", action="store_true", help="Skip items that already have icons")
    parser.add_argument("--dry-run", action="store_true", help="List items without generating")
    parser.add_argument("--items", nargs="*", help="Generate only these items (by stem name)")
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

    print(f"PCP Horticulture Icon Generator")
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

        # Rate limit courtesy pause (gpt-image-1 has limits)
        if i < len(items):
            time.sleep(2)

    print()
    print(f"Done: {generated} generated, {skipped} skipped, {failed} failed")


if __name__ == "__main__":
    main()
