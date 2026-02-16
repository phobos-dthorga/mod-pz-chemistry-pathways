---------------------------------------------------------------
-- PCP_ZScienceData.lua
-- ZScienceSkill specimen registration for PhobosChemistryPathways.
-- Registers PCP chemical items as researchable specimens when
-- the "Science, Bitch!" (ZScienceSkill) mod is active.
--
-- Only runs when PhobosLib.isModActive("ZScienceSkill") is true.
---------------------------------------------------------------

require "PhobosLib"

local function registerPCPSpecimens()
    -- Guard: only register if ZScienceSkill is loaded
    if not PhobosLib.isModActive("ZScienceSkill") then return end

    -- Guard: check that the ZScienceSkill registration API exists
    local ok, ZScience = pcall(function()
        return ZScienceData or nil
    end)
    if not ok or not ZScience then
        -- Try alternative API name
        ok, ZScience = pcall(function()
            return ZScienceSpecimens or nil
        end)
    end

    -- If no registration API found, try the simpler pattern used by many mods:
    -- ZScienceSkill stores specimen data in a global table that the microscope reads.
    -- We'll attempt to register items via the most common patterns.
    local registered = 0

    -- Attempt to use the ZScience API if available
    local function tryRegister(itemType, scienceXP, description)
        -- Pattern 1: ZScienceData.addSpecimen (most common)
        local success = pcall(function()
            if ZScienceData and ZScienceData.addSpecimen then
                ZScienceData.addSpecimen(itemType, scienceXP, description)
                registered = registered + 1
                return
            end
        end)
        if success then return end

        -- Pattern 2: Direct table insertion
        success = pcall(function()
            if ZScienceSpecimens then
                ZScienceSpecimens[itemType] = {
                    xp = scienceXP,
                    desc = description,
                }
                registered = registered + 1
            end
        end)
    end

    -- Chemical reagents and intermediates
    tryRegister("PhobosChemistryPathways.SulphurPowder",       25, "Elemental sulphur powder — extracted via acid reduction")
    tryRegister("PhobosChemistryPathways.PotassiumNitratePowder", 30, "Potassium nitrate — synthesized from compost or fertilizer leaching")
    tryRegister("PhobosChemistryPathways.PotassiumHydroxide",   20, "Potassium hydroxide (KOH) — alkali catalyst for transesterification")
    tryRegister("PhobosChemistryPathways.Potash",               15, "Potash (K2CO3) — by-product of charcoal purification")
    tryRegister("PhobosChemistryPathways.Calcite",              10, "Calcite (CaCO3) — calcium carbonate mineral")
    tryRegister("PhobosChemistryPathways.PurifiedCharcoal",     20, "Purified activated carbon — filtration and reagent grade")
    tryRegister("PhobosChemistryPathways.BoneChar",             20, "Bone char — pyrolysed animal bone carbon")
    tryRegister("PhobosChemistryPathways.CrushedCharcoal",      10, "Crushed charcoal — ground carbon for chemical reactions")

    -- Biodiesel pathway products
    tryRegister("PhobosChemistryPathways.CrudeVegetableOil",    15, "Crude vegetable oil — mechanically pressed from oilseed crops")
    tryRegister("PhobosChemistryPathways.WoodMethanol",         25, "Wood methanol — destructively distilled from timber")
    tryRegister("PhobosChemistryPathways.WoodTar",              15, "Wood tar — by-product of methanol distillation")
    tryRegister("PhobosChemistryPathways.Glycerol",             20, "Glycerol — by-product of transesterification")
    tryRegister("PhobosChemistryPathways.CrudeBiodiesel",       25, "Crude biodiesel — raw FAME from transesterification")
    tryRegister("PhobosChemistryPathways.WashedBiodiesel",      30, "Washed biodiesel — water-washed to remove residual catalyst")
    tryRegister("PhobosChemistryPathways.CrudeSoap",            15, "Crude lye soap — saponification product")

    -- Acid specimens
    tryRegister("PhobosChemistryPathways.SulphuricAcidJar",     35, "Sulphuric acid (H2SO4) — extracted from car battery electrolyte")

    if registered > 0 then
        print("[PCP] ZScienceSkill integration: " .. registered .. " specimens registered for microscope research")
    end
end

Events.OnGameStart.Add(registerPCPSpecimens)
