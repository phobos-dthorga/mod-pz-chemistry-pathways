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
------------- CATEGORY RECIPE BOOKS -----------------
-----------------------------------------------------
-- 5 category-specific books + 1 ultra-rare master compendium.
-- Each category book teaches only its own category's recipes.
-- Master compendium teaches ALL 275 recipes — ultra-rare jackpot find.
-- Rarity tiers based on survival value: practical books are easier to find.

-- ===== BkFieldChemistry (Common) =====
-- Practical field recipes — most accessible book
table.insert(ProceduralDistributions.list["ShelfGeneric"].items, "PhobosChemistryPathways.BkFieldChemistry")
table.insert(ProceduralDistributions.list["ShelfGeneric"].items, 1.5)

table.insert(ProceduralDistributions.list["CrateBooks"].items, "PhobosChemistryPathways.BkFieldChemistry")
table.insert(ProceduralDistributions.list["CrateBooks"].items, 1)

table.insert(ProceduralDistributions.list["BookstoreBooks"].items, "PhobosChemistryPathways.BkFieldChemistry")
table.insert(ProceduralDistributions.list["BookstoreBooks"].items, 2.5)

table.insert(ProceduralDistributions.list["GarageTools"].items, "PhobosChemistryPathways.BkFieldChemistry")
table.insert(ProceduralDistributions.list["GarageTools"].items, 0.5)

table.insert(ProceduralDistributions.list["CrateFertilizer"].items, "PhobosChemistryPathways.BkFieldChemistry")
table.insert(ProceduralDistributions.list["CrateFertilizer"].items, 1)

-- ===== BkKitchenChemistry (Medium) =====
table.insert(ProceduralDistributions.list["BookstoreBooks"].items, "PhobosChemistryPathways.BkKitchenChemistry")
table.insert(ProceduralDistributions.list["BookstoreBooks"].items, 2)

table.insert(ProceduralDistributions.list["ClassroomShelves"].items, "PhobosChemistryPathways.BkKitchenChemistry")
table.insert(ProceduralDistributions.list["ClassroomShelves"].items, 0.8)

table.insert(ProceduralDistributions.list["ShelfGeneric"].items, "PhobosChemistryPathways.BkKitchenChemistry")
table.insert(ProceduralDistributions.list["ShelfGeneric"].items, 0.8)

table.insert(ProceduralDistributions.list["LibraryScience"].items, "PhobosChemistryPathways.BkKitchenChemistry")
table.insert(ProceduralDistributions.list["LibraryScience"].items, 0.5)

-- ===== BkLabChemistry (Rare) =====
-- Found primarily in laboratories and universities
table.insert(ProceduralDistributions.list["LaboratoryBooks"].items, "PhobosChemistryPathways.BkLabChemistry")
table.insert(ProceduralDistributions.list["LaboratoryBooks"].items, 2)

table.insert(ProceduralDistributions.list["MedicalOfficeBooks"].items, "PhobosChemistryPathways.BkLabChemistry")
table.insert(ProceduralDistributions.list["MedicalOfficeBooks"].items, 1.5)

table.insert(ProceduralDistributions.list["BookstoreBooks"].items, "PhobosChemistryPathways.BkLabChemistry")
table.insert(ProceduralDistributions.list["BookstoreBooks"].items, 1.5)

table.insert(ProceduralDistributions.list["UniversityLibraryScience"].items, "PhobosChemistryPathways.BkLabChemistry")
table.insert(ProceduralDistributions.list["UniversityLibraryScience"].items, 1.5)

table.insert(ProceduralDistributions.list["LibraryScience"].items, "PhobosChemistryPathways.BkLabChemistry")
table.insert(ProceduralDistributions.list["LibraryScience"].items, 1)

table.insert(ProceduralDistributions.list["ClassroomShelves"].items, "PhobosChemistryPathways.BkLabChemistry")
table.insert(ProceduralDistributions.list["ClassroomShelves"].items, 0.5)

-- ===== BkIndustrialChemistry (Very Rare) =====
table.insert(ProceduralDistributions.list["BookstoreBooks"].items, "PhobosChemistryPathways.BkIndustrialChemistry")
table.insert(ProceduralDistributions.list["BookstoreBooks"].items, 0.8)

table.insert(ProceduralDistributions.list["GarageTools"].items, "PhobosChemistryPathways.BkIndustrialChemistry")
table.insert(ProceduralDistributions.list["GarageTools"].items, 0.3)

table.insert(ProceduralDistributions.list["UniversityStorageScience"].items, "PhobosChemistryPathways.BkIndustrialChemistry")
table.insert(ProceduralDistributions.list["UniversityStorageScience"].items, 0.5)

table.insert(ProceduralDistributions.list["LaboratoryBooks"].items, "PhobosChemistryPathways.BkIndustrialChemistry")
table.insert(ProceduralDistributions.list["LaboratoryBooks"].items, 0.3)

-- ===== BkHorticulture (Common-Medium) =====
table.insert(ProceduralDistributions.list["BookstoreBooks"].items, "PhobosChemistryPathways.BkHorticulture")
table.insert(ProceduralDistributions.list["BookstoreBooks"].items, 2)

table.insert(ProceduralDistributions.list["ShelfGeneric"].items, "PhobosChemistryPathways.BkHorticulture")
table.insert(ProceduralDistributions.list["ShelfGeneric"].items, 1)

table.insert(ProceduralDistributions.list["CrateBooks"].items, "PhobosChemistryPathways.BkHorticulture")
table.insert(ProceduralDistributions.list["CrateBooks"].items, 0.8)

table.insert(ProceduralDistributions.list["CrateFertilizer"].items, "PhobosChemistryPathways.BkHorticulture")
table.insert(ProceduralDistributions.list["CrateFertilizer"].items, 1.5)

table.insert(ProceduralDistributions.list["ClassroomShelves"].items, "PhobosChemistryPathways.BkHorticulture")
table.insert(ProceduralDistributions.list["ClassroomShelves"].items, 0.5)

table.insert(ProceduralDistributions.list["LibraryScience"].items, "PhobosChemistryPathways.BkHorticulture")
table.insert(ProceduralDistributions.list["LibraryScience"].items, 0.5)

-- ===== BkChemistryPathways — Master Compendium (Ultra-Rare) =====
-- Teaches ALL 275 recipes. Jackpot find for dedicated survivors.
table.insert(ProceduralDistributions.list["LaboratoryBooks"].items, "PhobosChemistryPathways.BkChemistryPathways")
table.insert(ProceduralDistributions.list["LaboratoryBooks"].items, 0.3)

table.insert(ProceduralDistributions.list["UniversityLibraryScience"].items, "PhobosChemistryPathways.BkChemistryPathways")
table.insert(ProceduralDistributions.list["UniversityLibraryScience"].items, 0.2)

table.insert(ProceduralDistributions.list["BookstoreBooks"].items, "PhobosChemistryPathways.BkChemistryPathways")
table.insert(ProceduralDistributions.list["BookstoreBooks"].items, 0.2)

table.insert(ProceduralDistributions.list["MedicalOfficeBooks"].items, "PhobosChemistryPathways.BkChemistryPathways")
table.insert(ProceduralDistributions.list["MedicalOfficeBooks"].items, 0.1)


