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

# Changelog (PhobosChemistryPathways)

All notable changes to this project will be documented in this file.

The format is based on Keep a Changelog, and this project follows Semantic Versioning.

## [1.6.0] - 2026-03-10

### Changed
- **PZ 42.15 translation migration** — Converted all 9 translation files from Lua `.txt` table format to flat JSON (`.json`). 895 keys across ContextMenu, Fluids, IG_UI, ItemName, Moodles, Recipes, Sandbox, Tooltip, and UI. Files renamed from `*_EN.txt` to `*.json`.
- **Minimum game version** bumped from 42.14.0 to **42.15.0**.
- Requires **PhobosLib 1.19.0+** (was 1.18.2+).
- CI: sandbox completeness check and encoding validation updated for JSON translation files.

## [1.5.2] - 2026-03-09

### Fixed
- **Filter degradation crash on crafting** — Safe-variant hazard recipes (methanol distillation, KOH synthesis, etc.) produced stack traces on every craft because `degradeFilterFromInputs` tried DrainableComboItem methods on Clothing-type gas masks. Fixed in PhobosLib 1.18.2 — now uses condition-based degradation.
- Requires **PhobosLib 1.18.2+** (was 1.18.1+)

## [1.5.1] - 2026-03-09

### Fixed
- **Server crash on startup** — `PCP_Distributions.lua` crashed with `RuntimeException: attempted index: items of non-table: null` when B42 distribution keys were missing. Fixed 4 invalid keys: `StoreCounterSmoke` → `StoreCounterTobacco`, `GardenStorageMisc` removed (duplicate), `RestaurantKitchen` → `RestaurantKitchenFridge`, `GroceryStoreSnacks` → `CafeteriaSnacks`. Added `BarShelfLiquor` for SimpleSugarSyrup (vanilla already stocks SimpleSyrup there).
- **Nil-guard helper** — All distribution inserts now use `dist()`/`vdist()` helpers that safely skip missing keys instead of crashing. Prevents future breakage if B42 renames or removes distribution tables.

## [1.5.0] - 2026-03-09

### Added
- **Dual-path chewing tobacco curing** — Prepare Chewing Tobacco Mix (tobacco + salt + sweetener + alkali + water), then fire-cure on a heat source (instant via ReplaceOnCooked) or seal in a jar for 14-day fermentation (ReplaceOnRotten).
- **4 new items** — ChewingTobaccoMixRaw, SealedChewingTobaccoJar, CuredChewingTobaccoJar, ChewingTobacco (20-use drainable with stress reduction).
- **4 chewing tobacco icons** generated via gpt-image-1 pipeline.
- **Custom ItemTag system** — 4 registered tags (pcp:protectivegloves, pcp:protectivegoggles, pcp:respirator, pcp:acidresistantvessel) replace 382 recipe OR-list inputs.
- **Pouch of Hemp** — HempLoose drainable integrated into pipe recipes via OR-list quantity override (1 bud OR 3 uses of pouch).
- **Vanilla tobacco integration** — TobaccoLoose integrated into all 6 PCP tobacco recipes via OR-list.
- **Farming spray tooltips** — Plain-English descriptions explaining crop problems and usage instructions on all 3 spray items.
- **4 Dynamic Trading sandbox toggles** — New PCP_DynamicTrading settings page with per-sub-category toggles for botanical trade items (Material, Medical, Survival, Literature). Soft dependency: no effect without Dynamic Trading installed.

### Changed
- 3 deprecated items: ChewingTobaccoTin, ChewingTobaccoWaterTin, ChewingTobaccoJar (save migration v1.5.0 converts to ChewingTobacco + teaches new recipes).
- `Base.Cork` input removed from all 67 lab recipes — aligns with ZVV which no longer uses cork stoppers. No save migration needed.
- Recipe count: 297 → **301**
- Item count: 112 → **121**
- Tradeable items: 67 → **76**
- Sandbox options: 52 → **66**
- ZScience specimens: 87 → **91**
- Save migrations: 8 → **9**
- Requires PhobosLib **1.18.1+** (was 1.18.0+)

### Fixed
- **Farming spray context menu** — Custom spray options now correctly appear in the "Treat Problem" submenu on diseased plants (fixed in PhobosLib 1.18.1).

## [1.4.0] - 2026-03-08

### Added
- **Medicated custom moodle** — Moodle Framework integration. Poultice and tincture medicinal items trigger a "Medicated" moodle with configurable duration via sandbox options. Soft dependency: functions gracefully when Moodle Framework is not installed.
- **Poultice and tincture timed actions** — Medicinal hemp items (poultice, tincture) now use ISTimedActionQueue with visual progress bar and audio feedback instead of instant application.
- **Hemp product effects system** — Doubled base effects for all hemp smoking items. Added effects to HempBudsDecarbed and SimpleSugarSyrup. All effects are individually tunable via sandbox options.
- **33 new sandbox options** on dedicated PCP_HempEffects settings page — Per-product stat tuning (Fatigue, Stress, Unhappy, Boredom, Pain) for pipes, cigars, cigarettes, decarbed buds, poultice, tincture, and sugar syrup. Includes moodle duration controls for poultice and tincture. Master toggle via EnableHempEffects.
- **EnableDebugLogging sandbox option** — Enables PhobosLib debug logging for PCP diagnostics.
- **Fermentation tooltip** — Dynamic curing progress percentage and remaining days displayed on CannedHempBuds via PhobosLib tooltip provider. Colour gradient from yellow (0%) to green (100%). Shows "Complete" when curing finishes.
- **Canning date stamp** — OnCreate callback on PCPCanHempBuds recipe stamps game date into item modData. Tooltip shows "Canned: Jul 12" in grey. Pre-existing items gracefully omit the date line.
- **Improved static tooltips** — CannedHempBuds tooltip now explicitly mentions ~4 week curing duration and clarifies that the freshness bar shows curing progress, not spoilage.

### Fixed
- **Cigar recipe ingredients** — Replaced cloth wrapper with tobacco leaves and sugar. Accept vanilla rolling papers as alternative.
- **Partial sugar consumption** — Changed from `item 1` (consumed entire bag) to `item 2` (partial consumption matching vanilla recipes).
- **Horticulture migration re-runnable** — Migration can now be triggered again after bug fixes via `unconsumeSandboxFlag()`.
- **RuntimeException in drainable migration** — Prevented exception from aborting entire conversion batch. Fixed notification field name mismatch.
- **Instanceof checks in migration** — Replaced pcall probing with instanceof checks for Horticulture migration item type detection.

