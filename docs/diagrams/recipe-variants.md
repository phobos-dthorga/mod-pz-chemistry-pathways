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

# Recipe Variants

PCP uses **recipe variants** to support sandbox settings without runtime scripting. Each sandbox toggle (like `RequireHeatSources` or `EnableHealthHazards`) controls which version of a recipe the player sees in the crafting menu.

---

## Why Variants Exist

Project Zomboid Build 42's `craftRecipe` system has no built-in way to conditionally add or remove ingredients at runtime. If the server admin turns off `RequireHeatSources`, PCP can't just remove the propane tank from an existing recipe -- it needs a **separate recipe** that was defined without it.

PCP solves this with **paired recipes**: a base version and one or more variants. A client-side recipe filter (`PCP_RecipeFilter.lua`) hides recipes whose sandbox conditions aren't met, so the player only sees the correct version.

---

## Naming Convention

All variant names are built by appending a suffix to the base recipe name:

| Suffix | Meaning | Sandbox Gate | What Changes |
|--------|---------|-------------|--------------|
| *(none)* | Base recipe | `RequireHeatSources = ON` | Has fuel input (PropaneTank, Charcoal, or Coke) |
| `Simple` | No fuel | `RequireHeatSources = OFF` | Fuel input removed |
| `Safe` | PPE required | `EnableHealthHazards = ON` | Adds goggles + respirator/gas mask; filter degrades 0.025/craft |
| `Unsafe` | Risk of injury | `EnableHealthHazards = ON` | No PPE; triggers EHR disease or vanilla stat penalty |
| `SimpleSafe` | No fuel + PPE | Both `OFF` + `ON` | Combines Simple + Safe |
| `SimpleUnsafe` | No fuel + risk | Both `OFF` + `ON` | Combines Simple + Unsafe |

A recipe family can have up to **6 members**: the base plus 5 variants.

### Example: Methanol Distillation Family

| Recipe Name | Fuel? | PPE? | Hazard Risk? | Visible When |
|-------------|-------|------|-------------|--------------|
| `PCPDistillMethanol` | PropaneTank | No | No | Heat ON, Hazards OFF |
| `PCPDistillMethanolSimple` | -- | No | No | Heat OFF, Hazards OFF |
| `PCPDistillMethanolSafe` | PropaneTank | Goggles + Mask | No (protected) | Heat ON, Hazards ON |
| `PCPDistillMethanolUnsafe` | PropaneTank | -- | Yes | Heat ON, Hazards ON |
| `PCPDistillMethanolSimpleSafe` | -- | Goggles + Mask | No (protected) | Heat OFF, Hazards ON |
| `PCPDistillMethanolSimpleUnsafe` | -- | -- | Yes | Heat OFF, Hazards ON |

> **Only one version is visible at a time.** If both sandbox options are OFF, only `PCPDistillMethanolSimple` appears. If both are ON, the player sees `Safe` and `Unsafe` (with or without `Simple`) and chooses whether to wear PPE.

---

## How the Filter Works

```
Server sandbox settings
        |
        v
PCP_RecipeFilter.lua (client-side)
        |
        +-- RequireHeatSources = ON?  --> show base, hide Simple
        +-- RequireHeatSources = OFF? --> show Simple, hide base
        |
        +-- EnableHealthHazards = ON?  --> show Safe + Unsafe, hide original
        +-- EnableHealthHazards = OFF? --> show original, hide Safe + Unsafe
```

The filter registers with `PhobosLib.registerRecipeFilter()`, which hooks into both the vanilla crafting UI and Neat Crafting (if installed).

---

## Safe Variants (Protected)

Safe variants add **personal protective equipment** as required inputs:

| PPE Slot | Accepted Items | Mode |
|----------|---------------|------|
| Eye protection | SafetyGoggles, SwimmingGoggles, SkiGoggles | `mode:keep` |
| Respiratory protection | GasMask, NBCmask, BuildersRespirator, ImprovisedGasMask | `mode:keep` |

The mask **degrades** by 0.025 condition per craft (approximately 40 crafts per mask). The OnCreate callback calls `PhobosLib.degradeFilterFromInputs()` to apply this wear.

Safe recipes use a dedicated callback (e.g., `pcpDistillMethanolSafePurity`) that handles both purity tracking and filter degradation.

