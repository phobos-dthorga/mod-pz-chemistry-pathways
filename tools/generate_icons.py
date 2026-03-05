#!/usr/bin/env python3
"""
PCP Icon Generator — OpenAI gpt-image-1 API
Generates 1024x1024 source images and 128x128 game icons for Project Zomboid.

Usage:
    set OPENAI_API_KEY=sk-...
    py tools/generate_icons.py [--item NAME] [--dry-run]

Options:
    --item NAME   Generate only one specific item (by icon name)
    --dry-run     Print prompts without calling the API
"""

import argparse
import base64
import io
import os
import sys
import time

from openai import OpenAI
from PIL import Image

# ---------------------------------------------------------------------------
# Paths
# ---------------------------------------------------------------------------
REPO_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SOURCE_DIR = os.path.join(REPO_ROOT, "source-images")          # 1024x art-assets
TEXTURE_DIR = os.path.join(REPO_ROOT, "42", "media", "textures")  # 128x game
TEMP_SOURCE_DIR = os.path.join(REPO_ROOT, "tools", "_source_staging")

# ---------------------------------------------------------------------------
# Style prefix applied to every prompt
# ---------------------------------------------------------------------------
STYLE_PREFIX = (
    "Project Zomboid inventory icon. Isometric pixel art style, 2D sprite on "
    "a fully transparent background. Muted post-apocalyptic colour palette. "
    "Single item centered, no text, no labels, no UI elements. Clean edges "
    "suitable for a 128x128 game inventory icon. "
)

# ---------------------------------------------------------------------------
# Item definitions — {icon_name, prompt_suffix}
# ---------------------------------------------------------------------------
ITEMS = [
    # --- Group A: 6 non-transparent icons to regenerate ---
    {
        "name": "CrudeSoap",
        "prompt": "A rough, lumpy bar of off-white homemade lye soap with uneven "
                  "surface texture. Slightly yellowish tinge. Handmade look.",
    },
    {
        "name": "LeadScrap",
        "prompt": "Irregular chunks of dull grey lead metal salvaged from a car "
                  "battery. Heavy, dense appearance with scratched and scored surfaces.",
    },
    {
        "name": "PotassiumHydroxide",
        "prompt": "Small pile of white caustic crystalline flakes and pellets. "
                  "Chemical reagent appearance, slightly waxy lustre. Dangerous chemical.",
    },
    {
        "name": "WoodMethanol",
        "prompt": "A clear glass bottle half-filled with pale liquid (wood alcohol). "
                  "Cork stopper, liquid has a slight yellowish tint. Chemistry reagent bottle.",
    },
    {
        "name": "WoodTar",
        "prompt": "A glass mason jar containing thick, dark brown-black viscous tar. "
                  "Semi-opaque, sticky-looking substance. Metal lid on the jar.",
    },
    {
        "name": "extracted_h2so4_porcelain_crucible",
        "prompt": "A white porcelain crucible (small bowl-shaped lab vessel) containing "
                  "clear, slightly oily sulphuric acid liquid. Ceramic laboratory equipment.",
    },

    # --- Group B: 13 botanical placeholder icons ---
    {
        "name": "RettedHempStalk",
        "prompt": "A bundle of soaked, partially decomposed hemp plant stalks. Fibrous, "
                  "greenish-brown, wet appearance with visible loosening bast fibers peeling away.",
    },
    {
        "name": "HempBastFiber",
        "prompt": "Long, pale golden-tan plant fibers in a loose bundle. Silky, "
                  "strong-looking natural textile fibers stripped from a hemp stalk.",
    },
    {
        "name": "HempHurd",
        "prompt": "Small pile of pale woody chip fragments, the broken inner core of "
                  "hemp stalks. Light tan, lightweight, absorbent-looking small pieces.",
    },
    {
        "name": "HempTwine",
        "prompt": "A small coil of hand-spun natural hemp cordage string. Rough, "
                  "twisted fiber twine in natural tan colour. Thin rope.",
    },
    {
        "name": "HempRope",
        "prompt": "A coil of thick braided hemp rope. Strong, natural tan-coloured, "
                  "heavy-duty rope with visible three-strand braid pattern.",
    },
    {
        "name": "HempCloth",
        "prompt": "A folded piece of coarse woven hemp fabric. Natural tan and beige "
                  "colour, visible weave texture, durable rustic cloth.",
    },
    {
        "name": "HempCanvas",
        "prompt": "A folded piece of thick, heavy-duty hemp canvas fabric. Darker tan "
                  "than regular cloth, layered, sail-like or tarpaulin material.",
    },
    {
        "name": "HempPulp",
        "prompt": "A wet, mushy mass of broken-down plant fiber pulp in a wooden bowl. "
                  "Pale greenish-grey, wet paper-making material. Soggy texture.",
    },
    {
        "name": "HempPaper",
        "prompt": "A few sheets of rough, handmade paper stacked together. Off-white "
                  "cream colour with visible fiber texture and slightly uneven torn edges.",
    },
    {
        "name": "HempPoultice",
        "prompt": "A warm herbal compress wrapped in cloth bandage. Green-brown plant "
                  "matter visible through the wrapping, medicinal herbal remedy appearance.",
    },
    {
        "name": "HempTincture",
        "prompt": "A small dark amber glass bottle with a cork stopper containing "
                  "amber-brown herbal extract liquid. Apothecary medicine bottle.",
    },
    {
        "name": "HempcreteBlock",
        "prompt": "A rectangular building block made from hemp hurds and lime binder. "
                  "Light grey-green colour, porous texture, lightweight construction block.",
    },
    {
        "name": "TarredHempRope",
        "prompt": "A coil of dark brown-black tarred hemp rope. Waterproofed glossy "
                  "appearance, darker and shinier than untreated natural rope.",
    },
]


