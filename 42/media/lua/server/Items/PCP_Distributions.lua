-----------------------------------------------------
-- Phobos' Chemistry Pathways - Loot Distributions
-----------------------------------------------------
require 'Items/ItemPicker'
require 'Items/Distributions'
require 'Items/ProceduralDistributions'
require 'Items/SuburbsDistributions'
require 'Vehicles/VehicleDistributions'

-----------------------------------------------------
--------------------- BOOK --------------------------
-----------------------------------------------------
-- Chemistry Pathways Handbook
-- Found in: bookstores, libraries, school classrooms,
-- medical offices, generic shelves, survivalist vehicles

-- Bookstores (best chance)
table.insert(ProceduralDistributions.list["BookstoreBooks"].items, "PhobosChemistryPathways.BkChemistryPathways")
table.insert(ProceduralDistributions.list["BookstoreBooks"].items, 2)

-- Libraries / generic bookshelves
table.insert(ProceduralDistributions.list["ShelfGeneric"].items, "PhobosChemistryPathways.BkChemistryPathways")
table.insert(ProceduralDistributions.list["ShelfGeneric"].items, 0.5)

-- Book crates in warehouses
table.insert(ProceduralDistributions.list["CrateBooks"].items, "PhobosChemistryPathways.BkChemistryPathways")
table.insert(ProceduralDistributions.list["CrateBooks"].items, 0.5)

-- School classrooms
table.insert(ProceduralDistributions.list["ClassroomShelves"].items, "PhobosChemistryPathways.BkChemistryPathways")
table.insert(ProceduralDistributions.list["ClassroomShelves"].items, 1)

table.insert(ProceduralDistributions.list["ClassroomDesk"].items, "PhobosChemistryPathways.BkChemistryPathways")
table.insert(ProceduralDistributions.list["ClassroomDesk"].items, 0.5)

table.insert(ProceduralDistributions.list["ClassroomMisc"].items, "PhobosChemistryPathways.BkChemistryPathways")
table.insert(ProceduralDistributions.list["ClassroomMisc"].items, 0.5)

table.insert(ProceduralDistributions.list["SchoolLockers"].items, "PhobosChemistryPathways.BkChemistryPathways")
table.insert(ProceduralDistributions.list["SchoolLockers"].items, 0.3)

table.insert(ProceduralDistributions.list["GigamartSchool"].items, "PhobosChemistryPathways.BkChemistryPathways")
table.insert(ProceduralDistributions.list["GigamartSchool"].items, 0.5)

-- Medical offices (chemistry reference material)
table.insert(ProceduralDistributions.list["MedicalOfficeBooks"].items, "PhobosChemistryPathways.BkChemistryPathways")
table.insert(ProceduralDistributions.list["MedicalOfficeBooks"].items, 2)

-- Survivalist vehicle (preppers would hoard knowledge)
table.insert(VehicleDistributions.SurvivalistTruckBed.items, "PhobosChemistryPathways.BkChemistryPathways")
table.insert(VehicleDistributions.SurvivalistTruckBed.items, 0.5)

table.insert(VehicleDistributions.SurvivalistGloveBox.items, "PhobosChemistryPathways.BkChemistryPathways")
table.insert(VehicleDistributions.SurvivalistGloveBox.items, 0.3)


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
