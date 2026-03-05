#!/usr/bin/env python3
"""
generate_book_icons.py
Generates 5 category recipe book icons + optional master compendium icon
for PhobosChemistryPathways via OpenAI gpt-image-1.

Usage:
    set OPENAI_API_KEY=sk-...
    py scripts/generate_book_icons.py

    # Skip items that already have icons:
    py scripts/generate_book_icons.py --skip-existing

    # Dry run (list items, don't generate):
    py scripts/generate_book_icons.py --dry-run

Icons are saved to: 42/media/textures/Item_PCP_<BookId>.png
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

# --- Configuration ---
REPO_ROOT = Path(__file__).resolve().parent.parent
TEXTURE_DIR = REPO_ROOT / "42" / "media" / "textures"
IMAGE_SIZE = "1024x1024"

STYLE_PREFIX = (
    "A single item icon for a 2D top-down survival video game inventory. "
    "Isometric pixel-art style, 128x128 pixels, transparent background. "
    "Clean dark outlines, soft shading, item centered in frame with small padding. "
    "No text, no labels, no UI elements. Consistent with Project Zomboid art style. "
)

# --- Book Definitions ---
BOOKS = [
    ("BkFieldChemistry",
     "A worn olive-green field notebook or paperback book with a small flask or "
     "beaker symbol embossed on the cover. Dog-eared pages, slightly battered. "
     "Olive green and brown tones. Chunky pixel-art with dark outlines."),

    ("BkKitchenChemistry",
     "A warm orange-brown recipe book or cookbook with a small mortar and pestle "
     "symbol on the cover. Soft rounded edges, homely appearance. Warm orange "
     "and brown tones. Chunky pixel-art with dark outlines."),

    ("BkLabChemistry",
     "A clean blue-and-white laboratory manual or textbook with a beaker or "
     "Erlenmeyer flask symbol on the cover. Pristine condition, professional look. "
     "Blue and white tones. Chunky pixel-art with dark outlines."),

    ("BkIndustrialChemistry",
     "A heavy dark grey technical manual with yellow warning stripes or industrial "
     "gear symbols on the cover. Thick binding, utilitarian appearance. Dark grey "
     "and yellow tones. Chunky pixel-art with dark outlines."),

    ("BkHorticulture",
     "A green garden handbook or botanical guide with a leaf or small plant sprout "
     "symbol on the cover. Fresh and natural appearance. Green and light brown "
     "tones. Chunky pixel-art with dark outlines."),
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
        print("  WARNING: Pillow not installed -- image saved at original size. "
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

        image_data = base64.b64decode(result.data[0].b64_json)
        output_path.parent.mkdir(parents=True, exist_ok=True)
        output_path.write_bytes(image_data)

        resize_to_128(output_path)
        return True

    except Exception as e:
        print(f"  ERROR generating {item_name}: {e}")
        return False


def main():
    parser = argparse.ArgumentParser(
        description="Generate PCP category recipe book icons"
    )
    parser.add_argument("--skip-existing", action="store_true",
                        help="Skip books that already have icons")
    parser.add_argument("--dry-run", action="store_true",
                        help="List books without generating")
    parser.add_argument("--items", nargs="*",
                        help="Generate only these books (by ID)")
    args = parser.parse_args()

    api_key = os.environ.get("OPENAI_API_KEY")
    if not api_key and not args.dry_run:
        print("ERROR: OPENAI_API_KEY environment variable not set.")
        print("  set OPENAI_API_KEY=sk-...")
        sys.exit(1)

    # Filter items if requested
    books = BOOKS
    if args.items:
        name_set = set(args.items)
        books = [(n, d) for n, d in BOOKS if n in name_set]
        if not books:
            print(f"No matching books found. Available: {[n for n, _ in BOOKS]}")
            sys.exit(1)

    print(f"PCP Book Icon Generation")
    print(f"  Output: {TEXTURE_DIR}")
    print(f"  Books:  {len(books)}")
    print()

    if args.dry_run:
        for i, (name, desc) in enumerate(books, 1):
            path = TEXTURE_DIR / f"Item_PCP_{name}.png"
            exists = "EXISTS" if path.exists() else "MISSING"
            print(f"  {i:2d}. Item_PCP_{name}.png [{exists}]")
        return

    client = OpenAI(api_key=api_key)

    generated = 0
    skipped = 0
    failed = 0

    for i, (name, desc) in enumerate(books, 1):
        output_path = TEXTURE_DIR / f"Item_PCP_{name}.png"

        if args.skip_existing and output_path.exists():
            print(f"  [{i:2d}/{len(books)}] SKIP {name} (exists)")
            skipped += 1
            continue

        print(f"  [{i:2d}/{len(books)}] Generating {name}...", end=" ", flush=True)

        if generate_icon(client, name, desc, output_path):
            print(f"OK -> {output_path.name}")
            generated += 1
        else:
            failed += 1

        # Rate limit courtesy pause
        if i < len(books):
            time.sleep(2)

    print()
    print(f"Done: {generated} generated, {skipped} skipped, {failed} failed")


if __name__ == "__main__":
    main()
