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

# PCP Features Overview

A player-friendly summary of everything PhobosChemistryPathways adds to Project Zomboid.

---

## Content at a Glance

| Category | Count |
|----------|-------|
| Recipes | 301 |
| Custom items | 120+ |
| Tradeable items (Dynamic Trading) | 76 |
| Skill books | 5 (levels 1-10) |
| Recipe books | 6 (5 category + 1 master compendium) |
| Fluids | 10 |
| Sandbox options | 66 |
| Crafting pathways | 10 |
| Occupations | 2 (Chemist, Pharmacist) |
| Traits | 2 (Chemistry Enthusiast, Chemical Aversion) |

---

## Applied Chemistry Skill

A custom perk under the Crafting parent with a steeper XP curve (75-9000 per level). All 301 recipes award XP, with 7 tiers of skill requirements gating progression from basic crushing to advanced synthesis.

- **Skill books**: 5 volumes distributed from common (Vol 1-2) to very rare (Vol 5)
- **Recipe books**: 6 category-specific books unlock pathway recipes on read
- **Occupations**: Chemist and Pharmacist provide starting skill bonuses
- **Traits**: Chemistry Enthusiast (positive) and Chemical Aversion (negative) affect starting level
- **ZScienceSkill mirror**: When ZScienceSkill is installed, Applied Chemistry XP mirrors to Science at 50% rate

---

## Crafting Pathways

### Blackpowder
Seven-step chain from raw charcoal to gunpowder. Crush, purify, prepare compost, extract battery acid, extract sulphur, synthesize potassium nitrate, and mix blackpowder.

### Biodiesel
Five-step chain from raw crops to refined vehicle fuel. Extract oil from 6 crop types using 3 equipment tiers, transesterify with methanol and catalyst, water-wash, and refine.

### Fat Rendering
Render lard, butter, margarine, or butchered meat into biodiesel feedstock. Slow-cook 6 meat pieces in a cooking pot for rendered fat and bone scraps.

### Soap-Making
Two pathways: glycerol-based crude soap from biodiesel by-products, and traditional fat-based soap from rendered animal fats. Both support KOH and NaOH catalysts.

### Bone Char
Pyrolyse animal bones and skulls in metal drums to produce bone char for filtration and reagent recipes.

### Salt Extraction
Right-click water wells to collect brine, then evaporate, crystallize, and purify into table salt. Six-recipe chain using condition-based purity tracking.

### Recycling
Nine-step chain: wood tar to wood glue, calcite to quicklime and fertilizer, crude soap to sterilized bandages, lead scrap to fishing tackle, plastic scrap to glue, and electronics to precision components.

### Agriculture
Garden pest sprays (sulphur fungicide, insecticidal soap, potash foliar), mineral feed supplements, water purification, gas mask filter recharging, epoxy resin, fire-starting materials, chemical leather tanning, and plaster powder.

### Concrete Mixer Workstation
Powered CraftBench entity built from a metal drum, salvaged motor, scrap metal, and welding equipment (Metalworking 4). Requires electricity. 13 bulk recipes including concrete, reinforced concrete, bulk biodiesel, and bulk soap.

### Botanical (Hemp)
31 recipes for hemp processing: chemical retting, fiber/hurd splitting, then branching into textiles (twine, rope, cloth, canvas), papermaking, medicinals (poultice, tincture), and construction (hempcrete). Gated by `EnableBotanicalPathway` sandbox option.

---

## Horticulture Items

45 items providing full parity with the [B42] Horticulture mod:

- **Tobacco**: Wet leaves with air-dry mechanic, dual-path chewing tobacco (fire-cure or 14-day jar fermentation)
- **Hemp buds**: Fresh, cured, decarboxylated, canned variants, ground loose pouch
- **Papermaking**: Mould and deckle, rolling papers
- **Smoking**: Glass pipe, loaded pipes, cigars, cigarettes, packs
- **Edibles**: Hemp butter, hemp-infused oil
- **Cooking**: Sugar syrup
- **Medicinals**: Poultice and tincture with timed visual/audio feedback and custom Medicated moodle

Hemp product effects are configurable via 33 sandbox options on the PCP_HempEffects settings page.

---

## Purity System

Optional condition-based purity tracking (0-100%) through recipe chains. Equipment quality factors, severity scaling, yield penalties, and player feedback via speech bubbles and custom tooltips. Higher Applied Chemistry skill produces higher purity outputs.

---

## Health Hazard System

Optional hazard system for 11 dangerous recipes. Each splits into Protected (mask + goggles, filter degrades) and Unprotected (risk of disease/stat penalties) variants. Integrates with EHR when available.

---

## Empty Vessel Replacement

Empty PCP fluid containers automatically revert to their vanilla vessel equivalents (mason jar, bottle, bucket, gas can) when opening a container. Gated by `EnableVesselReplacement` sandbox option.

---

## Maintenance & Reset Tools

Five one-shot sandbox options for version upgrades and mod removal:
- Strip purity data from all items
- Forget all learned PCP recipes
- Reset Applied Chemistry to level 0
- Remove all PCP items from inventory
- Nuclear reset (all four at once)

Each executes once on game load, then auto-resets to OFF.

---

## Cross-Mod Integration

All integrations are optional and activate automatically when the companion mod is detected:

| Mod | Integration |
|-----|------------|
| **ZScienceSkill** | XP mirroring (50% rate) + 83 items/8 fluids as microscope specimens |
| **EHR** | Health hazard recipes dispatch diseases instead of stat penalties |
| **Dynamic Trading** | 76 items registered for NPC trading with a custom Chemist archetype |
| **Neat Crafting** | Recipe visibility filter compatibility |
| **Moodle Framework** | Custom Medicated moodle for medicinal hemp items |

---

## In-Game Guides

- **Welcome popup**: First-install guide explaining pathways, sandbox options, and getting started
- **Changelog popup**: Version-based "What's New" on major/minor bumps showing changes since last played version

---

## See Also

- [Getting Started](getting-started.md) -- Quickstart for new players
- [FAQ](faq.md) -- Common questions
- [Troubleshooting](troubleshooting.md) -- Solving issues
