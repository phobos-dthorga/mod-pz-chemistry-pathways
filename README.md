# PhobosChemistryPathways

**Version:** 0.13.0 | **Requires:** Project Zomboid Build 42.14.0+ | PhobosLib 1.4.0+ | zReVaccin 3

> **Players:** Subscribe on [Steam Workshop](https://steamcommunity.com/sharedfiles/filedetails/?id=3668197831) for easy installation. This GitHub repo is for source code, documentation, and development.
>
> **Modders & Developers:** Bug reports, feature requests, and contributions are welcome via [GitHub Issues](https://github.com/phobos-dthorga/mod-pz-chemistry-pathways/issues).

A complete chemistry suite for Project Zomboid Build 42, adding realistic crafting pathways for blackpowder, biodiesel, soap, bone char, and advanced laboratory processes.

**Dependencies:** [PhobosLib](https://github.com/phobos-dthorga/mod-pz-phobos-lib) ([Workshop](https://steamcommunity.com/sharedfiles/filedetails/?id=3668598865)) | zReVaccin 3

This project is open-source, but the Steam Workshop upload is the official distribution channel. The goal of this repository is to allow collaboration, compatibility extensions, and dependency usage while preserving authorship identity.

## Features

### Applied Chemistry Skill System
Custom `AppliedChemistry` perk under the Crafting parent with a steeper XP curve (75-9000). Two occupations (Chemist and Pharmacist) and two traits (Chemistry Enthusiast and Chemical Aversion) provide starting skill bonuses. Five skill book volumes cover levels 1-10, distributed in loot from common (Vol 1-2) to very rare (Vol 5). All 150 recipes award Applied Chemistry XP with 7 tiers of skill requirements.

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

### Recycling Pathway
Eight-step recycling chain (R1-R8): wood tar to wood glue, calcite to quicklime and fertilizer, crude soap to usable bars and sterilized bandages, lead scrap to fishing tackle, plastic scrap to glue (with hazard variants), and acid-washed electronics to precision components.

### Health Hazard System
Optional hazard system for 11 dangerous chemistry recipes. Each splits into Protected (mask + goggles required, filter degrades) and Unprotected (risk of disease or stat penalties) variants. Integrates with EHR (Extensive Health Rework) when available, with vanilla stat fallback.

### Tiered Reset/Cleanup System
Five one-shot sandbox options on a dedicated "PCP - Maintenance / Reset" settings page for version upgrades and mod removal. Strip purity data, forget recipes, reset skill XP, remove all PCP items, or execute all four as a nuclear reset. Each option executes once on game load, then auto-resets to OFF with persistent notifications.

### Cross-Mod Integration
- **ZScienceSkill** ("Science, Bitch!"): When active, Applied Chemistry XP mirrors to Science at 50% rate, and 33 items + 8 fluids are registered as researchable microscope specimens.
- **EHR** (Extensive Health Rework): When active, health hazard recipes dispatch EHR diseases instead of vanilla stat penalties.

## Requirements

| Dependency | Purpose |
|------------|---------|
| **PhobosLib 1.4.0+** | Shared utility library (sandbox access, fluid helpers, quality tracking, hazard dispatch, skill XP mirroring, reset utilities, startup validation) |
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
| ResetStripPurity | boolean | false | One-shot: strip purity modData from all items |
| ResetForgetRecipes | boolean | false | One-shot: forget all learned PCP recipes |
| ResetSkillXP | boolean | false | One-shot: reset Applied Chemistry to level 0 |
| ResetNuclearRemove | boolean | false | One-shot: remove all PCP items from inventory |
| ResetNuclearAll | boolean | false | One-shot: execute all four reset operations |

## Content Summary

- **150 recipes** across blackpowder, biodiesel, soap, bone char, recycling, utility, and advanced lab pathways
- **39 items** including chemical reagents, intermediates, and container variants (jar, clay jar, bucket)
- **5 skill books** covering Applied Chemistry levels 1-10
- **2 occupations** (Chemist, Pharmacist) and **2 traits** (Chemistry Enthusiast, Chemical Aversion)
- **8 fluids** with Build 42 FluidContainer integration and poison profiles
- **12 sandbox options** for gameplay customization and maintenance
- **135 OnCreate callbacks** for purity tracking and propane partial consumption
- **1 handbook** (lootable) teaching all recipes with a coloured pathway guide

## License

This project uses dual licensing:
- **Code** (Lua scripts, recipe definitions, item definitions): [MIT License](LICENSE)
- **Assets** (textures, icons, images): [CC BY-NC-SA 4.0](LICENSE-CC-BY-NC-SA.txt)

Forks and addons are encouraged. Code is permissively licensed for integration. Assets are protected from unauthorized redistribution.

## Documentation

Visual guides for understanding recipe chains, sandbox settings, and mod architecture:

- [Recipe Pathways](docs/diagrams/recipe-pathways.md) — Complete crafting chain flowcharts for all 6 pathways
- [Sandbox Settings Guide](docs/diagrams/sandbox-gating.md) — How 12 sandbox options control recipe visibility, behavior, and maintenance
- [Skill Progression](docs/diagrams/skill-progression.md) — Applied Chemistry skill tiers, XP curve, occupations, and traits
- [Architecture & Dependencies](docs/diagrams/architecture.md) — Dependency graph, PhobosLib modules, and cross-mod integration

See [docs/README.md](docs/README.md) for the full index.

## Verification Checklist

After each intermediate or major version bump, verify:

- [ ] No `FluidCategory` enum errors in `console.txt` (all PCP fluids use valid B42 categories)
- [ ] No `CharacterTrait.*null` errors — all 3 traits + 2 professions load (check character creation screen)
- [ ] No `item not found` errors for recipe outputs (grep `console.txt` for `PCP`)
- [ ] `registries.lua` registers all traits/professions (no "removing script due to load error" for PCP entries)
- [ ] `[PhobosLib:Validate]` shows no MISSING entries for PCP dependencies
- [ ] Custom `AppliedChemistry` perk appears in skills panel
- [ ] At least one recipe per pathway is craftable (smoke test)

## Further Reading
- [PROJECT_IDENTITY.md](PROJECT_IDENTITY.md) — Authorship and fork policy
- [MODDING_PERMISSION.md](MODDING_PERMISSION.md) — What you can and cannot do with this mod
- [CONTRIBUTING.md](CONTRIBUTING.md) — How to contribute
- [CHANGELOG.md](CHANGELOG.md) — Release history
- [VERSIONING.md](VERSIONING.md) — Versioning policy
