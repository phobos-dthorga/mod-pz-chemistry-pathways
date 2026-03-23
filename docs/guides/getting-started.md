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

# Getting Started with PhobosChemistryPathways

A quickstart guide for new players.

---

## What Is PCP?

**PhobosChemistryPathways** (PCP) is a chemistry crafting mod for Project Zomboid Build 42. It adds 301 recipes across 10 crafting pathways, 120+ custom items, a dedicated Applied Chemistry skill, and a purity system that rewards higher skill with better results.

Whether you want to brew biodiesel for your generator truck, synthesize blackpowder for ammunition, extract salt from wells, or process hemp into textiles and building materials, PCP provides realistic multi-step crafting chains that turn raw materials into useful products.

---

## Dependencies

| Mod | Required? | Purpose |
|-----|-----------|---------|
| **[PhobosLib](https://steamcommunity.com/sharedfiles/filedetails/?id=3668598865)** | Yes | Shared utility library used by all Phobos mods |
| **[Zombie Virus Vaccine](https://steamcommunity.com/sharedfiles/filedetails/?id=3615135168)** (ZVV) | Yes | Provides lab equipment entities (chemistry set, centrifuge, microscope, etc.) |
| **EHR** (Extensive Health Rework) | Optional | Enhanced disease system for health hazard recipes |
| **ZScienceSkill** | Optional | Science skill XP mirroring and specimen registration |
| **Dynamic Trading** | Optional | NPC trader integration for PCP items |
| **Moodle Framework** | Optional | Custom Medicated moodle for medicinal items |

Install PhobosLib and ZVV from the Steam Workshop before enabling PCP.

---

## First Steps

1. **Find lab equipment.** Search hospitals, pharmacies, research labs, and science buildings for chemistry sets, centrifuges, and other lab gear. These are ZVV items and spawn in medical/scientific loot zones.

2. **Learn recipes.** PCP recipes are gated by Applied Chemistry skill level. Find and read **skill books** (5 volumes covering levels 1-10) and **recipe books** (6 category-specific books) to unlock new recipes faster.

3. **Level Applied Chemistry.** Every PCP recipe awards Applied Chemistry XP. Start with low-tier recipes (crushing charcoal, basic extractions) and work your way up. The **Chemist** and **Pharmacist** occupations give starting skill bonuses.

4. **Gather raw materials.** Most pathways start from common materials: charcoal, animal bones, crops (soybeans, sunflower, corn, hemp), water, and scavenged chemicals.

5. **Craft at the right station.** Different recipes require different crafting stations:
   - **Lab bench** (chemistry set) for precision chemistry
   - **Kitchen** (cooking pot, stove) for fat rendering, soap, and food processing
   - **Field** (campfire, metal drum) for large-batch outdoor processing
   - **Industrial** (concrete mixer workstation) for powered bulk production

---

## The 10 Pathways

| Pathway | What It Does |
|---------|-------------|
| **Blackpowder** | Charcoal to gunpowder via 7-step chain (crush, purify, compost, extract acid, extract sulphur, synthesize KNO3, mix) |
| **Biodiesel** | Crop oils to vehicle fuel via transesterification with methanol and catalyst |
| **Fat Rendering** | Butchered meat or cooking fats into biodiesel feedstock and soap ingredients |
| **Soap** | Glycerol-based or fat-based soap from biodiesel by-products or rendered animal fats |
| **Bone Char** | Pyrolysed animal bones for filtration and reagent recipes |
| **Salt Extraction** | Brine from water wells, evaporated and crystallized into rock salt and table salt |
| **Recycling** | Wood tar, calcite, lead scrap, plastic, and electronics into useful downstream products |
| **Agriculture** | Garden sprays, mineral feed, water purification, epoxy, fire-starting, and leather tanning |
| **Concrete Mixer** | Powered workstation for industrial-scale bulk recipes (concrete, biodiesel, soap, compost) |
| **Botanical (Hemp)** | Hemp retting, fiber processing, textiles, papermaking, medicinals, and hempcrete construction |

---

## Crafting Categories

PCP organises its 301 recipes into four crafting categories visible in the crafting UI:

| Category | Icon | Focus |
|----------|------|-------|
| **PhobosLabChem** | Lab flask | Precision chemistry requiring lab equipment |
| **PhobosKitchenChem** | Cooking pot | Recipes using kitchen equipment and heat |
| **PhobosFieldChem** | Campfire | Outdoor and large-batch field processing |
| **PhobosIndustrialChem** | Gear | Powered workstation and construction recipes |

---

## Purity System Basics

PCP tracks **purity** (0-100%) through recipe chains using item condition. Higher Applied Chemistry skill produces higher purity outputs, and purity carries forward through multi-step chains.

- **Higher skill = better purity.** The formula is multiplicative -- each skill level compounds your advantage.
- **Purity affects yield.** Low-purity intermediates produce fewer final outputs in multi-output recipes.
- **Variance is normal.** Each craft has a +/-15% random spread, so results vary slightly each time.
- **Vanilla outputs are unaffected.** When the final product is a vanilla item (matchbox, leather, etc.), purity does not reduce the quantity.

The purity system is optional and can be disabled via the `EnableImpuritySystem` sandbox option.

---

## Next Steps

- [Features Overview](features.md) -- Full list of what PCP adds to your game
- [FAQ](faq.md) -- Common questions answered
- [Troubleshooting](troubleshooting.md) -- Solving common issues
- [Architecture & Diagrams](../architecture/README.md) -- Technical documentation and recipe flowcharts
