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
-- PCP_DynamicTradingData.lua
-- Dynamic Trading integration for PhobosChemistryPathways.
--
-- Registers PCP items for NPC trading when the Dynamic Trading
-- mod is installed. Uses PhobosLib_Trading wrapper functions
-- for detection, registration, and error handling.
--
-- Registers:
--   - 1 custom tag ("Chemical")
--   - 1 trader archetype ("Chemist") with expertTags
--   - up to 76 tradeable items (botanical categories sandbox-gated)
--   - Chemical allocations injected into 8 existing DT archetypes
--
-- Only runs when PhobosLib.isDynamicTradingActive() returns true.
-- All DT calls are pcall-wrapped by PhobosLib_Trading.
--
-- Part of PhobosChemistryPathways >= 0.19.0
-- Requires PhobosLib >= 1.7.0
---------------------------------------------------------------

require "PhobosLib"
require "PCP_SandboxIntegration"

local _prefix = "[PCP:DynamicTrading]"

---------------------------------------------------------------
-- Inject Chemical allocations into existing DT archetypes.
-- Directly mutates DynamicTrading.Archetypes[id].allocations
-- (safe: DT stores plain Lua table references).
---------------------------------------------------------------
local function injectChemicalAllocations()
    if not DynamicTrading or not DynamicTrading.Archetypes then
        print(_prefix .. " DynamicTrading.Archetypes not found, skipping injection")
        return 0
    end

    local injections = {
        { id = "Pharmacist",  slots = 2 },  -- Medical chemicals (acids, KOH, soap)
        { id = "Doctor",      slots = 1 },  -- Medical supplies, crude soap
        { id = "Survivalist", slots = 2 },  -- Charcoal, bone char, fuel
        { id = "Herbalist",   slots = 3 },  -- Oils, rendered fat, glycerol, botanical fiber/medical
        { id = "Brewer",      slots = 1 },  -- Methanol, glycerol
        { id = "Farmer",      slots = 2 },  -- Fertilizers (potash, calcite, compost)
        { id = "Smuggler",    slots = 2 },  -- Chemicals + Illegal hemp/tobacco products
        { id = "General",     slots = 2 },  -- Small general chemical stock, common smoking/paper
    }

    local injected = 0
    for _, entry in ipairs(injections) do
        local arch = DynamicTrading.Archetypes[entry.id]
        if arch and arch.allocations then
            local existing = arch.allocations["Chemical"] or 0
            arch.allocations["Chemical"] = existing + entry.slots
            injected = injected + 1
        end
    end

    return injected
end

