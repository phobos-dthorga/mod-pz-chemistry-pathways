#!/usr/bin/env python3
"""
export_blender_model.py
Exports a Blender .blend file to PZ-compatible FBX via Blender's headless CLI.

This script runs INSIDE Blender's Python environment (bpy), not system Python.
It is called by import_pz_model.ps1 or can be run manually:

Usage (via Blender CLI):
    blender --background --python scripts/export_blender_model.py -- ^
        --input "D:\\Models\\acid_jar.blend" ^
        --output "common/media/models_X/PCP/PCP_SulphuricAcidJar.fbx"

    # Show help:
    blender --background --python scripts/export_blender_model.py -- --help

PZ-compatible FBX settings: Forward -Z, Up Y, apply transforms, triangulate.
See docs/3d-model-pipeline.md for full documentation.
"""

import sys
import os
import argparse

# ─── Parse Arguments ──────────────────────────────────────────────────────
# Blender passes everything after "--" to the script
argv = sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else []

parser = argparse.ArgumentParser(
    description="Export a .blend file to PZ-compatible FBX.",
    prog="export_blender_model.py",
)
parser.add_argument(
    "--input", required=True,
    help="Path to the .blend source file",
)
parser.add_argument(
    "--output", required=True,
    help="Path for the exported .fbx file",
)
parser.add_argument(
    "--scale", type=float, default=1.0,
    help="Export scale factor (default: 1.0)",
)

args = parser.parse_args(argv)

# ─── Blender Imports ─────────────────────────────────────────────────────
# These are only available inside Blender's Python environment
try:
    import bpy
except ImportError:
    print("ERROR: This script must be run inside Blender's Python environment.")
    print("  Usage: blender --background --python scripts/export_blender_model.py -- --help")
    sys.exit(1)

# ─── Validate Input ──────────────────────────────────────────────────────

input_path = os.path.abspath(args.input)
output_path = os.path.abspath(args.output)

if not os.path.isfile(input_path):
    print(f"ERROR: Input file not found: {input_path}")
    sys.exit(1)

# Ensure output directory exists
output_dir = os.path.dirname(output_path)
if output_dir and not os.path.isdir(output_dir):
    os.makedirs(output_dir, exist_ok=True)
    print(f"  Created directory: {output_dir}")

# ─── Open .blend File ────────────────────────────────────────────────────

print(f"PCP Model Export")
print(f"  Input:  {input_path}")
print(f"  Output: {output_path}")
print(f"  Scale:  {args.scale}")
print()

bpy.ops.wm.open_mainfile(filepath=input_path)

# ─── Validate Mesh ───────────────────────────────────────────────────────

mesh_objects = [obj for obj in bpy.data.objects if obj.type == 'MESH']

if not mesh_objects:
    print("ERROR: No mesh objects found in .blend file.")
    sys.exit(1)

print(f"  Found {len(mesh_objects)} mesh object(s):")

total_verts = 0
total_polys = 0
warnings = []

for obj in mesh_objects:
    mesh = obj.data
    verts = len(mesh.vertices)
    polys = len(mesh.polygons)
    total_verts += verts
    total_polys += polys

    uv_count = len(mesh.uv_layers)
    mat_count = len(obj.material_slots)

    status_parts = []
    if uv_count == 0:
        status_parts.append("NO UV")
        warnings.append(f"  WARNING: '{obj.name}' has no UV maps — textures will be broken in PZ")
    else:
        status_parts.append(f"{uv_count} UV")

    if mat_count == 0:
        status_parts.append("no materials")
    else:
        status_parts.append(f"{mat_count} material(s)")

    status = ", ".join(status_parts)
    print(f"    - {obj.name}: {verts} verts, {polys} polys ({status})")

print()

if total_polys > 5000:
    warnings.append(
        f"  WARNING: Total poly count ({total_polys}) exceeds 5000 — "
        f"consider simplifying for PZ performance"
    )

for w in warnings:
    print(w)

if warnings:
    print()

# ─── Apply Transforms ────────────────────────────────────────────────────

# Select all mesh objects and apply transforms
bpy.ops.object.select_all(action='DESELECT')
for obj in mesh_objects:
    obj.select_set(True)
bpy.context.view_layer.objects.active = mesh_objects[0]

bpy.ops.object.transform_apply(location=True, rotation=True, scale=True)
print("  Applied transforms to all mesh objects")

# ─── Export FBX ──────────────────────────────────────────────────────────

print(f"  Exporting FBX...")

bpy.ops.export_scene.fbx(
    filepath=output_path,
    # Selection
    use_selection=False,          # Export all objects (after filtering by type)
    object_types={'MESH'},        # Only mesh objects — no cameras, lights, armatures
    # Coordinate system (PZ: Y-up, Forward -Z)
    axis_forward='-Z',
    axis_up='Y',
    # Transforms
    global_scale=args.scale,
    apply_unit_scale=True,
    apply_scale_options='FBX_SCALE_ALL',
    # Geometry
    use_mesh_modifiers=True,      # Apply modifiers before export
    mesh_smooth_type='FACE',      # Per-face smoothing
    use_triangles=True,           # Triangulate — PZ expects triangulated meshes
    # Normals and tangents
    use_tspace=False,             # No tangent space (not needed for PZ items)
    # Animation (disabled for static items)
    bake_anim=False,
    # Misc
    path_mode='COPY',             # Copy textures alongside FBX (if embedded)
    embed_textures=False,         # Keep textures separate
)

# ─── Summary ─────────────────────────────────────────────────────────────

output_size = os.path.getsize(output_path)
print()
print(f"  Export complete:")
print(f"    File:     {output_path}")
print(f"    Size:     {output_size:,} bytes")
print(f"    Vertices: {total_verts}")
print(f"    Polygons: {total_polys}")
print(f"    Objects:  {len(mesh_objects)}")

if warnings:
    print()
    print(f"  {len(warnings)} warning(s) — review before importing into PZ")

print()
print("Done.")