### Changed
- Sandbox options: 19 → **52** (33 new on PCP_HempEffects page + EnableDebugLogging)
- Requires **PhobosLib 1.18.0+** (was 1.16.0+)
- Optional dependency: **Moodle Framework** (new soft dependency for Medicated moodle)

## [1.3.0] - 2026-03-07

### Added
- **Hemp Expansion** — 6 new items: Seed Press Cake, Hemp Sack, Oakum, Hemp Fishing Net, Hemp Sheet Rope, Hemp Snare.
- **Vanilla station integration** — Scutching Board for fiber extraction, Simple/Full Loom for weaving (oakum, sack), Hand Press for oil pressing with Seed Press Cake byproduct.
- **Mechanical hazard system** — Safe/Unsafe recipe variants for botanical processing (hurd charring, fiber extraction, cloth weaving, hempcrete mixing). Smoke inhalation and mineral dust exposure with light PPE tier (dust mask sufficient).
- **HempScutched acceptance** expanded across all fiber-consuming recipes.
- **Diversified skill requirements** — Farming, Tailoring, Fishing, and Trapping skills added to relevant botanical recipes alongside Applied Chemistry.
- **26 new ZScienceSkill specimens** — Horticulture items, salt products, and hemp expansion items registered for microscope research.
- **Expanded world loot distributions** — 13 additional B42 locations for new items.
- **Gas Mask Filter recipe cross-trains Doctor** — Activates Doctor XP mirroring via PhobosLib_Skill.
- **Art style guidelines** documented for icon contributors.
- **HempTincture FluidContainer conversion** — Converted from base:normal to B42 FluidContainer with save migration for pre-existing items.

### Changed
- **Mod renamed** — Display name changed from "Phobos' Chemistry Pathways" to "Phobos' Industrial Pathways: Biomass" as part of the Phobos' Industrial Pathways mod series. Internal mod ID and save data unchanged.
- Recipe count: 276 → **297**
- Item count: 101 → **112**
- Tradeable items: 59 → **67**
- ZScience specimens: 60 → **87**
- 15 non-conforming icons identified and regenerated via gpt-image-1

## [1.2.0] - 2026-03-06

### Added
- **Botanical Pathway** — 31 new recipes in `PCP_Recipes_Botanical.txt` covering hemp processing from raw stalks through chemical retting, fiber extraction, and downstream manufacturing:
  - **Retting & Extraction** (7 recipes): Chemical retting with KOH or NaOH, fiber/hurd splitting, seed threshing
  - **Textiles** (5 recipes): Spin twine, braid rope, weave cloth, layer canvas, tar rope with wood tar
  - **Papermaking** (5 recipes): Boil pulp, NaOH chemical pulping (+50% yield), press paper sheets
  - **Medicinal** (4 recipes): Herb-infused poultice, alcohol-extracted tincture
  - **Hurd Processing** (5 recipes): Char to charcoal (3 fuel variants), compost, fire bundles
  - **Cross-Pathway** (4 recipes): Sterilise hemp bandages, hempcrete (mixer), reinforced hempcrete (mixer, tarred rope), tarred rope
  - **1 mixer recipe** (PCPMixHempcrete): Hemp hurds + calcite in concrete mixer
  - **1 mixer recipe** (PCPMixReinforcedHempcrete): Hemp hurds + calcite + tarred hemp rope → 3 hempcrete blocks (vs 2 for standard)
- **29 horticulture recipes** in `PCP_Recipes_Horticulture.txt` — Tobacco processing (5), hemp bud curing/canning (8), papermaking (7), smoking (5), cooking (4)
- **13 botanical items** — RettedHempStalk, HempBastFiber, HempHurd, HempTwine, HempRope, TarredHempRope, HempCloth, HempCanvas, HempPulp, HempPaper, HempPoultice, HempTincture, HempcreteBlock
- **31 horticulture items** — Full parity with [B42] Horticulture mod:
  - **Tobacco** (4 items): TobaccoWet (air-dries naturally), ChewingTobacco in 3 container types (Tin, WaterTin, Jar)
  - **Hemp Buds** (9 items): Fresh, Cured, Decarbed buds; canned variants (sealed and open); ground HempLoose
  - **Papermaking** (5 items): PaperPulpPot (2 pot types), MouldAndDeckle, MouldAndDecklePaperSheet, RollingPapers
  - **Smoking** (10 items): Glass pipe, loaded pipes (wood/glass/can), hemp cigars, hemp cigarettes, cigarette packs, rolled tobacco cigars and cigarettes
  - **Cooking** (3 items): SaucepanSyrup (2 pot types), SimpleSugarSyrup
- **6 category recipe books** — Field Chemistry Primer, Kitchen Chemistry Companion, Laboratory Chemistry Reference, Industrial Processes Manual, Botanical Horticulture Guide, plus Complete Chemistry Compendium (master book teaching all recipes). Lootable, tradeable, and teachable via ZScience specimens.
- **Phobos Horticulture crafting category** — Dedicated crafting tab for all horticulture recipes (tobacco, hemp buds, papermaking, smoking, cooking)
- **Vanilla rope substitution** — HempRope tagged `base:rope` for vanilla recipe substitution (bags, tools, scarecrow, etc.); TarredHempRope tagged `base:rope` + fire fuel tags (`FireFuelRatio = 0.5`)
- **Horticulture migration system** — Dual-trigger migration converts [B42] Horticulture mod items to PCP equivalents:
  - **Manual trigger**: MigrateHorticultureItems sandbox button (PCP_Reset page) — proactive, works while Horticulture is still subscribed
  - **Automatic trigger**: Detects orphaned Horticulture items after mod unsubscription and converts them automatically on game load
  - Preserves UsedDelta, age, condition, and wet state during conversion
  - 38 item mappings from `Base.*` to `PhobosChemistryPathways.*`
- **MigrateHorticultureItems sandbox option** — One-shot migration button on PCP_Reset settings page
- **EnableBotanicalPathway sandbox option** — Master switch for botanical/horticulture recipes (default: true)
- **SkillPurityInfluence sandbox option** — Controls Applied Chemistry skill effect on purity (None/Low/Standard/High, default: Standard)
- **24 OpenAI-generated icons** — 6 regenerated chemistry icons + 13 botanical pathway icons + 5 category recipe book icons

### Fixed
- **CTD: Invalid item references in botanical recipes** — `Base.SodiumHydroxide` replaced with `LabItems.ChSodiumHydroxideBag` (4 occurrences); `Base.AlcoholBandages` replaced with `Base.AlcoholBandage` (4 occurrences); `Base.WhiskeyFull` and `Base.WhiskeyHalf` replaced with `Base.Whiskey` (4 occurrences)
- **41 missing recipe translations** — Added display names for all 29 horticulture recipes and 12 hazard protection variants (hemp retting + chemical pulping Safe/Unsafe)
- **Crafting category display** — Renamed camelCase categories (PhobosFieldChem, PhobosLabChem, etc.) to human-readable spaced names (Phobos Field Chem, Phobos Lab Chem, etc.) for clean UI display

