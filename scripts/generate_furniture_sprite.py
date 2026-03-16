#!/usr/bin/env python3
"""Generate PCP custom furniture sprites via OpenAI gpt-image-1 pipeline.

Reads item definitions from furniture_items.json and generates isometric
furniture sprites for each facing direction. Outputs individual facing PNGs
to scripts/sprite_output/ for later assembly into a tilesheet.

Follows docs/art-style-guidelines.md (Furniture Sprites section).

Usage:
    py scripts/generate_furniture_sprite.py                  # Generate all items
    py scripts/generate_furniture_sprite.py BioReactor       # Generate one item
    py scripts/generate_furniture_sprite.py --list           # List available items
    py scripts/generate_furniture_sprite.py --dry-run        # Show prompts without calling API
"""

import argparse
import base64
import io
import json
import sys
import winreg
from pathlib import Path

from openai import OpenAI
from PIL import Image

# --- Paths ---
SCRIPT_DIR = Path(__file__).resolve().parent
CONFIG_PATH = SCRIPT_DIR / "furniture_items.json"
OUTPUT_DIR = SCRIPT_DIR / "sprite_output"

# --- Constants ---
# PZ tile cell: 128x256 at 1x, 256x512 at 2x
# We generate at 1024x1024 and crop/resize to both resolutions.
CELL_1X = (128, 256)
CELL_2X = (256, 512)
SOURCE_SIZE = "1024x1024"

FACING_DESCRIPTIONS = {
    "S": "south-facing (viewer sees the front of the object)",
    "E": "east-facing (viewer sees the right side of the object, rotated 90 degrees clockwise from south)",
    "N": "north-facing (viewer sees the back of the object, rotated 180 degrees from south)",
    "W": "west-facing (viewer sees the left side of the object, rotated 90 degrees counter-clockwise from south)",
    "SINGLE": "single facing (the object looks the same from all directions)",
}

PROMPT_PREFIX = (
    "A single piece of furniture or equipment for a 2D isometric survival video game. "
    "Isometric view at approximately 45 degrees from above. "
    "Solid bright magenta (#FF00FF) background — the entire background must be a uniform "
    "flat magenta color with no gradients or variation. "
    "The object occupies a single floor tile (1x1 grid cell) and is taller than it is wide. "
    "The object should fill most of the image vertically — it is a tall, imposing piece of equipment. "
    "Clean dark outlines, soft interior shading with light from the top-left. "
    "Muted but not overly dark colour palette — worn steel, desaturated industrial tones. "
    "No text, no labels, no UI elements, no floor or ground surface, "
    "no ground plane, no shadow beneath the object, no floor reflections. "
    "Consistent with Project Zomboid Build 42 tile art style. "
)

# Chroma-key colour and distance threshold for background removal
CHROMA_KEY = (255, 0, 255)  # magenta
CHROMA_THRESHOLD = 80       # Manhattan distance in RGB space


def get_api_key() -> str:
    """Read OPENAI_API_KEY from Windows user environment."""
    k = winreg.OpenKey(winreg.HKEY_CURRENT_USER, r"Environment")
    val, _ = winreg.QueryValueEx(k, "OPENAI_API_KEY")
    return val


def load_config() -> dict:
    """Load furniture_items.json."""
    with open(CONFIG_PATH, encoding="utf-8") as f:
        return json.load(f)


def build_prompt(item: dict, facing: str) -> str:
    """Build the full generation prompt for one facing of one item."""
    facing_desc = FACING_DESCRIPTIONS.get(facing, facing)
    parts = [
        PROMPT_PREFIX,
        f"Facing: {facing_desc}. ",
        item["description"],
    ]
    # Append facing-specific details if defined
    facing_details = item.get("facing_details", {})
    if facing in facing_details:
        parts.append(f" {facing_details[facing]}")
    return "".join(parts)


def crop_to_content(img: Image.Image, padding: int = 16) -> Image.Image:
    """Crop image to its non-transparent bounding box with padding."""
    bbox = img.getbbox()
    if bbox is None:
        return img
    left, top, right, bottom = bbox
    left = max(0, left - padding)
    top = max(0, top - padding)
    right = min(img.width, right + padding)
    bottom = min(img.height, bottom + padding)
    return img.crop((left, top, right, bottom))


def resize_to_cell(img: Image.Image, cell_size: tuple[int, int],
                    min_fill: float = 0.90) -> Image.Image:
    """Resize image to fill at least min_fill of cell height, maintaining
    aspect ratio, then paste bottom-aligned onto a transparent canvas."""
    cw, ch = cell_size
    # Scale so sprite fills at least min_fill of cell height,
    # but don't exceed cell width
    target_h = int(ch * min_fill)
    scale = target_h / img.height
    if img.width * scale > cw:
        scale = cw / img.width
    new_w = max(1, int(img.width * scale))
    new_h = max(1, int(img.height * scale))
    resized = img.resize((new_w, new_h), Image.LANCZOS)

    # Bottom-align on transparent canvas
    canvas = Image.new("RGBA", cell_size, (0, 0, 0, 0))
    x_off = (cw - new_w) // 2
    y_off = ch - new_h  # Bottom-align (feet on ground)
    canvas.paste(resized, (x_off, y_off))
    return canvas