def generate_icon(client, item, dry_run=False):
    """Generate a single icon via gpt-image-1, save source + resized game icon."""
    name = item["name"]
    full_prompt = STYLE_PREFIX + item["prompt"]

    source_path = os.path.join(TEMP_SOURCE_DIR, f"Image_PCP_{name}.png")
    texture_path = os.path.join(TEXTURE_DIR, f"Item_PCP_{name}.png")

    print(f"\n{'='*60}")
    print(f"Generating: {name}")
    print(f"  Prompt: {full_prompt[:120]}...")

    if dry_run:
        print(f"  [DRY RUN] Would save source to: {source_path}")
        print(f"  [DRY RUN] Would save texture to: {texture_path}")
        return True

    try:
        response = client.images.generate(
            model="gpt-image-1",
            prompt=full_prompt,
            n=1,
            size="1024x1024",
            quality="medium",
        )

        # Decode base64 image
        image_b64 = response.data[0].b64_json
        image_bytes = base64.b64decode(image_b64)

        # Load with Pillow
        img = Image.open(io.BytesIO(image_bytes))

        # Ensure RGBA
        if img.mode != "RGBA":
            print(f"  WARNING: Image mode is {img.mode}, converting to RGBA")
            img = img.convert("RGBA")

        # Save 1024x1024 source
        img.save(source_path, "PNG")
        print(f"  Saved source ({img.size[0]}x{img.size[1]}): {source_path}")

        # Resize to 128x128 for game
        img_small = img.resize((128, 128), Image.LANCZOS)
        img_small.save(texture_path, "PNG")
        print(f"  Saved texture (128x128): {texture_path}")

        # Transparency check
        has_alpha = any(p[3] < 255 for p in img_small.getdata())
        if has_alpha:
            print(f"  Transparency: OK")
        else:
            print(f"  WARNING: No transparent pixels detected!")

        return True

    except Exception as e:
        print(f"  ERROR: {e}")
        return False


def main():
    parser = argparse.ArgumentParser(description="PCP Icon Generator")
    parser.add_argument("--item", type=str, help="Generate only this item (by icon name)")
    parser.add_argument("--dry-run", action="store_true", help="Print prompts, don't call API")
    args = parser.parse_args()

    # Check API key
    if not args.dry_run and not os.environ.get("OPENAI_API_KEY"):
        print("ERROR: OPENAI_API_KEY environment variable not set.")
        print("  PowerShell: $env:OPENAI_API_KEY = 'sk-...'")
        print("  Bash:       export OPENAI_API_KEY='sk-...'")
        sys.exit(1)

    # Create output directories
    os.makedirs(TEMP_SOURCE_DIR, exist_ok=True)
    os.makedirs(TEXTURE_DIR, exist_ok=True)

    # Filter items if --item specified
    items = ITEMS
    if args.item:
        items = [i for i in ITEMS if i["name"] == args.item]
        if not items:
            print(f"ERROR: No item found with name '{args.item}'")
            print(f"Available: {', '.join(i['name'] for i in ITEMS)}")
            sys.exit(1)

    print(f"PCP Icon Generator")
    print(f"  Items to generate: {len(items)}")
    print(f"  Source output: {TEMP_SOURCE_DIR}")
    print(f"  Texture output: {TEXTURE_DIR}")
    print(f"  Mode: {'DRY RUN' if args.dry_run else 'LIVE'}")

    client = None if args.dry_run else OpenAI()

    successes = 0
    failures = 0

    for i, item in enumerate(items):
        success = generate_icon(client, item, dry_run=args.dry_run)
        if success:
            successes += 1
        else:
            failures += 1

        # Rate limit: wait between API calls (skip on last item or dry run)
        if not args.dry_run and i < len(items) - 1:
            print("  Waiting 2s (rate limit)...")
            time.sleep(2)

    print(f"\n{'='*60}")
    print(f"DONE: {successes} succeeded, {failures} failed out of {len(items)} total")

    if failures > 0:
        print("\nFailed items can be retried individually with --item NAME")
        sys.exit(1)


if __name__ == "__main__":
    main()