### Changed
- **Mod renamed** from "Phobos' Chemistry Pathways" to "Phobos' Industrial Pathways: Biomass". Display-name-only change — internal mod ID (`PhobosChemistryPathways`), PCP prefix, and all save data remain unchanged. Part of the new Phobos' Industrial Pathways mod series.
- **EnableImpuritySystem default changed to TRUE** — Was false; one-time migration popup auto-enables for existing worlds and notifies admins
- Recipe count: 204 → **276** (31 botanical + 29 horticulture + 12 hazard variants added)
- Item count: 47 → **101** (13 botanical + 31 horticulture + 5 recipe books + 5 skill books already counted)
- Tradeable item count: 34 → **59** (botanical/horticulture items + recipe books)
- ZScience specimen count: 33 → **52** items (botanical items + recipe books)
- OnCreate callback count: 168 → **216**
- Sandbox option count: 17 → **19** (EnableBotanicalPathway, MigrateHorticultureItems added; SkillPurityInfluence added in v1.1.0)
- Crafting categories: 4 → **5** + mixer (added Phobos Horticulture)
- Requires **PhobosLib 1.16.0+** (getSkillBonus, randomBaseQualityWithSkill, isPlayerAdmin, registerNoticePopup)

### Summary
- **276 recipes**, **101 items**, **59 tradeable items**, **6 recipe books**, **5 skill books**, **9 fluids**, **19 sandbox options**, **216 OnCreate callbacks**
- 10 pathways: Blackpowder, Biodiesel, Fat Rendering, Soap, Bone Char, Salt Extraction, Recycling, Agriculture, Concrete Mixer, Botanical
- 6 crafting categories: Phobos Field Chem, Phobos Kitchen Chem, Phobos Lab Chem, Phobos Industrial Chem, Phobos Horticulture, + Concrete Mixer
- Hard deps: PhobosLib 1.16.0+, Zombie Virus Vaccine
- Soft deps: ZScienceSkill, EHR, Dynamic Trading, Neat Crafting

## [1.1.0] - 2026-03-06

### Added
- **SkillPurityInfluence sandbox option** — Controls how much the Applied Chemistry skill affects output purity (None/Low/Standard/High enum, default: Standard)
- **Impurity default migration** — One-time notice popup auto-enables EnableImpuritySystem for existing worlds (was default false, now default true) and notifies admins

### Changed
- **EnableImpuritySystem default = true** (was false)
- Requires **PhobosLib 1.16.0+** (getSkillBonus, randomBaseQualityWithSkill, isPlayerAdmin, registerNoticePopup)

## [1.0.0] - 2026-03-05

### BREAKING
- **Hard dependency changed: zReVaccin 3 replaced by Zombie Virus Vaccine (ZVV)** — PCP now requires `ZVirusVaccine42BETA` instead of `zReModVaccin30bykERHUS`. All 474 code references to zReVaccin module IDs, entity tags, and item types updated across 18 files. Players must subscribe to [Zombie Virus Vaccine](https://steamcommunity.com/sharedfiles/filedetails/?id=3615135168) and can unsubscribe from zReVaccin 3.

### Added
- **v1.0.0 save migration** — Automatically converts orphaned `zReLabItems` items (from zReVaccin) to their ZVV or vanilla equivalents on first load. Preserves condition (purity) and fluid contents. Covers LabFlask, LabFlaskDirty, ChSodiumHydroxideBag, ChSulfuricAcidCan (mapped to `LabItems.*`), LabCorks (mapped to `Base.Cork`), and lab gloves (mapped to `Base.Gloves_Surgical`). Unknown zReLabItems are safely removed. Uses PhobosLib's deep inventory scanner for backpacks and bags.

### Changed
- Entity tags in all recipe files migrated from `zReVAC2:*` to `ZVirusVaccine42BETA:*` (ChemistrySet, ChemistryCentrifuge, ChemistryChromatograph, Microscope, Spectrometer)
- Timed action references migrated from `zReVAC2TimedActionChem1` to `MixingChm`/`MixingB`
- Requires **PhobosLib 1.15.0+** and **Zombie Virus Vaccine** (ZVirusVaccine42BETA)

### Summary
- **204 recipes**, **47 items**, **34 tradeable items**, **5 skill books**, **9 fluids**, **16 sandbox options**, **168 OnCreate callbacks**
- 9 pathways: Blackpowder, Biodiesel, Fat Rendering, Soap, Bone Char, Salt Extraction, Recycling, Agriculture, Concrete Mixer
- Hard deps: PhobosLib 1.15.0+, Zombie Virus Vaccine
- Soft deps: ZScienceSkill, EHR, Dynamic Trading, Neat Crafting

## [0.26.0] - 2026-03-05

### Fixed
- **`hotFluidContainer` checked wrong item** — `RecipeCodeOnTest.hotFluidContainer` (Java-side, unmodifiable) checks whether the `-fluid` source item is hot. PCP's two-item pattern separated the water source (`[*]`) from the heated vessel (`tags[base:cookable]`), causing `hotFluidContainer` to check the water source (e.g. a cold petrol can) instead of the hot pot on the stove. Containers that cannot be placed on stoves (petrol cans, jars, bottles) failed as water sources even when a hot pot was present. 23 recipes across 5 files now use a merged single-item pattern matching vanilla DisinfectBandage:
  - 16 `tags[base:cookable]` recipes: merged to `[*] mode:keep` + `-fluid` — the container on the stove provides both water and heat
  - 7 `[Base.Pot]` recipes: `-fluid` binds directly to the pot — the pot on the stove provides both water and heat
- **Empty FluidContainer showed "(Worn)"** — Drained FluidContainers retained purity-stamped condition (e.g. condition 80 of max 100), causing PZ to display the "(Worn)" suffix on empty containers. Now registers with PhobosLib's `registerEmptyConditionReset()` to restore condition to ConditionMax when fluid amount drops to zero.

### Changed
- Requires **PhobosLib 1.15.0+** (empty condition reset API)

## [0.25.0] - 2026-03-05

### Added
- **Salt Extraction Pathway** — 6 new recipes: collect brine from water wells via right-click context menu (PhobosLib_WorldAction), concentrate brine (2 tiers: cooking pot and chemistry set), crystallize salt (2 tiers), purify table salt. Generic FluidContainer filling with condition-based purity and MP sync.
- **Entity Rebinding** — Pre-existing concrete mixer workstations are automatically re-bound to updated entity scripts on game load via PhobosLib_EntityRebind.
- **4 new items** (47 total) — Brine (FluidContainer), ConcentratedBrine (FluidContainer), RockSalt, TableSalt
- **1 new fluid** — Brine (9 fluids total)

### Changed
- **B42 Native Fluid Syntax** — All 133 FluidContainer recipe inputs converted from legacy item-based syntax to B42's native `-fluid` (drain) and `+fluid` (fill) syntax across all recipe files. Recipes now use `InHandCraft;Cooking` tags for proper player inventory routing of filled containers.
- Recipe count: 198 → **204** (6 salt recipes added)
- Item count: 43 → **47** (4 salt items added)
- Fluid count: 8 → **9** (Brine added)
- Requires **PhobosLib 1.14.0+** (WorldAction, EntityRebind, fluid utilities)

### Fixed
- **Fluid recipe output routing** — Recipes using `+fluid` outputs now correctly place filled containers in the player's inventory instead of the world/ground inventory. Changed from `AnySurfaceCraft` → `InHandCraft;Cooking` tags (matching SapphCookingB42's proven pattern).
- **FluidCategory enum error** — Removed custom `Triglyceride` FluidCategory that caused all PCP fluids to fail registration.
- **`-fluid` input ordering** — Reordered `-fluid` inputs to satisfy B42's "preceding item must have amount 1" constraint. Added `item 1 [*]` container lines before every `-fluid` input.
- **Base.GasCan removal** — Removed non-existent `Base.GasCan` from gas can container lists (B42 only has `Base.PetrolCan`).
- **Brine collection MP sync** — Added missing `stopSound()` and `sendItemStats()` calls for multiplayer synchronization.
- **CraftBench entity definitions** — Added missing xuiSkin definitions, CraftLogic component, and all 4 rotation sprites for concrete mixer entity.
- **Entity file comment syntax** — Converted Lua-style comments to C-style block comments in entity files.
- **Context menu translation** — Moved ContextMenu key to correct `UI_EN` translation namespace.

