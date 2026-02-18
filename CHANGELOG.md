# Changelog (PhobosChemistryPathways)

All notable changes to this project will be documented in this file.

The format is based on Keep a Changelog, and this project follows Semantic Versioning.

## [Unreleased]

## [0.13.0] - 2026-02-19

### Added
- **`registries.lua`** — Registers all PCP custom traits and professions with B42.13+ registry system; fixes `CharacterTrait null` errors that prevented traits/professions from loading
- **`PCP_Validate.lua`** — Startup dependency validation via PhobosLib; registers critical items, fluids, and perks and logs any missing dependencies with `[PCP:Validate]` prefix

### Fixed
- **FluidCategory.Food** — Replaced invalid `Food` category with `Beverage` for CrudeVegetableOil, RenderedFat, and Glycerol fluids; `Food` is not a valid `FluidCategory` enum in B42
- **Base.Transistor** — Replaced non-existent `Base.Transistor` output in `PCPRecoverComponents` recipe with `Base.Amplifier` (Transistor was removed in B42)

## [0.12.2] - 2026-02-19

### Fixed
- **R6 Cast Lead Fishing Weights** — replaced removed `Base.FishingTackle` with `Base.FishingHook_Forged` in all 4 fuel variants (charcoal, coke, propane, simplified). `FishingTackle` was a legacy item ID removed in current B42 builds, causing `OutputMapper.getItem` failures and a fatal `WorldDictionaryException` that prevented world loading.

## [0.12.0] - 2026-02-18

### Added
- **Tiered Reset/Cleanup System** — 5 one-shot sandbox options on a dedicated "PCP - Maintenance / Reset" settings page
  - Tier 1: Strip Purity Data — removes PCP_Purity modData from all items (deep inventory scan)
  - Tier 2: Forget PCP Recipes — removes all learned PCP recipes from known recipe list
  - Tier 3: Reset Applied Chemistry XP — resets skill to level 0 / 0 XP
  - Tier 4: Remove All PCP Items — permanently removes all PhobosChemistryPathways items from inventory
  - Tier 5: Nuclear Reset — executes all four tiers in sequence
- **Client-side reset notifications** via `PCP_ResetNotify.lua`
  - Success: HaloTextHelper green on-screen text with sound
  - Failure: ISModalRichText modal dialog that blocks game until acknowledged
  - Server→client messaging via `sendServerCommand` / `Events.OnServerCommand`
- **World modData execution guard** — each reset executes exactly once, guarded by `getGameTime():getModData()` flags
- **Auto-reset** — sandbox options automatically reset to OFF after execution
- **5 new sandbox options** (12 total): ResetStripPurity, ResetForgetRecipes, ResetSkillXP, ResetNuclearRemove, ResetNuclearAll

### Changed
- Requires **PhobosLib 1.2.0+** (PhobosLib_Reset module + setSandboxVar)

### Summary
- **150 recipes**, **39 items**, **8 fluids**, **12 sandbox options**, **135 OnCreate callbacks**

## [0.11.0] - 2026-02-17

### Added
- **Recycling Pathway (R1-R8)** — 18 new recipes in `PCP_Recipes_Recycling.txt`
  - R1: WoodTar → WoodGlue (tar pitch adhesive, AnySurfaceCraft)
  - R2: Calcite → Quicklime (calcination, DomeKiln, 4 heat variants)
  - R3: Calcite → Fertilizer (agricultural lime + compost, AnySurfaceCraft)
  - R4: CrudeSoap → Soap2 (cure and shape usable soap bars, AnySurfaceCraft)
  - R5: CrudeSoap → Sterilized Bandages (lye antiseptic, ChemistrySet, 2 variants)
  - R6: LeadScrap → FishingTackle (lead casting, PrimitiveFurnace, 4 heat variants)
  - R7: PlasticScrap → Glue (melt plastic, ChemistrySet, + 2 hazard twins)
  - R8: AcidWashedElectronics → Transistor + Amplifier (component recovery, AnySurfaceCraft)
- **plastic_fumes hazard profile** for R7 PlasticScrap → Glue recipe
- **PCPRefineBiodieselBulk** — WashedBiodieselBucket → 2× RefinedBiodieselCan (bulk biodiesel chain completion)

### Changed
- **Bone char workstation migrated**: 8 bone char recipes moved from `PCP:MetalDrumStation` to `WoodCharcoal` tag (Charcoal Pit, Charcoal Burner, Dome Kiln)
- **Health hazard gating**: 11 originals / 22 Safe+Unsafe twins (was 10/20, R7 adds one)

### Fixed
- **ZScienceSkill integration rewrite** — corrected broken API
  - Old: `ZScienceData.addSpecimen` (nonexistent). New: `ZScienceSkill.Data.add()`
  - 16 items → 33 item specimens + 8 fluid specimens
  - Dual-perk XP (Science + AppliedChemistry) on all specimens
  - Container variant deduplication keys

### Summary
- **150 recipes** (was 132), **39 items**, **8 fluids**, **7 sandbox options**, **135 OnCreate callbacks** (was 122)