-----------------------------------------------------
--------------- SULPHUR POWDER ----------------------
-----------------------------------------------------
-- Found in: chemistry labs, farming supply (fungicide),
-- industrial warehouses, hardware/tool stores

-- Farming and garden supply (sulphur is a common fungicide/soil amendment)
table.insert(ProceduralDistributions.list["CrateFertilizer"].items, "PhobosChemistryPathways.SulphurPowder")
table.insert(ProceduralDistributions.list["CrateFertilizer"].items, 2)

-- Janitor / cleaning chemical storage
table.insert(ProceduralDistributions.list["JanitorChemicals"].items, "PhobosChemistryPathways.SulphurPowder")
table.insert(ProceduralDistributions.list["JanitorChemicals"].items, 1)

table.insert(ProceduralDistributions.list["JanitorMisc"].items, "PhobosChemistryPathways.SulphurPowder")
table.insert(ProceduralDistributions.list["JanitorMisc"].items, 0.5)

-- Medical / lab storage (reagent)
table.insert(ProceduralDistributions.list["MedicalStorageDrugs"].items, "PhobosChemistryPathways.SulphurPowder")
table.insert(ProceduralDistributions.list["MedicalStorageDrugs"].items, 1)

table.insert(ProceduralDistributions.list["MedicalClinicDrugs"].items, "PhobosChemistryPathways.SulphurPowder")
table.insert(ProceduralDistributions.list["MedicalClinicDrugs"].items, 0.5)

-- Hardware / tool stores (used in various industrial applications)
table.insert(ProceduralDistributions.list["ToolStoreMisc"].items, "PhobosChemistryPathways.SulphurPowder")
table.insert(ProceduralDistributions.list["ToolStoreMisc"].items, 1)

-- Army surplus (military chemical stores)
table.insert(ProceduralDistributions.list["ArmySurplusTools"].items, "PhobosChemistryPathways.SulphurPowder")
table.insert(ProceduralDistributions.list["ArmySurplusTools"].items, 0.5)

table.insert(ProceduralDistributions.list["ArmyStorageMedical"].items, "PhobosChemistryPathways.SulphurPowder")
table.insert(ProceduralDistributions.list["ArmyStorageMedical"].items, 0.5)

-- Farmer truck beds
table.insert(VehicleDistributions.FarmerTruckBed.items, "PhobosChemistryPathways.SulphurPowder")
table.insert(VehicleDistributions.FarmerTruckBed.items, 1)

-- Survivalist stash
table.insert(VehicleDistributions.SurvivalistTruckBed.items, "PhobosChemistryPathways.SulphurPowder")
table.insert(VehicleDistributions.SurvivalistTruckBed.items, 0.5)


-----------------------------------------------------
----------- POTASSIUM NITRATE POWDER ----------------
-----------------------------------------------------
-- Found in: farming supply (fertiliser component / stump remover),
-- garden stores, chemistry labs, hardware stores

-- Farming and garden supply (KNO3 is sold as stump remover and fertiliser)
table.insert(ProceduralDistributions.list["CrateFertilizer"].items, "PhobosChemistryPathways.PotassiumNitratePowder")
table.insert(ProceduralDistributions.list["CrateFertilizer"].items, 2)

-- Janitor / cleaning storage
table.insert(ProceduralDistributions.list["JanitorChemicals"].items, "PhobosChemistryPathways.PotassiumNitratePowder")
table.insert(ProceduralDistributions.list["JanitorChemicals"].items, 1)

table.insert(ProceduralDistributions.list["JanitorMisc"].items, "PhobosChemistryPathways.PotassiumNitratePowder")
table.insert(ProceduralDistributions.list["JanitorMisc"].items, 0.5)

-- Medical / lab storage (reagent)
table.insert(ProceduralDistributions.list["MedicalStorageDrugs"].items, "PhobosChemistryPathways.PotassiumNitratePowder")
table.insert(ProceduralDistributions.list["MedicalStorageDrugs"].items, 1)

table.insert(ProceduralDistributions.list["MedicalClinicDrugs"].items, "PhobosChemistryPathways.PotassiumNitratePowder")
table.insert(ProceduralDistributions.list["MedicalClinicDrugs"].items, 0.5)

-- Hardware / tool stores (stump remover, industrial)
table.insert(ProceduralDistributions.list["ToolStoreMisc"].items, "PhobosChemistryPathways.PotassiumNitratePowder")
table.insert(ProceduralDistributions.list["ToolStoreMisc"].items, 1)

table.insert(ProceduralDistributions.list["StoreShelfMechanics"].items, "PhobosChemistryPathways.PotassiumNitratePowder")
table.insert(ProceduralDistributions.list["StoreShelfMechanics"].items, 0.5)

-- Garage / workshop (general chemical)
table.insert(ProceduralDistributions.list["GarageTools"].items, "PhobosChemistryPathways.PotassiumNitratePowder")
table.insert(ProceduralDistributions.list["GarageTools"].items, 0.3)

-- Army surplus
table.insert(ProceduralDistributions.list["ArmySurplusTools"].items, "PhobosChemistryPathways.PotassiumNitratePowder")
table.insert(ProceduralDistributions.list["ArmySurplusTools"].items, 0.5)

table.insert(ProceduralDistributions.list["ArmyStorageMedical"].items, "PhobosChemistryPathways.PotassiumNitratePowder")
table.insert(ProceduralDistributions.list["ArmyStorageMedical"].items, 0.5)

-- Farmer truck beds
table.insert(VehicleDistributions.FarmerTruckBed.items, "PhobosChemistryPathways.PotassiumNitratePowder")
table.insert(VehicleDistributions.FarmerTruckBed.items, 1)

-- Survivalist stash
table.insert(VehicleDistributions.SurvivalistTruckBed.items, "PhobosChemistryPathways.PotassiumNitratePowder")
table.insert(VehicleDistributions.SurvivalistTruckBed.items, 0.5)


-----------------------------------------------------
----------- POTASSIUM HYDROXIDE (KOH) --------------
-----------------------------------------------------
-- Found in: hardware stores (drain cleaner / lye),
-- janitor chemical storage, medical/lab storage

-- Hardware stores (drain cleaner / lye)
table.insert(ProceduralDistributions.list["ToolStoreMisc"].items, "PhobosChemistryPathways.PotassiumHydroxide")
table.insert(ProceduralDistributions.list["ToolStoreMisc"].items, 0.5)

-- Janitor chemical storage
table.insert(ProceduralDistributions.list["JanitorChemicals"].items, "PhobosChemistryPathways.PotassiumHydroxide")
table.insert(ProceduralDistributions.list["JanitorChemicals"].items, 0.5)

-- Medical / lab storage
table.insert(ProceduralDistributions.list["MedicalStorageDrugs"].items, "PhobosChemistryPathways.PotassiumHydroxide")
table.insert(ProceduralDistributions.list["MedicalStorageDrugs"].items, 0.3)


-----------------------------------------------------
-------------- WOOD METHANOL -----------------------
-----------------------------------------------------
-- Found in: hardware stores (paint thinner / solvent),
-- garages, janitor supplies, mechanics shelves

