"""
generate_clay_vessel.py
Procedurally generates a wide clay vessel/pot with lip.

Geometry: Wider, more rustic pot shape via lathe profile.
Used by: SulphuricAcidClayJar, CrudeVegOilClayJar, RenderedFatClayJar,
         CrudeBiodieselClayJar, WashedBiodieselClayJar (5 items)
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

# Wide clay pot — hand-thrown style with belly and rim
pot_profile = [
    (0.025, 0.0),         # Flat bottom
    (0.028, 0.005),       # Foot ring
    (0.030, 0.010),       # Base transition
    (0.038, 0.025),       # Lower belly
    (0.042, 0.045),       # Widest belly
    (0.040, 0.060),       # Upper belly
    (0.035, 0.072),       # Shoulder
    (0.032, 0.078),       # Neck
    (0.033, 0.080),       # Rim flare out
    (0.035, 0.082),       # Rim lip
    (0.035, 0.084),       # Rim top
    (0.033, 0.085),       # Inner rim step
]

# Simple clay lid — flat disc with knob
lid_profile = [
    (0.036, 0.086),       # Lid rim overhang
    (0.036, 0.089),       # Lid side
    (0.034, 0.090),       # Lid bevel
    (0.010, 0.090),       # Flat top to knob
    (0.010, 0.095),       # Knob side
    (0.008, 0.097),       # Knob bevel
    (0.0,   0.097),       # Centre
]

pot_mesh = create_lathe_mesh("Body", pot_profile, SEGMENTS)
pot_obj = bpy.data.objects.new("Body", pot_mesh)
bpy.context.collection.objects.link(pot_obj)

lid_mesh = create_lathe_mesh("Lid", lid_profile, SEGMENTS)
lid_obj = bpy.data.objects.new("Lid", lid_mesh)
bpy.context.collection.objects.link(lid_obj)

# Materials — earthy terracotta
mat_clay = bpy.data.materials.new("Clay")
mat_clay.node_tree.nodes["Principled BSDF"].inputs["Base Color"].default_value = (0.65, 0.42, 0.28, 1.0)
mat_clay.node_tree.nodes["Principled BSDF"].inputs["Roughness"].default_value = 0.80
pot_obj.data.materials.append(mat_clay)

mat_lid = bpy.data.materials.new("ClayLid")
mat_lid.node_tree.nodes["Principled BSDF"].inputs["Base Color"].default_value = (0.60, 0.40, 0.26, 1.0)
mat_lid.node_tree.nodes["Principled BSDF"].inputs["Roughness"].default_value = 0.85
lid_obj.data.materials.append(mat_lid)

# UV + join + triangulate
for obj in [pot_obj, lid_obj]:
    bpy.context.view_layer.objects.active = obj
    obj.select_set(True)
    bpy.ops.object.mode_set(mode='EDIT')
    bpy.ops.mesh.select_all(action='SELECT')
    bpy.ops.uv.smart_project(angle_limit=66.0, island_margin=0.02)
    bpy.ops.object.mode_set(mode='OBJECT')
    obj.select_set(False)

bpy.ops.object.select_all(action='SELECT')
bpy.context.view_layer.objects.active = pot_obj
bpy.ops.object.join()
pot_obj.name = "PCP_ClayVessel"
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
print(f"[PCP] ClayVessel exported: {args.output} ({vc} verts)")
