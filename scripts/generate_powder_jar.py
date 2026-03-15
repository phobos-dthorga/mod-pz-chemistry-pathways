"""
generate_powder_jar.py
Procedurally generates a wide-mouth powder jar model for PCP.

Run via Blender headless:
    blender --background --python scripts/generate_powder_jar.py -- ^
        --output "common/media/models_X/PCP/PCP_PowderJar.fbx"

Geometry: Wide glass jar with flat screw-cap lid, slightly tapered body.
Used by: SulphurPowder, KNO3, Potash, BoneMeal, BrineConcentrate,
         CoarseSalt, Calcite, KOH, ActivatedCarbon, BoneChar (10 items)
"""

import sys
import os
import math
import argparse

# ─── Parse Arguments ─────────────────────────────────────────────────
argv = sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else []
parser = argparse.ArgumentParser(description="Generate PCP_PowderJar model.")
parser.add_argument("--output", required=True, help="Output .fbx path")
parser.add_argument("--blend-output", default="", help="Also save .blend file")
args = parser.parse_args(argv)

# ─── Blender Imports ─────────────────────────────────────────────────
import bpy
import bmesh

# ─── Clear Scene ─────────────────────────────────────────────────────
bpy.ops.wm.read_factory_settings(use_empty=True)

# ─── Parameters ──────────────────────────────────────────────────────
# All dimensions in Blender units (metres). PZ model scale will be set
# in the model definition file (typically 0.3-0.5 for jar-sized items).
JAR_RADIUS_BOTTOM = 0.035      # Bottom radius (slightly narrower)
JAR_RADIUS_TOP = 0.04          # Top radius (wider mouth)
JAR_HEIGHT = 0.08              # Body height
JAR_WALL_THICKNESS = 0.003     # Glass wall thickness
LID_HEIGHT = 0.008             # Lid thickness
LID_RADIUS = 0.042             # Lid slightly wider than jar mouth
LID_GAP = 0.001                # Gap between jar top and lid bottom
SEGMENTS = 24                  # Circumference resolution
BEVEL_SEGMENTS = 2             # Edge bevel smoothness

# ─── Helper: Create Lathe Profile ────────────────────────────────────
def create_lathe_mesh(name, profile_points, segments=24):
    """Create a mesh by revolving a 2D profile around the Z axis.
    profile_points: list of (radius, z) tuples defining the cross-section.
    """
    mesh = bpy.data.meshes.new(name)
    bm = bmesh.new()

    # Create vertices for each ring
    rings = []
    for r, z in profile_points:
        ring = []
        for i in range(segments):
            angle = 2.0 * math.pi * i / segments
            x = r * math.cos(angle)
            y = r * math.sin(angle)
            v = bm.verts.new((x, y, z))
            ring.append(v)
        rings.append(ring)

    bm.verts.ensure_lookup_table()

    # Create faces between consecutive rings
    for ri in range(len(rings) - 1):
        for si in range(segments):
            sn = (si + 1) % segments
            v1 = rings[ri][si]
            v2 = rings[ri][sn]
            v3 = rings[ri + 1][sn]
            v4 = rings[ri + 1][si]
            bm.faces.new([v1, v2, v3, v4])

    # Cap the top and bottom if they have non-zero radius
    # Bottom cap
    if profile_points[0][0] > 0.001:
        bottom_ring = rings[0]
        center = bm.verts.new((0, 0, profile_points[0][1]))
        for i in range(segments):
            ni = (i + 1) % segments
            bm.faces.new([center, bottom_ring[ni], bottom_ring[i]])

    # Top cap
    if profile_points[-1][0] > 0.001:
        top_ring = rings[-1]
        center = bm.verts.new((0, 0, profile_points[-1][1]))
        for i in range(segments):
            ni = (i + 1) % segments
            bm.faces.new([center, top_ring[i], top_ring[ni]])

    bm.to_mesh(mesh)
    bm.free()
    mesh.update()
    return mesh

# ─── Create Jar Body ─────────────────────────────────────────────────
# Profile: flat bottom, slight taper outward, straight walls, rim
jar_profile = [
    (JAR_RADIUS_BOTTOM, 0.0),                       # Bottom edge
    (JAR_RADIUS_BOTTOM, 0.005),                      # Bottom curve start
    (JAR_RADIUS_BOTTOM + 0.002, 0.01),               # Lower body curve
    (JAR_RADIUS_TOP - 0.002, JAR_HEIGHT * 0.4),      # Mid body
    (JAR_RADIUS_TOP, JAR_HEIGHT * 0.6),               # Upper body
    (JAR_RADIUS_TOP, JAR_HEIGHT - 0.005),             # Below rim
    (JAR_RADIUS_TOP + 0.002, JAR_HEIGHT - 0.002),     # Rim flare
    (JAR_RADIUS_TOP + 0.002, JAR_HEIGHT),              # Rim top
]