-- Hardware stores (solvent / methylated spirits)
table.insert(ProceduralDistributions.list["ToolStoreMisc"].items, "PhobosChemistryPathways.WoodMethanol")
table.insert(ProceduralDistributions.list["ToolStoreMisc"].items, 0.5)

-- Garage / workshop
table.insert(ProceduralDistributions.list["GarageTools"].items, "PhobosChemistryPathways.WoodMethanol")
table.insert(ProceduralDistributions.list["GarageTools"].items, 0.3)

-- Janitor supplies
table.insert(ProceduralDistributions.list["JanitorChemicals"].items, "PhobosChemistryPathways.WoodMethanol")
table.insert(ProceduralDistributions.list["JanitorChemicals"].items, 0.3)

-- Mechanics shelves
table.insert(ProceduralDistributions.list["StoreShelfMechanics"].items, "PhobosChemistryPathways.WoodMethanol")
table.insert(ProceduralDistributions.list["StoreShelfMechanics"].items, 0.3)


-----------------------------------------------------
----------------- GLYCEROL -------------------------
-----------------------------------------------------
-- Found in: medical storage (pharmaceutical glycerine)

-- Medical storage
table.insert(ProceduralDistributions.list["MedicalStorageDrugs"].items, "PhobosChemistryPathways.Glycerol")
table.insert(ProceduralDistributions.list["MedicalStorageDrugs"].items, 0.3)

table.insert(ProceduralDistributions.list["MedicalClinicDrugs"].items, "PhobosChemistryPathways.Glycerol")
table.insert(ProceduralDistributions.list["MedicalClinicDrugs"].items, 0.2)


-----------------------------------------------------
----------------- CALCITE (CHALK) ------------------
-----------------------------------------------------
-- Found in: school classrooms (blackboard chalk),
-- hardware stores (calcium carbonate filler),
-- farm supply (soil amendment / liming agent)

-- School classrooms (chalk sticks, science demo)
table.insert(ProceduralDistributions.list["ClassroomShelves"].items, "PhobosChemistryPathways.Calcite")
table.insert(ProceduralDistributions.list["ClassroomShelves"].items, 1)

table.insert(ProceduralDistributions.list["ClassroomDesk"].items, "PhobosChemistryPathways.Calcite")
table.insert(ProceduralDistributions.list["ClassroomDesk"].items, 0.5)

table.insert(ProceduralDistributions.list["ClassroomMisc"].items, "PhobosChemistryPathways.Calcite")
table.insert(ProceduralDistributions.list["ClassroomMisc"].items, 0.3)

-- Hardware stores (filler / calcium carbonate powder)
table.insert(ProceduralDistributions.list["ToolStoreMisc"].items, "PhobosChemistryPathways.Calcite")
table.insert(ProceduralDistributions.list["ToolStoreMisc"].items, 0.3)

-- Farming supply (agricultural lime / soil pH)
table.insert(ProceduralDistributions.list["CrateFertilizer"].items, "PhobosChemistryPathways.Calcite")
table.insert(ProceduralDistributions.list["CrateFertilizer"].items, 0.5)

-- Farmer truck beds
table.insert(VehicleDistributions.FarmerTruckBed.items, "PhobosChemistryPathways.Calcite")
table.insert(VehicleDistributions.FarmerTruckBed.items, 0.3)


-----------------------------------------------------
----------------- POTASH (K2CO3) -------------------
-----------------------------------------------------
-- Found in: farm/garden supply (potash fertiliser),
-- hardware stores (water softener / pH adjuster),
-- janitor supplies (cleaning agent)

-- Farming and garden supply (potash fertiliser, soil amendment)
table.insert(ProceduralDistributions.list["CrateFertilizer"].items, "PhobosChemistryPathways.Potash")
table.insert(ProceduralDistributions.list["CrateFertilizer"].items, 1)

-- Hardware stores (water softener)
table.insert(ProceduralDistributions.list["ToolStoreMisc"].items, "PhobosChemistryPathways.Potash")
table.insert(ProceduralDistributions.list["ToolStoreMisc"].items, 0.3)

-- Janitor chemical storage
table.insert(ProceduralDistributions.list["JanitorChemicals"].items, "PhobosChemistryPathways.Potash")
table.insert(ProceduralDistributions.list["JanitorChemicals"].items, 0.3)

-- Medical / lab storage (analytical reagent)
table.insert(ProceduralDistributions.list["MedicalStorageDrugs"].items, "PhobosChemistryPathways.Potash")
table.insert(ProceduralDistributions.list["MedicalStorageDrugs"].items, 0.2)

-- Farmer truck beds (common fertiliser component)
table.insert(VehicleDistributions.FarmerTruckBed.items, "PhobosChemistryPathways.Potash")
table.insert(VehicleDistributions.FarmerTruckBed.items, 0.5)


-----------------------------------------------------
------------ CRUSHED CHARCOAL ----------------------
-----------------------------------------------------
-- Found in: medical storage (activated charcoal for
-- poison treatment), garages (filtration media),
-- survivalist stashes (water purification)

-- Medical storage (activated charcoal / poison antidote)
table.insert(ProceduralDistributions.list["MedicalStorageDrugs"].items, "PhobosChemistryPathways.CrushedCharcoal")
table.insert(ProceduralDistributions.list["MedicalStorageDrugs"].items, 0.3)

table.insert(ProceduralDistributions.list["MedicalClinicDrugs"].items, "PhobosChemistryPathways.CrushedCharcoal")
table.insert(ProceduralDistributions.list["MedicalClinicDrugs"].items, 0.2)

-- Garage / workshop (filtration / cleaning)
table.insert(ProceduralDistributions.list["GarageTools"].items, "PhobosChemistryPathways.CrushedCharcoal")
table.insert(ProceduralDistributions.list["GarageTools"].items, 0.2)

-- Survivalist stash (water purification prep)
table.insert(VehicleDistributions.SurvivalistTruckBed.items, "PhobosChemistryPathways.CrushedCharcoal")
table.insert(VehicleDistributions.SurvivalistTruckBed.items, 0.3)


-----------------------------------------------------
----------- PURIFIED CHARCOAL ----------------------
-----------------------------------------------------
-- Found in: medical/lab storage only (lab-grade
-- activated carbon is a specialist reagent)

-- Medical / lab storage (pharmaceutical-grade activated carbon)
table.insert(ProceduralDistributions.list["MedicalStorageDrugs"].items, "PhobosChemistryPathways.PurifiedCharcoal")
table.insert(ProceduralDistributions.list["MedicalStorageDrugs"].items, 0.1)


-----------------------------------------------------
----------------- WOOD TAR -------------------------
-----------------------------------------------------
-- Found in: hardware stores (wood preservative / sealant),
-- farm supply (pine tar for fencing/timber treatment),
-- garages (rustproofing / lubricant)

-- Hardware stores (wood preservative / pine tar)
table.insert(ProceduralDistributions.list["ToolStoreMisc"].items, "PhobosChemistryPathways.WoodTar")
table.insert(ProceduralDistributions.list["ToolStoreMisc"].items, 0.3)

-- Farm supply (timber treatment / fencing tar)
table.insert(ProceduralDistributions.list["CrateFertilizer"].items, "PhobosChemistryPathways.WoodTar")
table.insert(ProceduralDistributions.list["CrateFertilizer"].items, 0.2)

