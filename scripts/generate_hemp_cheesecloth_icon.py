#!/usr/bin/env python3
"""Generate PCP_HempCheeseCloth icon via OpenAI gpt-image-1 pipeline.

Follows docs/art-style-guidelines.md:
  - 1024x1024 source → 128x128 LANCZOS downscale
  - RGBA, transparent background
  - Isometric pixel-art, PZ-consistent style
"""

import base64
import io
import sys
import winreg
from pathlib import Path

from openai import OpenAI
from PIL import Image

# --- Config ---
OUTPUT_DIR = Path(__file__).resolve().parent.parent / "common" / "media" / "textures"
ICON_NAME = "Item_PCP_HempCheeseCloth.png"
FINAL_SIZE = (128, 128)

PROMPT = (
    "A single item icon for a 2D top-down survival video game inventory. "
    "Isometric pixel-art style, 128x128 pixels, transparent background. "
    "Clean dark outlines, soft shading, item centered in frame with small padding. "
    "No text, no labels, no UI elements. Consistent with Project Zomboid art style. "
    "A folded piece of loose-weave hemp cheesecloth, similar to muslin or gauze fabric. "
    "Natural tan/beige colour with visible open weave texture. The cloth is loosely folded "
    "into a small square, showing the characteristic open mesh pattern of cheesecloth. "
    "Slightly rougher and more natural-looking than cotton cheesecloth, with subtle "
    "greenish-tan hemp fibre tones. Muted post-apocalyptic palette."
)


def get_api_key() -> str:
    """Read OPENAI_API_KEY from Windows user environment."""
    k = winreg.OpenKey(winreg.HKEY_CURRENT_USER, r"Environment")
    val, _ = winreg.QueryValueEx(k, "OPENAI_API_KEY")
    return val


def main() -> None:
    client = OpenAI(api_key=get_api_key())

    print(f"Generating icon: {ICON_NAME}")
    print(f"Prompt: {PROMPT[:80]}...")

    result = client.images.generate(
        model="gpt-image-1",
        prompt=PROMPT,
        size="1024x1024",
        quality="high",
        background="transparent",
        n=1,
    )

    # Decode base64 image data
    image_data = base64.b64decode(result.data[0].b64_json)
    img = Image.open(io.BytesIO(image_data)).convert("RGBA")

    # Verify not blank
    alpha = img.getchannel("A")
    non_transparent = sum(1 for p in alpha.getdata() if p > 0)
    print(f"Source: {img.size}, non-transparent pixels: {non_transparent:,}")
    if non_transparent < 100:
        print("ERROR: Image appears blank (< 100 non-transparent pixels). Aborting.")
        sys.exit(1)

    # Downscale to 128x128
    img = img.resize(FINAL_SIZE, Image.LANCZOS)
    print(f"Resized to: {img.size}")

    # Save
    output_path = OUTPUT_DIR / ICON_NAME
    img.save(output_path, "PNG")
    print(f"Saved: {output_path}")
    print(f"File size: {output_path.stat().st_size:,} bytes")


if __name__ == "__main__":
    main()
