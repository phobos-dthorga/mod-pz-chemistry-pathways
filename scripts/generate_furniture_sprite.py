#!/usr/bin/env python3
"""Generate PCP custom furniture sprites via Replicate (Flux + RMBG-2.0).

Reads item definitions from furniture_items.json and generates isometric
furniture sprites for each facing direction. Uses a two-stage pipeline:
  1. Flux (black-forest-labs/flux-1.1-pro) for image generation
  2. RMBG-2.0 (bria/remove-background) for AI background segmentation

Can also process pre-existing images (e.g. from ChatGPT/gpt-image-1)
via the --from-dir flag, skipping Flux and going straight to bg removal.

Uses the Replicate HTTP API directly (no SDK needed).

Follows docs/art-style-guidelines.md (Furniture Sprites section).

Usage:
    py scripts/generate_furniture_sprite.py                  # Generate all items
    py scripts/generate_furniture_sprite.py BioReactor       # Generate one item
    py scripts/generate_furniture_sprite.py --list           # List available items
    py scripts/generate_furniture_sprite.py --dry-run        # Show prompts without calling API
    py scripts/generate_furniture_sprite.py --skip-rembg     # Skip background removal step
    py scripts/generate_furniture_sprite.py --from-dir path/ # Process existing images (skip Flux)
"""

import argparse
import base64
import io
import json
import sys
import time
import winreg
from pathlib import Path
from urllib.error import HTTPError
from urllib.request import Request, urlopen

from PIL import Image

# --- Paths ---
SCRIPT_DIR = Path(__file__).resolve().parent
CONFIG_PATH = SCRIPT_DIR / "furniture_items.json"
OUTPUT_DIR = SCRIPT_DIR / "sprite_output"

# --- Constants ---
CELL_1X = (128, 256)
CELL_2X = (256, 512)

REPLICATE_API = "https://api.replicate.com/v1"
FLUX_VERSION = "black-forest-labs/flux-1.1-pro"
RMBG_MODEL = "bria/remove-background"

FACING_DESCRIPTIONS = {
    "S": "south-facing (viewer sees the front of the object)",
    "E": "east-facing (viewer sees the right side of the object, rotated 90 degrees clockwise from south)",
    "N": "north-facing (viewer sees the back of the object, rotated 180 degrees from south)",
    "W": "west-facing (viewer sees the left side of the object, rotated 90 degrees counter-clockwise from south)",
    "SINGLE": "single facing (the object looks the same from all directions)",
}

PROMPT_PREFIX = (
    "A single piece of furniture or equipment for a 2D isometric survival video game. "
    "Clean edges with subtle shading, suitable for a 2D tile-based game. "
    "Isometric view at approximately 45 degrees from above. "
    "Plain solid-colour background, no patterns or gradients. "
    "The object occupies a single floor tile (1x1 grid cell) and is taller than it is wide. "
    "The object should fill most of the image vertically — it is a tall, imposing piece of equipment. "
    "Soft interior shading with light from the top-left, realistic metal and material textures. "
    "Muted but not overly dark colour palette — worn steel, desaturated industrial tones. "
    "No text, no labels, no UI elements, no floor or ground surface, "
    "no ground plane, no shadow beneath the object, no floor reflections. "
)


def get_replicate_token() -> str:
    """Read REPLICATE_API_TOKEN from Windows user environment."""
    k = winreg.OpenKey(winreg.HKEY_CURRENT_USER, r"Environment")
    val, _ = winreg.QueryValueEx(k, "REPLICATE_API_TOKEN")
    return val


def replicate_api(endpoint: str, token: str, body: dict | None = None,
                  method: str = "GET", retries: int = 3) -> dict:
    """Make a Replicate API request and return JSON response.
    Retries on 429 (rate limit) with exponential backoff."""
    url = f"{REPLICATE_API}/{endpoint}" if not endpoint.startswith("http") else endpoint
    data = json.dumps(body).encode() if body else None
    for attempt in range(retries):
        req = Request(url, data=data, method=method)
        req.add_header("Authorization", f"Bearer {token}")
        req.add_header("Content-Type", "application/json")
        req.add_header("Prefer", "wait")
        try:
            with urlopen(req, timeout=300) as resp:
                return json.loads(resp.read())
        except HTTPError as e:
            if e.code == 429 and attempt < retries - 1:
                wait = 5 * (attempt + 1)
                print(f"    Rate limited, waiting {wait}s...")
                time.sleep(wait)
            else:
                raise


