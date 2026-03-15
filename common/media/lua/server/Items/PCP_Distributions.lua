--  ________________________________________________________________________
-- / Copyright (c) 2026 Phobos A. D'thorga                                \
-- |                                                                        |
-- |           /\_/\                                                         |
-- |         =/ o o \=    Phobos' PZ Modding                                |
-- |          (  V  )     All rights reserved.                              |
-- |     /\  / \   / \                                                      |
-- |    /  \/   '-'   \   This source code is part of the Phobos            |
-- |   /  /  \  ^  /\  \  mod suite for Project Zomboid (Build 42).         |
-- |  (__/    \_/ \/  \__)                                                  |
-- |     |   | |  | |     Unauthorised copying, modification, or            |
-- |     |___|_|  |_|     distribution of this file is prohibited.          |
-- |                                                                        |
-- \________________________________________________________________________/
--

-----------------------------------------------------
-- Phobos' Industrial Pathways: Biomass - Loot Distributions
-----------------------------------------------------
require 'Items/ItemPicker'
require 'Items/Distributions'
require 'Items/ProceduralDistributions'
require 'Items/SuburbsDistributions'
require 'Vehicles/VehicleDistributions'

-----------------------------------------------------
-- Nil-guarded distribution helpers.
-- Prevents crash if a distribution key is renamed,
-- removed, or absent in the current B42 build.
-----------------------------------------------------
local function dist(listName, itemType, chance)
    local entry = ProceduralDistributions.list[listName]
    if entry and entry.items then
        table.insert(entry.items, itemType)
        table.insert(entry.items, chance)
    end
end

local function vdist(vehTable, itemType, chance)
    if vehTable and vehTable.items then
        table.insert(vehTable.items, itemType)
        table.insert(vehTable.items, chance)
    end
end

-----------------------------------------------------
------------- CATEGORY RECIPE BOOKS -----------------
-----------------------------------------------------
-- 5 category-specific books + 1 ultra-rare master compendium.
-- Each category book teaches only its own category's recipes.
-- Master compendium teaches ALL 301 recipes — ultra-rare jackpot find.
-- Rarity tiers based on survival value: practical books are easier to find.

-- ===== BkFieldChemistry (Common) =====
-- Practical field recipes — most accessible book
dist("ShelfGeneric",      "PhobosChemistryPathways.BkFieldChemistry", 1.5)
dist("CrateBooks",        "PhobosChemistryPathways.BkFieldChemistry", 1)
dist("BookstoreBooks",    "PhobosChemistryPathways.BkFieldChemistry", 2.5)
dist("GarageTools",       "PhobosChemistryPathways.BkFieldChemistry", 0.5)
dist("CrateFertilizer",   "PhobosChemistryPathways.BkFieldChemistry", 1)

-- ===== BkKitchenChemistry (Common) =====
-- Fat rendering, soap-making, basic biodiesel
dist("ShelfGeneric",      "PhobosChemistryPathways.BkKitchenChemistry", 1)
dist("CrateBooks",        "PhobosChemistryPathways.BkKitchenChemistry", 0.8)
dist("BookstoreBooks",    "PhobosChemistryPathways.BkKitchenChemistry", 2)
dist("ClassroomShelves",  "PhobosChemistryPathways.BkKitchenChemistry", 0.3)

-- ===== BkLabChemistry (Uncommon) =====
-- Lab-based recipes requiring chemistry equipment
dist("ShelfGeneric",      "PhobosChemistryPathways.BkLabChemistry", 0.3)
dist("CrateBooks",        "PhobosChemistryPathways.BkLabChemistry", 0.5)
dist("BookstoreBooks",    "PhobosChemistryPathways.BkLabChemistry", 1)
dist("LibraryScience",    "PhobosChemistryPathways.BkLabChemistry", 1)
dist("LaboratoryBooks",   "PhobosChemistryPathways.BkLabChemistry", 2)

-- ===== BkIndustrialChemistry (Uncommon) =====
-- Concrete mixer and industrial-scale recipes
dist("ShelfGeneric",      "PhobosChemistryPathways.BkIndustrialChemistry", 0.2)
dist("CrateBooks",        "PhobosChemistryPathways.BkIndustrialChemistry", 0.3)
dist("BookstoreBooks",    "PhobosChemistryPathways.BkIndustrialChemistry", 0.8)
dist("LibraryScience",    "PhobosChemistryPathways.BkIndustrialChemistry", 0.5)