def generate_sprite(client: OpenAI, item: dict, facing: str,
                    dry_run: bool = False) -> Image.Image | None:
    """Generate a single facing sprite via gpt-image-1."""
    prompt = build_prompt(item, facing)

    if dry_run:
        print(f"  [DRY RUN] {item['id']}_{facing}")
        print(f"  Prompt: {prompt[:120]}...")
        return None

    print(f"  Generating {item['id']}_{facing}...")
    result = client.images.generate(
        model="gpt-image-1",
        prompt=prompt,
        size=SOURCE_SIZE,
        quality="high",
        background="opaque",
        n=1,
    )

    image_data = base64.b64decode(result.data[0].b64_json)
    img = Image.open(io.BytesIO(image_data)).convert("RGBA")

    # Chroma-key removal: detect the actual background color from corners
    # (gpt-image-1 approximates the requested magenta, not exact), then
    # replace all pixels close to that color with full transparency.
    pixels = img.load()
    corners = [(0, 0), (img.width - 1, 0),
               (0, img.height - 1), (img.width - 1, img.height - 1)]
    cr = sum(pixels[x, y][0] for x, y in corners) // 4
    cg = sum(pixels[x, y][1] for x, y in corners) // 4
    cb = sum(pixels[x, y][2] for x, y in corners) // 4
    print(f"    Detected bg color: ({cr}, {cg}, {cb})")
    for y in range(img.height):
        for x in range(img.width):
            r, g, b, a = pixels[x, y]
            dist = abs(r - cr) + abs(g - cg) + abs(b - cb)
            if dist < CHROMA_THRESHOLD:
                pixels[x, y] = (0, 0, 0, 0)

    # Verify not blank
    alpha = img.getchannel("A")
    non_transparent = sum(1 for p in alpha.getdata() if p > 0)
    print(f"    Source: {img.size}, non-transparent pixels: {non_transparent:,}")
    if non_transparent < 100:
        print("    WARNING: Image appears blank (< 100 non-transparent pixels)!")
        return None

    return img


def process_item(client: OpenAI | None, item: dict,
                 dry_run: bool = False) -> None:
    """Generate all facings for one furniture item."""
    item_id = item["id"]
    facings = item["facings"]
    print(f"\n{'='*60}")
    print(f"Item: {item_id} ({len(facings)} facing(s): {', '.join(facings)})")
    print(f"{'='*60}")

    item_dir = OUTPUT_DIR / item_id
    item_dir.mkdir(parents=True, exist_ok=True)

    for facing in facings:
        img = generate_sprite(client, item, facing, dry_run=dry_run)
        if img is None:
            continue

        # Save raw source (1024x1024)
        raw_path = item_dir / f"{item_id}_{facing}_raw.png"
        img.save(raw_path, "PNG")

        # Crop to content
        cropped = crop_to_content(img)
        print(f"    Cropped: {cropped.size}")

        # Save 2x cell
        cell_2x = resize_to_cell(cropped, CELL_2X)
        path_2x = item_dir / f"{item_id}_{facing}_2x.png"
        cell_2x.save(path_2x, "PNG")
        print(f"    Saved 2x: {path_2x.name} ({CELL_2X[0]}x{CELL_2X[1]})")

        # Save 1x cell
        cell_1x = resize_to_cell(cropped, CELL_1X)
        path_1x = item_dir / f"{item_id}_{facing}_1x.png"
        cell_1x.save(path_1x, "PNG")
        print(f"    Saved 1x: {path_1x.name} ({CELL_1X[0]}x{CELL_1X[1]})")

    print(f"\nOutput directory: {item_dir}")


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Generate PCP furniture sprites via gpt-image-1")
    parser.add_argument("item_id", nargs="?", default=None,
                        help="Generate only this item (by id)")
    parser.add_argument("--list", action="store_true",
                        help="List available items and exit")
    parser.add_argument("--dry-run", action="store_true",
                        help="Show prompts without calling the API")
    args = parser.parse_args()

    config = load_config()
    items = config["items"]

    if args.list:
        print("Available furniture items:")
        for item in items:
            facings = ", ".join(item["facings"])
            print(f"  {item['id']:20s}  {item['custom_name']:25s}  [{facings}]")
        return

    # Filter to specific item if requested
    if args.item_id:
        items = [i for i in items if i["id"] == args.item_id]
        if not items:
            print(f"Error: Item '{args.item_id}' not found in {CONFIG_PATH.name}")
            sys.exit(1)

    client = None
    if not args.dry_run:
        client = OpenAI(api_key=get_api_key())

    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

    for item in items:
        process_item(client, item, dry_run=args.dry_run)

    print(f"\nDone. Generated sprites in: {OUTPUT_DIR}")


if __name__ == "__main__":
    main()
