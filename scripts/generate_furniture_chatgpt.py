#!/usr/bin/env python3
"""Generate furniture source images via gpt-image-1 for RMBG-2.0 processing.

Generates opaque-background images that can then be fed through
generate_furniture_sprite.py --from-dir for AI background removal.

Usage:
    py scripts/generate_furniture_chatgpt.py BioReactor
    py scripts/generate_furniture_chatgpt.py --dry-run BioReactor
"""

import argparse
import base64
import json
import sys
import winreg
from pathlib import Path

try:
    from openai import OpenAI
except ImportError:
    print("ERROR: openai package not found. Install with: pip install openai")
    sys.exit(1)

# --- Paths ---
SCRIPT_DIR = Path(__file__).resolve().parent
CONFIG_PATH = SCRIPT_DIR / "furniture_items.json"
OUTPUT_DIR = SCRIPT_DIR / "sprite_output"

FACING_DESCRIPTIONS = {
    "S": "south-facing (viewer sees the front of the object)",
    "E": "east-facing (viewer sees the right side of the object, rotated 90 degrees clockwise from south)",
    "N": "north-facing (viewer sees the back of the object, rotated 180 degrees from south)",
    "W": "west-facing (viewer sees the left side of the object, rotated 90 degrees counter-clockwise from south)",
}

PROMPT_PREFIX = (
    "A single piece of furniture or equipment for a 2D isometric survival video game. "
    "Clean edges with subtle shading, suitable for a 2D tile-based game. "
    "Isometric view at approximately 45 degrees from above. "
    "Plain solid-colour background with no patterns or gradients. "
    "The object occupies a single floor tile (1x1 grid cell) and is taller than it is wide. "
    "The object should fill most of the image vertically — it is a tall, imposing piece of equipment. "
    "Soft interior shading with light from the top-left, realistic metal and material textures. "
    "Muted but not overly dark colour palette — worn steel, desaturated industrial tones. "
    "No text, no labels, no UI elements, no floor or ground surface, "
    "no ground plane, no shadow beneath the object, no floor reflections. "
)


def get_openai_key() -> str:
    """Read OPENAI_API_KEY from Windows user environment."""
    k = winreg.OpenKey(winreg.HKEY_CURRENT_USER, r"Environment")
    val, _ = winreg.QueryValueEx(k, "OPENAI_API_KEY")
    return val


def load_config() -> dict:
    with open(CONFIG_PATH, encoding="utf-8") as f:
        return json.load(f)


def build_prompt(item: dict, facing: str) -> str:
    facing_desc = FACING_DESCRIPTIONS.get(facing, facing)
    parts = [
        PROMPT_PREFIX,
        f"Facing: {facing_desc}. ",
        item["description"],
    ]
    facing_details = item.get("facing_details", {})
    if facing in facing_details:
        parts.append(f" {facing_details[facing]}")
    return "".join(parts)


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Generate furniture source images via gpt-image-1")
    parser.add_argument("item_id", help="Item id to generate")
    parser.add_argument("--dry-run", action="store_true",
                        help="Show prompts without calling API")
    parser.add_argument("--facings", nargs="*", default=None,
                        help="Generate only these facings (e.g. S E)")
    args = parser.parse_args()

    config = load_config()
    items = [i for i in config["items"] if i["id"] == args.item_id]
    if not items:
        print(f"Error: Item '{args.item_id}' not found")
        sys.exit(1)
    item = items[0]

    facings = args.facings or item["facings"]

    # Output to a chatgpt subfolder
    out_dir = OUTPUT_DIR / item["id"] / "chatgpt"
    out_dir.mkdir(parents=True, exist_ok=True)

    if args.dry_run:
        for facing in facings:
            prompt = build_prompt(item, facing)
            print(f"\n[{facing}] {prompt[:200]}...")
        return

    client = OpenAI(api_key=get_openai_key())

    for facing in facings:
        prompt = build_prompt(item, facing)
        print(f"\nGenerating {item['id']}_{facing} via gpt-image-1...")
        print(f"  Prompt: {prompt[:120]}...")

        result = client.images.generate(
            model="gpt-image-1",
            prompt=prompt,
            n=1,
            size="1024x1024",
            quality="high",
            background="opaque",
        )

        image_data = base64.b64decode(result.data[0].b64_json)
        out_path = out_dir / f"{item['id']}_{facing}.png"
        out_path.write_bytes(image_data)
        print(f"  Saved: {out_path}")
        print(f"  Size: {len(image_data):,} bytes")

    print(f"\nDone. Source images in: {out_dir}")
    print(f"\nNext step: py scripts/generate_furniture_sprite.py {item['id']} --from-dir \"{out_dir}\"")


if __name__ == "__main__":
    main()