def run_replicate_model(model: str, input_data: dict, token: str) -> str:
    """Run a Replicate model and return the output URL.
    Uses the /models/{owner}/{name}/predictions endpoint for official models."""
    # Parse model string: "owner/name" or "owner/name:version"
    if ":" in model:
        model_path, version = model.rsplit(":", 1)
        # Use versioned prediction
        body = {"version": version, "input": input_data}
        result = replicate_api("predictions", token, body, "POST")
    else:
        # Use model predictions endpoint (auto-selects latest version)
        body = {"input": input_data}
        result = replicate_api(f"models/{model}/predictions", token, body, "POST")

    # Poll for completion if not using sync/wait
    while result.get("status") in ("starting", "processing"):
        time.sleep(2)
        result = replicate_api(result["urls"]["get"], token)
        print(f"    Status: {result['status']}...")

    if result["status"] == "failed":
        print(f"    ERROR: {result.get('error', 'Unknown error')}")
        return ""

    output = result.get("output")
    if isinstance(output, list):
        return output[0] if output else ""
    return output or ""


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
    target_h = int(ch * min_fill)
    scale = target_h / img.height
    if img.width * scale > cw:
        scale = cw / img.width
    new_w = max(1, int(img.width * scale))
    new_h = max(1, int(img.height * scale))
    resized = img.resize((new_w, new_h), Image.LANCZOS)

    canvas = Image.new("RGBA", cell_size, (0, 0, 0, 0))
    x_off = (cw - new_w) // 2
    y_off = ch - new_h
    canvas.paste(resized, (x_off, y_off))
    return canvas


def download_image(url: str) -> Image.Image:
    """Download an image from a URL and return as PIL Image."""
    with urlopen(url, timeout=60) as resp:
        data = resp.read()
    return Image.open(io.BytesIO(data)).convert("RGBA")


def image_to_data_uri(img: Image.Image) -> str:
    """Convert a PIL Image to a data URI for Replicate API input."""
    buf = io.BytesIO()
    img.save(buf, format="PNG")
    b64 = base64.b64encode(buf.getvalue()).decode("ascii")
    return f"data:image/png;base64,{b64}"


def remove_background(token: str, img: Image.Image) -> Image.Image:
    """Remove background from an image using RMBG-2.0 on Replicate."""
    print("    Removing background via RMBG-2.0...")
    data_uri = image_to_data_uri(img)

    output_url = run_replicate_model(RMBG_MODEL, {
        "image": data_uri,
    }, token)

    if not output_url:
        print("    ERROR: No output URL from RMBG-2.0")
        return img

    result = download_image(output_url)
    # Verify not blank
    bbox = result.getbbox()
    if bbox is None:
        print("    WARNING: Image appears blank after bg removal!")
        return img

    w = bbox[2] - bbox[0]
    h = bbox[3] - bbox[1]
    print(f"    RMBG-2.0 output: {result.size}, content bbox: {w}x{h}")
    return result


def generate_sprite(token: str, item: dict, facing: str,
                    dry_run: bool = False,
                    skip_rembg: bool = False) -> Image.Image | None:
    """Generate a single facing sprite via Flux + RMBG-2.0 background removal."""
    prompt = build_prompt(item, facing)

    if dry_run:
        print(f"  [DRY RUN] {item['id']}_{facing}")
        print(f"  Prompt: {prompt[:150]}...")
        return None

    # Stage 1: Generate image with Flux
    print(f"  Generating {item['id']}_{facing} via Flux...")
    img_url = run_replicate_model(FLUX_VERSION, {
        "prompt": prompt,
        "aspect_ratio": "1:1",
        "output_format": "png",
        "safety_tolerance": 5,
    }, token)

    if not img_url:
        print("    ERROR: No image URL returned from Flux")
        return None

    print(f"    Downloading generated image...")
    img = download_image(img_url)
    print(f"    Source: {img.size}")

    # Save pre-removal image for inspection
    item_dir = OUTPUT_DIR / item["id"]
    item_dir.mkdir(parents=True, exist_ok=True)
    pre_path = item_dir / f"{item['id']}_{facing}_source.png"
    img.save(pre_path, "PNG")

    if skip_rembg:
        print("    Skipping background removal (--skip-rembg)")
        return img

    # Stage 2: AI background segmentation via RMBG-2.0
    return remove_background(token, img)