## [0.24.0] - 2026-02-23

### Added
- **In-game Welcome Guide** (`PCP_GuidePopup.lua`, client/) — First-time tutorial popup explaining PCP's chemistry pathways, sandbox options, and getting started. Uses PhobosLib's `registerGuidePopup()` API with "Don't show again" checkbox. ISRichTextPanel with scrollable content. Per-character persistence via player modData.
- **In-game Changelog** (`PCP_ChangelogPopup.lua`, client/) — Version-based "What's New" popup that appears on major.minor version bumps. Uses PhobosLib's `registerChangelogPopup()` API with lastSeenVersion filtering to show only relevant changes. "Got it!" dismiss button.

### Fixed
- **Invalid `base:smallblade` tag** — Replaced with `base:sharpknife;base:scissors` in PCPCutPlasticScrap. `base:smallblade` is a weapon Category, not an ItemTag; using it in `tags[]` causes NPE CTD at `InputScript.OnPostWorldDictionaryInit`.
- **MineralFeedSupplement ConditionMax** — Corrected from 1 to 100 to match other PCP items.
- **Workstation translation keys** — Added `IGUI_CraftingWindow_*` translation entries for `PCP_ConcreteMixer` and renamed CraftBench tags for consistency.
- **Guide popup colour tag spacing** — Rewrote guide popup to eliminate inline colour tag spacing bug caused by `<RGB>` tag whitespace handling in ISRichTextPanel.
- **Mixer recipe -fluid input ordering** — Reordered -fluid inputs in mixer recipes to satisfy B42 "previous input must have item amount 1" constraint. Fixed changelog version filtering.
- **Invalid item IDs in mixer recipes** — Corrected `Base.Blackpowder` and `Base.WoodVinegar` to valid B42 item IDs in mixer recipe outputs.
- **FluidContainer -fluid binding cascade** — Fixed 4 cascading CTDs caused by B42 -fluid input rules discovered empirically:
  - `item 1 [*]` wildcards greedily match FluidContainer items, stealing them from designated input slots
  - Category A (13 hotFluidContainer recipes): replaced `[*]` with `tags[base:cookable] mode:keep`
  - Category B (all other recipes): restored `item 1 [*]` as the fluid container for `-fluid`
  - B42 rules: -fluid cannot be first input; preceding item must have amount 1; preceding item IS the container -fluid drains from

### Changed
- Requires **PhobosLib 1.13.0+** (PhobosLib_Popup module)

## [0.23.0] - 2026-02-23

### Added
- **Concrete Mixer Workstation** — Powered CraftBench entity (`PCP_Entities_ConcreteMixer.txt`) with 13 new recipes in `PCP_Recipes_Mixer.txt`. New `PhobosIndustrialChem` crafting category. Requires electricity (grid, generator, or custom power source) via PhobosLib_Power module.
  - **Construction** (6 recipes): PCPMixConcrete, PCPMixClayCement, PCPMixMortar, PCPMixStucco, PCPMixReinforcedConcrete, PCPMixFireclay
  - **Bulk Chemistry** (5 recipes): PCPMixBlackpowderBulk, PCPMixBiodieselOil, PCPMixSoap, PCPMixCompost, PCPMixWoodVinegar
  - **Processing** (1 recipe): PCPMixPlaster
  - **Fabrication** (1 recipe): PCPBuildConcreteMixer (Metalworking:4, requires BlowTorch + WeldingMask + WeldingRods)
- **`PCP_MixerCompat.lua`** (client/) — Registers `PCP_ConcreteMixer` entity with PhobosLib's `registerPoweredCraftBench()` API. Craft button greyed out with tooltip when no power available. Generator fuel drain during crafting.
- **4 new items** (43 total) — MortarMix, StuccoMix, ReinforcedConcrete, Fireclay
- **3 new sandbox options** (16 total):
  - `EnableConcreteMixer` — Enable/disable concrete mixer workstation
  - `ConcreteMixerYieldBonus` — Output yield multiplier for mixer recipes
  - `MixerFuelDrainRate` — Generator fuel drain rate during mixer crafting

### Changed
- Requires **PhobosLib 1.12.0+** (PhobosLib_Power module)
- Recipe count: 185 → 198

### Summary
- **198 recipes**, **43 items**, **34 tradeable items**, **5 skill books**, **8 fluids**, **16 sandbox options**, **168 OnCreate callbacks**

## [0.22.0] - 2026-02-22

