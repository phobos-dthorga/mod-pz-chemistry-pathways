#!/usr/bin/env python3
"""Unify hue, saturation, and brightness across furniture sprite facings.

Reads the _raw.png files (post-RMBG-2.0 background removal) for a given
item, computes the average HSV values of the reference facing (default: S),
and adjusts the other facings to match. Regenerates _1x.png and _2x.png.

Usage:
    py scripts/unify_sprite_hue.py BioReactor          # Unify all facings to S
    py scripts/unify_sprite_hue.py BioReactor --ref N   # Use N as reference
    py scripts/unify_sprite_hue.py BioReactor --analyze # Show HSV stats only
"""

import argparse
import math
import sys
from pathlib import Path

import numpy as np
from PIL import Image

# --- Paths ---
SCRIPT_DIR = Path(__file__).resolve().parent
OUTPUT_DIR = SCRIPT_DIR / "sprite_output"

# --- Cell sizes (must match generate_furniture_sprite.py) ---
CELL_1X = (128, 256)
CELL_2X = (256, 512)


def compute_hsv_stats(img: Image.Image) -> tuple[float, float, float, int]:
    """Compute circular mean hue, mean saturation, mean value for non-transparent pixels.
    Returns (mean_hue, mean_sat, mean_val, pixel_count)."""
    arr = np.array(img.convert("RGBA"))
    alpha = arr[:, :, 3]
    mask = alpha > 128

    rgb = Image.fromarray(arr[:, :, :3])
    hsv = np.array(rgb.convert("HSV"))

    h = hsv[:, :, 0][mask].astype(np.float64)
    s = hsv[:, :, 1][mask].astype(np.float64)
    v = hsv[:, :, 2][mask].astype(np.float64)

    # Circular mean for hue (handles wrap-around)
    angles = h * 2 * math.pi / 256
    mean_angle = math.atan2(np.mean(np.sin(angles)), np.mean(np.cos(angles)))
    if mean_angle < 0:
        mean_angle += 2 * math.pi
    mean_hue = mean_angle * 256 / (2 * math.pi)

    return mean_hue, float(np.mean(s)), float(np.mean(v)), int(mask.sum())


