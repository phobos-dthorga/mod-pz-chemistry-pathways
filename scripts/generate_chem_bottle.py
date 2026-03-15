"""
generate_chem_bottle.py
Procedurally generates an amber reagent bottle with cork stopper.

Geometry: Narrow lathe-profile bottle (Erlenmeyer-inspired) with cork.
Used by: WoodMethanol, SulphuricAcidBottle, HempTincture (3-4 items)
"""

import sys, os, math, argparse

argv = sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else []
parser = argparse.ArgumentParser()
parser.add_argument("--output", required=True)
args = parser.parse_args(argv)

import bpy, bmesh

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

# Reagent bottle — wide base tapering to narrow neck
bottle_profile = [
    (0.025, 0.0),         # Flat bottom edge
    (0.028, 0.005),       # Bottom curve
    (0.032, 0.015),       # Lower body widening
    (0.035, 0.035),       # Widest point (belly)
    (0.032, 0.055),       # Upper body tapering
    (0.024, 0.070),       # Shoulder
    (0.016, 0.080),       # Neck start
    (0.014, 0.095),       # Neck
    (0.014, 0.100),       # Neck top
    (0.016, 0.100),       # Lip flare
    (0.016, 0.102),       # Lip top
]

# Cork stopper — tapered cylinder
cork_profile = [
    (0.015, 0.101),       # Cork bottom (overlaps lip slightly)
    (0.014, 0.103),
    (0.013, 0.108),       # Cork taper
    (0.012, 0.113),       # Cork top
    (0.0,   0.113),       # Centre cap
]

bottle_mesh = create_lathe_mesh("Body", bottle_profile, SEGMENTS)
bottle_obj = bpy.data.objects.new("Body", bottle_mesh)
bpy.context.collection.objects.link(bottle_obj)

cork_mesh = create_lathe_mesh("Cork", cork_profile, SEGMENTS)
cork_obj = bpy.data.objects.new("Cork", cork_mesh)
bpy.context.collection.objects.link(cork_obj)

# Materials
mat_glass = bpy.data.materials.new("Glass")
mat_glass.node_tree.nodes["Principled BSDF"].inputs["Base Color"].default_value = (0.55, 0.35, 0.15, 1.0)  # Amber
mat_glass.node_tree.nodes["Principled BSDF"].inputs["Roughness"].default_value = 0.10
bottle_obj.data.materials.append(mat_glass)

mat_cork = bpy.data.materials.new("Cork")
mat_cork.node_tree.nodes["Principled BSDF"].inputs["Base Color"].default_value = (0.72, 0.58, 0.38, 1.0)
mat_cork.node_tree.nodes["Principled BSDF"].inputs["Roughness"].default_value = 0.85
cork_obj.data.materials.append(mat_cork)

# UV + join + triangulate
for obj in [bottle_obj, cork_obj]:
    bpy.context.view_layer.objects.active = obj
    obj.select_set(True)
    bpy.ops.object.mode_set(mode='EDIT')
    bpy.ops.mesh.select_all(action='SELECT')
    bpy.ops.uv.smart_project(angle_limit=66.0, island_margin=0.02)
    bpy.ops.object.mode_set(mode='OBJECT')
    obj.select_set(False)

bpy.ops.object.select_all(action='SELECT')
bpy.context.view_layer.objects.active = bottle_obj
bpy.ops.object.join()
bottle_obj.name = "PCP_ChemBottle"
bpy.ops.object.transform_apply(location=True, rotation=True, scale=True)
bpy.ops.object.mode_set(mode='EDIT')
bpy.ops.mesh.select_all(action='SELECT')
bpy.ops.mesh.quads_convert_to_tris()
bpy.ops.object.mode_set(mode='OBJECT')

os.makedirs(os.path.dirname(os.path.abspath(args.output)), exist_ok=True)
bpy.ops.export_scene.fbx(
    filepath=args.output, use_selection=False, apply_scale_options='FBX_SCALE_ALL',
    axis_forward='-Z', axis_up='Y', use_mesh_modifiers=True, mesh_smooth_type='OFF',
    use_tspace=False, bake_anim=False, object_types={'MESH'}, use_triangles=True,
)
vc = sum(len(o.data.vertices) for o in bpy.data.objects if o.type == 'MESH')
print(f"[PCP] ChemBottle exported: {args.output} ({vc} verts)")