-- Garage / workshop (sealant / lubricant)
table.insert(ProceduralDistributions.list["GarageTools"].items, "PhobosChemistryPathways.WoodTar")
table.insert(ProceduralDistributions.list["GarageTools"].items, 0.2)

-- Mechanics shelves
table.insert(ProceduralDistributions.list["StoreShelfMechanics"].items, "PhobosChemistryPathways.WoodTar")
table.insert(ProceduralDistributions.list["StoreShelfMechanics"].items, 0.2)

-- Farmer truck beds
table.insert(VehicleDistributions.FarmerTruckBed.items, "PhobosChemistryPathways.WoodTar")
table.insert(VehicleDistributions.FarmerTruckBed.items, 0.2)


-----------------------------------------------------
-------------- CRUDE SOAP --------------------------
-----------------------------------------------------
-- Found in: rural/farm households (homemade lye soap),
-- survivalist stashes (handmade hygiene supplies)

-- Farmhouse kitchen shelves (homemade soap tradition)
table.insert(ProceduralDistributions.list["ShelfGeneric"].items, "PhobosChemistryPathways.CrudeSoap")
table.insert(ProceduralDistributions.list["ShelfGeneric"].items, 0.1)

-- Survivalist stash (handmade soap)
table.insert(VehicleDistributions.SurvivalistTruckBed.items, "PhobosChemistryPathways.CrudeSoap")
table.insert(VehicleDistributions.SurvivalistTruckBed.items, 0.2)


-----------------------------------------------------
-------- APPLIED CHEMISTRY SKILL BOOKS -------------
-----------------------------------------------------
-- Vol 1-2: Bookstores, classrooms, medical offices
-- Vol 3-4: Medical offices, labs (rare)
-- Vol 5:   Medical storage only (very rare)

-- ===== Volume 1 (Levels 1-2) =====
table.insert(ProceduralDistributions.list["BookstoreBooks"].items, "PhobosChemistryPathways.BookAppliedChemistry1")
table.insert(ProceduralDistributions.list["BookstoreBooks"].items, 1.5)

table.insert(ProceduralDistributions.list["ClassroomShelves"].items, "PhobosChemistryPathways.BookAppliedChemistry1")
table.insert(ProceduralDistributions.list["ClassroomShelves"].items, 0.8)

table.insert(ProceduralDistributions.list["CrateBooks"].items, "PhobosChemistryPathways.BookAppliedChemistry1")
table.insert(ProceduralDistributions.list["CrateBooks"].items, 0.5)

table.insert(ProceduralDistributions.list["MedicalOfficeBooks"].items, "PhobosChemistryPathways.BookAppliedChemistry1")
table.insert(ProceduralDistributions.list["MedicalOfficeBooks"].items, 1)

table.insert(ProceduralDistributions.list["ShelfGeneric"].items, "PhobosChemistryPathways.BookAppliedChemistry1")
table.insert(ProceduralDistributions.list["ShelfGeneric"].items, 0.3)

-- ===== Volume 2 (Levels 3-4) =====
table.insert(ProceduralDistributions.list["BookstoreBooks"].items, "PhobosChemistryPathways.BookAppliedChemistry2")
table.insert(ProceduralDistributions.list["BookstoreBooks"].items, 1)

table.insert(ProceduralDistributions.list["ClassroomShelves"].items, "PhobosChemistryPathways.BookAppliedChemistry2")
table.insert(ProceduralDistributions.list["ClassroomShelves"].items, 0.5)

table.insert(ProceduralDistributions.list["CrateBooks"].items, "PhobosChemistryPathways.BookAppliedChemistry2")
table.insert(ProceduralDistributions.list["CrateBooks"].items, 0.3)

table.insert(ProceduralDistributions.list["MedicalOfficeBooks"].items, "PhobosChemistryPathways.BookAppliedChemistry2")
table.insert(ProceduralDistributions.list["MedicalOfficeBooks"].items, 1)

-- ===== Volume 3 (Levels 5-6) =====
table.insert(ProceduralDistributions.list["MedicalOfficeBooks"].items, "PhobosChemistryPathways.BookAppliedChemistry3")
table.insert(ProceduralDistributions.list["MedicalOfficeBooks"].items, 0.5)

table.insert(ProceduralDistributions.list["MedicalStorageDrugs"].items, "PhobosChemistryPathways.BookAppliedChemistry3")
table.insert(ProceduralDistributions.list["MedicalStorageDrugs"].items, 0.3)

table.insert(ProceduralDistributions.list["BookstoreBooks"].items, "PhobosChemistryPathways.BookAppliedChemistry3")
table.insert(ProceduralDistributions.list["BookstoreBooks"].items, 0.5)

-- ===== Volume 4 (Levels 7-8) =====
table.insert(ProceduralDistributions.list["MedicalOfficeBooks"].items, "PhobosChemistryPathways.BookAppliedChemistry4")
table.insert(ProceduralDistributions.list["MedicalOfficeBooks"].items, 0.3)

table.insert(ProceduralDistributions.list["MedicalStorageDrugs"].items, "PhobosChemistryPathways.BookAppliedChemistry4")
table.insert(ProceduralDistributions.list["MedicalStorageDrugs"].items, 0.2)

-- ===== Volume 5 (Levels 9-10) =====
table.insert(ProceduralDistributions.list["MedicalStorageDrugs"].items, "PhobosChemistryPathways.BookAppliedChemistry5")
table.insert(ProceduralDistributions.list["MedicalStorageDrugs"].items, 0.1)


-----------------------------------------------------
------- LAB & UNIVERSITY DISTRIBUTION EXPANSION -----
-----------------------------------------------------
-- New lab/university containers discovered in vanilla PZ B42.
-- Adds thematic spawns for chemistry books, reagents, and
-- select recipe-only items at low weights.

-- ===== Skill Books → lab/university shelves =====
table.insert(ProceduralDistributions.list["LaboratoryBooks"].items, "PhobosChemistryPathways.BookAppliedChemistry1")
table.insert(ProceduralDistributions.list["LaboratoryBooks"].items, 1)
table.insert(ProceduralDistributions.list["UniversityLibraryScience"].items, "PhobosChemistryPathways.BookAppliedChemistry1")
table.insert(ProceduralDistributions.list["UniversityLibraryScience"].items, 1)

table.insert(ProceduralDistributions.list["LaboratoryBooks"].items, "PhobosChemistryPathways.BookAppliedChemistry2")
table.insert(ProceduralDistributions.list["LaboratoryBooks"].items, 0.8)
table.insert(ProceduralDistributions.list["UniversityLibraryScience"].items, "PhobosChemistryPathways.BookAppliedChemistry2")
table.insert(ProceduralDistributions.list["UniversityLibraryScience"].items, 0.8)

table.insert(ProceduralDistributions.list["LaboratoryBooks"].items, "PhobosChemistryPathways.BookAppliedChemistry3")
table.insert(ProceduralDistributions.list["LaboratoryBooks"].items, 0.5)
table.insert(ProceduralDistributions.list["UniversityLibraryScience"].items, "PhobosChemistryPathways.BookAppliedChemistry3")
table.insert(ProceduralDistributions.list["UniversityLibraryScience"].items, 0.5)