def process_from_dir(token: str, item: dict, from_dir: Path,
                     skip_rembg: bool = False) -> None:
    """Process existing images from a directory through RMBG-2.0 + cell sizing.

    Expects files named {item_id}_{facing}.png or {item_id}_{facing}_*.png
    (e.g. BioReactor_S.png, BioReactor_S_flux.png, BioReactor_S_source.png).
    """
    item_id = item["id"]
    facings = item["facings"]
    print(f"\n{'='*60}")
    print(f"Item: {item_id} (from-dir: {from_dir})")
    print(f"{'='*60}")

    item_dir = OUTPUT_DIR / item_id
    item_dir.mkdir(parents=True, exist_ok=True)

    for facing in facings:
        # Find the source image — try several naming patterns
        candidates = [
            from_dir / f"{item_id}_{facing}.png",
            from_dir / f"{item_id}_{facing}_source.png",
            from_dir / f"{item_id}_{facing}_flux.png",
            from_dir / f"{item_id}_{facing}_raw.png",
        ]
        src_path = None
        for c in candidates:
            if c.exists():
                src_path = c
                break

        if src_path is None:
            # Try case-insensitive glob
            matches = list(from_dir.glob(f"{item_id}_{facing}*.[pP][nN][gG]"))
            if matches:
                src_path = matches[0]

        if src_path is None:
            print(f"  SKIP {item_id}_{facing}: no source image found in {from_dir}")
            continue

        print(f"  Processing {src_path.name}...")
        img = Image.open(src_path).convert("RGBA")
        print(f"    Source: {img.size}")

        if skip_rembg:
            print("    Skipping background removal (--skip-rembg)")
            result = img
        else:
            result = remove_background(token, img)

        # Save processed source (after bg removal)
        raw_path = item_dir / f"{item_id}_{facing}_raw.png"
        result.save(raw_path, "PNG")
        print(f"    Saved raw: {raw_path.name}")

        # Crop to content
        cropped = crop_to_content(result)
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


def process_item(token: str, item: dict, dry_run: bool = False,
                 skip_rembg: bool = False) -> None:
    """Generate all facings for one furniture item."""
    item_id = item["id"]
    facings = item["facings"]
    print(f"\n{'='*60}")
    print(f"Item: {item_id} ({len(facings)} facing(s): {', '.join(facings)})")
    print(f"{'='*60}")

    item_dir = OUTPUT_DIR / item_id
    item_dir.mkdir(parents=True, exist_ok=True)

    for facing in facings:
        img = generate_sprite(token, item, facing, dry_run=dry_run,
                              skip_rembg=skip_rembg)
        if img is None:
            continue

        # Save processed source (after bg removal)
        raw_path = item_dir / f"{item_id}_{facing}_raw.png"
        img.save(raw_path, "PNG")
        print(f"    Saved raw: {raw_path.name}")

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
        description="Generate PCP furniture sprites via Replicate (Flux + RMBG-2.0)")
    parser.add_argument("item_id", nargs="?", default=None,
                        help="Generate only this item (by id)")
    parser.add_argument("--list", action="store_true",
                        help="List available items and exit")
    parser.add_argument("--dry-run", action="store_true",
                        help="Show prompts without calling the API")
    parser.add_argument("--skip-rembg", action="store_true",
                        help="Skip background removal (keep original bg for inspection)")
    parser.add_argument("--from-dir", type=Path, default=None,
                        help="Process existing images from this directory (skip Flux)")
    args = parser.parse_args()

    config = load_config()
    items = config["items"]

    if args.list:
        print("Available furniture items:")
        for item in items:
            facings = ", ".join(item["facings"])
            print(f"  {item['id']:20s}  {item['custom_name']:25s}  [{facings}]")
        return

    if args.item_id:
        items = [i for i in items if i["id"] == args.item_id]
        if not items:
            print(f"Error: Item '{args.item_id}' not found in {CONFIG_PATH.name}")
            sys.exit(1)

    token = ""
    if not args.dry_run:
        token = get_replicate_token()

    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

    for item in items:
        if args.from_dir:
            process_from_dir(token, item, args.from_dir,
                             skip_rembg=args.skip_rembg)
        else:
            process_item(token, item, dry_run=args.dry_run,
                         skip_rembg=args.skip_rembg)

    print(f"\nDone. Output in: {OUTPUT_DIR}")


if __name__ == "__main__":
    main()