## [0.10.0] - 2026-02-17

### Added
- **Applied Chemistry Skill System** — Complete custom skill (perk) for chemistry crafting
  - Custom `AppliedChemistry` perk under Crafting parent with steeper XP curve (75-9000)
  - **Chemist** occupation (Cost -4, Applied Chemistry 3, Doctor 1, 13 granted recipes)
  - **Pharmacist** occupation (Cost -2, Applied Chemistry 2, Doctor 2, 5 granted recipes)
  - **Chemistry Enthusiast** trait (+4 cost, Applied Chemistry +1, 2 granted recipes)
  - **Chemical Aversion** trait (-2 cost, Applied Chemistry -1)
  - 5 skill book volumes (Applied Chemistry Vol. 1-5, levels 1-10 in pairs)
  - Skill book loot distributions (Vol 1-2 common, Vol 3-4 rare, Vol 5 very rare)

### Changed
- **All 132 recipes migrated** from Doctor XP to Applied Chemistry XP
  - 7 tiers of skill requirements (Tier 0-7) with AutoLearnAll thresholds
  - PCPCutPlasticScrap unchanged (remains Maintenance:5)
- Handbook tooltip updated with Applied Chemistry skill progression guide

### Added (Cross-Mod)
- **ZScienceSkill integration** — When "Science, Bitch!" mod is active:
  - Applied Chemistry XP mirrors to Science at 50% rate via PhobosLib.registerXPMirror
  - 16 PCP chemical items registered as researchable microscope specimens
- **Requires PhobosLib 1.1.0+** for PhobosLib_Skill module

## [0.9.0] - 2026-02-17
### Added
- **Blackpowder Pathway** (7 steps): Crush charcoal, purify (water/alkaline wash), prepare diluted compost, extract battery acid, extract sulphur, synthesize KNO3, mix blackpowder.
- **Biodiesel Pathway** (5 steps): Oil extraction from 6 crops (soybeans, sunflower, corn, flax, hemp, peanuts) across 3 equipment tiers (mortar, chemistry set, metal drum), transesterification with KOH or NaOH catalysts, water-wash purification, and refining into usable fuel.
- **Fat Rendering**: Lard, Butter, and Margarine can be rendered into fat feedstock for biodiesel.
- **Oil Conversion**: Bottled vegetable oil and olive oil converted to crude vegetable oil.
- **Soap-Making**: Glycerol-based crude soap (S1) and traditional fat-based soap (S2), each with KOH and NaOH variants.
- **Bone Char Production**: Animal bones and skulls pyrolysed in metal drums to produce bone char, an alternative to purified charcoal in filtration and reagent recipes.
- **Advanced Lab Equipment**: Centrifuge (biodiesel wash, glycerol separation), chromatograph (biodiesel/methanol purification), microscope (oil analysis), and spectrometer (fuel testing). Microscope and spectrometer are sandbox-gated.
- **Utility Recipes**: Cut plastic scrap and acid-wash electronics.
- **Dung Compost**: Animal dung as an alternative to compost bags for diluted compost production.
- **Heat Source System**: Metal drum recipes use charcoal, coke, or propane as fuel. Chemistry set recipes use propane tanks with degradation. All heat requirements are sandbox-gated (RequireHeatSources option).
- **Propane Partial Consumption**: OnCreate callback system returns partially-used propane tanks (~25 uses per full tank).
- **Impurity/Purity System**: modData-backed 0-100 purity scoring through recipe chains. Equipment factors, severity scaling, yield penalties, and player feedback via speech bubbles and tooltips. Gated by 3 sandbox options: EnableImpuritySystem, ImpuritySeverity, ShowPurityOnCraft.
- **Health Hazard System**: 10 hazardous recipes split into Protected (mask + goggles required) and Unprotected (risk of disease/stat penalties) twins (20 recipes total). Soft-depends on EHR (Extensive Health Rework) for disease dispatch with vanilla stat fallback. Gated by EnableHealthHazards sandbox option.
- **Loot Distributions**: Handbook, chemical reagents, and intermediate products distributed across appropriate container types (classrooms, pharmacies, hardware stores, farm supply, vehicles).
- **Foraging**: Calcite (year-round, all zones, Kentucky karst geology) and sulphur powder (seasonal, deep forest, skill 3).
- **MetalDrum Workstation Entity**: Entity-based workstation system for metal drum recipes. Drum is placed as furniture; players craft nearby via tag-based recipe binding.
- **Container Variants**: Mason jars (1L), clay jars (2.5L), buckets (10L), and gas cans (10L) for oils, fats, and biodiesel intermediates.
- **Fluid System**: 8 custom fluids with Build 42 FluidContainer integration, poison profiles, and blend whitelists.
- **Recipe Step Numbering**: All 132 recipe display names prefixed with pathway step numbers for clear crafting guidance.
- **Handbook**: In-game chemistry handbook (lootable) that teaches all 132 recipes with a coloured pathway guide.
- **132 recipes**, **34 items**, **8 fluids**, **7 sandbox options**, **122 OnCreate callbacks**.
