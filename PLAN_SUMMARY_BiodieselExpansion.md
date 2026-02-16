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

## Impurity/Purity System (2026-02-17)
- [x] PCP_Fluids.txt: Fixed 3 invalid maxEffect values (Heavy→Severe, Light→Mild)
- [x] PhobosLib_Util.lua: 3 modData helpers (getModData, getModDataValue, setModDataValue)
- [x] PhobosLib_Quality.lua: NEW — 12 generic quality/purity functions (reusable across mods)
- [x] PhobosLib.lua: Added `require "PhobosLib_Quality"`
- [x] PCP_PuritySystem.lua: NEW — PCP-specific config + wrappers (tiers, factors, yield table)
- [x] sandbox-options.txt: 3 new options (EnableImpuritySystem, ImpuritySeverity, ShowPurityOnCraft)
- [x] Sandbox_EN.txt: 3 new option translations + 3 enum labels
- [x] PCP_RecipeCallbacks.lua: 37 new purity callbacks (9 source + 15 propagation + 4 terminal + 2 utility + 7 combined propane+purity)
- [x] All 112 recipes have OnCreate callbacks (82 new + 11 replaced propane callbacks + 19 ChemistrySet/Utility)
- [x] PCP_PurityTooltip.lua: NEW client-side tooltip hook (pcall-wrapped, best-effort)
- [x] Handbook tooltip updated with purity system note
- [x] Sandbox options: 6 total (3 original + 3 purity system)
- [x] Total: 34 items, 112 recipes, 8 fluids, 6 sandbox options, 112 OnCreate callbacks

## EHR Health Hazard Integration (2026-02-17)
- [x] PhobosLib_Hazard.lua: NEW — 6 generic PPE detection + hazard dispatch functions (reusable across mods)
- [x] PhobosLib.lua: Added `require "PhobosLib_Hazard"`
- [x] PCP_HazardSystem.lua: NEW — PCP-specific hazard config (4 hazard profiles, mask types, filter degrade constants)
- [x] sandbox-options.txt: 1 new option (EnableHealthHazards, boolean, default false)
- [x] Sandbox_EN.txt: EnableHealthHazards translation + tooltip (Safe/Unsafe variants, EHR/vanilla fallback)
- [x] PCP_SandboxIntegration.lua: 6 new combined OnTest functions (heat×hazard matrix) + isEHRActive() + isHealthHazardsEnabled()
- [x] 10 original hazardous recipes modified: OnTest changed to hide when hazards ON
- [x] PCP_Recipes_Hazard.txt: NEW — 20 new recipes (10 Safe + 10 Unsafe twins)
- [x] PCP_RecipeCallbacks.lua: 10 new callbacks (5 safe + 5 unsafe) via DRY _safeWrapper/_unsafeWrapper helpers
- [x] Recipes_EN.txt: 20 new display name translations (Protected/No Mask! naming)
- [x] Handbook tooltip updated with Health Hazards section
- [x] Handbook LearnedRecipes updated to 132 IDs
- [x] Sandbox options: 7 total (3 original + 3 purity + 1 health hazard)
- [x] Total: 34 items, 132 recipes, 8 fluids, 7 sandbox options, 122 OnCreate callbacks

## Applied Chemistry Skill System (2026-02-17)
- [x] PhobosLib_Skill.lua: NEW — 6 generic skill functions (perkExists, getPerkLevel, addXP, getXP, mirrorXP, registerXPMirror)
- [x] PhobosLib.lua: Added `require "PhobosLib_Skill"`, bumped VERSION to 1.1.0
- [x] PhobosLib mod.info: bumped modversion to 1.1.0 (root + 42/mod.info)
- [x] perks.txt: NEW — AppliedChemistry perk (parent=Crafting, steeper XP curve: 75-9000)
- [x] PCP_Professions.txt: NEW — Chemist (Cost -4, AC 3, Doctor 1, 13 recipes) + Pharmacist (Cost -2, AC 2, Doctor 2, 5 recipes)
- [x] PCP_Traits.txt: NEW — pcp_chemist_trait (profession), pcp_chemistry_enthusiast (+4 cost, AC +1), pcp_chem_aversion (-2 cost, AC -1)
- [x] PCP_SkillBooks.txt: NEW — 5 skill book volumes (levels 1-10, green-tinted generic books)
- [x] IG_UI_EN.txt: Perk, profession, and trait translations added
- [x] ItemName_EN.txt: 5 skill book name translations added
- [x] Tooltip_EN.txt: Handbook tooltip updated with Applied Chemistry skill section
- [x] PCP_Distributions.lua: Skill book loot distributions (Vol 1-2 common, Vol 3-4 rare, Vol 5 very rare)
- [x] ALL 132 recipes migrated: xpAward Doctor → AppliedChemistry, SkillRequired + AutoLearnAll added per tier
  - Tier 0 (7 recipes): No SkillRequired, AC:10 XP, AutoLearnAll AC:2
  - Tier 1 (6 recipes): AC:1 required, AC:10-15 XP, AutoLearnAll AC:3
  - Tier 2 (55 recipes): AC:2 required, AC:20-25 XP, AutoLearnAll AC:4-5
  - Tier 3 (26 recipes): AC:3 required, AC:30-40 XP, AutoLearnAll AC:6-7
  - Tier 4 (30 recipes): AC:4 required, AC:40-90 XP, AutoLearnAll AC:7-8
  - Tier 5 (5 recipes): AC:5 required, AC:35-50 XP, AutoLearnAll AC:8-9
  - Tier 7 (2 recipes): AC:7 required, AC:80 XP, no AutoLearnAll
  - PCPCutPlasticScrap: unchanged (Maintenance:5)
- [x] PCP_SkillXP.lua: NEW — ZScienceSkill XP mirror (Applied Chemistry → Science at 50%)
- [x] PCP_ZScienceData.lua: NEW — 16 PCP items registered as ZScienceSkill researchable specimens
- [x] PCP_SandboxIntegration.lua: ZScienceSkill comment updated (no longer dormant)
- [x] Profession placeholder icons created (profession_pcp_chemist.png, profession_pcp_pharmacist.png)
- [x] Total: 39 items (34 + 5 skill books), 132 recipes, 8 fluids, 7 sandbox options, 122 OnCreate callbacks