-- ===== BkHorticulture (Common) =====
-- Botanical pathway, tobacco, hemp cultivation
dist("ShelfGeneric",      "PhobosChemistryPathways.BkHorticulture", 1.2)
dist("CrateBooks",        "PhobosChemistryPathways.BkHorticulture", 0.8)
dist("BookstoreBooks",    "PhobosChemistryPathways.BkHorticulture", 2)
dist("CrateFertilizer",   "PhobosChemistryPathways.BkHorticulture", 1.5)
dist("GarageTools",       "PhobosChemistryPathways.BkHorticulture", 0.3)

-- ===== BkChemistryPathways (Rare master compendium) =====
-- Teaches ALL recipes — extremely rare find
dist("BookstoreBooks",    "PhobosChemistryPathways.BkChemistryPathways", 0.1)
dist("LibraryScience",    "PhobosChemistryPathways.BkChemistryPathways", 0.2)
dist("LaboratoryBooks",   "PhobosChemistryPathways.BkChemistryPathways", 0.3)
dist("CrateBooks",        "PhobosChemistryPathways.BkChemistryPathways", 0.05)


-----------------------------------------------------
------------- SKILL BOOKS ---------------------------
-----------------------------------------------------
-- 5 skill books for Applied Chemistry skill levels 1-10.
-- Rarity scales with skill tier to match vanilla skill book distribution.

-- ===== BookAppliedChemistry1 (Levels 1-2, Common) =====
dist("ShelfGeneric",      "PhobosChemistryPathways.BookAppliedChemistry1", 2)
dist("CrateBooks",        "PhobosChemistryPathways.BookAppliedChemistry1", 1.5)
dist("BookstoreBooks",    "PhobosChemistryPathways.BookAppliedChemistry1", 3)
dist("ClassroomShelves",  "PhobosChemistryPathways.BookAppliedChemistry1", 0.5)

-- ===== BookAppliedChemistry2 (Levels 3-4, Common) =====
dist("ShelfGeneric",      "PhobosChemistryPathways.BookAppliedChemistry2", 1.5)
dist("CrateBooks",        "PhobosChemistryPathways.BookAppliedChemistry2", 1)
dist("BookstoreBooks",    "PhobosChemistryPathways.BookAppliedChemistry2", 2)
dist("LibraryScience",    "PhobosChemistryPathways.BookAppliedChemistry2", 0.5)

-- ===== BookAppliedChemistry3 (Levels 5-6, Uncommon) =====
dist("ShelfGeneric",      "PhobosChemistryPathways.BookAppliedChemistry3", 0.5)
dist("CrateBooks",        "PhobosChemistryPathways.BookAppliedChemistry3", 0.5)
dist("BookstoreBooks",    "PhobosChemistryPathways.BookAppliedChemistry3", 1)
dist("LibraryScience",    "PhobosChemistryPathways.BookAppliedChemistry3", 1)
dist("LaboratoryBooks",   "PhobosChemistryPathways.BookAppliedChemistry3", 1)

-- ===== BookAppliedChemistry4 (Levels 7-8, Rare) =====
dist("CrateBooks",        "PhobosChemistryPathways.BookAppliedChemistry4", 0.2)
dist("BookstoreBooks",    "PhobosChemistryPathways.BookAppliedChemistry4", 0.5)
dist("LibraryScience",    "PhobosChemistryPathways.BookAppliedChemistry4", 0.5)
dist("LaboratoryBooks",   "PhobosChemistryPathways.BookAppliedChemistry4", 0.8)

-- ===== BookAppliedChemistry5 (Levels 9-10, Very Rare) =====
dist("BookstoreBooks",    "PhobosChemistryPathways.BookAppliedChemistry5", 0.1)
dist("LibraryScience",    "PhobosChemistryPathways.BookAppliedChemistry5", 0.2)
dist("LaboratoryBooks",   "PhobosChemistryPathways.BookAppliedChemistry5", 0.5)


-----------------------------------------------------
------------ CHEMISTRY PATHWAY ITEMS ----------------
-----------------------------------------------------

-- ===== CHEMICAL REAGENTS =====
-- Medical storage, janitor closets, labs

-- Medical storage (common chemical source)
dist("MedicalStorageDrugs",  "PhobosChemistryPathways.SulphurPowder", 0.5)
dist("MedicalClinicDrugs",   "PhobosChemistryPathways.SulphurPowder", 0.3)
dist("MedicalStorageDrugs",  "PhobosChemistryPathways.PotassiumHydroxide", 0.3)

-- Janitor closets (cleaning chemicals)
dist("JanitorChemicals",    "PhobosChemistryPathways.PotassiumHydroxide", 0.5)
dist("JanitorChemicals",    "PhobosChemistryPathways.CrudeSoap", 0.8)
dist("JanitorMisc",         "PhobosChemistryPathways.CrudeSoap", 0.3)

