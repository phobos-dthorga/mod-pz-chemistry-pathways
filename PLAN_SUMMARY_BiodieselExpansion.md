# PhobosChemistryPathways — Biodiesel Expansion Plan Summary
## Local backup file (in case of context loss)
## Date: 2026-02-16

## Overview
Major expansion adding: new crop feedstocks, NaOH catalyst, B42 fluid system integration, multi-tier lab equipment, bulk container support, pottery vessels, PhobosLib integration, sandbox options, heat source system, loot distributions, foraging, and entity-based workstation system.

## Key Decisions Made
- Corn: use whole Base.Corn directly (no separate husk item)
- NaOH: add as alternative catalyst for ALL transesterification (lab + bulk, oil + fat)
- New crops: Flax (Base.FlaxSeed), Hemp (Base.HempSeed), Peanuts (Base.Peanuts)
- Bioreactor: Base.MetalDrum only (not colored barrels), now an entity workstation (PCP:MetalDrumStation)
- Equipment: Centrifuge + Chromatograph always on; Microscope + Spectrometer sandbox-gated
- Sandbox: YieldMultiplier (0.25-4.0x) + EnableAdvancedLabRecipes (boolean) + RequireHeatSources (boolean)
- Containers: Mason jars consumed, lids NOT re-required on pre-filled inputs
- Bulk containers: Buckets (10L), Clay Jars (2.5L), Gas Cans (10L) alongside jars
- PhobosLib: Add sandbox utilities (getSandboxVar, isModActive)

## Heat Source System
- **Bulk (MetalDrum) recipes**: Charcoal (×3) OR Coke (×1) OR Propane (×1, mode:destroy + OnCreate callback) — separate recipe variants
- **Chemistry Set recipes**: PropaneTank (Base.PropaneTank, mode:keep flags[MayDegrade], UseDelta=0.0002)
- **Surface craft (soap)**: Charcoal (×3) or Coke (×1) or Propane (×1, mode:destroy + OnCreate callback)
- **Mortar/cold-press recipes**: No heat source needed
- **Recipes NOT needing heat**: CrushCharcoal, PrepareDilutedCompost, ExtractBatteryAcid, MixBlackpowder, ConvertVegetableOil, RefineBiodiesel, Centrifuge×2, PurifyBiodieselChromatograph, Microscope, Spectrometer, all mortar/bulk oil press
- **Heat variants**: Dual-variant system — heated (OnTest=pcpHeatRequiredCheck) + simplified (OnTest=pcpNoHeatRequiredCheck)
- **RequireHeatSources sandbox option**: ON=realistic (fuel needed), OFF=simplified (no fuel)

## Loot Distribution
Already distributed: BkChemistryPathways, SulphurPowder, KNO3, KOH, WoodMethanol, Glycerol, Calcite
Newly distributed: Potash, CrushedCharcoal, PurifiedCharcoal, WoodTar, CrudeSoap
NOT distributed (player-crafted only): DilutedCompost, CrudeVegetableOil, RenderedFat, CrudeBiodiesel, WashedBiodiesel, RefinedBiodieselCan, LeadScrap, PlasticScrap, AcidWashedElectronics, SulphuricAcid containers, all ClayJar/Bucket variants

## Foraging
- **Calcite**: Forageable year-round in all zones (Kentucky karst limestone), skill 0, 1-2 per find, snow penalty
- **SulphurPowder**: Forageable Mar-Nov in forest/deep forest/vegetation only, skill 3, rare, rain bonus

## New Items (9)
CrudeVegetableOilClayJar, CrudeVegetableOilBucket, RenderedFatClayJar, RenderedFatBucket,
CrudeBiodieselClayJar, CrudeBiodieselBucket, WashedBiodieselClayJar, WashedBiodieselBucket,
BoneChar (animal bone pyrolysis product — PurifiedCharcoal alternative in filtration/reagent recipes)

## MetalDrum Workstation Entity
- **Entity**: `PCP_MetalDrumStation` in `PCP_Entities_MetalDrumStation.txt`
- **Sprite**: `crafted_01_32` (same as Base.MetalDrum moveable) — auto-detected when placed
- **CraftBench tag**: `PCP:MetalDrumStation` — all 21 bulk recipes use this tag
- **No build step needed**: Placing a MetalDrum automatically creates the workstation
- **Player stands near drum** (~1 tile) to access recipes, drum is NOT carried in inventory
- Chemistry Set / Centrifuge / Chromatograph / Microscope / Spectrometer already handled by zReVaccin entity Tags

## New Files (7)
- PCP: sandbox-options.txt, Sandbox_EN.txt, PCP_SandboxIntegration.lua, PCP_ForageDefs.lua, PCP_Entities_MetalDrumStation.txt, PCP_RecipeCallbacks.lua
- PhobosLib: PhobosLib_Sandbox.lua

## Existing 7 liquid items upgraded with FluidContainer
CrudeVegetableOil, RenderedFat, WoodMethanol, WoodTar, CrudeBiodiesel, Glycerol, WashedBiodiesel

## Sandbox Options (3)
- YieldMultiplier (double, 0.25-4.0, default 1.0) — scales recipe output quantities
- EnableAdvancedLabRecipes (boolean, default false) — gates Microscope/Spectrometer recipes
- RequireHeatSources (boolean, default true) — gates fuel requirements on heated recipes

## Total after expansion: 34 items, 112 recipes, 8 fluids, 3 sandbox options, 1 handbook

