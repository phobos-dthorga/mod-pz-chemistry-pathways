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

# Frequently Asked Questions

---

## Where do I find lab equipment?

Lab equipment (chemistry sets, centrifuges, chromatographs, microscopes, spectrometers) comes from the **Zombie Virus Vaccine** (ZVV) mod, which is a required dependency. These items spawn in:

- **Hospitals** and medical facilities
- **Pharmacies**
- **Research labs** and university science buildings
- **Military medical tents** and field hospitals

Look for medical and scientific loot zones on the map. Chemistry sets are the most common; advanced equipment like spectrometers is rarer.

---

## What does the Applied Chemistry skill do?

Applied Chemistry is a custom perk under the Crafting parent that controls your ability to perform PCP recipes:

- **Unlocks recipes**: Each of the 301 recipes has a minimum skill level requirement (7 tiers from level 0 to level 8+)
- **Improves purity**: Higher skill produces higher-purity outputs in the purity tracking system
- **XP from crafting**: Every PCP recipe awards Applied Chemistry XP, so you level up by crafting
- **Skill books accelerate learning**: 5 volumes provide XP multipliers (like vanilla skill books)
- **Recipe books teach recipes**: 6 category-specific books and 1 master compendium unlock pathway recipes on read

The **Chemist** and **Pharmacist** occupations start with bonus levels. The **Chemistry Enthusiast** trait gives a smaller starting bonus.

---

## How does purity work?

Purity tracks the quality of chemical products through multi-step recipe chains:

- **Skill-based**: Your Applied Chemistry level is the primary factor. The formula is multiplicative, so each skill level compounds your advantage.
- **Carried forward**: Purity of input items affects purity of output items in downstream recipes.
- **Random variance**: Each craft has a +/-15% random spread around the skill-determined baseline.
- **Yield impact**: Low-purity intermediates produce fewer final outputs in multi-output recipes.
- **Vanilla outputs exempt**: When the final product is a vanilla item (matchbox, leather, firestarter), purity does not reduce quantity.
- **Visual feedback**: A speech bubble shows the result purity after crafting (configurable via sandbox).
- **Optional**: The entire purity system can be disabled via the `EnableImpuritySystem` sandbox option.

For the full technical specification, see [Purity System Rules](../architecture/purity-system-rules.md).

---

## Can I make explosives?

Yes. The **Blackpowder Pathway** is a 7-step chain from raw charcoal to gunpowder:

1. Crush charcoal
2. Purify (water or alkaline wash)
3. Prepare compost
4. Extract battery acid
5. Extract sulphur
6. Synthesize potassium nitrate (KNO3)
7. Mix blackpowder

This requires progressively higher Applied Chemistry skill levels and access to lab equipment for the later steps. The concrete mixer workstation also offers a bulk blackpowder recipe for large-scale production.

---

## Do I need all dependencies?

- **PhobosLib**: Required. The shared utility library that PCP depends on for core functionality.
- **Zombie Virus Vaccine (ZVV)**: Required. Provides the lab equipment entities (chemistry set, centrifuge, etc.) that many recipes use as crafting stations.
- **EHR, ZScienceSkill, Dynamic Trading, Neat Crafting, Moodle Framework**: All optional. PCP detects these at runtime and activates integrations only when present. You will never see errors from missing optional mods.

---

## How do sandbox options work?

PCP provides 66 sandbox options across several settings pages:

- **Yield and difficulty**: Adjust output multipliers, purity severity, skill influence
- **Feature toggles**: Enable/disable health hazards, botanical pathway, advanced lab recipes, concrete mixer, hemp effects
- **Hemp effects tuning**: 33 per-product stat knobs for smoking, edibles, and medicinal items
- **Maintenance**: One-shot reset options for cleaning up purity data, recipes, skill XP, or all PCP items

All options are accessible from the sandbox settings screen when creating or hosting a game. Changes take effect on game load.

---

## Can I use PCP in multiplayer?

Yes. PCP is fully multiplayer-compatible. Sandbox options are server-side, and features like empty vessel replacement and reset operations are MP-synced.

---

## Does PCP conflict with other mods?

PCP is designed to minimise conflicts:

- All item IDs are prefixed with `PCP_` to avoid collisions
- Cross-mod integrations are runtime-detected and optional
- Vanilla items are never modified -- PCP only adds new content
- The horticulture migration system converts existing [B42] Horticulture items gracefully

If you experience conflicts, check [Troubleshooting](troubleshooting.md) or report them via [GitHub Issues](https://github.com/phobos-dthorga/mod-pz-chemistry-pathways/issues).

---

## See Also

- [Getting Started](getting-started.md) -- Quickstart for new players
- [Features Overview](features.md) -- Full feature list
- [Troubleshooting](troubleshooting.md) -- Solving issues