-- ===== INTERMEDIATES =====
-- Tool stores, garages, mechanics

-- Tool stores (charcoal, bone char, carbon)
dist("ToolStoreMisc",        "PhobosChemistryPathways.CrushedCharcoal", 0.3)
dist("ToolStoreMisc",        "PhobosChemistryPathways.PurifiedCharcoal", 0.1)
dist("ToolStoreMisc",        "PhobosChemistryPathways.BoneChar", 0.1)

-- Garages (tar, methanol)
dist("GarageTools",          "PhobosChemistryPathways.WoodTar", 0.2)
dist("GarageTools",          "PhobosChemistryPathways.WoodMethanol", 0.1)

-- ===== MILITARY =====
-- Surplus stores, military storage

-- Army surplus (blackpowder ingredients, charcoal)
dist("ArmySurplusTools",     "PhobosChemistryPathways.SulphurPowder", 0.3)
dist("ArmySurplusTools",     "PhobosChemistryPathways.PotassiumNitratePowder", 0.2)
dist("ArmySurplusTools",     "PhobosChemistryPathways.CrushedCharcoal", 0.5)

-- Army medical (sulphur for antiseptic, crude soap)
dist("ArmyStorageMedical",   "PhobosChemistryPathways.SulphurPowder", 0.3)
dist("ArmyStorageMedical",   "PhobosChemistryPathways.CrudeSoap", 0.5)

-- ===== AUTOMOTIVE =====
-- Mechanic shops (biodiesel chain)
dist("StoreShelfMechanics",  "PhobosChemistryPathways.CrudeBiodiesel", 0.1)
dist("StoreShelfMechanics",  "PhobosChemistryPathways.WoodMethanol", 0.1)

-- ===== EDUCATION =====
-- Classrooms and science labs
dist("ClassroomDesk",        "PhobosChemistryPathways.SulphurPowder", 0.1)
dist("ClassroomDesk",        "PhobosChemistryPathways.Calcite", 0.2)
dist("ClassroomMisc",        "PhobosChemistryPathways.CrushedCharcoal", 0.2)
dist("TestingLab",           "PhobosChemistryPathways.SulphuricAcidBottle", 0.1)
dist("ScienceMisc",          "PhobosChemistryPathways.PotassiumHydroxide", 0.2)
dist("ScienceMisc",          "PhobosChemistryPathways.Calcite", 0.3)
dist("MedicalOfficeBooks",   "PhobosChemistryPathways.BkLabChemistry", 0.3)

-- ===== AGRICULTURE =====
-- Farm supply, fertilizer crates
dist("CrateFertilizer",     "PhobosChemistryPathways.BoneMeal", 0.5)
dist("CrateFertilizer",     "PhobosChemistryPathways.Calcite", 0.5)
dist("CrateFertilizer",     "PhobosChemistryPathways.DilutedCompost", 0.8)
dist("CrateFarming",        "PhobosChemistryPathways.BoneMeal", 0.3)
dist("CrateFarming",        "PhobosChemistryPathways.MineralFeedSupplement", 0.1)
vdist(VehicleDistributions.FarmerTruckBed, "PhobosChemistryPathways.DilutedCompost", 0.3)

-- ===== SALVAGE =====
-- Tool stores, garages (scrap materials)
dist("ToolStoreMisc",        "PhobosChemistryPathways.LeadScrap", 0.2)
dist("ToolStoreMisc",        "PhobosChemistryPathways.PlasticScrap", 0.3)
dist("GarageTools",          "PhobosChemistryPathways.LeadScrap", 0.3)
dist("GarageTools",          "PhobosChemistryPathways.PlasticScrap", 0.2)
dist("GarageTools",          "PhobosChemistryPathways.AcidWashedElectronics", 0.05)


-----------------------------------------------------
------------ BOTANICAL PATHWAY ITEMS ----------------
-----------------------------------------------------

-- ===== HEMP TEXTILES =====
-- Camping and survivalist stores
dist("CampingStoreGear",    "PhobosChemistryPathways.HempRope", 0.3)
dist("CampingStoreGear",    "PhobosChemistryPathways.HempTwine", 0.5)
dist("CampingStoreGear",    "PhobosChemistryPathways.HempCanvas", 0.1)

-- Fishing stores (fishing net, oakum for boat caulking)
dist("FishingStoreGear",    "PhobosChemistryPathways.HempFishingNet", 0.3)
dist("FishingStoreGear",    "PhobosChemistryPathways.Oakum", 0.2)
dist("FishingStoreGear",    "PhobosChemistryPathways.HempTwine", 0.3)