---------------------------------------------------------------
-- Helper: append items from source table to destination table
---------------------------------------------------------------
local function appendItems(dest, src)
    for _, v in ipairs(src) do dest[#dest + 1] = v end
end

---------------------------------------------------------------
-- Main registration
---------------------------------------------------------------
local function registerPCPTradeData()
    if isClient() then return end
    if not PhobosLib.isDynamicTradingActive() then return end

    ---------------------------------------------------------------
    -- Custom tag: Chemical
    -- Slightly above Common pricing, moderate spawn weight
    ---------------------------------------------------------------
    PhobosLib.registerTradeTag("Chemical", {
        priceMult = 1.3,
        weight    = 15,
    })

    ---------------------------------------------------------------
    -- Trader archetype: Chemist
    -- NPC trader specialising in chemical reagents and literature.
    -- expertTags guarantees 100% condition on Chemical items.
    ---------------------------------------------------------------
    PhobosLib.registerTradeArchetype("Chemist", {
        name        = "Chemist",
        allocations = { Chemical = 80, Literature = 40, Medical = 20, Material = 15 },
        wants       = { Chemical = 1.3, Literature = 1.2 },
        forbid      = { "Weapon", "Ammo", "Illegal" },
        expertTags  = { "Chemical" },
    })

    ---------------------------------------------------------------
    -- Tradeable items
    -- Prices anchored to DT vanilla input basePrices (Charcoal=15,
    -- CarBattery1=80, OilVegetable=15, Lard=10, Limestone=10, Soap2=12)
    -- then scaled upward through each chain step (~1.5-2x per step).
    -- Tag multipliers (highest wins): Common 1.0x, Uncommon 1.25x,
    -- Rare 2.0x, Legendary 5.0x, Chemical 1.3x, Fuel 1.5x
    --
    -- Per-vendor tags enable multi-archetype stock:
    --   Medical  -> Pharmacist, Doctor
    --   Survival -> Survivalist
    --   Farming  -> Farmer
    --   Herb     -> Herbalist
    --   Alcohol  -> Brewer
    --   Fuel     -> (Chemical allocation on Survivalist)
    ---------------------------------------------------------------
    local items = {
        -- Final products
        { item = "PhobosChemistryPathways.RefinedBiodieselCan",    basePrice = 120, tags = { "Fuel", "Uncommon" },                         stockRange = { min = 1, max = 2 } },

        -- Key reagents (anchored to CarBattery1=80, Charcoal=15, Limestone=10)
        { item = "PhobosChemistryPathways.SulphurPowder",         basePrice = 45,  tags = { "Chemical", "Medical", "Uncommon" },            stockRange = { min = 2, max = 5 } },
        { item = "PhobosChemistryPathways.PotassiumNitratePowder", basePrice = 60,  tags = { "Chemical", "Uncommon" },                     stockRange = { min = 1, max = 4 } },
        { item = "PhobosChemistryPathways.PotassiumHydroxide",    basePrice = 35,  tags = { "Chemical", "Uncommon" },                      stockRange = { min = 2, max = 5 } },
        { item = "PhobosChemistryPathways.Potash",                basePrice = 15,  tags = { "Chemical", "Farming", "Common" },              stockRange = { min = 4, max = 10 } },

        -- Carbon (anchored to Charcoal=15)
        { item = "PhobosChemistryPathways.CrushedCharcoal",       basePrice = 12,  tags = { "Chemical", "Common" },                        stockRange = { min = 5, max = 12 } },
        { item = "PhobosChemistryPathways.PurifiedCharcoal",      basePrice = 25,  tags = { "Chemical", "Survival", "Common" },             stockRange = { min = 5, max = 15 } },
        { item = "PhobosChemistryPathways.BoneChar",              basePrice = 20,  tags = { "Chemical", "Survival", "Common" },             stockRange = { min = 3, max = 10 } },

        -- Intermediates (anchored to OilVegetable=15, Lard=10, Soap2=12)
        { item = "PhobosChemistryPathways.CrudeVegetableOil",     basePrice = 20,  tags = { "Chemical", "Herb", "Common" },                stockRange = { min = 3, max = 8 } },
        { item = "PhobosChemistryPathways.RenderedFat",           basePrice = 18,  tags = { "Chemical", "Herb", "Common" },                 stockRange = { min = 3, max = 8 } },
        { item = "PhobosChemistryPathways.WoodMethanol",          basePrice = 40,  tags = { "Chemical", "Alcohol", "Uncommon", "Illegal" }, stockRange = { min = 1, max = 2 } },
        { item = "PhobosChemistryPathways.WoodTar",              basePrice = 30,  tags = { "Chemical", "Survival", "Uncommon" },             stockRange = { min = 1, max = 3 } },
        { item = "PhobosChemistryPathways.Glycerol",              basePrice = 25,  tags = { "Chemical", "Herb", "Common" },                 stockRange = { min = 3, max = 8 } },
        { item = "PhobosChemistryPathways.CrudeSoap",             basePrice = 15,  tags = { "Chemical", "Medical", "Common" },              stockRange = { min = 4, max = 10 } },
        { item = "PhobosChemistryPathways.Calcite",               basePrice = 8,   tags = { "Chemical", "Farming", "Common" },              stockRange = { min = 5, max = 12 } },
        { item = "PhobosChemistryPathways.DilutedCompost",        basePrice = 10,  tags = { "Chemical", "Farming", "Common" },              stockRange = { min = 3, max = 8 } },

        -- Salt pathway (anchored to Calcite=8; basic survival chemistry)
        { item = "PhobosChemistryPathways.CoarseSalt",           basePrice = 8,   tags = { "Chemical", "Common" },                        stockRange = { min = 3, max = 8 } },
        { item = "PhobosChemistryPathways.BrineConcentrate",     basePrice = 5,   tags = { "Chemical", "Common" },                        stockRange = { min = 2, max = 5 } },

        -- Acid (anchored to CarBattery1=80; dangerous lab extraction)
        { item = "PhobosChemistryPathways.SulphuricAcidJar",      basePrice = 80,  tags = { "Chemical", "Medical", "Rare", "Illegal" },    stockRange = { min = 1, max = 2 } },

        -- Salvage
        { item = "PhobosChemistryPathways.LeadScrap",             basePrice = 8,   tags = { "Material", "Common" },                        stockRange = { min = 3, max = 8 } },
        { item = "PhobosChemistryPathways.PlasticScrap",          basePrice = 5,   tags = { "Material", "Common" },                         stockRange = { min = 4, max = 10 } },
        { item = "PhobosChemistryPathways.AcidWashedElectronics", basePrice = 25,  tags = { "Material", "Uncommon" },                       stockRange = { min = 1, max = 3 } },

        -- Biodiesel (anchored to Oil→Methanol→KOH chain costs)
        { item = "PhobosChemistryPathways.CrudeBiodiesel",        basePrice = 55,  tags = { "Chemical", "Fuel", "Uncommon" },               stockRange = { min = 1, max = 3 } },
        { item = "PhobosChemistryPathways.WashedBiodiesel",       basePrice = 80,  tags = { "Chemical", "Fuel", "Uncommon" },               stockRange = { min = 1, max = 3 } },

        -- Agriculture & downstream (new pathways connecting PCP to vanilla systems)
        { item = "PhobosChemistryPathways.BoneMeal",               basePrice = 12,  tags = { "Chemical", "Farming", "Common" },              stockRange = { min = 4, max = 10 } },
        { item = "PhobosChemistryPathways.ActivatedCarbon",        basePrice = 40,  tags = { "Chemical", "Survival", "Uncommon" },            stockRange = { min = 2, max = 5 } },
        { item = "PhobosChemistryPathways.SulphurFungicideSpray",  basePrice = 30,  tags = { "Chemical", "Farming", "Common" },              stockRange = { min = 2, max = 5 } },
        { item = "PhobosChemistryPathways.InsecticidalSoapSpray",  basePrice = 20,  tags = { "Chemical", "Farming", "Common" },              stockRange = { min = 2, max = 5 } },
        { item = "PhobosChemistryPathways.PotashFoliarSpray",      basePrice = 20,  tags = { "Chemical", "Farming", "Common" },              stockRange = { min = 2, max = 5 } },
        { item = "PhobosChemistryPathways.MineralFeedSupplement",  basePrice = 35,  tags = { "Farming", "Uncommon" },                        stockRange = { min = 1, max = 3 } },

        -- Concrete mixer products (construction materials)
        { item = "PhobosChemistryPathways.MortarMix",           basePrice = 25,  tags = { "Chemical", "Material", "Common" },                  stockRange = { min = 2, max = 6 } },
        { item = "PhobosChemistryPathways.StuccoMix",           basePrice = 20,  tags = { "Chemical", "Material", "Common" },                  stockRange = { min = 2, max = 6 } },
        { item = "PhobosChemistryPathways.ReinforcedConcrete",  basePrice = 50,  tags = { "Chemical", "Material", "Uncommon" },                stockRange = { min = 1, max = 3 } },
        { item = "PhobosChemistryPathways.Fireclay",            basePrice = 35,  tags = { "Chemical", "Material", "Uncommon" },                stockRange = { min = 1, max = 4 } },

        -- Botanical items: see sandbox-gated blocks below

        -- Horticulture items (tobacco, hemp buds, smoking, papermaking, cooking)
        { item = "PhobosChemistryPathways.ChewingTobacco",      basePrice = 16,  tags = { "Herb", "Common" },                    stockRange = { min = 2, max = 5 } },
        { item = "PhobosChemistryPathways.CigarRolled",        basePrice = 12,  tags = { "Herb", "Common" },                    stockRange = { min = 2, max = 6 } },
        { item = "PhobosChemistryPathways.CigarHemp",          basePrice = 20,  tags = { "Herb", "Illegal", "Uncommon" },       stockRange = { min = 1, max = 3 } },
        { item = "PhobosChemistryPathways.CigarettePackHemp",  basePrice = 25,  tags = { "Herb", "Illegal", "Uncommon" },       stockRange = { min = 1, max = 3 } },
        { item = "PhobosChemistryPathways.CigarettePackRolled", basePrice = 15, tags = { "Herb", "Common" },                    stockRange = { min = 2, max = 5 } },
        { item = "PhobosChemistryPathways.SmokingPipeGlass",   basePrice = 35,  tags = { "Material", "Uncommon" },              stockRange = { min = 1, max = 2 } },
        { item = "PhobosChemistryPathways.RollingPapers",      basePrice = 8,   tags = { "Material", "Common" },                stockRange = { min = 3, max = 8 } },
        { item = "PhobosChemistryPathways.MouldAndDeckle",     basePrice = 20,  tags = { "Material", "Uncommon" },              stockRange = { min = 1, max = 2 } },
        { item = "PhobosChemistryPathways.SimpleSugarSyrup",   basePrice = 10,  tags = { "Herb", "Common" },                    stockRange = { min = 2, max = 5 } },
        { item = "PhobosChemistryPathways.HempButter",         basePrice = 30,  tags = { "Chemical", "Uncommon" },              stockRange = { min = 1, max = 3 } },
        { item = "PhobosChemistryPathways.HempInfusedOil",     basePrice = 25,  tags = { "Chemical", "Uncommon" },              stockRange = { min = 1, max = 3 } },
        { item = "PhobosChemistryPathways.HempBudsCured",      basePrice = 15,  tags = { "Herb", "Illegal", "Uncommon" },       stockRange = { min = 1, max = 3 } },
        { item = "PhobosChemistryPathways.HempBudsDecarbed",  basePrice = 20,  tags = { "Chemical", "Herb", "Uncommon" },     stockRange = { min = 1, max = 3 } },
        { item = "PhobosChemistryPathways.HempLoose",          basePrice = 12,  tags = { "Herb", "Common" },                   stockRange = { min = 2, max = 5 } },

        -- Category recipe books (tiered by survival value)
        { item = "PhobosChemistryPathways.BkFieldChemistry",      basePrice = 80,  tags = { "Literature", "Common" },                       stockRange = { min = 0, max = 2 } },
        { item = "PhobosChemistryPathways.BkKitchenChemistry",    basePrice = 120, tags = { "Literature", "Uncommon" },                     stockRange = { min = 0, max = 1 } },
        { item = "PhobosChemistryPathways.BkLabChemistry",        basePrice = 200, tags = { "Literature", "Rare" },                         stockRange = { min = 0, max = 1 } },
        { item = "PhobosChemistryPathways.BkIndustrialChemistry", basePrice = 250, tags = { "Literature", "Rare" },                         stockRange = { min = 0, max = 1 } },
        { item = "PhobosChemistryPathways.BkHorticulture",        basePrice = 100, tags = { "Literature", "Common" },                       stockRange = { min = 0, max = 2 } },
        { item = "PhobosChemistryPathways.BkChemistryPathways",   basePrice = 500, tags = { "Literature", "Rare" },                         stockRange = { min = 0, max = 1 } },

        -- Skill books (calibrated to DT tier scale)
        { item = "PhobosChemistryPathways.BookAppliedChemistry1", basePrice = 50,  tags = { "Literature", "Common" },                       stockRange = { min = 1, max = 3 } },
        { item = "PhobosChemistryPathways.BookAppliedChemistry2", basePrice = 100, tags = { "Literature", "Uncommon" },                     stockRange = { min = 1, max = 2 } },
        { item = "PhobosChemistryPathways.BookAppliedChemistry3", basePrice = 180, tags = { "Literature", "Rare" },                         stockRange = { min = 0, max = 1 } },
        { item = "PhobosChemistryPathways.BookAppliedChemistry4", basePrice = 350, tags = { "Literature", "Rare" },                         stockRange = { min = 0, max = 1 } },
        { item = "PhobosChemistryPathways.BookAppliedChemistry5", basePrice = 600, tags = { "Literature", "Legendary" },                    stockRange = { min = 0, max = 1 } },
    }

    ---------------------------------------------------------------
    -- Botanical items — gated by DT sandbox toggles
    -- Each sub-category can be independently disabled by the player
    ---------------------------------------------------------------
    if PCP_Sandbox.isDTBotanicalMaterialEnabled() then
        appendItems(items, {
            { item = "PhobosChemistryPathways.HempTwine",        basePrice = 8,   tags = { "Chemical", "Material", "Common" },    stockRange = { min = 3, max = 8 } },
            { item = "PhobosChemistryPathways.HempRope",         basePrice = 15,  tags = { "Chemical", "Material", "Common" },    stockRange = { min = 2, max = 5 } },
            { item = "PhobosChemistryPathways.TarredHempRope",   basePrice = 25,  tags = { "Chemical", "Material", "Uncommon" },  stockRange = { min = 1, max = 3 } },
            { item = "PhobosChemistryPathways.HempCloth",        basePrice = 20,  tags = { "Chemical", "Material", "Common" },    stockRange = { min = 2, max = 5 } },
            { item = "PhobosChemistryPathways.HempCanvas",       basePrice = 30,  tags = { "Chemical", "Material", "Uncommon" },  stockRange = { min = 1, max = 3 } },
            { item = "PhobosChemistryPathways.HempcreteBlock",   basePrice = 35,  tags = { "Chemical", "Material", "Uncommon" },  stockRange = { min = 1, max = 3 } },
            { item = "PhobosChemistryPathways.SeedPressCake",    basePrice = 5,   tags = { "Chemical", "Material", "Common" },    stockRange = { min = 3, max = 8 } },
            { item = "PhobosChemistryPathways.HempSack",         basePrice = 40,  tags = { "Chemical", "Material", "Uncommon" },  stockRange = { min = 1, max = 2 } },
            { item = "PhobosChemistryPathways.Oakum",            basePrice = 12,  tags = { "Chemical", "Material", "Common" },    stockRange = { min = 2, max = 5 } },
            { item = "PhobosChemistryPathways.HempSheetRope",    basePrice = 20,  tags = { "Chemical", "Material", "Common" },    stockRange = { min = 1, max = 3 } },
            { item = "PhobosChemistryPathways.HempBastFiber",    basePrice = 10,  tags = { "Chemical", "Material", "Common" },    stockRange = { min = 3, max = 8 } },
            { item = "PhobosChemistryPathways.HempHurd",         basePrice = 6,   tags = { "Chemical", "Material", "Common" },    stockRange = { min = 3, max = 8 } },
        })
    end

    if PCP_Sandbox.isDTBotanicalMedicalEnabled() then
        appendItems(items, {
            { item = "PhobosChemistryPathways.HempPoultice",     basePrice = 25,  tags = { "Chemical", "Medical", "Common" },     stockRange = { min = 2, max = 5 } },
            { item = "PhobosChemistryPathways.HempTincture",     basePrice = 45,  tags = { "Chemical", "Medical", "Uncommon" },   stockRange = { min = 1, max = 3 } },
        })
    end

    if PCP_Sandbox.isDTBotanicalSurvivalEnabled() then
        appendItems(items, {
            { item = "PhobosChemistryPathways.HempFishingNet",   basePrice = 35,  tags = { "Chemical", "Survival", "Uncommon" },  stockRange = { min = 1, max = 2 } },
            { item = "PhobosChemistryPathways.HempSnare",        basePrice = 15,  tags = { "Chemical", "Survival", "Common" },    stockRange = { min = 2, max = 4 } },
        })
    end

    if PCP_Sandbox.isDTBotanicalLiteratureEnabled() then
        appendItems(items, {
            { item = "PhobosChemistryPathways.HempPaper",        basePrice = 12,  tags = { "Chemical", "Literature", "Common" },  stockRange = { min = 3, max = 8 } },
        })
    end

    local ok, count = PhobosLib.registerTradeItems(items)

    ---------------------------------------------------------------
    -- Inject Chemical allocations into existing DT archetypes
    ---------------------------------------------------------------
    local injected = injectChemicalAllocations()

    if ok then
        print(_prefix .. " Registration complete: 1 tag, 1 archetype, "
            .. tostring(count) .. "/76 items, "
            .. tostring(injected) .. " archetype injections"
            .. " [" .. (isServer() and "server" or "local") .. "]")
    else
        print(_prefix .. " Registration failed [" .. (isServer() and "server" or "local") .. "]")
    end
end

Events.OnGameStart.Add(registerPCPTradeData)