table.insert(ProceduralDistributions.list["LaboratoryBooks"].items, "PhobosChemistryPathways.BookAppliedChemistry4")
table.insert(ProceduralDistributions.list["LaboratoryBooks"].items, 0.3)
table.insert(ProceduralDistributions.list["UniversityLibraryScience"].items, "PhobosChemistryPathways.BookAppliedChemistry4")
table.insert(ProceduralDistributions.list["UniversityLibraryScience"].items, 0.3)

table.insert(ProceduralDistributions.list["LaboratoryBooks"].items, "PhobosChemistryPathways.BookAppliedChemistry5")
table.insert(ProceduralDistributions.list["LaboratoryBooks"].items, 0.1)
table.insert(ProceduralDistributions.list["UniversityLibraryScience"].items, "PhobosChemistryPathways.BookAppliedChemistry5")
table.insert(ProceduralDistributions.list["UniversityLibraryScience"].items, 0.2)

-- ===== Chemical reagents → lab containers =====
table.insert(ProceduralDistributions.list["TestingLab"].items, "PhobosChemistryPathways.SulphurPowder")
table.insert(ProceduralDistributions.list["TestingLab"].items, 0.5)
table.insert(ProceduralDistributions.list["ScienceMisc"].items, "PhobosChemistryPathways.SulphurPowder")
table.insert(ProceduralDistributions.list["ScienceMisc"].items, 0.3)
table.insert(ProceduralDistributions.list["UniversityStorageScience"].items, "PhobosChemistryPathways.SulphurPowder")
table.insert(ProceduralDistributions.list["UniversityStorageScience"].items, 0.3)

table.insert(ProceduralDistributions.list["TestingLab"].items, "PhobosChemistryPathways.PotassiumNitratePowder")
table.insert(ProceduralDistributions.list["TestingLab"].items, 0.5)
table.insert(ProceduralDistributions.list["ScienceMisc"].items, "PhobosChemistryPathways.PotassiumNitratePowder")
table.insert(ProceduralDistributions.list["ScienceMisc"].items, 0.3)
table.insert(ProceduralDistributions.list["UniversityStorageScience"].items, "PhobosChemistryPathways.PotassiumNitratePowder")
table.insert(ProceduralDistributions.list["UniversityStorageScience"].items, 0.3)

table.insert(ProceduralDistributions.list["TestingLab"].items, "PhobosChemistryPathways.PotassiumHydroxide")
table.insert(ProceduralDistributions.list["TestingLab"].items, 0.3)
table.insert(ProceduralDistributions.list["ScienceMisc"].items, "PhobosChemistryPathways.PotassiumHydroxide")
table.insert(ProceduralDistributions.list["ScienceMisc"].items, 0.3)
table.insert(ProceduralDistributions.list["UniversityStorageScience"].items, "PhobosChemistryPathways.PotassiumHydroxide")
table.insert(ProceduralDistributions.list["UniversityStorageScience"].items, 0.2)

table.insert(ProceduralDistributions.list["ScienceMisc"].items, "PhobosChemistryPathways.Calcite")
table.insert(ProceduralDistributions.list["ScienceMisc"].items, 0.3)
table.insert(ProceduralDistributions.list["UniversityStorageScience"].items, "PhobosChemistryPathways.Calcite")
table.insert(ProceduralDistributions.list["UniversityStorageScience"].items, 0.2)

table.insert(ProceduralDistributions.list["ScienceMisc"].items, "PhobosChemistryPathways.Potash")
table.insert(ProceduralDistributions.list["ScienceMisc"].items, 0.2)
table.insert(ProceduralDistributions.list["UniversityStorageScience"].items, "PhobosChemistryPathways.Potash")
table.insert(ProceduralDistributions.list["UniversityStorageScience"].items, 0.2)

-- ===== Carbon materials & glycerol =====
table.insert(ProceduralDistributions.list["TestingLab"].items, "PhobosChemistryPathways.CrushedCharcoal")
table.insert(ProceduralDistributions.list["TestingLab"].items, 0.2)
table.insert(ProceduralDistributions.list["ScienceMisc"].items, "PhobosChemistryPathways.CrushedCharcoal")
table.insert(ProceduralDistributions.list["ScienceMisc"].items, 0.2)

table.insert(ProceduralDistributions.list["TestingLab"].items, "PhobosChemistryPathways.PurifiedCharcoal")
table.insert(ProceduralDistributions.list["TestingLab"].items, 0.1)
table.insert(ProceduralDistributions.list["ScienceMisc"].items, "PhobosChemistryPathways.PurifiedCharcoal")
table.insert(ProceduralDistributions.list["ScienceMisc"].items, 0.1)

table.insert(ProceduralDistributions.list["TestingLab"].items, "PhobosChemistryPathways.ActivatedCarbon")
table.insert(ProceduralDistributions.list["TestingLab"].items, 0.2)
table.insert(ProceduralDistributions.list["ScienceMisc"].items, "PhobosChemistryPathways.ActivatedCarbon")
table.insert(ProceduralDistributions.list["ScienceMisc"].items, 0.2)
table.insert(ProceduralDistributions.list["UniversityStorageScience"].items, "PhobosChemistryPathways.ActivatedCarbon")
table.insert(ProceduralDistributions.list["UniversityStorageScience"].items, 0.1)

table.insert(ProceduralDistributions.list["TestingLab"].items, "PhobosChemistryPathways.Glycerol")
table.insert(ProceduralDistributions.list["TestingLab"].items, 0.2)
table.insert(ProceduralDistributions.list["ScienceMisc"].items, "PhobosChemistryPathways.Glycerol")
table.insert(ProceduralDistributions.list["ScienceMisc"].items, 0.2)

-- ===== Recipe-only items — NEW low-weight lab spawns =====
-- Previously craft-only; realistic to find in a university chemistry lab.
table.insert(ProceduralDistributions.list["TestingLab"].items, "PhobosChemistryPathways.SulphuricAcidBottle")
table.insert(ProceduralDistributions.list["TestingLab"].items, 0.2)
table.insert(ProceduralDistributions.list["UniversityStorageScience"].items, "PhobosChemistryPathways.SulphuricAcidBottle")
table.insert(ProceduralDistributions.list["UniversityStorageScience"].items, 0.1)

table.insert(ProceduralDistributions.list["TestingLab"].items, "PhobosChemistryPathways.SulphuricAcidJar")
table.insert(ProceduralDistributions.list["TestingLab"].items, 0.1)
table.insert(ProceduralDistributions.list["ScienceMisc"].items, "PhobosChemistryPathways.SulphuricAcidJar")
table.insert(ProceduralDistributions.list["ScienceMisc"].items, 0.1)

table.insert(ProceduralDistributions.list["TestingLab"].items, "PhobosChemistryPathways.WoodMethanol")
table.insert(ProceduralDistributions.list["TestingLab"].items, 0.2)
table.insert(ProceduralDistributions.list["ScienceMisc"].items, "PhobosChemistryPathways.WoodMethanol")
table.insert(ProceduralDistributions.list["ScienceMisc"].items, 0.1)

