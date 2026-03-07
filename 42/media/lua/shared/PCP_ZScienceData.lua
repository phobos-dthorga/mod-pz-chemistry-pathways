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

---------------------------------------------------------------
-- PCP_ZScienceData.lua
-- ZScienceSkill specimen and fluid registration for
-- PhobosChemistryPathways.
--
-- Registers PCP chemical items as researchable microscope
-- specimens and PCP fluids as analysable fluid specimens
-- when the "Science, Bitch!" (ZScienceSkill) mod is active.
--
-- Uses the correct ZScienceSkill.Data.add() API:
--   ZScienceSkill.Data.add({ specimens = { ... }, fluids = { ... } })
--
-- Each specimen awards both Science and AppliedChemistry XP.
-- Container variants (ClayJar, Bucket) share a deduplication key
-- with the base item so only one research credit per substance.
--
-- Only runs when PhobosLib.isModActive("ZScienceSkill") is true.
-- All calls pcall-wrapped for safety if mod is removed mid-save.
---------------------------------------------------------------

require "PhobosLib"

local function registerPCPSpecimens()
    if isClient() then return end  -- MP: only register on server or singleplayer
    -- Guard: only register if ZScienceSkill is loaded
    if not PhobosLib.isModActive("ZScienceSkill") then return end

    -- Guard: verify the real API exists
    local ok = pcall(function()
        return ZScienceSkill and ZScienceSkill.Data and ZScienceSkill.Data.add
    end)
    if not ok then return end
    if not ZScienceSkill or not ZScienceSkill.Data or not ZScienceSkill.Data.add then return end

    -- Guard: verify AppliedChemistry perk exists (it should, from our perks.txt)
    local acPerk = "AppliedChemistry"
    local hasPerk = pcall(function() return Perks[acPerk] end)
    if not hasPerk or not Perks[acPerk] then
        -- Fallback: award Science only if our perk isn't loaded yet
        acPerk = nil
    end

    -- Helper: build XP table with Science + AppliedChemistry (if available)
    local function xp(scienceAmt, chemAmt, dedupKey)
        local t = { Science = scienceAmt }
        if acPerk then
            t[acPerk] = chemAmt
        end
        if dedupKey then
            t.key = dedupKey
        end
        return t
    end

    local success, err = pcall(function()
        ZScienceSkill.Data.add({

            -------------------------------------------------------
            -- ITEM SPECIMENS
            -------------------------------------------------------
            specimens = {

                -- Blackpowder pathway reagents & intermediates
                ["PhobosChemistryPathways.SulphurPowder"]          = xp(25, 20),
                ["PhobosChemistryPathways.PotassiumNitratePowder"] = xp(30, 25),
                ["PhobosChemistryPathways.PotassiumHydroxide"]     = xp(25, 20),
                ["PhobosChemistryPathways.Potash"]                 = xp(15, 10),
                ["PhobosChemistryPathways.Calcite"]                = xp(10, 8),

                -- Carbon materials
                ["PhobosChemistryPathways.CrushedCharcoal"]        = xp(10, 8),
                ["PhobosChemistryPathways.PurifiedCharcoal"]       = xp(20, 15),
                ["PhobosChemistryPathways.BoneChar"]               = xp(20, 15),

                -- Compost
                ["PhobosChemistryPathways.DilutedCompost"]         = xp(10, 8),

                -- Biodiesel pathway — oils (container variants share dedup key)
                ["PhobosChemistryPathways.CrudeVegetableOil"]         = xp(15, 12, "PCP.CrudeVegetableOil"),
                ["PhobosChemistryPathways.CrudeVegetableOilClayJar"]  = xp(15, 12, "PCP.CrudeVegetableOil"),
                ["PhobosChemistryPathways.CrudeVegetableOilBucket"]   = xp(15, 12, "PCP.CrudeVegetableOil"),

                -- Biodiesel pathway — rendered fat (container variants share dedup key)
                ["PhobosChemistryPathways.RenderedFat"]               = xp(15, 12, "PCP.RenderedFat"),
                ["PhobosChemistryPathways.RenderedFatClayJar"]        = xp(15, 12, "PCP.RenderedFat"),
                ["PhobosChemistryPathways.RenderedFatBucket"]         = xp(15, 12, "PCP.RenderedFat"),

                -- Biodiesel pathway — methanol and tar
                ["PhobosChemistryPathways.WoodMethanol"]           = xp(25, 20),
                ["PhobosChemistryPathways.WoodTar"]                = xp(15, 12),

                -- Biodiesel pathway — transesterification products (container variants share dedup key)
                ["PhobosChemistryPathways.CrudeBiodiesel"]            = xp(25, 20, "PCP.CrudeBiodiesel"),
                ["PhobosChemistryPathways.CrudeBiodieselClayJar"]     = xp(25, 20, "PCP.CrudeBiodiesel"),
                ["PhobosChemistryPathways.CrudeBiodieselBucket"]      = xp(25, 20, "PCP.CrudeBiodiesel"),

                ["PhobosChemistryPathways.WashedBiodiesel"]           = xp(30, 25, "PCP.WashedBiodiesel"),
                ["PhobosChemistryPathways.WashedBiodieselClayJar"]    = xp(30, 25, "PCP.WashedBiodiesel"),
                ["PhobosChemistryPathways.WashedBiodieselBucket"]     = xp(30, 25, "PCP.WashedBiodiesel"),

                ["PhobosChemistryPathways.RefinedBiodieselCan"]    = xp(35, 30),

                -- Biodiesel pathway — by-products
                ["PhobosChemistryPathways.Glycerol"]               = xp(20, 15),
                ["PhobosChemistryPathways.CrudeSoap"]              = xp(15, 12),

                -- Acid specimens (container variants share dedup key)
                ["PhobosChemistryPathways.SulphuricAcidJar"]       = xp(35, 30, "PCP.SulphuricAcid"),
                ["PhobosChemistryPathways.SulphuricAcidBottle"]    = xp(35, 30, "PCP.SulphuricAcid"),
                ["PhobosChemistryPathways.SulphuricAcidCrucible"]  = xp(35, 30, "PCP.SulphuricAcid"),
                ["PhobosChemistryPathways.SulphuricAcidClayJar"]   = xp(35, 30, "PCP.SulphuricAcid"),

                -- Salvage materials
                ["PhobosChemistryPathways.LeadScrap"]              = xp(15, 10),
                ["PhobosChemistryPathways.PlasticScrap"]           = xp(10, 8),
                ["PhobosChemistryPathways.AcidWashedElectronics"]  = xp(25, 20),

                -- Concrete mixer products
                ["PhobosChemistryPathways.MortarMix"]              = xp(15, 12),
                ["PhobosChemistryPathways.StuccoMix"]              = xp(15, 12),
                ["PhobosChemistryPathways.ReinforcedConcrete"]     = xp(20, 15),
                ["PhobosChemistryPathways.Fireclay"]               = xp(20, 15),

                -- Category recipe books (literature specimens)
                ["PhobosChemistryPathways.BkChemistryPathways"]    = xp(40, 30),
                ["PhobosChemistryPathways.BkFieldChemistry"]       = xp(20, 15),
                ["PhobosChemistryPathways.BkKitchenChemistry"]     = xp(20, 15),
                ["PhobosChemistryPathways.BkLabChemistry"]         = xp(25, 20),
                ["PhobosChemistryPathways.BkIndustrialChemistry"]  = xp(25, 20),
                ["PhobosChemistryPathways.BkHorticulture"]         = xp(20, 15),

                -- Botanical pathway — hemp processing specimens
                ["PhobosChemistryPathways.RettedHempStalk"]        = xp(10, 8),
                ["PhobosChemistryPathways.HempBastFiber"]          = xp(10, 8),
                ["PhobosChemistryPathways.HempHurd"]               = xp(8, 6),
                ["PhobosChemistryPathways.HempTwine"]              = xp(10, 8),
                ["PhobosChemistryPathways.HempRope"]               = xp(12, 10),
                ["PhobosChemistryPathways.TarredHempRope"]         = xp(15, 12),
                ["PhobosChemistryPathways.HempCloth"]              = xp(15, 12),
                ["PhobosChemistryPathways.HempCanvas"]             = xp(18, 15),
                ["PhobosChemistryPathways.HempPulp"]               = xp(12, 10),
                ["PhobosChemistryPathways.HempPaper"]              = xp(15, 12),
                ["PhobosChemistryPathways.HempPoultice"]           = xp(18, 15),
                ["PhobosChemistryPathways.HempTincture"]           = xp(25, 20),
                ["PhobosChemistryPathways.HempcreteBlock"]         = xp(20, 15),

                -- Hemp expansion — end products
                ["PhobosChemistryPathways.SeedPressCake"]        = xp(8, 6),
                ["PhobosChemistryPathways.Oakum"]                = xp(15, 12),
                ["PhobosChemistryPathways.HempSack"]             = xp(12, 10),
                ["PhobosChemistryPathways.HempFishingNet"]       = xp(12, 10),
                ["PhobosChemistryPathways.HempSheetRope"]        = xp(10, 8),
                ["PhobosChemistryPathways.HempSnare"]            = xp(10, 8),

                -- Horticulture pathway — tobacco
                ["PhobosChemistryPathways.TobaccoWet"]           = xp(8, 6),
                ["PhobosChemistryPathways.ChewingTobaccoTin"]    = xp(12, 10),
                ["PhobosChemistryPathways.ChewingTobaccoJar"]    = xp(12, 10),

                -- Horticulture pathway — hemp buds & smoking
                ["PhobosChemistryPathways.HempBuds"]             = xp(10, 8),
                ["PhobosChemistryPathways.HempBudsCured"]        = xp(15, 12),
                ["PhobosChemistryPathways.HempBudsDecarbed"]     = xp(18, 15),
                ["PhobosChemistryPathways.HempLoose"]            = xp(10, 8),
                ["PhobosChemistryPathways.CigarHemp"]            = xp(10, 8),
                ["PhobosChemistryPathways.CigarRolled"]          = xp(10, 8),
                ["PhobosChemistryPathways.SmokingPipeGlass"]     = xp(15, 12),

                -- Horticulture pathway — papermaking & cooking
                ["PhobosChemistryPathways.MouldAndDeckle"]       = xp(12, 10),
                ["PhobosChemistryPathways.RollingPapers"]        = xp(8, 6),
                ["PhobosChemistryPathways.PaperPulpPot"]         = xp(12, 10),
                ["PhobosChemistryPathways.SimpleSugarSyrup"]     = xp(10, 8),
                ["PhobosChemistryPathways.HempButter"]          = xp(18, 15),
                ["PhobosChemistryPathways.HempInfusedOil"]      = xp(16, 12),

                -- Salt pathway
                ["PhobosChemistryPathways.BrineConcentrate"]     = xp(15, 12),
                ["PhobosChemistryPathways.CoarseSalt"]           = xp(20, 15),

                -- Intermediates
                ["PhobosChemistryPathways.BoneMeal"]             = xp(12, 10),
            },

            -------------------------------------------------------
            -- FLUID SPECIMENS
            -- Keyed by bare fluid type name (no "Base." prefix).
            -- Player puts any container with the fluid under the
            -- microscope. Deduplication is automatic per fluid.
            -------------------------------------------------------
            fluids = {
                ["SulphuricAcid"]     = xp(40, 30),
                ["CrudeVegetableOil"] = xp(15, 12),
                ["RenderedFat"]       = xp(15, 12),
                ["WoodMethanol"]      = xp(30, 25),
                ["WoodTar"]           = xp(20, 15),
                ["CrudeBiodiesel"]    = xp(30, 25),
                ["Glycerol"]          = xp(20, 15),
                ["WashedBiodiesel"]   = xp(35, 30),
            },
        })
    end)

    if success then
        print("[PCP] ZScienceSkill: 78 items + 8 fluids registered [" .. (isServer() and "server" or "local") .. "]")
    else
        print("[PCP] ZScienceSkill: registration failed — " .. tostring(err))
    end
end

Events.OnGameStart.Add(registerPCPSpecimens)
