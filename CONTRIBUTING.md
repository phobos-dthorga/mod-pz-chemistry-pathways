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

# Contributing to PhobosChemistryPathways

Thanks for helping improve the project. This repo is intended to support collaboration, compatibility patches, and addon/dependency mods while keeping the official release cohesive.

## Quick rules (the short version)
- **Small, focused PRs** are best (one issue/feature per PR).
- **Don’t re-upload unchanged releases**; forks must be clearly labeled “unofficial”.
- **Code contributions** should be compatible with Build 42 and avoid hard-crashes.
- **No breaking changes** to public IDs unless there is a strong reason and a migration plan.

## What to contribute
Good contributions include:
- Bug fixes and crash fixes
- Performance improvements
- Build 42 API resilience (nil-guards, safe probing)
- Translation updates
- Compatibility patches with other mods (runtime-detected, optional)
- Balance tweaks (ideally behind sandbox options)

Please avoid:
- Large, opinionated rebalances without sandbox toggles
- Removing or renaming items/recipes/fluids that other mods may depend on
- Bundling third-party assets without clear licensing

## Project layout (Build 42)
This mod uses a Build 42 foldered layout (e.g. `42/media/...`). Keep changes in the correct directories and mirror existing conventions.

Typical locations:
- `42/media/scripts/` — items, recipes, fluids
- `42/media/lua/` — Lua logic, distributions, translations
- `42/media/textures/` — icons (PNG, transparent background)

## Compatibility & stability expectations
- Prefer **runtime detection** over hard dependencies where feasible.
- Use defensive coding patterns (pcall / nil checks) when touching game globals or mod hooks.
- Avoid assuming specific mods are installed unless the feature is explicitly “requires X”.

If the project includes shared helpers (e.g., `PhobosLib`), prefer using them for:
- sandbox var access
- mod-active detection
- fluid container helpers
- safe API probing

## Versioning & public IDs
These identifiers are considered part of the public surface:
- Item type names
- Recipe IDs
- Fluid names
- Module names
- Tag names used for workstations

If you must change any of these:
1) explain why, 2) list downstream impact, 3) include migration notes.

## How to submit a PR
1. Fork the repository
2. Create a feature branch:
   - `fix/...` for bug fixes
   - `feat/...` for features
   - `compat/...` for compatibility patches
3. Keep commits descriptive (what + why)
4. Open a PR with:
   - the problem statement
   - what changed
   - how you tested (even basic “loaded into B42, crafted X, no errors”)

## Testing checklist (minimum)
Before submitting:
- Game launches to main menu without errors
- New/modified recipes show correctly and craft with expected inputs/outputs
- No free-craft / void-output regressions
- Relevant containers (jar/clay jar/bucket/gas can where applicable) behave correctly
- If Lua changed: check `console.txt` for new errors/warnings

## Licensing reminder
- Code contributions are accepted under the repository’s code license.
- Do not contribute assets you don’t have rights to share.
- Forks must remain clearly labeled unofficial (see PROJECT_IDENTITY.md).

Thank you — and may your industrial chains be ever stable.
