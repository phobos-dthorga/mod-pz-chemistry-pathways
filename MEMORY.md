# PhobosChemistryPathways - Session Memory

## Project Structure
- Root: `C:\Users\phobo\Zomboid\mods\PhobosChemistryPathways\`
- Build 42 content: `42/media/scripts/` (items, recipes, fluids), `42/media/lua/` (distributions, translations)
- Module name in scripts: `PhobosChemistryPathways` (items), `Base` (recipes, fluids)
- Recipe prefix: `PCP` (e.g., `PCPCrushCharcoal`)

## Key Patterns
- **Build 42 craftRecipe syntax**: `item 1 [*]` + `-fluid X [FluidName]` = fluid source container, NOT heat source
- **Container realism**: Recipes outputting items in containers MUST consume empty containers as input (`mode:destroy`). Mason jars require `Base.JarLid` separately.
- **Chemistry Set recipes**: `Tags = zReVAC2:ChemistrySet;CannotBeResearched`, `timedAction = zReVAC2TimedActionChem1`
- **MetalDrum bulk recipes**: `Tags = PCP:MetalDrumStation;CannotBeResearched`, `timedAction = Making_Surface` — player must be NEAR a placed MetalDrum
- **Surface craft recipes**: `Tags = AnySurfaceCraft;CannotBeResearched`, `timedAction = Making_Surface`
- **Mortar recipes**: `Tags = AnySurfaceCraft;CannotBeResearched`, `timedAction = MixingMortarPestle`
- All chemistry recipes require `NeedToBeLearn = true` and the handbook

## B42 Entity Workstation System
- **Mechanism**: Recipes bind to placed furniture via Tags ↔ CraftBench. Recipe `Tags = TagName` matches entity `CraftBench { Recipes = TagName }`.
- **Sprite binding**: Entity SpriteConfig sprite MUST match the moveable item's WorldObjectSprite for auto-detection when placed.
- **No NearItem property**: B42 craftRecipe does NOT have NearItem. Proximity detection is entirely Tags+CraftBench.
- **Entity definition pattern** (from zReVaccin): `module Base { entity Name { component UiConfig {...} component CraftBench { Recipes = Tag } component SpriteConfig { face SINGLE { layer { row = sprite } } } } }`
- **PCP MetalDrum entity**: `PCP_Entities_MetalDrumStation.txt` — entity `PCP_MetalDrumStation`, sprite `crafted_01_32`, tag `PCP:MetalDrumStation`
- **MetalDrum is NOT carried**: Do NOT use `item 1 [Base.MetalDrum] mode:keep` in recipes — MetalDrum is furniture, use entity Tags instead

## Dependencies
- **zReModVaccin30bykERHUS**: Lab equipment — see [zReVaccin details](zrevaccin-equipment.md)
- **PhobosLib**: Shared utility library — see [PhobosLib details](phoboslib.md)

## zReVaccin Equipment Tags (for recipes)
- `zReVAC2:ChemistrySet` / `zReVAC2TimedActionChem1` or `zReVAC2TimedActionChem2`
- `zReVAC2:Centrifuge` / `Making_Surface`
- `zReVAC2:Chromatograph` / `Making_Surface`
- `zReVAC2:Microscope` / `Making_Surface`
- `zReVAC2:Spectrometer` / `Making_Surface`

## PhobosLib Capabilities
- Fluid helpers: tryGetFluidContainer, tryAddFluid, tryDrainFluid, tryGetAmount, tryGetCapacity
- Item search: findItemByKeywords, findAllItemsByKeywords, matchesKeywords
- World scan: scanNearbySquares, findNearbyObjectByKeywords
- API probing: pcallMethod, probeMethod (B42 API resilience)

## Vanilla PZ Build 42 Notes
- `Base.Lime` is a CITRUS FRUIT, not chemical lime
- `Base.Quicklime` is the chemical (CaO)
- No vanilla Tallow, Methanol, Ethanol, Glycerol, Diesel, Slaked Lime
- `Base.Petrol` is the fuel fluid; `Base.PetrolCan` has FluidContainer (10L capacity)
- No empty PetrolCan variant — use `flags[IsEmpty]` on PetrolCan
- Metal drums/barrels (`Base.Mov_OrangeBarrel` etc.) are moveable items, no FluidContainer
- `Base.JarLid` exists as a separate item (Weight: 0.1)

## Current Mod Content (Post-Expansion + Animal Debris)
- **Blackpowder chain**: Charcoal → CrushedCharcoal → PurifiedCharcoal + Potash → KNO3 + Sulphur → Gunpowder
- **Bone Char chain**: Animal bones/skulls → BoneChar (MetalDrum pyrolysis) — alternative to PurifiedCharcoal in filtration/reagent recipes
- **Biodiesel chain**: 6 crops × 3 tiers → CrudeVegetableOil → + Methanol + KOH/NaOH → CrudeBiodiesel → WashedBiodiesel → RefinedBiodieselCan (5L Petrol)
- **Fat rendering**: Lard, Butter, Margarine → RenderedFat (Chemistry Set)
- **Oil conversion**: OilVegetable, OilOlive → CrudeVegetableOil (SesameOil removed — too low lipid content)
- **Crops**: Soybeans, SunflowerSeeds, Corn, FlaxSeed, HempSeed, Peanuts
- **Tiers**: Mortar (1 jar), Chemistry Set (2 jars), MetalDrum (1 bucket/10L)
- **Advanced equipment**: Centrifuge (wash/glycerol), Chromatograph (purify biodiesel/methanol), Microscope+Spectrometer (sandbox-gated)
- **Container variants**: Jar (1L), ClayJar (2.5L), Bucket (10L) for oil/fat/biodiesel/washed
- **Sandbox**: YieldMultiplier (0.25-4.0x), EnableAdvancedLabRecipes (boolean), RequireHeatSources (boolean)
- **Heat sources**: Bulk recipes use charcoal (×3) or coke (×1) consumed; Chemistry Set uses PropaneTank (MayDegrade); all sandbox-gated
- **By-products**: WoodTar, Calcite, Glycerol → CrudeSoap (glycerol-based OR traditional fat-based with Lard/Butter/Margarine)
- **Loot**: Handbook, SulphurPowder, KNO3, KOH, WoodMethanol, Glycerol, Calcite, Potash, CrushedCharcoal, PurifiedCharcoal, WoodTar, CrudeSoap
- **Foraging**: Calcite (Kentucky karst geology, all zones), SulphurPowder (mineral deposits, deep forest, skill 3)
- **Total**: 34 items, 100 recipes, 8 fluids, 3 sandbox options, 1 handbook

## Vanilla B42 Animal Items (Relevant)
- **Fats**: `Base.Lard`, `Base.Butter`, `Base.Margarine` (all tag `base:bakingfat`)
- **Bones**: `Base.SmallAnimalBone` (0.3), `Base.SharpBoneFragment` (0.3), `Base.AnimalBone` (1.5, weapon), `Base.LargeAnimalBone` (2.0, weapon)
- **Skulls**: Various items tagged `base:animalskull`
- **Note**: No `base:animalfat` tag exists; `base:bakingfat` also includes OilVegetable and OilOlive
- **SesameOil**: Only 14g lipids vs 130-150g for OilVegetable/OilOlive — removed from oil conversion as unrealistic

## Vanilla B42 Fuel Items
- `Base.Charcoal` — forageable charcoal, Tags: base:charcoal;base:isfirefuel
- `Base.CharcoalCrafted` — crafted wood charcoal, Tags: base:charcoal;base:isfirefuel
- `Base.Coke` — industrial coke, Tags: base:charcoal;base:isfirefuel, FireFuelRatio=2.0
- `Base.PropaneTank` — drainable (UseDelta=0.0002, ~5000 uses), KeepOnDeplete=true
- `Base.BlowTorch` — drainable (UseDelta=0.1, ~10 uses), KeepOnDeplete=true

## Vanilla B42 Fluid Containers (Key Subset)
- Mason Jar: `Base.EmptyJar`/`Base.JarCrafted` — 1.0L, needs `Base.JarLid`
- Glass Bottle: `Base.BottleCrafted` — 1.0L
- Clay Jar: `Base.ClayJar`/`Base.ClayJarGlazed` — 2.5L (pottery skill)
- Bucket: `Base.Bucket`/`Base.BucketEmpty`/`Base.BucketForged`/`Base.BucketCarved`/`Base.BucketWood` — 10L
- Large Bucket: `Base.BucketLargeWood` — 20L
- Gas Can: `Base.PetrolCan` — 10L (no empty variant, use `flags[IsEmpty]`)
- Pot: `Base.Pot`/`Base.PotForged` — 1.5L
- Clay Bowl: `Base.ClayBowl` — 0.3L

## Sandbox Options Pattern (from zReVaccin reference)
- File: `42/media/sandbox-options.txt` at mod root
- Format: `option ModId.OptionName { type=..., min=..., max=..., default=..., page=..., translation=... }`
- Types: integer, double, boolean, enum
- Translations: `42/media/lua/shared/Translate/EN/Sandbox_EN.txt`
- Access in Lua: `SandboxVars.ModId.OptionName`

## Icon/Texture Convention (PZ Build 42)
- Location: `42/media/textures/`
- Naming: `Item_PCP_<IconName>.png` (128×128, inventory) + `Image_PCP_<IconName>.png` (1024×1024, UI/handbook)
- Format: PNG, RGBA preferred (some older icons are RGB)
- Item definition references: `Icon = PCP_<IconName>` (no `Item_` prefix in scripts)
- **Container variants** (ClayJar, Bucket) should REUSE the base item's icon (e.g., `CrudeVegetableOilClayJar` uses `PCP_CrudeVegetableOil`)
- **Placeholder icons MUST be created** whenever new items are added that need new icon names
- Existing icons (51 total): 25 unique icon pairs + 1 handbook-only (Item_PCP_BkChemistryPathways)
- BoneChar placeholder icons copied from PurifiedCharcoal (both dark carbon materials)

## User Preferences
- Cross-mod tie-ins ALWAYS welcome (optional, runtime-detected)
- PhobosLib must be used for all shared Lua utilities
- Recipes consuming containers: container is CONSUMED (mode:destroy), becomes part of output
- Output in mason jar: requires empty jar + lid as inputs
- If output-in-jar is used as input: DO NOT require another lid (already sealed)
- Bulk containers (buckets, clay jars, gas cans) must be supported alongside mason jars
- Pottery containers should be valid alternatives where applicable
- Plans/summaries should be saved to local files as backup against context loss
- Placeholder icons must always be created for new items (Item_ + Image_ PNG pairs)