---

## Unsafe Variants (Unprotected)

Unsafe variants have **no PPE requirement** but trigger health consequences via the OnCreate callback:

1. **If EHR (Extensive Health Rework) is installed**: Calls `EHR.Disease.TryContract(player, diseaseId, chance)` with protection-scaled probability
2. **If EHR is not installed**: Falls back to vanilla stat penalties (`Sickness`, `Pain`, `Stress`)

All EHR calls are `pcall`-wrapped -- if EHR is removed mid-save, the fallback triggers automatically.

| Hazard Profile | Disease (EHR) | Fallback (vanilla) | Recipes |
|---------------|--------------|-------------------|---------|
| `methanol_fumes` | corpse_sickness | Sickness + Pain | Methanol distillation |
| `acid_fumes` | pneumonia | Sickness + Stress | Sulphur extraction, Battery acid |
| `lye_burn` | wound_infection | Pain + Stress | KOH synthesis |
| `plastic_fumes` | corpse_sickness | Sickness + Pain | Plastic scrap melting |

---

## Other Variant Types

Not all variants follow the Simple/Safe/Unsafe pattern. PCP also has:

### Equipment Tier Variants

Some recipes have Mortar, Chemistry Set, and Metal Drum versions with different yields:

| Tier | Example | Yield | Equipment Tag |
|------|---------|-------|---------------|
| Mortar | `PCPPressSoybeanOilMortar` | 1 jar | `AnySurfaceCraft` |
| Lab | `PCPPressSoybeanOilLab` | 2 jars | `zReVAC2:ChemistrySet` |
| Bulk | `PCPPressSoybeanOilBulk` | 1 bucket | `PCP:MetalDrumStation` |

### Catalyst Variants

Transesterification and soap recipes have KOH and NaOH versions:
- `PCPTransesterifyOilKOH` -- uses PCP-crafted KOH
- `PCPTransesterifyOilNaOH` -- uses zReVaccin NaOH

### Fuel Variants (Metal Drum)

Metal drum recipes have 3 fuel sub-variants (unrelated to Simple):
- `Charcoal` -- 3x Charcoal fuel
- `Coke` -- 1x Coke fuel
- `Propane` -- PropaneTank fuel

These are always visible (not sandbox-gated) and let the player use whatever fuel they have.

### Container Variants

Some recipes support different container sizes:
- `Jar` -- Mason jar (1.0L)
- `ClayJar` -- Clay jar (2.5L)
- `Bucket` -- Bucket (10.0L)

---

## Variant Counts (v0.22.0)

| Suffix | Count | Controlled By |
|--------|-------|---------------|
| Simple | 33 | `RequireHeatSources` |
| Safe | 10 | `EnableHealthHazards` |
| Unsafe | 10 | `EnableHealthHazards` |
| SimpleSafe | 8 | Both |
| SimpleUnsafe | 8 | Both |
| **Total gated variants** | **69** | |
| Equipment/catalyst/fuel/container | ~30 | Always visible |
| Non-variant recipes | ~86 | Always visible |
| **Grand total** | **185** | |

---

## Troubleshooting

**"Why can't I see a recipe?"**

1. **Check sandbox settings**: If `RequireHeatSources` is ON, you won't see `Simple` variants. If `EnableHealthHazards` is OFF, you won't see `Safe`/`Unsafe` variants.
2. **Check skill level**: Every recipe has a `SkillRequired` gate. Open the skills panel and check your Applied Chemistry level.
3. **Check NeedToBeLearn**: All PCP recipes require learning. Read the Chemistry Pathways Handbook, or reach the AutoLearnAll skill level.
4. **Check equipment proximity**: Chemistry Set recipes require standing near a placed zReVaccin chemistry set. Metal Drum recipes require a placed metal drum.
5. **Check Neat Crafting**: If you're using Neat Crafting, make sure PhobosLib 1.6.0+ is installed for filter compatibility.

**"I see two versions of the same recipe"**

This is intended when `EnableHealthHazards` is ON. You'll see both a Safe (with PPE) and Unsafe (without PPE) version. Choose based on whether you have protective equipment.

**"The recipe disappeared after changing sandbox settings"**

Recipe visibility updates when the crafting window is opened. Close and reopen the crafting menu after changing sandbox settings.
