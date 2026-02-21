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
--   - 34 tradeable items (reagents, intermediates, fuels, agriculture, books)
--   - Chemical allocations injected into 8 existing DT archetypes
--
-- Only runs when PhobosLib.isDynamicTradingActive() returns true.
-- All DT calls are pcall-wrapped by PhobosLib_Trading.
--
-- Part of PhobosChemistryPathways >= 0.19.0
-- Requires PhobosLib >= 1.7.0
---------------------------------------------------------------

require "PhobosLib"

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
        { id = "Herbalist",   slots = 2 },  -- Oils, rendered fat, glycerol
        { id = "Brewer",      slots = 1 },  -- Methanol, glycerol
        { id = "Farmer",      slots = 2 },  -- Fertilizers (potash, calcite, compost)
        { id = "Smuggler",    slots = 1 },  -- Non-illegal chemicals
        { id = "General",     slots = 1 },  -- Small general chemical stock
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

        -- Skill books (calibrated to DT tier scale — unchanged)
        { item = "PhobosChemistryPathways.BkChemistryPathways",   basePrice = 300, tags = { "Literature", "Rare" },                         stockRange = { min = 0, max = 1 } },
        { item = "PhobosChemistryPathways.BookAppliedChemistry1", basePrice = 50,  tags = { "Literature", "Common" },                       stockRange = { min = 1, max = 3 } },
        { item = "PhobosChemistryPathways.BookAppliedChemistry2", basePrice = 100, tags = { "Literature", "Uncommon" },                     stockRange = { min = 1, max = 2 } },
        { item = "PhobosChemistryPathways.BookAppliedChemistry3", basePrice = 180, tags = { "Literature", "Rare" },                         stockRange = { min = 0, max = 1 } },
        { item = "PhobosChemistryPathways.BookAppliedChemistry4", basePrice = 350, tags = { "Literature", "Rare" },                         stockRange = { min = 0, max = 1 } },
        { item = "PhobosChemistryPathways.BookAppliedChemistry5", basePrice = 600, tags = { "Literature", "Legendary" },                    stockRange = { min = 0, max = 1 } },
    }

    local ok, count = PhobosLib.registerTradeItems(items)

    ---------------------------------------------------------------
    -- Inject Chemical allocations into existing DT archetypes
    ---------------------------------------------------------------
    local injected = injectChemicalAllocations()

    if ok then
        print(_prefix .. " Registration complete: 1 tag, 1 archetype, "
            .. tostring(count) .. " items, "
            .. tostring(injected) .. " archetype injections"
            .. " [" .. (isServer() and "server" or "local") .. "]")
    else
        print(_prefix .. " Registration failed [" .. (isServer() and "server" or "local") .. "]")
    end
end

Events.OnGameStart.Add(registerPCPTradeData)
