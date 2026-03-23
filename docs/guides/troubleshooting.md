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

# Troubleshooting

Solutions for common issues with PhobosChemistryPathways.

---

## Recipes Not Showing Up

**Check dependencies are installed and enabled.**
PCP requires both **PhobosLib** and **Zombie Virus Vaccine** (ZVV). Verify all three mods appear in your active mod list and are enabled.

**Check your Applied Chemistry skill level.**
Most recipes have minimum skill requirements (7 tiers from level 0 to level 8+). If a recipe is not visible, you may not have reached the required skill level yet. Read skill books and recipe books to accelerate progression.

**Check sandbox options.**
Several features are gated by sandbox toggles:
- `EnableBotanicalPathway` must be ON for hemp/botanical recipes
- `EnableAdvancedLabRecipes` must be ON for microscope/spectrometer recipes
- `EnableHealthHazards` must be ON for Protected/Unprotected hazard recipe variants
- `EnableConcreteMixer` must be ON for concrete mixer workstation recipes

**Check you have the right crafting station.**
Different recipes require different stations:
- Lab recipes need a chemistry set (from ZVV) nearby
- Kitchen recipes need a cooking pot or stove
- Concrete mixer recipes need a built concrete mixer workstation with power
- Some recipes need specific items equipped (e.g., welding mask for metalworking steps)

**Check mod load order.**
PCP should load after PhobosLib and ZVV. If using a mod manager, verify the load order is correct. PCP's `mod.info` declares its dependencies, so most launchers handle this automatically.

---

## Low Purity Results

**Improve your Applied Chemistry skill.**
Purity is primarily driven by your skill level. The formula is multiplicative, so each skill level compounds your advantage. Higher skill = consistently better purity.

**Check input purity.**
Purity carries forward through recipe chains. If your inputs are low-purity, your outputs will be too. Try to maintain high purity from the start of a chain.

**Random variance is normal.**
Each craft has a +/-15% random spread. Occasional low rolls happen even at high skill. Craft multiple batches for more consistent results.

**Adjust sandbox settings.**
- `ImpuritySeverity` (1-3) controls how aggressively purity degrades (Mild/Standard/Harsh)
- `SkillPurityInfluence` (1-4) controls how much skill affects purity (None/Low/Standard/High)
- `EnableImpuritySystem` can disable purity tracking entirely if desired

---

## Missing Items After Update

**Run the migration system.**
If you updated PCP and items seem to have changed names or disappeared, the mod may have a migration for your save. Check the changelog for migration notes.

**Check the horticulture migration.**
If you previously used the [B42] Horticulture mod, enable the `MigrateHorticultureItems` sandbox option (one-shot) to convert old items to PCP equivalents.

**Use the reset tools if needed.**
If items are in a bad state, the maintenance sandbox options can help:
- `ResetStripPurity` removes purity data from all items
- `ResetNuclearRemove` removes all PCP items from inventory (use with caution)
- `ResetNuclearAll` executes all reset operations

These are one-shot options that execute once on game load and then auto-reset to OFF.

---

## Empty Vessels Not Replacing

**Check the sandbox option.**
`EnableVesselReplacement` must be ON (it is by default). When enabled, empty PCP fluid containers revert to their vanilla vessel equivalents (mason jar, bottle, bucket, gas can) when you open a container.

---

## Concrete Mixer Not Working

**Check power.**
The concrete mixer workstation requires electricity (grid power, a running generator, or a custom power source).

**Check fuel.**
Generator-powered mixers consume fuel during crafting at a rate controlled by `MixerFuelDrainRate`.

**Check sandbox option.**
`EnableConcreteMixer` must be ON.

**Check Metalworking skill.**
Building the concrete mixer requires Metalworking level 4 and welding equipment (blow torch, welding mask, welding rods).

---

## Console Errors

**Enable debug logging.**
Set `EnableDebugLogging` to ON in sandbox options. PCP will write detailed debug output to `console.txt` via PhobosLib_Debug, which can help diagnose issues.

**Common error patterns:**
- `FluidCategory` enum errors: Report as a bug -- PCP fluids may reference an invalid Build 42 category
- `item not found` errors mentioning PCP: Check that all dependencies are installed and up to date
- `[PhobosLib:Validate] MISSING` entries: A required dependency is not installed or is the wrong version

---

## Reporting Bugs

If the above steps do not resolve your issue:

1. Enable `EnableDebugLogging` in sandbox options
2. Reproduce the issue
3. Collect your `console.txt` from `%USERPROFILE%\Zomboid\` (Windows) or `~/Zomboid/` (Linux)
4. Open a [GitHub Issue](https://github.com/phobos-dthorga/mod-pz-chemistry-pathways/issues) with:
   - PCP version, PhobosLib version, and ZVV version
   - Steps to reproduce
   - Relevant `console.txt` excerpts

---

## See Also

- [Getting Started](getting-started.md) -- Quickstart for new players
- [Features Overview](features.md) -- Full feature list
- [FAQ](faq.md) -- Common questions
