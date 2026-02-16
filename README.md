# PhobosChemistryPathways

**Version:** 0.10.0 | **Requires:** Project Zomboid Build 42.13.0+ | PhobosLib 1.1.0+ | zReVaccin 3

A complete chemistry suite for Project Zomboid Build 42, adding realistic crafting pathways for blackpowder, biodiesel, soap, bone char, and advanced laboratory processes.

This project is open-source, but the Steam Workshop upload is the official distribution channel. The goal of this repository is to allow collaboration, compatibility extensions, and dependency usage while preserving authorship identity.

## Features

### Applied Chemistry Skill System
Custom `AppliedChemistry` perk under the Crafting parent with a steeper XP curve (75-9000). Two occupations (Chemist and Pharmacist) and two traits (Chemistry Enthusiast and Chemical Aversion) provide starting skill bonuses. Five skill book volumes cover levels 1-10, distributed in loot from common (Vol 1-2) to very rare (Vol 5). All 132 recipes award Applied Chemistry XP with 7 tiers of skill requirements.

### Blackpowder Pathway
Seven-step chain from raw charcoal to gunpowder: crush, purify (water or alkaline wash), prepare compost, extract battery acid, extract sulphur, synthesize potassium nitrate, and mix blackpowder.

### Biodiesel Pathway
Five-step chain from raw crops to refined fuel. Extract oil from 6 crop types (soybeans, sunflower, corn, flax, hemp, peanuts) using 3 equipment tiers (mortar and pestle, chemistry set, metal drum). Transesterify with methanol and KOH or NaOH catalyst, water-wash, and refine into usable vehicle fuel.

### Fat Rendering and Oil Conversion
Render lard, butter, or margarine into biodiesel feedstock. Convert bottled vegetable or olive oil directly.

### Soap-Making
Two soap pathways: glycerol-based crude soap from biodiesel by-products, and traditional fat-based soap from rendered animal fats. Both support KOH and NaOH catalysts.

### Bone Char Production
Pyrolyse animal bones and skulls in metal drums to produce bone char, an alternative to purified charcoal in filtration and reagent recipes.

### Advanced Lab Equipment
Centrifuge, chromatograph, microscope, and spectrometer recipes for enhanced processing. Microscope and spectrometer are gated by the EnableAdvancedLabRecipes sandbox option.

### Impurity/Purity System
Optional modData-backed purity tracking (0-100 scale) through recipe chains. Equipment quality factors, severity scaling, yield penalties, and player feedback via speech bubbles and tooltips.

### Health Hazard System
Optional hazard system for 10 dangerous chemistry recipes. Each splits into Protected (mask + goggles required, filter degrades) and Unprotected (risk of disease or stat penalties) variants. Integrates with EHR (Extensive Health Rework) when available, with vanilla stat fallback.

### Cross-Mod Integration
- **ZScienceSkill** ("Science, Bitch!"): When active, Applied Chemistry XP mirrors to Science at 50% rate, and 16 PCP chemical items are registered as researchable microscope specimens.
- **EHR** (Extensive Health Rework): When active, health hazard recipes dispatch EHR diseases instead of vanilla stat penalties.

## Requirements

| Dependency | Purpose |
|------------|---------|
| **PhobosLib 1.1.0+** | Shared utility library (sandbox access, fluid helpers, quality tracking, hazard dispatch, skill XP mirroring) |
| **zReVaccin 3** (zReModVaccin30bykERHUS) | Lab equipment entities (chemistry set, centrifuge, chromatograph, microscope, spectrometer) |
| **EHR** (optional) | Disease system for health hazard integration; vanilla stat penalties used as fallback |
| **ZScienceSkill** (optional) | Science skill XP mirroring and microscope specimen registration |

## Sandbox Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| YieldMultiplier | 0.25 - 4.0 | 1.0 | Scales recipe output quantities |
| EnableAdvancedLabRecipes | boolean | false | Gates microscope and spectrometer recipes |
| RequireHeatSources | boolean | true | Gates fuel requirements on heated recipes |
| EnableImpuritySystem | boolean | false | Enables purity tracking through recipe chains |
| ImpuritySeverity | 1-3 | 2 | Controls purity degradation intensity (Mild/Standard/Harsh) |
| ShowPurityOnCraft | boolean | true | Shows purity speech bubble after crafting |
| EnableHealthHazards | boolean | false | Enables Protected/Unprotected recipe variants for hazardous chemistry |

## Content Summary

- **132 recipes** across blackpowder, biodiesel, soap, bone char, utility, and advanced lab pathways
- **34 items** including chemical reagents, intermediates, and container variants (jar, clay jar, bucket)
- **5 skill books** covering Applied Chemistry levels 1-10
- **2 occupations** (Chemist, Pharmacist) and **2 traits** (Chemistry Enthusiast, Chemical Aversion)
- **8 fluids** with Build 42 FluidContainer integration and poison profiles
- **7 sandbox options** for gameplay customization
- **122 OnCreate callbacks** for purity tracking and propane partial consumption
- **1 handbook** (lootable) teaching all recipes with a coloured pathway guide

## License

This project uses dual licensing:
- **Code** (Lua scripts, recipe definitions, item definitions): [MIT License](LICENSE)
- **Assets** (textures, icons, images): [CC BY-NC-SA 4.0](LICENSE-CC-BY-NC-SA.txt)

Forks and addons are encouraged. Code is permissively licensed for integration. Assets are protected from unauthorized redistribution.

## Further Reading
- [PROJECT_IDENTITY.md](PROJECT_IDENTITY.md) — Authorship and fork policy
- [MODDING_PERMISSION.md](MODDING_PERMISSION.md) — What you can and cannot do with this mod
- [CONTRIBUTING.md](CONTRIBUTING.md) — How to contribute
- [CHANGELOG.md](CHANGELOG.md) — Release history
- [VERSIONING.md](VERSIONING.md) — Versioning policy