table.insert(ProceduralDistributions.list["ScienceMisc"].items, "PhobosChemistryPathways.BrineJar")
table.insert(ProceduralDistributions.list["ScienceMisc"].items, 0.1)


-----------------------------------------------------
------------ BOTANICAL PATHWAY ITEMS ----------------
-----------------------------------------------------

-- Hemp Seed Bags — farm supply / garden centres / farm trucks
-- (vanilla HempBagSeed exists but adding to additional farm locations)
table.insert(ProceduralDistributions.list["CrateFertilizer"].items, "Base.HempBagSeed")
table.insert(ProceduralDistributions.list["CrateFertilizer"].items, 1)

table.insert(VehicleDistributions.FarmerTruckBed.items, "Base.HempBagSeed")
table.insert(VehicleDistributions.FarmerTruckBed.items, 0.5)

-- Hemp Twine — farm supply (baling twine), hardware stores
table.insert(ProceduralDistributions.list["CrateFertilizer"].items, "PhobosChemistryPathways.HempTwine")
table.insert(ProceduralDistributions.list["CrateFertilizer"].items, 0.5)

table.insert(ProceduralDistributions.list["ToolStoreMisc"].items, "PhobosChemistryPathways.HempTwine")
table.insert(ProceduralDistributions.list["ToolStoreMisc"].items, 0.3)

table.insert(ProceduralDistributions.list["GarageTools"].items, "PhobosChemistryPathways.HempTwine")
table.insert(ProceduralDistributions.list["GarageTools"].items, 0.2)

table.insert(VehicleDistributions.FarmerTruckBed.items, "PhobosChemistryPathways.HempTwine")
table.insert(VehicleDistributions.FarmerTruckBed.items, 0.3)

-- Hemp Rope — farm supply, hardware stores, survivalist stashes
table.insert(ProceduralDistributions.list["CrateFertilizer"].items, "PhobosChemistryPathways.HempRope")
table.insert(ProceduralDistributions.list["CrateFertilizer"].items, 0.3)

table.insert(ProceduralDistributions.list["ToolStoreMisc"].items, "PhobosChemistryPathways.HempRope")
table.insert(ProceduralDistributions.list["ToolStoreMisc"].items, 0.2)

table.insert(VehicleDistributions.SurvivalistTruckBed.items, "PhobosChemistryPathways.HempRope")
table.insert(VehicleDistributions.SurvivalistTruckBed.items, 0.2)

-- Hemp Cloth — sewing/textiles locations, survivalist stashes
table.insert(ProceduralDistributions.list["ShelfGeneric"].items, "PhobosChemistryPathways.HempCloth")
table.insert(ProceduralDistributions.list["ShelfGeneric"].items, 0.1)

table.insert(VehicleDistributions.SurvivalistTruckBed.items, "PhobosChemistryPathways.HempCloth")
table.insert(VehicleDistributions.SurvivalistTruckBed.items, 0.1)

-- Hemp Paper — bookstores, classrooms, medical offices (archival paper)
table.insert(ProceduralDistributions.list["BookstoreBooks"].items, "PhobosChemistryPathways.HempPaper")
table.insert(ProceduralDistributions.list["BookstoreBooks"].items, 0.2)

table.insert(ProceduralDistributions.list["ClassroomShelves"].items, "PhobosChemistryPathways.HempPaper")
table.insert(ProceduralDistributions.list["ClassroomShelves"].items, 0.1)

-- Hemp Poultice — medical storage, herbal remedy locations
table.insert(ProceduralDistributions.list["MedicalStorageDrugs"].items, "PhobosChemistryPathways.HempPoultice")
table.insert(ProceduralDistributions.list["MedicalStorageDrugs"].items, 0.2)

table.insert(ProceduralDistributions.list["MedicalClinicDrugs"].items, "PhobosChemistryPathways.HempPoultice")
table.insert(ProceduralDistributions.list["MedicalClinicDrugs"].items, 0.1)

-- Hemp Tincture — medical storage (herbal medicine)
table.insert(ProceduralDistributions.list["MedicalStorageDrugs"].items, "PhobosChemistryPathways.HempTincture")
table.insert(ProceduralDistributions.list["MedicalStorageDrugs"].items, 0.1)

-- Seed Press Cake — fertiliser crates, farm storage
table.insert(ProceduralDistributions.list["CrateFertilizer"].items, "PhobosChemistryPathways.SeedPressCake")
table.insert(ProceduralDistributions.list["CrateFertilizer"].items, 0.4)

table.insert(ProceduralDistributions.list["CrateFarming"].items, "PhobosChemistryPathways.SeedPressCake")
table.insert(ProceduralDistributions.list["CrateFarming"].items, 0.3)

-- Hemp Sack — farm storage, survivalist stashes
table.insert(ProceduralDistributions.list["CrateFarming"].items, "PhobosChemistryPathways.HempSack")
table.insert(ProceduralDistributions.list["CrateFarming"].items, 0.1)

table.insert(VehicleDistributions.SurvivalistTruckBed.items, "PhobosChemistryPathways.HempSack")
table.insert(VehicleDistributions.SurvivalistTruckBed.items, 0.1)

-- Oakum — tool stores, garages, fertiliser crates (wood tar product)
table.insert(ProceduralDistributions.list["ToolStoreMisc"].items, "PhobosChemistryPathways.Oakum")
table.insert(ProceduralDistributions.list["ToolStoreMisc"].items, 0.2)

table.insert(ProceduralDistributions.list["GarageTools"].items, "PhobosChemistryPathways.Oakum")
table.insert(ProceduralDistributions.list["GarageTools"].items, 0.2)

table.insert(ProceduralDistributions.list["CrateFertilizer"].items, "PhobosChemistryPathways.Oakum")
table.insert(ProceduralDistributions.list["CrateFertilizer"].items, 0.2)

-- Hemp Fishing Net — fishing stores, survivalist stashes
table.insert(ProceduralDistributions.list["FishingStoreGear"].items, "PhobosChemistryPathways.HempFishingNet")
table.insert(ProceduralDistributions.list["FishingStoreGear"].items, 0.2)

table.insert(VehicleDistributions.SurvivalistTruckBed.items, "PhobosChemistryPathways.HempFishingNet")
table.insert(VehicleDistributions.SurvivalistTruckBed.items, 0.1)

-- Hemp Sheet Rope — tool stores, survivalist stashes
table.insert(ProceduralDistributions.list["ToolStoreMisc"].items, "PhobosChemistryPathways.HempSheetRope")
table.insert(ProceduralDistributions.list["ToolStoreMisc"].items, 0.2)

table.insert(VehicleDistributions.SurvivalistTruckBed.items, "PhobosChemistryPathways.HempSheetRope")
table.insert(VehicleDistributions.SurvivalistTruckBed.items, 0.1)

-- Hemp Snare — survivalist stashes, camping stores
table.insert(VehicleDistributions.SurvivalistTruckBed.items, "PhobosChemistryPathways.HempSnare")
table.insert(VehicleDistributions.SurvivalistTruckBed.items, 0.2)

table.insert(ProceduralDistributions.list["CampingStoreGear"].items, "PhobosChemistryPathways.HempSnare")
table.insert(ProceduralDistributions.list["CampingStoreGear"].items, 0.2)


