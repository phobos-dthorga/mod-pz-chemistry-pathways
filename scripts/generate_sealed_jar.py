"""
generate_sealed_jar.py
Procedurally generates a sealed preserving jar with cloth/wax top.

Geometry: Similar to ChemJar but with wider mouth and cloth seal cap.
Used by: SealedChewingTobaccoJar, CuredChewingTobaccoJar,
         HempButter, HempInfusedOil (4 items)
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

# Wide-mouth preserving jar
jar_profile = [
    (0.030, 0.0),
    (0.033, 0.005),
    (0.035, 0.015),
    (0.035, 0.075),
    (0.033, 0.085),
    (0.030, 0.09),
    (0.030, 0.095),      # Rim
    (0.032, 0.095),      # Rim lip
    (0.032, 0.097),
]

# Cloth seal — slightly larger diameter, dome-shaped
seal_profile = [
    (0.035, 0.098),       # Cloth overhang
    (0.034, 0.100),
    (0.030, 0.105),       # Dome curve
    (0.020, 0.108),
    (0.0,   0.109),       # Centre top
]

jar_mesh = create_lathe_mesh("Body", jar_profile, SEGMENTS)
jar_obj = bpy.data.objects.new("Body", jar_mesh)
bpy.context.collection.objects.link(jar_obj)

seal_mesh = create_lathe_mesh("Seal", seal_profile, SEGMENTS)
seal_obj = bpy.data.objects.new("Seal", seal_mesh)
bpy.context.collection.objects.link(seal_obj)

# Materials
mat_glass = bpy.data.materials.new("Glass")
mat_glass.node_tree.nodes["Principled BSDF"].inputs["Base Color"].default_value = (0.85, 0.88, 0.82, 1.0)
mat_glass.node_tree.nodes["Principled BSDF"].inputs["Roughness"].default_value = 0.15
jar_obj.data.materials.append(mat_glass)

mat_cloth = bpy.data.materials.new("Cloth")
mat_cloth.node_tree.nodes["Principled BSDF"].inputs["Base Color"].default_value = (0.90, 0.85, 0.70, 1.0)
mat_cloth.node_tree.nodes["Principled BSDF"].inputs["Roughness"].default_value = 0.95
seal_obj.data.materials.append(mat_cloth)

# UV + join + triangulate
for obj in [jar_obj, seal_obj]:
    bpy.context.view_layer.objects.active = obj
    obj.select_set(True)
    bpy.ops.object.mode_set(mode='EDIT')
    bpy.ops.mesh.select_all(action='SELECT')
    bpy.ops.uv.smart_project(angle_limit=66.0, island_margin=0.02)
    bpy.ops.object.mode_set(mode='OBJECT')
    obj.select_set(False)

bpy.ops.object.select_all(action='SELECT')
bpy.context.view_layer.objects.active = jar_obj
bpy.ops.object.join()
jar_obj.name = "PCP_SealedJar"
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
print(f"[PCP] SealedJar exported: {args.output} ({vc} verts)")