jar_mesh = create_lathe_mesh("PCP_PowderJar_Body", jar_profile, SEGMENTS)
jar_obj = bpy.data.objects.new("PCP_PowderJar_Body", jar_mesh)
bpy.context.collection.objects.link(jar_obj)

# ─── Create Lid ──────────────────────────────────────────────────────
lid_bottom_z = JAR_HEIGHT + LID_GAP
lid_top_z = lid_bottom_z + LID_HEIGHT

lid_profile = [
    (LID_RADIUS, lid_bottom_z),                       # Lid bottom edge
    (LID_RADIUS, lid_bottom_z + LID_HEIGHT * 0.3),    # Lid side
    (LID_RADIUS, lid_top_z - 0.001),                   # Near top
    (LID_RADIUS - 0.003, lid_top_z),                    # Top bevel inward
    (0.0, lid_top_z),                                    # Centre top (flat)
]

lid_mesh = create_lathe_mesh("PCP_PowderJar_Lid", lid_profile, SEGMENTS)
lid_obj = bpy.data.objects.new("PCP_PowderJar_Lid", lid_mesh)
bpy.context.collection.objects.link(lid_obj)

# ─── Materials ───────────────────────────────────────────────────────
# Jar body: semi-transparent glass tint
jar_mat = bpy.data.materials.new("PCP_PowderJar_Glass")
jar_mat.use_nodes = True
bsdf = jar_mat.node_tree.nodes["Principled BSDF"]
bsdf.inputs["Base Color"].default_value = (0.85, 0.90, 0.88, 1.0)  # Light grey-green
bsdf.inputs["Roughness"].default_value = 0.15
jar_obj.data.materials.append(jar_mat)

# Lid: dark metal cap
lid_mat = bpy.data.materials.new("PCP_PowderJar_Cap")
lid_mat.use_nodes = True
bsdf_lid = lid_mat.node_tree.nodes["Principled BSDF"]
bsdf_lid.inputs["Base Color"].default_value = (0.25, 0.25, 0.28, 1.0)  # Dark grey metal
bsdf_lid.inputs["Metallic"].default_value = 0.8
bsdf_lid.inputs["Roughness"].default_value = 0.4
lid_obj.data.materials.append(lid_mat)

# ─── UV Unwrap ───────────────────────────────────────────────────────
for obj in [jar_obj, lid_obj]:
    bpy.context.view_layer.objects.active = obj
    obj.select_set(True)
    bpy.ops.object.mode_set(mode='EDIT')
    bpy.ops.mesh.select_all(action='SELECT')
    bpy.ops.uv.smart_project(angle_limit=66.0, island_margin=0.02)
    bpy.ops.object.mode_set(mode='OBJECT')
    obj.select_set(False)

# ─── Join Into Single Object ─────────────────────────────────────────
bpy.ops.object.select_all(action='SELECT')
bpy.context.view_layer.objects.active = jar_obj
bpy.ops.object.join()

# Rename final object
jar_obj.name = "PCP_PowderJar"

# ─── Apply Transforms ───────────────────────────────────────────────
bpy.ops.object.select_all(action='SELECT')
bpy.ops.object.transform_apply(location=True, rotation=True, scale=True)

# ─── Triangulate ─────────────────────────────────────────────────────
bpy.ops.object.mode_set(mode='EDIT')
bpy.ops.mesh.select_all(action='SELECT')
bpy.ops.mesh.quads_convert_to_tris()
bpy.ops.object.mode_set(mode='OBJECT')

# ─── Save .blend (Optional) ─────────────────────────────────────────
if args.blend_output:
    os.makedirs(os.path.dirname(args.blend_output), exist_ok=True)
    bpy.ops.wm.save_as_mainfile(filepath=args.blend_output)
    print(f"[PCP] Saved .blend: {args.blend_output}")

# ─── Export FBX ──────────────────────────────────────────────────────
os.makedirs(os.path.dirname(os.path.abspath(args.output)), exist_ok=True)

bpy.ops.export_scene.fbx(
    filepath=args.output,
    use_selection=False,
    apply_scale_options='FBX_SCALE_ALL',
    axis_forward='-Z',
    axis_up='Y',
    use_mesh_modifiers=True,
    mesh_smooth_type='OFF',
    use_tspace=False,
    use_armature_deform_only=False,
    add_leaf_bones=False,
    bake_anim=False,
    object_types={'MESH'},
    use_triangles=True,
)

# ─── Report ──────────────────────────────────────────────────────────
vert_count = sum(len(obj.data.vertices) for obj in bpy.data.objects if obj.type == 'MESH')
face_count = sum(len(obj.data.polygons) for obj in bpy.data.objects if obj.type == 'MESH')
print(f"[PCP] PowderJar exported: {args.output}")
print(f"[PCP]   Vertices: {vert_count}, Faces: {face_count}")
if vert_count > 5000:
    print(f"[PCP]   WARNING: High vertex count ({vert_count}), consider reducing segments")