-----------------------------------------------------
------------ HORTICULTURE PATHWAY ITEMS -------------
-----------------------------------------------------

-- ===== TOBACCO PRODUCTS =====
-- Smoke shops, bars, living rooms

-- Smoke shop counters (chewing tobacco, rolled cigars)
table.insert(ProceduralDistributions.list["StoreCounterSmoke"].items, "PhobosChemistryPathways.ChewingTobacco")
table.insert(ProceduralDistributions.list["StoreCounterSmoke"].items, 0.5)

table.insert(ProceduralDistributions.list["StoreCounterSmoke"].items, "PhobosChemistryPathways.CigarRolled")
table.insert(ProceduralDistributions.list["StoreCounterSmoke"].items, 0.3)

-- Bar counters (chewing tobacco)
table.insert(ProceduralDistributions.list["BarCounterMisc"].items, "PhobosChemistryPathways.ChewingTobacco")
table.insert(ProceduralDistributions.list["BarCounterMisc"].items, 0.3)

-- Residential (occasional find)
table.insert(ProceduralDistributions.list["LivingRoomShelf"].items, "PhobosChemistryPathways.ChewingTobacco")
table.insert(ProceduralDistributions.list["LivingRoomShelf"].items, 0.1)

table.insert(ProceduralDistributions.list["KitchenRandom"].items, "PhobosChemistryPathways.ChewingTobacco")
table.insert(ProceduralDistributions.list["KitchenRandom"].items, 0.1)


-- ===== HEMP BUDS =====
-- Farm supply, garden, medical storage

-- Farm supply (fresh and cured buds)
table.insert(ProceduralDistributions.list["CrateFertilizer"].items, "PhobosChemistryPathways.HempBuds")
table.insert(ProceduralDistributions.list["CrateFertilizer"].items, 0.5)

table.insert(ProceduralDistributions.list["CrateFertilizer"].items, "PhobosChemistryPathways.HempBudsCured")
table.insert(ProceduralDistributions.list["CrateFertilizer"].items, 0.2)

-- Farmer trucks
table.insert(VehicleDistributions.FarmerTruckBed.items, "PhobosChemistryPathways.HempBuds")
table.insert(VehicleDistributions.FarmerTruckBed.items, 0.3)

-- Garden storage
table.insert(ProceduralDistributions.list["GardenStorageMisc"].items, "PhobosChemistryPathways.HempBuds")
table.insert(ProceduralDistributions.list["GardenStorageMisc"].items, 0.2)

-- Medical storage (cured buds for tincture preparation)
table.insert(ProceduralDistributions.list["MedicalStorageDrugs"].items, "PhobosChemistryPathways.HempBudsCured")
table.insert(ProceduralDistributions.list["MedicalStorageDrugs"].items, 0.1)


-- ===== SMOKING ITEMS =====
-- Smoke shops, bars, bedrooms

-- Smoke shop counters (cigarette packs, rolling papers)
table.insert(ProceduralDistributions.list["StoreCounterSmoke"].items, "PhobosChemistryPathways.CigarettePackRolled")
table.insert(ProceduralDistributions.list["StoreCounterSmoke"].items, 0.3)

table.insert(ProceduralDistributions.list["StoreCounterSmoke"].items, "PhobosChemistryPathways.RollingPapers")
table.insert(ProceduralDistributions.list["StoreCounterSmoke"].items, 0.5)

-- Bar counters (glass pipe — rare novelty)
table.insert(ProceduralDistributions.list["BarCounterMisc"].items, "PhobosChemistryPathways.SmokingPipeGlass")
table.insert(ProceduralDistributions.list["BarCounterMisc"].items, 0.1)

-- Bedrooms (glass pipe — personal possession)
table.insert(ProceduralDistributions.list["BedroomDresser"].items, "PhobosChemistryPathways.SmokingPipeGlass")
table.insert(ProceduralDistributions.list["BedroomDresser"].items, 0.05)

-- General shelves (rolling papers)
table.insert(ProceduralDistributions.list["ShelfGeneric"].items, "PhobosChemistryPathways.RollingPapers")
table.insert(ProceduralDistributions.list["ShelfGeneric"].items, 0.1)


-- ===== PAPERMAKING =====
-- Hardware stores, classrooms, offices

-- Hardware stores (mould and deckle — artisan tool)
table.insert(ProceduralDistributions.list["ToolStoreMisc"].items, "PhobosChemistryPathways.MouldAndDeckle")
table.insert(ProceduralDistributions.list["ToolStoreMisc"].items, 0.1)

-- Classrooms (rolling papers — art supply / craft paper)
table.insert(ProceduralDistributions.list["ClassroomShelves"].items, "PhobosChemistryPathways.RollingPapers")
table.insert(ProceduralDistributions.list["ClassroomShelves"].items, 0.2)

-- Office desks (rolling papers — occasional find)
table.insert(ProceduralDistributions.list["OfficeDesk"].items, "PhobosChemistryPathways.RollingPapers")
table.insert(ProceduralDistributions.list["OfficeDesk"].items, 0.1)


-- ===== COOKING =====
-- Restaurant kitchens, grocery stores

-- Restaurant kitchens (simple sugar syrup — cocktail/baking ingredient)
table.insert(ProceduralDistributions.list["RestaurantKitchen"].items, "PhobosChemistryPathways.SimpleSugarSyrup")
table.insert(ProceduralDistributions.list["RestaurantKitchen"].items, 0.3)

-- Grocery store snacks (bottled syrup)
table.insert(ProceduralDistributions.list["GroceryStoreSnacks"].items, "PhobosChemistryPathways.SimpleSugarSyrup")
table.insert(ProceduralDistributions.list["GroceryStoreSnacks"].items, 0.2)


-----------------------------------------------------
----------- B42 EXPANDED LOCATIONS ------------------
-----------------------------------------------------
-- Additional vanilla B42 ProceduralDistributions
-- locations identified during v1.3.0 audit.

-- ===== GARDEN STORES =====
-- Garden centres stock agricultural chemistry products
table.insert(ProceduralDistributions.list["GardenStoreMisc"].items, "PhobosChemistryPathways.SulphurFungicideSpray")
table.insert(ProceduralDistributions.list["GardenStoreMisc"].items, 0.3)

table.insert(ProceduralDistributions.list["GardenStoreMisc"].items, "PhobosChemistryPathways.InsecticidalSoapSpray")
table.insert(ProceduralDistributions.list["GardenStoreMisc"].items, 0.3)

table.insert(ProceduralDistributions.list["GardenStoreMisc"].items, "PhobosChemistryPathways.PotashFoliarSpray")
table.insert(ProceduralDistributions.list["GardenStoreMisc"].items, 0.2)

table.insert(ProceduralDistributions.list["GardenStoreMisc"].items, "PhobosChemistryPathways.BoneMeal")
table.insert(ProceduralDistributions.list["GardenStoreMisc"].items, 0.3)

table.insert(ProceduralDistributions.list["GardenStoreMisc"].items, "PhobosChemistryPathways.SeedPressCake")
table.insert(ProceduralDistributions.list["GardenStoreMisc"].items, 0.2)