### Added
- **Agriculture & Downstream Recipes** — 31 new recipes in `PCP_Recipes_Agriculture.txt` connecting PCP intermediates to vanilla gameplay systems across 6 pathways:
  - **Pathway C: Garden Pest Sprays** (3 recipes) — SulphurFungicideSpray (cures Mildew), InsecticidalSoapSpray (cures Aphids), PotashFoliarSpray (cures Flies). Functional B42 gardening sprays via PhobosLib's `registerFarmingSpray()` API.
  - **Pathway A: Mineral Feed Supplement** (3 recipes) — BoneChar + Calcite feed supplements for animal husbandry.
  - **Pathway B: Water Purification & Filtration** (4 recipes) — Activated charcoal filters, water purification tablets, gas mask filter recharging.
  - **Pathway D: Epoxy Resin Synthesis** (6 recipes) — Epoxy resin from WoodTar + Glycerol for structural crafting.
  - **Pathway E: Vanilla Quick Wins** (7 recipes) — Fire starters, lighter fluid, slug repellent, duct tape, matchboxes from PCP intermediates.
  - **Pathway F: Vanilla Moderate** (8 recipes) — Wood vinegar, chemical leather tanning, plaster powder.
- **3 new FluidContainer items** — SulphurFungicideSpray, InsecticidalSoapSpray, PotashFoliarSpray (gardening sprays with ConditionMax=100)
- **`PCP_FarmingCompat.lua`** (client/) — Registers 3 PCP sprays + vanilla SlugRepellent with PhobosLib's farming spray API so they appear in the "Treat Problem" submenu and respond to the Interact hotkey on diseased plants.
- **7 new DT tradeable items** (34 total) — WoodTar and agriculture pathway outputs added to Dynamic Trading vendor stock.
- **Pneumonia** added to `caustic_vapor` and `resin_fumes` hazard profiles as a rare severe disease outcome.

### Fixed
- **`pcpMakeMatchboxYield` callback** — Matchbox recipe now returns correct output quantities.
- **`pcpChemicalTanningYield` callback** — Chemical tanning recipe now returns correct leather output.

### Changed
- Requires **PhobosLib 1.11.0+** (PhobosLib_FarmingSpray module)
- Recipe count: 154 → 185

### Summary
- **185 recipes**, **39 items**, **34 tradeable items**, **5 skill books**, **8 fluids**, **13 sandbox options**, **144 OnCreate callbacks**

## [0.21.3] - 2026-02-21

### Changed
- **Dynamic Trading prices rebalanced** — All 22 non-book item prices anchored to vanilla DT basePrices (Charcoal=15, CarBattery1=80, OilVegetable=15, Lard=10, Limestone=10, Soap2=12) and scaled upward through each chain step (~1.5-2× per processing step). Key increases: SulphuricAcidJar 35→80, KNO3 25→60, SulphurPowder 15→45, biodiesel chain 25/40/80→55/80/120, WoodMethanol 20→40, Glycerol 10→25. Stock ranges tightened on high-value items. Skill books unchanged.

## [0.21.2] - 2026-02-21

### Fixed
- **Purity not visible immediately after crafting** — `setPurity()` and `stampOutputs()` called `setCondition()` server-side but never synced to the client via `sendItemStats()`. The inventory UI only learned about the changed condition on the next automatic sync cycle, causing a long visible delay before purity appeared on crafted items. Now calls `pcall(sendItemStats, item)` after each `setCondition()`, matching the pattern used by PhobosLib_LazyStamp and PhobosLib_VesselReplace.

## [0.21.1] - 2026-02-21

### Fixed
- **Cooking-pot recipes craftable cold** — The `Cooking` tag in `Tags = AnySurfaceCraft;Cooking` is purely cosmetic in B42 — it has zero functional heat enforcement. All 19 PhobosKitchenChem cooking-pot recipes could be crafted cold with no heat source. Now uses vanilla heat-gating patterns:
  - 12 wet-heat recipes (water-as-reagent: charcoal purification, KNO3 synthesis, fat-from-meat rendering, biodiesel washing, soap-making, bandage sterilisation) use `OnTest = RecipeCodeOnTest.hotFluidContainer` — player must heat the pot on a stove first. Tooltip: "Water container needs to be very hot."
  - 7 dry-heat recipes (oil pressing, fat melting) use `OnTest = RecipeCodeOnTest.openFire` — player must stand near a burning campfire, fireplace, or stove. Tooltip: open fire indicator.
  - All 19 recipes: `AnySurfaceCraft;Cooking` → `InHandCraft;CanBeDoneFromFloor;CannotBeResearched`, `Making_Surface` → `Making`.
- **Purity crash on vanilla-output recipes** — Recycling recipes outputting vanilla items (`Base.Fertilizer`, `Base.Soap2`, `Base.Glue`, etc.) crashed with "Object tried to call nil" when purity callbacks called `setPurity()` on items that don't support condition-as-purity. Hardened `_stampAndAnnounce` with module-prefix guard; deleted 10 dead purity-only callbacks; rewrote R7 MeltPlasticGlue Safe/Unsafe as hazard-only; removed OnCreate from 11 vanilla-output recycling recipes.

## [0.21.0] - 2026-02-20

### Added
- **Empty vessel replacement** (`PCP_VesselReplacement.lua`, client/) — Registers 20 FluidContainer→vessel mappings with PhobosLib. When a player opens a container, empty PCP FluidContainers are automatically replaced with their vanilla vessel equivalents (EmptyJar, EmptyPetrolCan, Bucket, etc.). 6 jar-type mappings return both `Base.EmptyJar` and `Base.JarLid` as bonus. Gated by `PCP.EnableVesselReplacement` sandbox option (default: true).
- **Vanilla JarLid override** (`PCP_VanillaOverrides.txt`) — Overrides `Base.JarLid` ConditionMax from 10 → 100 so condition values directly match `Base.EmptyJar`.
- **`EnableVesselReplacement` sandbox option** (13 total) — Server admins can disable vessel replacement if experiencing MP sync issues. Tooltip documents jar lid return, empty-only replacement, and MP sync considerations.

### Changed
- Requires **PhobosLib 1.10.0+** (PhobosLib_VesselReplace module)

## [0.20.0] - 2026-02-20