-- Survivalist truck beds (rope, snares)
vdist(VehicleDistributions.SurvivalistTruckBed, "PhobosChemistryPathways.HempRope", 0.3)
vdist(VehicleDistributions.SurvivalistTruckBed, "PhobosChemistryPathways.HempTwine", 0.5)

-- ===== HEMP MEDICAL =====
-- Medical storage (poultice, tincture)
dist("MedicalStorageDrugs",  "PhobosChemistryPathways.HempPoultice", 0.2)
dist("MedicalStorageDrugs",  "PhobosChemistryPathways.HempTincture", 0.1)
dist("MedicalClinicDrugs",   "PhobosChemistryPathways.HempPoultice", 0.1)

-- ===== HEMP CONSTRUCTION =====
-- Tool stores (hempcrete, oakum)
dist("ToolStoreMisc",        "PhobosChemistryPathways.HempcreteBlock", 0.1)
dist("ToolStoreMisc",        "PhobosChemistryPathways.Oakum", 0.2)

-- Hemp Snare — survivalist stashes, camping stores
vdist(VehicleDistributions.SurvivalistTruckBed, "PhobosChemistryPathways.HempSnare", 0.2)
dist("CampingStoreGear",    "PhobosChemistryPathways.HempSnare", 0.2)


-----------------------------------------------------
------------ HORTICULTURE PATHWAY ITEMS -------------
-----------------------------------------------------

-- ===== TOBACCO PRODUCTS =====
-- Smoke shops, bars, living rooms

-- Smoke shop counters (chewing tobacco, rolled cigars)
dist("StoreCounterTobacco",  "PhobosChemistryPathways.ChewingTobacco", 0.5)
dist("StoreCounterTobacco",  "PhobosChemistryPathways.CigarRolled", 0.3)

-- Bar counters (chewing tobacco)
dist("BarCounterMisc",       "PhobosChemistryPathways.ChewingTobacco", 0.3)

-- Residential (occasional find)
dist("LivingRoomShelf",      "PhobosChemistryPathways.ChewingTobacco", 0.1)
dist("KitchenRandom",        "PhobosChemistryPathways.ChewingTobacco", 0.1)


-- ===== HEMP BUDS =====
-- Farm supply, garden, medical storage

-- Farm supply (fresh and cured buds)
dist("CrateFertilizer",     "PhobosChemistryPathways.HempBuds", 0.5)
dist("CrateFertilizer",     "PhobosChemistryPathways.HempBudsCured", 0.2)

-- Farmer trucks
vdist(VehicleDistributions.FarmerTruckBed, "PhobosChemistryPathways.HempBuds", 0.3)

-- Medical storage (cured buds for tincture preparation)
dist("MedicalStorageDrugs",  "PhobosChemistryPathways.HempBudsCured", 0.1)


-- ===== SMOKING ITEMS =====
-- Smoke shops, bars, bedrooms

-- Smoke shop counters (cigarette packs, rolling papers)
dist("StoreCounterTobacco",  "PhobosChemistryPathways.CigarettePackRolled", 0.3)
dist("StoreCounterTobacco",  "PhobosChemistryPathways.RollingPapers", 0.5)

-- Bar counters (glass pipe — rare novelty)
dist("BarCounterMisc",       "PhobosChemistryPathways.SmokingPipeGlass", 0.1)

-- Bedrooms (glass pipe — personal possession)
dist("BedroomDresser",       "PhobosChemistryPathways.SmokingPipeGlass", 0.05)

-- General shelves (rolling papers)
dist("ShelfGeneric",         "PhobosChemistryPathways.RollingPapers", 0.1)


-- ===== PAPERMAKING =====
-- Hardware stores, classrooms, offices

-- Hardware stores (mould and deckle — artisan tool)
dist("ToolStoreMisc",        "PhobosChemistryPathways.MouldAndDeckle", 0.1)

-- Classrooms (rolling papers — art supply / craft paper)
dist("ClassroomShelves",     "PhobosChemistryPathways.RollingPapers", 0.2)

-- Office desks (rolling papers — occasional find)
dist("OfficeDesk",           "PhobosChemistryPathways.RollingPapers", 0.1)


-- ===== COOKING =====
-- Restaurant kitchens, bar shelves, cafeterias

-- Restaurant kitchen fridges (sugar syrup — cocktail/baking ingredient)
dist("RestaurantKitchenFridge", "PhobosChemistryPathways.SimpleSugarSyrup", 0.3)

