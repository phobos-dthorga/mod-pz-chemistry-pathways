"""
generate_chem_jar.py
Procedurally generates a tall sealed chemistry jar for PCP.

Run via Blender headless:
    blender --background --python scripts/generate_chem_jar.py -- ^
        --output "common/media/models_X/PCP/PCP_ChemJar.fbx"

Geometry: Taller, narrower jar with screw-thread lid detail.
Used by: SulphuricAcidJar, CrudeVegOil, RenderedFat, CrudeBiodiesel,
         WashedBiodiesel, BrineJar, WoodTar, Glycerol (8 items)
"""

import sys
import os
import math
import argparse

argv = sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else []
parser = argparse.ArgumentParser(description="Generate PCP_ChemJar model.")
parser.add_argument("--output", required=True, help="Output .fbx path")
args = parser.parse_args(argv)

import bpy
import bmesh

bpy.ops.wm.read_factory_settings(use_empty=True)

SEGMENTS = 24

def create_lathe_mesh(name, profile, segs=24):
    mesh = bpy.data.meshes.new(name)
    bm = bmesh.new()
    rings = []
    for r, z in profile:
        ring = []
        for i in range(segs):
            a = 2.0 * math.pi * i / segs
            v = bm.verts.new((r * math.cos(a), r * math.sin(a), z))
            ring.append(v)
        rings.append(ring)
    bm.verts.ensure_lookup_table()
    for ri in range(len(rings) - 1):
        for si in range(segs):
            sn = (si + 1) % segs
            bm.faces.new([rings[ri][si], rings[ri][sn], rings[ri+1][sn], rings[ri+1][si]])
    if profile[0][0] > 0.001:
        c = bm.verts.new((0, 0, profile[0][1]))
        for i in range(segs):
            bm.faces.new([c, rings[0][(i+1)%segs], rings[0][i]])
    if profile[-1][0] > 0.001:
        c = bm.verts.new((0, 0, profile[-1][1]))
        for i in range(segs):
            bm.faces.new([c, rings[-1][i], rings[-1][(i+1)%segs]])
    bm.to_mesh(mesh)
    bm.free()
    mesh.update()
    return mesh

# Taller, narrower jar with neck
jar_profile = [
    (0.028, 0.0),
    (0.030, 0.005),
    (0.033, 0.015),
    (0.033, 0.08),       # Straight body
    (0.030, 0.09),       # Shoulder taper
    (0.022, 0.095),      # Neck
    (0.022, 0.105),      # Neck top (thread area)
    (0.024, 0.105),      # Thread ridge
    (0.024, 0.107),      # Thread top
    (0.022, 0.107),      # Back to neck
]

lid_profile = [
    (0.026, 0.108),
    (0.026, 0.118),
    (0.024, 0.120),      # Top bevel
    (0.0,   0.120),      # Centre
]

jar_mesh = create_lathe_mesh("Body", jar_profile, SEGMENTS)
jar_obj = bpy.data.objects.new("Body", jar_mesh)
bpy.context.collection.objects.link(jar_obj)

lid_mesh = create_lathe_mesh("Lid", lid_profile, SEGMENTS)
lid_obj = bpy.data.objects.new("Lid", lid_mesh)
bpy.context.collection.objects.link(lid_obj)

# Materials
mat_glass = bpy.data.materials.new("Glass")
mat_glass.node_tree.nodes["Principled BSDF"].inputs["Base Color"].default_value = (0.82, 0.88, 0.92, 1.0)
mat_glass.node_tree.nodes["Principled BSDF"].inputs["Roughness"].default_value = 0.12
jar_obj.data.materials.append(mat_glass)

mat_cap = bpy.data.materials.new("Cap")
mat_cap.node_tree.nodes["Principled BSDF"].inputs["Base Color"].default_value = (0.20, 0.22, 0.25, 1.0)
mat_cap.node_tree.nodes["Principled BSDF"].inputs["Metallic"].default_value = 0.85
mat_cap.node_tree.nodes["Principled BSDF"].inputs["Roughness"].default_value = 0.35
lid_obj.data.materials.append(mat_cap)

# UV unwrap
for obj in [jar_obj, lid_obj]:
    bpy.context.view_layer.objects.active = obj
    obj.select_set(True)
    bpy.ops.object.mode_set(mode='EDIT')
    bpy.ops.mesh.select_all(action='SELECT')
    bpy.ops.uv.smart_project(angle_limit=66.0, island_margin=0.02)
    bpy.ops.object.mode_set(mode='OBJECT')
    obj.select_set(False)

# Join + finalise
bpy.ops.object.select_all(action='SELECT')
bpy.context.view_layer.objects.active = jar_obj
bpy.ops.object.join()
jar_obj.name = "PCP_ChemJar"
bpy.ops.object.transform_apply(location=True, rotation=True, scale=True)
bpy.ops.object.mode_set(mode='EDIT')
bpy.ops.mesh.select_all(action='SELECT')
bpy.ops.mesh.quads_convert_to_tris()
bpy.ops.object.mode_set(mode='OBJECT')

# Export
os.makedirs(os.path.dirname(os.path.abspath(args.output)), exist_ok=True)
bpy.ops.export_scene.fbx(
    filepath=args.output, use_selection=False, apply_scale_options='FBX_SCALE_ALL',
    axis_forward='-Z', axis_up='Y', use_mesh_modifiers=True, mesh_smooth_type='OFF',
    use_tspace=False, bake_anim=False, object_types={'MESH'}, use_triangles=True,
)
vc = sum(len(o.data.vertices) for o in bpy.data.objects if o.type == 'MESH')
print(f"[PCP] ChemJar exported: {args.output} ({vc} verts)")