### Fixed
- **FluidContainer purity broken** — FluidContainer items (acids, oils, fats, biodiesel, glycerol, methanol, tar) defaulted to `ConditionMax = 10` in PZ B42 (not 100 as assumed). With condition 3 out of max 10, purity displayed as 30% instead of the correct value. All 20 FluidContainer items now have explicit `ConditionMax = 100` in item scripts.
- **Purity system normalised for any ConditionMax** — All condition-purity conversions (`getPurity`, `setPurity`, `averageInputPurity`, `stampOutputs`, tooltip display, DT stamp, lazy stamper) now normalise to 0-100% using `condition / maxCond * 100` for reads and `value / 100 * maxCond` for writes. System is now resilient regardless of item ConditionMax.
- **DT stamp scaling** — `PCP_DynamicTradingStamp.lua` now scales the 99% stamp value to the item's ConditionMax instead of setting raw condition 99.
- **Tooltip diagnostic logging removed** — Cleaned up debug print statements from `PCP_PurityTooltip.lua`.

### Added
- **v0.20.0 save migration** — Rescales condition values on 20 FluidContainer items from the old max-10 range to the new max-100 range (e.g. condition 3 to 30). Uses a static set of known FluidContainer fullTypes for identification.
- **Explicit ConditionMax on all items** — All 33 PCP items (20 FluidContainer + 13 solid) now declare `ConditionMax = 100` in their item scripts, ensuring consistent purity behaviour regardless of PZ defaults.

### Changed
- Requires **PhobosLib 1.9.1+** (LazyStamp ConditionMax scaling fix)

## [0.19.1] - 2026-02-20

### Fixed
- **Skill books not readable** — Applied Chemistry Vol 1-5 could not be read (no "Read" context menu option). Root cause: missing `SkillBook["AppliedChemistry"]` registration, compounded by load-order issue (`shared/` loads before vanilla resets `SkillBook = {}`). Moved `PCP_SkillBookData.lua` to `server/` so registration persists after vanilla's table init.
- **DT Radio panel showing "PCP_Chemist"** — Traders spawned before v0.19.0 had the old archetype ID baked into DT save data. Save-data migration patches `trader.archetype` from `"PCP_Chemist"` to `"Chemist"`. Idempotent; skips gracefully when DynamicTrading is not installed.
- **DT-purchased items had no purity label** — DT's condition logic skips FluidContainers and books. Expert items arrive at 100% condition, hidden as "unstamped". Monkey-patches `DynamicTrading.ServerHelpers.AddItemWithCondition` to stamp condition 99 (Lab-Grade) on PCP items at ConditionMax.
- **Raw RGB tags in item tooltips** — `<RGB:r,g,b>` tags in `Tooltip_EN.txt` appeared as literal text because Java `ObjectTooltip` doesn't parse them. Removed all `<RGB>` tags from 4 tooltip entries. Hazard warnings now use plain `WARNING:` prefix.
- **Purity tooltip not showing** — Rewrote `PCP_PurityTooltip.lua` using new `PhobosLib.registerTooltipProvider()` API which uses a full render replacement to draw coloured text below the vanilla tooltip. Purity line now appears for all stamped PCP items (e.g. "Purity: Lab-Grade (99%)").
- **Migration only scanned main inventory** — Previous migration used `player:getInventory():getItems()` which only covers the main 40-slot inventory. Now uses `PhobosLib.iterateInventoryDeep()` to recurse into worn backpacks and bags.
- **Migration/reset notifications use ISModalRichText modal** — Was ephemeral HaloText, invisible during game start when UI hasn't fully loaded.

### Added
- **Chemist archetype dialogue for Dynamic Trading** — 6 dialogue types with chemistry-themed lines registered via `DynamicTrading.RegisterDialogue()`.
- **`PCP_DynamicTradingStamp.lua`** — Server-side monkey-patch for ongoing DT purity stamping on future purchases.
- **Purity migration (v0.19.1)** — One-time migration stamps all existing PCP items at condition 100 to 99 (Lab-Grade), renames DT traders, and deep-scans backpacks/bags. Covers DT purchases, loot, and expert items.
- **Lazy container purity stamper** — PCP items in safehouse containers, vehicle trunks, and other world containers are now stamped when the player first opens them. Uses new `PhobosLib.registerLazyConditionStamp()` API.
- **Copyright headers** on all source files (dragon cat ASCII art)
- Requires **PhobosLib >= 1.9.0** (tooltip, lazy stamper, and migration APIs)

## [0.19.0] - 2026-02-20

### Added
- **Multi-vendor Dynamic Trading integration** — PCP items now appear at 8 existing DT vendor archetypes via Chemical allocation injection:
  - Pharmacist (+2): acids, KOH, soap
  - Survivalist (+2): charcoal, bone char
  - Herbalist (+2): oils, rendered fat, glycerol
  - Farmer (+2): potash, calcite, compost
  - Doctor (+1), Brewer (+1), Smuggler (+1), General (+1)
- **4 new tradeable items** — CrushedCharcoal, DilutedCompost, PlasticScrap, AcidWashedElectronics (27 total)
- **Per-vendor DT tags** — Items tagged with Medical, Survival, Farming, Herb, Alcohol, Fuel for targeted vendor stock
- **Chemist expertTags** — Chemist vendor guarantees 100% condition on Chemical-tagged items
- **v0.19.0 save migration** — Converts legacy `modData["PCP_Purity"]` to item condition; removes old modData key

### Changed
- **Purity system rewritten** — Purity now stored as item condition (`ConditionMax = 100`), replacing `modData["PCP_Purity"]`. Condition maps 1:1 to purity (condition 80 = purity 80%). No scaling math needed
- **13 solid items gain ConditionMax = 100** — CrushedCharcoal, PurifiedCharcoal, BoneChar, Potash, DilutedCompost, LeadScrap, PlasticScrap, AcidWashedElectronics, SulphurPowder, PotassiumNitratePowder, PotassiumHydroxide, Calcite, CrudeSoap
- **DT archetype ID fixed** — `"PCP_Chemist"` renamed to `"Chemist"`, fixing the "Find a PCP_Chemist" UI bug in DT V1
- **Tooltip reads condition** — PCP_PurityTooltip.lua reads item condition directly instead of modData
- **DT purchased items have meaningful quality** — Items bought from vendors arrive with 20-100% condition (= purity). Any vendor can roll up to 100%

### Summary
- **154 recipes**, **39 items**, **27 tradeable items** (was 23), **5 skill books**, **8 fluids**, **12 sandbox options**, **144 OnCreate callbacks**

## [0.18.0] - 2026-02-20

### Added
- **12 cooking-pot alternative recipes** — Low-heat ChemistrySet operations (charcoal purification, KNO3 synthesis, oil extraction, fat rendering, biodiesel washing) can now be performed with a cooking pot on a stove. Lower purity than lab versions but no chemistry set required. All use `AnySurfaceCraft;Cooking` tags
  - `PCPPurifyCharcoalWaterPot`, `PCPPurifyCharcoalNaOHPot` (purity 60-80)
  - `PCPSynthesizeKNO3FertilizerPot` (purity 35-55), `PCPSynthesizeKNO3CompostPot` (purity 30-50)
  - `PCPPressOil{Soybeans,Sunflower,Corn,Flax,Hemp,Peanut}LabPot` (purity 40-60)
  - `PCPRenderFatPot` (purity 30-50), `PCPWashBiodieselPot` (purity 35-55)
