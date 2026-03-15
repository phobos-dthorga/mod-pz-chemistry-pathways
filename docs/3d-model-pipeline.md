<!--
  ________________________________________________________________________
 / Copyright (c) 2026 Phobos A. D'thorga                                \
 |                                                                        |
 |           /\_/\                                                         |
 |         =/ o o \=    Phobos' PZ Modding                                |
 |          (  V  )     All rights reserved.                              |
 |     /\  / \   / \                                                      |
 |    /  \/   '-'   \   This source code is part of the Phobos            |
 |   /  /  \  ^  /\  \  mod suite for Project Zomboid (Build 42).         |
 |  (__/    \_/ \/  \__)                                                  |
 |     |   | |  | |     Unauthorised copying, modification, or            |
 |     |___|_|  |_|     distribution of this file is prohibited.          |
 |                                                                        |
 \________________________________________________________________________/
-->

# 3D Model Pipeline

Guide for creating and importing custom 3D models into **Phobos' Industrial Pathways: Biomass** (PCP) for Project Zomboid Build 42.

> **See also:** [Art Style Guidelines](art-style-guidelines.md) for 2D inventory icon conventions.

---

## Table of Contents

1. [Overview](#overview)
2. [Prerequisites](#prerequisites)
3. [PZ Model System](#pz-model-system)
4. [Modelling Guidelines](#modelling-guidelines)
5. [Blender Export Settings](#blender-export-settings)
6. [File Placement](#file-placement)
7. [Model Definition Syntax](#model-definition-syntax)
8. [Updating Item Definitions](#updating-item-definitions)
9. [Automation](#automation)
10. [In-Game Tuning](#in-game-tuning)
11. [Naming Conventions](#naming-conventions)
12. [Anti-Patterns](#anti-patterns)

---

## Overview

PCP currently reuses vanilla models for all items. This guide describes the full workflow for replacing them with custom 3D models:

```
Blender .blend file  ──►  FBX export  ──►  File placement  ──►  Model definition  ──►  Item script update
```

A companion automation script (`scripts/import_pz_model.ps1`) handles steps 2–5 automatically. See [Automation](#automation).

![Pipeline flowchart](images/model-pipeline.png)

---

## Prerequisites

| Tool | Version | Purpose |
|------|---------|---------|
| **Blender** | 5.0+ | 3D modelling and FBX export |
| **PowerShell** | 7+ (`pwsh`) | Automation orchestrator |
| **Project Zomboid** | Build 42 | In-game testing |

Blender install path (default): `C:\Program Files\Blender Foundation\Blender 5.0\blender.exe`

---

## PZ Model System

PZ B42 loads 3D models through three interconnected parts:

### 1. Model files (`.fbx` or `.X`)

Placed in `media/models_X/`. PZ accepts both:
- **FBX** (Autodesk binary) — Blender exports this natively, no addons needed
- **.X** (DirectX 11 text) — Legacy format, Blender does **not** export this

FBX is the recommended format for new models.

### 2. Model definitions (`media/scripts/models_*.txt`)

Script files that bind a model name to its mesh, texture, scale, and attachment points:

```
module Base
{
    model BlowTorch
    {
        mesh = Blowtorch,
        attachment world
        {
            offset = 0.0 0.25 0.0,
            rotate = -180.0 0.0 -180.0,
        }
    }
}
```

### 3. Item definitions (`StaticModel` / `WorldStaticModel`)

Item scripts reference models by name:

```
item MyItem
{
    ...
    StaticModel = ModelName,          /* Hand-held / inventory 3D view */
    WorldStaticModel = ModelName,     /* Ground / world placement */
    ...
}
```

---

## Modelling Guidelines

### Polygon Budget

Vanilla PZ items are low-poly. Keep models simple:

| Item Type | Target Poly Count |
|-----------|-------------------|
| Small items (bottles, jars) | 200–500 |
| Medium items (tools, equipment) | 500–1500 |
| Large items (furniture, machines) | 1500–5000 |

### Coordinate System

PZ uses a **Y-up** coordinate system:

| Axis | Direction |
|------|-----------|
| **X** | Right |
| **Y** | Up |
| **Z** | Forward (into screen) |

When exporting from Blender (which uses Z-up internally), set Forward = `-Z`, Up = `Y`.

### UV Mapping

- All meshes **must** have UV maps
- One UV channel is sufficient for items
- UV islands should have small padding to prevent bleeding at lower mip levels

### Textures

| Property | Value |
|----------|-------|
| **Format** | PNG (RGBA if transparency needed, RGB otherwise) |
| **Dimensions** | Power-of-two preferred (256x256, 512x512) |
| **Style** | Consistent with PZ's muted, post-apocalyptic palette |
| **Location** | `common/media/textures/PCP/` |

> **Note:** Inventory icons (128x128 sprites) are separate from 3D model textures. See [Art Style Guidelines](art-style-guidelines.md) for icon conventions.

### Scale Reference

Vanilla scale values observed in `models_items.txt`:

| Scale | Used For | Examples |
|-------|----------|----------|
| `0.125` | Small hand-held items | Books, knives, fleshing tools |
| `0.4` | Jars, bottles | — |
| `0.5` | Medium bowls, containers | BowlBrainTan |
| `0.8961` | Attachment-specific scaling | Bowl in secondary hand |
| `1.0` | Default / large items | Buckets, cans |
| `1.595` | Oversized crafting props | CraftingBowl |

For PCP chemistry items (jars, bottles, lab equipment), **0.4** is a good starting point.

---

## Blender Export Settings

### Manual Export (File → Export → FBX)

| Setting | Value |
|---------|-------|
| **Forward** | `-Z Forward` |
| **Up** | `Y Up` |
| **Scale** | `1.0` |
| **Apply Scalings** | `All Local` |
| **Object Types** | `Mesh` only (no Armature, Camera, Light) |
| **Apply Transform** | Enabled |
| **Triangulate Faces** | Enabled |
| **Tangent Space** | Disabled (not needed for PZ items) |
| **Include Normals** | Enabled |

### Headless Export (CLI)

The automation script calls Blender in headless mode:

```
blender --background --python scripts/export_blender_model.py -- ^
    --input "D:\Models\acid_jar.blend" ^
    --output "common/media/models_X/PCP/PCP_SulphuricAcidJar.fbx"
```

See `scripts/export_blender_model.py` for the full export configuration.

---

## File Placement

| File Type | Destination | Example |
|-----------|-------------|---------|
| **3D model** (`.fbx`) | `common/media/models_X/PCP/` | `PCP_SulphuricAcidJar.fbx` |
| **Model texture** (`.png`) | `common/media/textures/PCP/` | `PCP_SulphuricAcidJar.png` |
| **Model definition** | `common/media/scripts/models_PCP.txt` | Appended block |
| **Item definition** | `common/media/scripts/items/PCP_Items*.txt` | `StaticModel` field |

The `models_X/PCP/` and `textures/PCP/` subdirectories keep PCP assets namespaced away from vanilla files.

---

## Model Definition Syntax

All PCP model definitions live in a single file: `common/media/scripts/models_PCP.txt`

```
/* ________________________________________________________________________
 / Copyright (c) 2026 Phobos A. D'thorga                                \
 |                                                                        |
 |           /\_/\                                                         |
 |         =/ o o \=    Phobos' PZ Modding                                |
 |          (  V  )     All rights reserved.                              |
 |     /\  / \   / \                                                      |
 |    /  \/   '-'   \   This source code is part of the Phobos            |
 |   /  /  \  ^  /\  \  mod suite for Project Zomboid (Build 42).         |
 |  (__/    \_/ \/  \__)                                                  |
 |     |   | |  | |     Unauthorised copying, modification, or            |
 |     |___|_|  |_|     distribution of this file is prohibited.          |
 |                                                                        |
 \________________________________________________________________________/
*/

module PhobosChemistryPathways
{
    model PCP_SulphuricAcidJar
    {
        mesh = PCP/PCP_SulphuricAcidJar,
        texture = PCP/PCP_SulphuricAcidJar,
        scale = 0.4,
        attachment world
        {
            offset = 0.0 0.0 0.0,
            rotate = 0.0 0.0 0.0,
        }
    }

    model PCP_Retort
    {
        mesh = PCP/PCP_Retort,
        texture = PCP/PCP_Retort,
        scale = 0.5,
        attachment world
        {
            offset = 0.0 0.0 0.0,
            rotate = 0.0 0.0 0.0,
        }
    }
}
```

### Property Reference

| Property | Required | Description |
|----------|----------|-------------|
| `mesh` | Yes | Path to the `.fbx`/`.X` file relative to `models_X/` (no extension) |
| `texture` | No | Path to texture relative to `textures/` (no extension). Omit if baked into FBX. |
| `scale` | No | Global scale multiplier (default `1.0`) |
| `attachment <name>` | No | Defines how the model attaches to a character bone or world |

### Attachment Types

| Name | Purpose |
|------|---------|
| `world` | Ground/surface placement (WorldStaticModel) |
| `Bip01_Prop1` | Primary hand (right hand) |
| `Bip01_Prop2` | Secondary hand (left hand) |

Each attachment has `offset` (X Y Z translation), `rotate` (X Y Z Euler degrees), and optional `scale`.

---

## Updating Item Definitions

After creating the model definition, reference it in the item script:

```
item SulphuricAcidJar
{
    ...
    StaticModel = PCP_SulphuricAcidJar,
    WorldStaticModel = PCP_SulphuricAcidJar,
    ...
}
```

- **`StaticModel`** — Used when the item is held or viewed in inventory
- **`WorldStaticModel`** — Used when the item is placed on the ground or a surface

Both can reference the same model or different models (e.g., a simplified ground model).

---

## Automation

The `import_pz_model.ps1` script automates the full pipeline from Blender export through item definition updates.

### Quick Start

```powershell
# Full import with Blender export
pwsh scripts/import_pz_model.ps1 `
    -BlendFile "D:\Models\acid_jar.blend" `
    -ModelName "PCP_SulphuricAcidJar" `
    -TextureFile "D:\Models\acid_jar.png" `
    -Items "SulphuricAcidJar" `
    -Scale 0.4

# Preview what would happen (no files written)
pwsh scripts/import_pz_model.ps1 `
    -BlendFile "D:\Models\acid_jar.blend" `
    -ModelName "PCP_SulphuricAcidJar" `
    -DryRun
```

### Parameter Reference

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `-BlendFile` | string | Yes | — | Path to the `.blend` source file |
| `-ModelName` | string | Yes | — | PZ model name (e.g. `PCP_SulphuricAcidJar`) |
| `-TextureFile` | string | No | — | Path to the model texture `.png` |
| `-Items` | string[] | No | — | Item names to update with model references |
| `-ModelType` | string | No | `Both` | `Static`, `World`, or `Both` |
| `-Scale` | float | No | `0.4` | Model scale in PZ |
| `-DryRun` | switch | No | — | Preview changes without writing any files |

### What the Script Does

1. Validates that the `.blend` file exists and Blender is installed
2. Calls Blender CLI to export `.blend` → `.fbx` (via `export_blender_model.py`)
3. Copies `.fbx` to `common/media/models_X/PCP/`
4. Copies texture `.png` to `common/media/textures/PCP/` (if provided)
5. Creates or appends to `common/media/scripts/models_PCP.txt`
6. Updates each item in `-Items` with `StaticModel` / `WorldStaticModel`
7. Prints a summary of all changes

---

## In-Game Tuning

After importing a model, the attachment offsets and scale will likely need fine-tuning in-game.

### Workflow

1. Launch PZ in debug mode
2. Spawn the item: open the debug item spawner and search for the item name
3. Place the item on the ground — check `WorldStaticModel` alignment
4. Pick up the item — check `StaticModel` in hand
5. Adjust `offset`, `rotate`, and `scale` values in `models_PCP.txt`
6. Reload the mod (restart PZ or use mod reload if available)
7. Repeat until satisfied

### Common Adjustments

| Issue | Fix |
|-------|-----|
| Item floating above ground | Decrease Y offset (e.g., `0.0 -0.1 0.0`) |
| Item sunk into ground | Increase Y offset |
| Item facing wrong direction | Adjust Y rotation (90° increments) |
| Item too large/small | Adjust `scale` value |
| Item offset in hand | Adjust attachment `offset` and `rotate` |

---

## Naming Conventions

| Asset | Convention | Example |
|-------|-----------|---------|
| **Model name** | `PCP_<PascalCaseName>` | `PCP_SulphuricAcidJar` |
| **FBX file** | `PCP_<PascalCaseName>.fbx` | `PCP_SulphuricAcidJar.fbx` |
| **Model texture** | `PCP_<PascalCaseName>.png` | `PCP_SulphuricAcidJar.png` |
| **Inventory icon** | `Item_PCP_<PascalCaseName>.png` | `Item_PCP_SulphuricAcidJar.png` |

Model names should match the item name where possible. If one model serves multiple items, use a descriptive generic name (e.g., `PCP_LabJar` for several jar-based items).

---

## Anti-Patterns

| Mistake | Why It's Wrong | Fix |
|---------|---------------|-----|
| Exporting with Z-up | PZ expects Y-up; model will be rotated 90° | Set Forward = `-Z`, Up = `Y` in export |
| No UV maps | PZ will render the model with broken/missing textures | Always UV unwrap before exporting |
| High poly count | PZ is not designed for high-fidelity meshes; performance impact | Keep under 1500 polys for items |
| Forgetting `module` wrapper | PZ won't find the model definition | Always wrap in `module PhobosChemistryPathways { ... }` |
| Using `.X` format from Blender | Blender cannot export `.X`; use a converter or just use FBX | Export as `.fbx` directly |
| Placing `.fbx` in wrong directory | PZ won't find the mesh file | Must be under `common/media/models_X/PCP/` |
| Non-power-of-two textures | May cause rendering issues on some GPUs | Use 256x256, 512x512, or 1024x1024 |
| Embedding armatures in static items | Unnecessary data, may confuse PZ | Export `Mesh` only for static items |
| Duplicate model names | Later definition may silently override the first | Always prefix with `PCP_` and use unique names |