## Recipe Breakdown (112 total)
### Original recipes (pre-expansion): 34
### New recipes from biodiesel expansion: 54
- 9 oil extraction (3 crops × 3 tiers)
- 4 NaOH transesterification (oil+fat × lab+bulk)
- 4 centrifuge/chromatograph
- 2 microscope/spectrometer (sandbox-gated)
- 7 coke fuel variants (bulk transest ×4, bulk wash ×1, soap ×2)
- 7 bulk/surface simplified variants (no fuel, sandbox-gated)
- 20 chemistry set simplified variants (no propane, sandbox-gated)
- 1 chromatograph simplified variant (no propane, sandbox-gated)
### New recipes from animal debris integration: 12
- 6 bone char production (bones ×3 + skulls ×3, each with charcoal/coke/simple variants)
- 6 traditional fat soap (KOH ×3 + NaOH ×3, each with charcoal/coke/simple variants)
### New recipes from Phase 1 overhaul: 12
- 11 propane fuel variants (bulk transest ×4, bulk wash ×1, bone char ×2, soap ×4)
- 1 dung compost (PCPPrepareDilutedCompostDung — animal waste alternative)

## Implementation Status (Updated 2026-02-16)
- [x] PhobosLib sandbox utilities (getSandboxVar, isModActive, applyYieldMultiplier)
- [x] sandbox-options.txt + Sandbox_EN.txt
- [x] PCP_SandboxIntegration.lua (pcpAdvancedLabCheck, pcpHeatRequiredCheck, pcpNoHeatRequiredCheck)
- [x] 8 new container variant items in PCP_Items.txt
- [x] 7 existing liquid items upgraded with FluidContainer components
- [x] 7 fluid display names in Fluids_EN.txt
- [x] 9 new crop oil extraction recipes (flax/hemp/peanut × 3 tiers)
- [x] 4 NaOH transesterification recipes (oil+fat × lab+bulk)
- [x] 6 advanced equipment recipes (2 centrifuge, 2 chromatograph, 1 microscope, 1 spectrometer)
- [x] Existing bulk recipes updated (MetalDrum only, bucket I/O)
- [x] Tooltip line breaks fixed (<LINE> → <br>, 22 occurrences)
- [x] Bulk heated recipes: charcoal (×3) or coke (×1) consumed as fuel (replaced BlowTorch)
- [x] 7 coke fuel recipe variants for bulk/surface recipes
- [x] Chemistry Set heated recipes: PropaneTank (mode:keep flags[MayDegrade])
- [x] 20 chemistry set simplified variants (no propane, sandbox-gated)
- [x] 1 chromatograph simplified variant (no propane, sandbox-gated)
- [x] 7 bulk/surface simplified recipe variants (no fuel, sandbox-gated)
- [x] Handbook LearnedRecipes updated with all 100 recipe IDs (post-animal debris)
- [x] All translation entries (Recipes_EN, ItemName_EN, Fluids_EN)
- [x] RequireHeatSources sandbox tooltip updated for charcoal/coke/propane
- [x] Loot distributions: Potash, CrushedCharcoal, PurifiedCharcoal, WoodTar, CrudeSoap added
- [x] Calcite distribution expanded (classrooms, hardware, farm supply, vehicles)
- [x] Foraging: Calcite + SulphurPowder via PCP_ForageDefs.lua
- [x] MetalDrum workstation entity (PCP_Entities_MetalDrumStation.txt, sprite crafted_01_32, tag PCP:MetalDrumStation)
- [x] All 21 bulk recipes updated: Tags changed from AnySurfaceCraft to PCP:MetalDrumStation, MetalDrum removed from inputs
- [x] Verified: chemistry set/centrifuge/chromatograph/microscope/spectrometer already use zReVaccin entity Tags

## Animal Debris Integration (2026-02-16)
- [x] BoneChar item added to PCP_Items.txt (Weight 0.3, Icon PCP_BoneChar, WorldStaticModel Charcoal_Ground)
- [x] BoneChar translations: ItemName_EN + Tooltip_EN
- [x] Fat rendering expanded: PCPRenderFat/Simple now accept Lard, Butter, Margarine
- [x] SesameOil removed from PCPConvertVegetableOil (unrealistic lipid content)
- [x] 6 bone char production recipes (bones + skulls × charcoal/coke/simple)
- [x] 6 traditional fat soap recipes (KOH + NaOH × charcoal/coke/simple, yield 3 vs 4 for glycerol)
- [x] BoneChar added as PurifiedCharcoal alternative in 9 ChemistrySet input slots
- [x] 12 new recipe translations in Recipes_EN.txt
- [x] Handbook LearnedRecipes updated to 100 IDs
- [x] Placeholder icons created (Item_PCP_BoneChar.png + Image_PCP_BoneChar.png)

## Phase 1 Overhaul (2026-02-17)
- [x] MEMORY.md updated: heat source mutual exclusivity rule, dung items, propane notes, ZScienceSkill info
- [x] Plastic scrap recipe restricted to base:smallblade only (removed base:largeblade)
- [x] Dung compost recipe (PCPPrepareDilutedCompostDung) — 10 base:iscompostable items → 3 DilutedCompost
- [x] PCP_RecipeCallbacks.lua created — pcpReturnPartialPropane OnCreate callback (uses PhobosLib.pcallMethod)
- [x] 11 propane fuel recipe variants added (mode:destroy + OnCreate returns partially-used tank, ~25 uses per tank)
- [x] All recipe display names numbered with pathway step prefixes (1., 2a., 3b., etc.)
- [x] 12 new recipe translations in Recipes_EN.txt (11 propane + 1 dung compost)
- [x] Handbook tooltip updated with coloured pathway guide (Blackpowder, Biodiesel, By-Products)
- [x] ZScienceSkill detection function added to PCP_SandboxIntegration.lua (dormant, Phase 2 integration)
- [x] Handbook LearnedRecipes updated to 112 IDs
- [x] Total verified: 34 items, 112 recipes, 112 translations, 112 handbook IDs
