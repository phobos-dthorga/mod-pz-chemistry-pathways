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

## [Unreleased]

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