table.insert(ProceduralDistributions.list["GardenStoreTools"].items, "PhobosChemistryPathways.MouldAndDeckle")
table.insert(ProceduralDistributions.list["GardenStoreTools"].items, 0.1)

-- ===== GARDEN CRATES =====
table.insert(ProceduralDistributions.list["CrateGardening"].items, "PhobosChemistryPathways.DilutedCompost")
table.insert(ProceduralDistributions.list["CrateGardening"].items, 0.3)

table.insert(ProceduralDistributions.list["CrateGardening"].items, "PhobosChemistryPathways.SeedPressCake")
table.insert(ProceduralDistributions.list["CrateGardening"].items, 0.2)

table.insert(ProceduralDistributions.list["CrateGardening"].items, "PhobosChemistryPathways.BoneMeal")
table.insert(ProceduralDistributions.list["CrateGardening"].items, 0.2)

-- ===== FARMING TOOL STORES =====
table.insert(ProceduralDistributions.list["ToolStoreFarming"].items, "PhobosChemistryPathways.SeedPressCake")
table.insert(ProceduralDistributions.list["ToolStoreFarming"].items, 0.2)

table.insert(ProceduralDistributions.list["ToolStoreFarming"].items, "PhobosChemistryPathways.BoneMeal")
table.insert(ProceduralDistributions.list["ToolStoreFarming"].items, 0.2)

table.insert(ProceduralDistributions.list["ToolStoreFarming"].items, "PhobosChemistryPathways.MineralFeedSupplement")
table.insert(ProceduralDistributions.list["ToolStoreFarming"].items, 0.1)

-- ===== SCIENCE LABS & UNIVERSITY =====
-- Testing labs and university science storage stock reagents
table.insert(ProceduralDistributions.list["TestingLab"].items, "PhobosChemistryPathways.PotassiumHydroxide")
table.insert(ProceduralDistributions.list["TestingLab"].items, 0.2)

table.insert(ProceduralDistributions.list["TestingLab"].items, "PhobosChemistryPathways.ActivatedCarbon")
table.insert(ProceduralDistributions.list["TestingLab"].items, 0.2)

table.insert(ProceduralDistributions.list["TestingLab"].items, "PhobosChemistryPathways.SulphuricAcidBottle")
table.insert(ProceduralDistributions.list["TestingLab"].items, 0.1)

table.insert(ProceduralDistributions.list["TestingLab"].items, "PhobosChemistryPathways.WoodMethanol")
table.insert(ProceduralDistributions.list["TestingLab"].items, 0.1)

table.insert(ProceduralDistributions.list["LaboratoryLockers"].items, "PhobosChemistryPathways.Calcite")
table.insert(ProceduralDistributions.list["LaboratoryLockers"].items, 0.2)

table.insert(ProceduralDistributions.list["LaboratoryLockers"].items, "PhobosChemistryPathways.BoneChar")
table.insert(ProceduralDistributions.list["LaboratoryLockers"].items, 0.15)

table.insert(ProceduralDistributions.list["LaboratoryLockers"].items, "PhobosChemistryPathways.WoodMethanol")
table.insert(ProceduralDistributions.list["LaboratoryLockers"].items, 0.1)

table.insert(ProceduralDistributions.list["LaboratoryGasStorage"].items, "PhobosChemistryPathways.SulphuricAcidJar")
table.insert(ProceduralDistributions.list["LaboratoryGasStorage"].items, 0.1)

table.insert(ProceduralDistributions.list["LaboratoryGasStorage"].items, "PhobosChemistryPathways.SulphuricAcidBottle")
table.insert(ProceduralDistributions.list["LaboratoryGasStorage"].items, 0.1)

table.insert(ProceduralDistributions.list["UniversityStorageScience"].items, "PhobosChemistryPathways.BkChemistryPathways")
table.insert(ProceduralDistributions.list["UniversityStorageScience"].items, 0.05)

table.insert(ProceduralDistributions.list["UniversityStorageScience"].items, "PhobosChemistryPathways.BkLabChemistry")
table.insert(ProceduralDistributions.list["UniversityStorageScience"].items, 0.1)

-- ===== MORGUE =====
-- Morgue chemical cabinets stock caustic reagents
table.insert(ProceduralDistributions.list["MorgueChemicals"].items, "PhobosChemistryPathways.PotassiumHydroxide")
table.insert(ProceduralDistributions.list["MorgueChemicals"].items, 0.15)

table.insert(ProceduralDistributions.list["MorgueChemicals"].items, "PhobosChemistryPathways.ActivatedCarbon")
table.insert(ProceduralDistributions.list["MorgueChemicals"].items, 0.1)

-- ===== METALWORK & FACTORY =====
-- Metal shops and factories have salvage materials
table.insert(ProceduralDistributions.list["MetalShopTools"].items, "PhobosChemistryPathways.LeadScrap")
table.insert(ProceduralDistributions.list["MetalShopTools"].items, 0.2)

table.insert(ProceduralDistributions.list["MetalShopTools"].items, "PhobosChemistryPathways.PlasticScrap")
table.insert(ProceduralDistributions.list["MetalShopTools"].items, 0.15)

table.insert(ProceduralDistributions.list["ToolFactoryTools"].items, "PhobosChemistryPathways.AcidWashedElectronics")
table.insert(ProceduralDistributions.list["ToolFactoryTools"].items, 0.1)

table.insert(ProceduralDistributions.list["ToolFactoryTools"].items, "PhobosChemistryPathways.PlasticScrap")
table.insert(ProceduralDistributions.list["ToolFactoryTools"].items, 0.2)

-- ===== CONSTRUCTION =====
-- Construction workers carry building materials
table.insert(ProceduralDistributions.list["ConstructionWorkerTools"].items, "PhobosChemistryPathways.MortarMix")
table.insert(ProceduralDistributions.list["ConstructionWorkerTools"].items, 0.15)

table.insert(ProceduralDistributions.list["ConstructionWorkerTools"].items, "PhobosChemistryPathways.StuccoMix")
table.insert(ProceduralDistributions.list["ConstructionWorkerTools"].items, 0.1)

table.insert(ProceduralDistributions.list["ConstructionWorkerTools"].items, "PhobosChemistryPathways.HempcreteBlock")
table.insert(ProceduralDistributions.list["ConstructionWorkerTools"].items, 0.1)

-- ===== CAMPING CRATES =====
-- Camping supply crates stock survival rope and trapping gear
table.insert(ProceduralDistributions.list["CrateCamping"].items, "PhobosChemistryPathways.HempRope")
table.insert(ProceduralDistributions.list["CrateCamping"].items, 0.2)

table.insert(ProceduralDistributions.list["CrateCamping"].items, "PhobosChemistryPathways.HempTwine")
table.insert(ProceduralDistributions.list["CrateCamping"].items, 0.3)

table.insert(ProceduralDistributions.list["CrateCamping"].items, "PhobosChemistryPathways.HempSnare")
table.insert(ProceduralDistributions.list["CrateCamping"].items, 0.15)

table.insert(ProceduralDistributions.list["CrateCamping"].items, "PhobosChemistryPathways.HempSheetRope")
table.insert(ProceduralDistributions.list["CrateCamping"].items, 0.1)