- **Migration system** (`PCP_MigrationSystem.lua`, `PCP_MigrateNotify.lua`) — Existing saves automatically teach pot-alternative and surviving soap recipes to players who knew the corresponding lab or deleted variants. Uses PhobosLib_Migrate framework with world modData guards
- **`PCPRenderFatPot` added to Chemist profession** granted recipes

### Changed
- **Category split**: Single `PhobosChemistry` crafting category replaced by 3 equipment-based categories:
  - **Phobos' Lab Chemistry** (72 recipes) — ChemistrySet, Centrifuge, Chromatograph, Microscope, Spectrometer
  - **Phobos' Kitchen Chemistry** (19 recipes) — Cooking pot on stove (`AnySurfaceCraft;Cooking`)
  - **Phobos' Field Chemistry** (63 recipes) — Mortar, kiln, furnace, metal drum, hand-craft
- **Soap recipes collapsed** (16 → 4) — Fuel variants (Charcoal/Coke/Propane/Simple) removed; 4 surviving base recipes (`PCPMakeSoap`, `PCPMakeSoapNaOH`, `PCPMakeSoapFat`, `PCPMakeSoapFatNaOH`) converted to cooking-pot Kitchen recipes. Soap no longer requires explicit fuel or chemistry set
- **Bandage sterilization converted** — `PCPSterilizeBandageRipped` and `PCPSterilizeBandage` moved from ChemistrySet to cooking-pot Kitchen category
- Requires **PhobosLib 1.8.0+** (PhobosLib_Migrate framework)

### Removed
- 12 soap fuel-variant recipes (Coke, Propane, Simple for each of 4 soap bases)
- 16 soap recipe filter entries (no longer sandbox-gated)

### Summary
- **154 recipes** (net zero: +12 pot, -12 soap), **39 items**, **5 skill books**, **8 fluids**, **12 sandbox options**, **144 OnCreate callbacks**

## [0.17.1] - 2026-02-20

### Fixed
- **PCPRenderFatFromMeat missing from handbook** — Recipe was not listed in `BkChemistryPathways` LearnedRecipes, so reading the Chemistry Pathways Handbook would not teach it. Added to the Fat Rendering group.
- **PCPRenderFatFromMeat missing translation** — No `Recipe_PCPRenderFatFromMeat` entry in `Recipes_EN.txt`, causing the crafting menu to display the raw recipe key instead of "1. Render Fat from Meat".

### Changed
- Requires **PhobosLib 1.7.1+** (fluid validation API fix)

## [0.17.0] - 2026-02-20

### Added
- **Fat rendering from meat** (`PCPRenderFatFromMeat`) — Slow-cook 6 butchered meat cuts in a cooking pot with water to produce 2 jars of RenderedFat + 2 SmallAnimalBone. Accepts 21 meat item types (all butcherable cuts, whole poultry, and packaged meat). Uses `AnySurfaceCraft;Cooking` tags — no chemistry set or fuel required. Provides a renewable source of fat from animal husbandry for the biodiesel and soap chains.
- **Recipe variants guide** (`docs/diagrams/recipe-variants.md`) — Newcomer-friendly guide explaining why PCP recipes have multiple versions, naming conventions (Simple, Safe, Unsafe, etc.), sandbox gating, and troubleshooting.

### Fixed
- **Mojibake in biodiesel recipe comments** — Replaced 26 corrupted multi-byte UTF-8 sequences (triple-encoded em-dashes, smart quotes) with clean ASCII equivalents in `PCP_Recipes_Biodiesel.txt`
- **Stale recipe overview diagram** — Added MEAT and WOOD input nodes; corrected methanol pathway (WOOD→METHANOL, charcoal as byproduct instead of feedstock)
- **Stale counts across documentation** — Updated recipe count (153→154), callback count (135→138), pathway count (6→7) in all docs, diagrams, and mod.info files

### Changed
- Recipe count: 153 → 154

## [0.16.3] - 2026-02-20

### Fixed
- **Methanol distillation feedstock** -- All 8 methanol-producing recipes (6 chemistry set + 2 chromatograph) now require raw wood (`Base.Plank` or `Base.Firewood`) instead of charcoal as input, matching real-world destructive distillation chemistry. Charcoal (`Base.Charcoal` x2) added as output byproduct alongside methanol and tar. Updated recipe comments and item description comments.

## [0.16.2] - 2026-02-19

### Fixed
- **R9 Tar-Pitch Torch world-load crash (continued)** — `Base.DirtyRag` and `Base.Rag` do not exist in Build 42; replaced with `Base.RippedSheets;Base.RippedSheetsDirty` to match vanilla item registry

## [0.16.1] - 2026-02-19

### Fixed
- **R9 Tar-Pitch Torch world-load crash** — `Base.TreeBranch` does not exist in Build 42; replaced with `Base.TreeBranch2;Base.WoodenStick2` to match vanilla recipe conventions

## [0.16.0] - 2026-02-19

### Added
- **R3b: Sulphur-Enhanced Fertilizer** (`PCPCalciteFertilizerSulphur`) — 3 Calcite + 1 Sulphur + 1 Diluted Compost + water → 3 Fertilizer. Sulphur improves nutrient uptake; +50% yield over R3. Requires AC:2, auto-learns at AC:4
- **R3c: Potash Fertilizer** (`PCPPotashFertilizer`) — 3 Potash + 1 Diluted Compost + water → 2 Fertilizer. Bypasses Calcite requirement for players without lab equipment. Requires AC:1, auto-learns at AC:2
- **R9: Tar-Pitch Torch** (`PCPMakeTarTorch`) — 1 Wood Tar + 1 Tree Branch + 1 cloth → 2 Torch. Second downstream use for Wood Tar (alongside R1 wood glue). Requires AC:1, auto-learns at AC:1
- **Dynamic Trading integration** (`PCP_DynamicTradingData.lua`) — When Dynamic Trading mod is installed, registers 23 PCP items for NPC trading via PhobosLib_Trading wrapper, including a custom "Chemical" tag and "PCP_Chemist" trader archetype. All registrations are no-ops when DT is absent
- All 3 new recipes added to handbook (`BkChemistryPathways`) LearnedRecipes
- Purity callbacks for all 3 new recipes (R3b: source 35-55, R3c: source 30-50, R9: source 40-60)