def adjust_hsv(img: Image.Image, hue_shift: float, sat_scale: float,
               val_scale: float) -> Image.Image:
    """Adjust HSV channels of non-transparent pixels.

    hue_shift: added to hue channel (circular, mod 256)
    sat_scale: multiplied with saturation channel
    val_scale: multiplied with value channel
    """
    arr = np.array(img.convert("RGBA"))
    alpha = arr[:, :, 3]
    mask = alpha > 128

    rgb = Image.fromarray(arr[:, :, :3])
    hsv = np.array(rgb.convert("HSV"), dtype=np.float64)

    # Apply adjustments only to non-transparent pixels
    hsv[:, :, 0][mask] = (hsv[:, :, 0][mask] + hue_shift) % 256
    hsv[:, :, 1][mask] = np.clip(hsv[:, :, 1][mask] * sat_scale, 0, 255)
    hsv[:, :, 2][mask] = np.clip(hsv[:, :, 2][mask] * val_scale, 0, 255)

    # Convert back to RGB
    corrected_rgb = Image.fromarray(hsv.astype(np.uint8), mode="HSV").convert("RGB")
    corrected = np.array(corrected_rgb)

    # Reattach original alpha
    result = np.dstack([corrected, alpha])
    return Image.fromarray(result, mode="RGBA")


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
    """Resize to fill cell height, bottom-aligned on transparent canvas."""
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


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Unify hue/saturation/brightness across furniture sprite facings")
    parser.add_argument("item_id", help="Item id (e.g. BioReactor)")
    parser.add_argument("--ref", default="S",
                        help="Reference facing to match (default: S)")
    parser.add_argument("--analyze", action="store_true",
                        help="Show HSV stats only, don't modify images")
    args = parser.parse_args()

    item_dir = OUTPUT_DIR / args.item_id
    if not item_dir.exists():
        print(f"Error: {item_dir} not found")
        sys.exit(1)

    # Find all raw facing files
    facings = {}
    for p in sorted(item_dir.glob(f"{args.item_id}_*_raw.png")):
        # Extract facing from filename: BioReactor_S_raw.png -> S
        facing = p.stem.replace(f"{args.item_id}_", "").replace("_raw", "")
        facings[facing] = p

    if not facings:
        print(f"Error: No _raw.png files found in {item_dir}")
        sys.exit(1)

    if args.ref not in facings:
        print(f"Error: Reference facing '{args.ref}' not found. Available: {list(facings.keys())}")
        sys.exit(1)

    # Compute stats for all facings
    print(f"Analyzing {len(facings)} facings (reference: {args.ref})...\n")
    stats = {}
    for facing, path in facings.items():
        img = Image.open(path)
        h, s, v, count = compute_hsv_stats(img)
        stats[facing] = (h, s, v, count)
        marker = " <-- REF" if facing == args.ref else ""
        print(f"  {facing}: hue={h:5.1f}  sat={s:5.1f}  val={v:5.1f}  ({count:,} px){marker}")

    if args.analyze:
        ref_h, ref_s, ref_v, _ = stats[args.ref]
        print(f"\nCorrections needed (to match {args.ref}):")
        for facing in facings:
            if facing == args.ref:
                continue
            fh, fs, fv, _ = stats[facing]
            dh = ref_h - fh
            # Wrap hue shift to [-128, 128]
            if dh > 128:
                dh -= 256
            elif dh < -128:
                dh += 256
            ss = ref_s / fs if fs > 0 else 1.0
            vs = ref_v / fv if fv > 0 else 1.0
            print(f"  {facing}: hue_shift={dh:+.1f}  sat_scale={ss:.3f}  val_scale={vs:.3f}")
        return

    # Apply corrections
    ref_h, ref_s, ref_v, _ = stats[args.ref]
    print(f"\nApplying corrections (target: hue={ref_h:.1f} sat={ref_s:.1f} val={ref_v:.1f})...\n")

    for facing, path in facings.items():
        fh, fs, fv, _ = stats[facing]
        dh = ref_h - fh
        if dh > 128:
            dh -= 256
        elif dh < -128:
            dh += 256
        ss = ref_s / fs if fs > 0 else 1.0
        vs = ref_v / fv if fv > 0 else 1.0

        if facing == args.ref:
            print(f"  {facing}: reference — no correction needed")
            img = Image.open(path)
        else:
            print(f"  {facing}: hue_shift={dh:+.1f}  sat_scale={ss:.3f}  val_scale={vs:.3f}")
            img = Image.open(path)
            img = adjust_hsv(img, dh, ss, vs)
            # Save corrected raw
            img.save(path, "PNG")
            print(f"    Saved corrected: {path.name}")

        # Regenerate cell-sized outputs
        cropped = crop_to_content(img)

        cell_2x = resize_to_cell(cropped, CELL_2X)
        path_2x = item_dir / f"{args.item_id}_{facing}_2x.png"
        cell_2x.save(path_2x, "PNG")

        cell_1x = resize_to_cell(cropped, CELL_1X)
        path_1x = item_dir / f"{args.item_id}_{facing}_1x.png"
        cell_1x.save(path_1x, "PNG")

        print(f"    Saved: {path_1x.name}, {path_2x.name}")

    # Verify
    print(f"\nPost-correction stats:")
    for facing, path in facings.items():
        img = Image.open(path)
        h, s, v, count = compute_hsv_stats(img)
        print(f"  {facing}: hue={h:5.1f}  sat={s:5.1f}  val={v:5.1f}")

    print(f"\nDone. Next: py scripts/build_tilesheet.py && py scripts/compile_tilepack.py")


if __name__ == "__main__":
    main()
