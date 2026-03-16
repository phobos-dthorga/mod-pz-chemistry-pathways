#!/usr/bin/env python3
"""Extract valid 3D model names from vanilla Project Zomboid model definition files.

Usage:
    python scripts/extract_vanilla_models.py [PZ_INSTALL_DIR]

If PZ_INSTALL_DIR is not provided, defaults to:
    C:\\Program Files (x86)\\Steam\\steamapps\\common\\ProjectZomboid

Outputs: scripts/vanilla_models_allowlist.txt
"""

import os
import re
import sys

DEFAULT_PZ_DIR = r"C:\Program Files (x86)\Steam\steamapps\common\ProjectZomboid"
MODEL_FILES = [
    "models_items.txt",
    "models_food.txt",
    "models_weapons.txt",
    "models_isoobject.txt",
]

def main():
    pz_dir = sys.argv[1] if len(sys.argv) > 1 else DEFAULT_PZ_DIR
    scripts_dir = os.path.join(pz_dir, "media", "scripts", "generated")

    if not os.path.isdir(scripts_dir):
        print(f"ERROR: PZ scripts directory not found: {scripts_dir}")
        sys.exit(1)

    models = set()
    for fname in MODEL_FILES:
        path = os.path.join(scripts_dir, fname)
        if os.path.isfile(path):
            with open(path) as f:
                for m in re.finditer(r"^\s*model\s+(\w+)", f.read(), re.MULTILINE):
                    models.add(m.group(1))
            print(f"  {fname}: {sum(1 for m in re.finditer(r'model', open(path).read()))} entries")

    out_path = os.path.join(os.path.dirname(__file__), "vanilla_models_allowlist.txt")
    with open(out_path, "w") as f:
        f.write("# Vanilla PZ Build 42 model names -- extracted from models_*.txt\n")
        f.write("# Regenerate with: python scripts/extract_vanilla_models.py\n")
        f.write(f"# Total: {len(models)} models\n")
        f.write("#\n")
        for name in sorted(models):
            f.write(name + "\n")

    print(f"\nWrote {len(models)} model names to {out_path}")


if __name__ == "__main__":
    main()
