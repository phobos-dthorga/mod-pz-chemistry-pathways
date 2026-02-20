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

# Versioning Policy (PhobosChemistryPathways)

PhobosChemistryPathways is a content mod. Treat versions as save-compatibility contracts.

## Scheme
Use Semantic Versioning: **MAJOR.MINOR.PATCH**

- **MAJOR**: breaking or save-incompatible changes
  - removing or renaming item type names, recipe IDs, or fluid names
  - changing entity tags or workstation bindings in a way that breaks existing saves
  - removing sandbox options or changing their key names
- **MINOR**: backward-compatible additions
  - new recipes, items, fluids, or sandbox options
  - new crafting pathways or equipment tiers
  - new systems (e.g., purity tracking, health hazards)
- **PATCH**: backward-compatible fixes
  - balance tweaks (yield amounts, purity factors, costs)
  - bug fixes (nil guards, callback fixes, recipe corrections)
  - translation fixes and tooltip improvements
  - icon/texture updates

## What counts as "public surface"
These identifiers are referenced by save files, other mods, or player configurations:
- item type names (e.g., `PhobosChemistryPathways.CrudeVegetableOil`)
- recipe IDs (e.g., `PCPTransesterifyOilBulk`)
- fluid names (e.g., `PCP_CrudeBiodiesel`)
- entity tags (e.g., `PCP:MetalDrumStation`)
- sandbox option keys (e.g., `PCP.YieldMultiplier`)
- mod ID (`PhobosChemistryPathways`)

Changing any of these is a MAJOR version bump.

## Pre-release versions (0.x.y)
While below 1.0.0, the mod is in pre-release:
- MINOR bumps may include breaking changes (with migration notes in CHANGELOG)
- Players should expect some instability between pre-release versions
- Version 1.0.0 will be the first Steam Workshop stable release

## Tagging releases
- Tag GitHub releases as `vX.Y.Z`
- Include a concise changelog section for each release