-- Bar shelves (vanilla already stocks SimpleSyrup here — same product class)
dist("BarShelfLiquor",       "PhobosChemistryPathways.SimpleSugarSyrup", 0.2)

-- Cafeteria snacks (bottled syrup — sweet condiment)
dist("CafeteriaSnacks",     "PhobosChemistryPathways.SimpleSugarSyrup", 0.2)


-----------------------------------------------------
----------- B42 EXPANDED LOCATIONS ------------------
-----------------------------------------------------
-- Additional vanilla B42 ProceduralDistributions
-- locations identified during v1.3.0 audit.

-- ===== GARDEN STORES =====
-- Garden centres stock agricultural chemistry products
dist("GardenStoreMisc",      "PhobosChemistryPathways.BoneMeal", 0.3)
dist("GardenStoreMisc",      "PhobosChemistryPathways.SeedPressCake", 0.2)
dist("GardenStoreTools",    "PhobosChemistryPathways.MouldAndDeckle", 0.1)

-- ===== GARDEN CRATES =====
dist("CrateGardening",      "PhobosChemistryPathways.DilutedCompost", 0.3)
dist("CrateGardening",      "PhobosChemistryPathways.SeedPressCake", 0.2)
dist("CrateGardening",      "PhobosChemistryPathways.BoneMeal", 0.2)

-- ===== FARMING TOOL STORES =====
dist("ToolStoreFarming",    "PhobosChemistryPathways.SeedPressCake", 0.2)
dist("ToolStoreFarming",    "PhobosChemistryPathways.BoneMeal", 0.2)
dist("ToolStoreFarming",    "PhobosChemistryPathways.MineralFeedSupplement", 0.1)

-- ===== SCIENCE LABS & UNIVERSITY =====
-- Testing labs and university science storage stock reagents
dist("TestingLab",           "PhobosChemistryPathways.PotassiumHydroxide", 0.2)
dist("TestingLab",           "PhobosChemistryPathways.ActivatedCarbon", 0.2)
dist("TestingLab",           "PhobosChemistryPathways.SulphuricAcidBottle", 0.1)
dist("TestingLab",           "PhobosChemistryPathways.WoodMethanol", 0.1)
dist("LaboratoryLockers",   "PhobosChemistryPathways.Calcite", 0.2)
dist("LaboratoryLockers",   "PhobosChemistryPathways.BoneChar", 0.15)
dist("LaboratoryLockers",   "PhobosChemistryPathways.WoodMethanol", 0.1)
dist("LaboratoryGasStorage", "PhobosChemistryPathways.SulphuricAcidJar", 0.1)
dist("LaboratoryGasStorage", "PhobosChemistryPathways.SulphuricAcidBottle", 0.1)
dist("UniversityStorageScience", "PhobosChemistryPathways.BkChemistryPathways", 0.05)
dist("UniversityStorageScience", "PhobosChemistryPathways.BkLabChemistry", 0.1)

-- ===== MORGUE =====
-- Morgue chemical cabinets stock caustic reagents
dist("MorgueChemicals",     "PhobosChemistryPathways.PotassiumHydroxide", 0.15)
dist("MorgueChemicals",     "PhobosChemistryPathways.ActivatedCarbon", 0.1)

-- ===== METALWORK & FACTORY =====
-- Metal shops and factories have salvage materials
dist("MetalShopTools",      "PhobosChemistryPathways.LeadScrap", 0.2)
dist("MetalShopTools",      "PhobosChemistryPathways.PlasticScrap", 0.15)
dist("ToolFactoryTools",    "PhobosChemistryPathways.AcidWashedElectronics", 0.1)
dist("ToolFactoryTools",    "PhobosChemistryPathways.PlasticScrap", 0.2)

-- ===== CONSTRUCTION =====
-- Construction workers carry building materials
dist("ConstructionWorkerTools", "PhobosChemistryPathways.MortarMix", 0.15)
dist("ConstructionWorkerTools", "PhobosChemistryPathways.StuccoMix", 0.1)
dist("ConstructionWorkerTools", "PhobosChemistryPathways.HempcreteBlock", 0.1)

-- ===== CAMPING CRATES =====
-- Camping supply crates stock survival rope and trapping gear
dist("CrateCamping",        "PhobosChemistryPathways.HempRope", 0.2)
dist("CrateCamping",        "PhobosChemistryPathways.HempTwine", 0.3)
dist("CrateCamping",        "PhobosChemistryPathways.HempSnare", 0.15)
dist("CrateCamping",        "PhobosChemistryPathways.HempSheetRope", 0.1)