### Changed
- Requires **PhobosLib 1.7.0+** (PhobosLib_Trading module)
- Recipe count: 150 → 153

## [0.15.0] - 2026-02-19

### Fixed
- **Recipe sandbox gating with Neat Crafting** — Neat Crafting mod completely replaces the vanilla crafting window (`ISEntityUI.OpenHandcraftWindow()` → `NC_HandcraftWindow`), so the vanilla `ISRecipeScrollingListBox:addGroup()` override was never called. PhobosLib 1.6.0 now hooks `NC_FilterBar:shouldIncludeRecipe()` for Neat Crafting compatibility alongside the existing vanilla UI overrides. All 121 recipe filters now work correctly in both vanilla and Neat Crafting crafting windows.

### Changed
- Requires **PhobosLib 1.6.0+** (Neat Crafting recipe filter compatibility)

## [0.14.1] - 2026-02-19

### Fixed
- **Profession/trait translations** — Moved `UI_prof_*`, `UI_profdesc_*`, `UI_trait_*` keys from `IG_UI_EN.txt` to new `UI_EN.txt`. PZ B42 resolves character creation UI keys from the `UI_EN` translation table, not `IGUI_EN`. Raw keys were showing instead of display names.

### Added
- **Profession placeholder icons** — Replaced identical powder-pile textures with proper 64×64 profession icons (flask for Chemist, mortar & pestle for Pharmacist) in `media/textures/`
- **Trait placeholder icons** — Added 24×24 trait icons in new `media/ui/Traits/` directory: blue star (Chemist profession trait), green plus (Chemistry Enthusiast), red minus (Chemical Aversion)

### Changed
- Requires **PhobosLib 1.5.1+** (recipe filter load-order fix)

## [0.14.0] - 2026-02-19

### Fixed
- **Recipe sandbox gating (definitive fix)** — B42 `craftRecipe` `OnTest` is a **server-side execution gate**, NOT a UI visibility gate. `getOnAddToMenu()` returns nil for ALL craftRecipe objects (including vanilla). Previous versions (0.13.1-0.13.4) incorrectly assumed OnTest controlled crafting menu visibility. Fix: client-side UI override via `PhobosLib.registerRecipeFilter()` that injects filter checks into `ISRecipeScrollingListBox:addGroup()` and `ISTiledIconPanel:setDataList()`

### Added
- **`PCP_RecipeFilter.lua`** (client/) — Registers 121 recipe visibility filters for 3 sandbox gates:
  - `RequireHeatSources` — 56 heated + 30 simplified variants
  - `EnableHealthHazards` — 6 hazard-enabled + 3 no-hazard originals + 20 combined heat/hazard variants
  - `EnableAdvancedLabRecipes` — 2 microscope/spectrometer recipes

### Removed
- All 121 `OnTest = RecipeCodeOnTest.pcpXxx` lines from recipe scripts (no effect on craftRecipe visibility)
- `RecipeCodeOnTest.*` callback assignments from `PCP_SandboxIntegration.lua`
- Diagnostic `getOnAddToMenu()` dump from `PCP_SandboxIntegration.lua`
- Unused OnTest callback functions (`onTestHeatRequired`, `onTestNoHeatRequired`, etc.)

### Changed
- `PCP_Sandbox` table is now global (was local) so client-side `PCP_RecipeFilter.lua` can access sandbox queries
- Requires **PhobosLib 1.5.0+** (PhobosLib_RecipeFilter)

## [0.13.4] - 2026-02-19

### Fixed
- **Recipe OnTest gating (root cause)** — Java script parser for craftRecipe `OnTest` only recognises callbacks registered on `RecipeCodeOnTest` (the Java-exposed table); custom Lua table names like `PCP_RecipeOnTest` are silently dropped during script parsing, causing `getOnAddToMenu()` to return nil. Fix: register all 9 callbacks directly on `RecipeCodeOnTest` from Lua (which IS accessible — proven by vanilla `Fish.lua`), and update all 121 recipe script references back to `RecipeCodeOnTest.pcpXxx`
- **OnTest callback signature** — Aligned all 9 callbacks to vanilla `(param)` single-table signature (was `(recipe, player)` positional args)
- Removed debug diagnostic logging from v0.13.3

## [0.13.3] - 2026-02-19

### Fixed
- **Perk description key** — Added `IGUI_perks_Applied Chemistry_Description` with literal space matching vanilla PZ pattern; PZ constructs description keys from `perk:getName()` which returns the display name with spaces
- **Recipe OnTest gating** — Moved 9 OnTest callbacks from Java-side `RecipeCodeOnTest` table to PCP-owned `PCP_RecipeOnTest` Lua table via `PhobosLib.registerOnTest()`; `RecipeCodeOnTest` is Java-exposed and Lua additions are invisible to the engine's `callLuaBool()` resolver; all 121 recipe references updated

### Changed
- Requires **PhobosLib 1.4.2+** (createCallbackTable / registerOnTest)

## [0.13.2] - 2026-02-19

### Fixed
- **Recipe OnTest gating** — All 121 OnTest references across 5 recipe files now use `RecipeCodeOnTest.` table-qualified names (e.g., `RecipeCodeOnTest.pcpHeatRequiredCheck`); bare function names were silently ignored by PZ 42, causing all sandbox-gated recipes to always be visible
- **Perk translation** — Added missing `name = AppliedChemistry` field in `perks.txt`; PZ 42.14.x showed raw key `IGUI_perks_Applied` instead of "Applied Chemistry" in the skills panel
- **Perk description keys** — Added fallback perk name variants and `_Description` keys covering all PZ lookup patterns
- **Persistent reset clearing** — Reset system now uses `PhobosLib.consumeSandboxFlag()` instead of `setSandboxVar()`; sandbox checkboxes stay OFF after game restart
- **Reset notification dialog** — Changed from Yes/No to single OK button; informational notifications should not present a yes/no choice

### Changed
- Requires **PhobosLib 1.4.1+** (consumeSandboxFlag for persistent sandbox reset)

## [0.13.1] - 2026-02-19

### Fixed
- **Registry namespace** — Changed `base:` → `pcp:` for all trait/profession identifiers; `base:` is reserved for vanilla PZ and caused a fatal crash in debug mode
- **ImpuritySeverity translations** — Enum dropdown labels now display correctly (Mild/Standard/Harsh); key format changed to `_option<N>` per PZ convention
- **Recipe sandbox gating** — Moved `PCP_SandboxIntegration.lua` from `server/` to `shared/` so `OnTest` callbacks register client-side; fixes all recipes being visible regardless of sandbox settings

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
