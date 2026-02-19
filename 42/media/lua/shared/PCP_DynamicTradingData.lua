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
--   - 1 trader archetype ("PCP_Chemist")
--   - 23 tradeable items (reagents, intermediates, fuels, books)
--
-- Only runs when PhobosLib.isDynamicTradingActive() returns true.
-- All DT calls are pcall-wrapped by PhobosLib_Trading.
--
-- Part of PhobosChemistryPathways >= 0.16.0
-- Requires PhobosLib >= 1.7.0
---------------------------------------------------------------

require "PhobosLib"

local _prefix = "[PCP:DynamicTrading]"

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
    -- Trader archetype: PCP_Chemist
    -- NPC trader specialising in chemical reagents and literature
    ---------------------------------------------------------------
    PhobosLib.registerTradeArchetype("PCP_Chemist", {
        name        = "Chemist",
        allocations = { Chemical = 80, Literature = 40, Medical = 20, Material = 15 },
        wants       = { Chemical = 1.3, Literature = 1.2 },
        forbid      = { "Weapon", "Ammo", "Illegal" },
    })

    ---------------------------------------------------------------
    -- Tradeable items
    -- Prices calibrated to DT's existing scale:
    --   Tag multipliers: Literature 1.2x, Common 1.0x,
    --   Uncommon 1.25x, Rare 2.0x, Legendary 5.0x
    ---------------------------------------------------------------
    local items = {
        -- Final products
        { item = "PhobosChemistryPathways.RefinedBiodieselCan",    basePrice = 80,  tags = { "Fuel", "Uncommon" },                stockRange = { min = 1, max = 3 } },

        -- Key reagents
        { item = "PhobosChemistryPathways.SulphurPowder",         basePrice = 15,  tags = { "Chemical", "Common" },              stockRange = { min = 3, max = 8 } },
        { item = "PhobosChemistryPathways.PotassiumNitratePowder", basePrice = 25,  tags = { "Chemical", "Uncommon" },            stockRange = { min = 2, max = 6 } },
        { item = "PhobosChemistryPathways.PotassiumHydroxide",    basePrice = 20,  tags = { "Chemical", "Uncommon" },             stockRange = { min = 2, max = 5 } },
        { item = "PhobosChemistryPathways.Potash",                basePrice = 8,   tags = { "Chemical", "Common" },               stockRange = { min = 4, max = 10 } },

        -- Carbon
        { item = "PhobosChemistryPathways.PurifiedCharcoal",      basePrice = 18,  tags = { "Chemical", "Common" },              stockRange = { min = 5, max = 15 } },
        { item = "PhobosChemistryPathways.BoneChar",              basePrice = 20,  tags = { "Chemical", "Common" },              stockRange = { min = 3, max = 10 } },

        -- Intermediates
        { item = "PhobosChemistryPathways.CrudeVegetableOil",     basePrice = 12,  tags = { "Chemical", "Common" },              stockRange = { min = 3, max = 8 } },
        { item = "PhobosChemistryPathways.RenderedFat",           basePrice = 10,  tags = { "Chemical", "Common" },               stockRange = { min = 3, max = 8 } },
        { item = "PhobosChemistryPathways.WoodMethanol",          basePrice = 20,  tags = { "Chemical", "Uncommon", "Illegal" },  stockRange = { min = 1, max = 3 } },
        { item = "PhobosChemistryPathways.Glycerol",              basePrice = 10,  tags = { "Chemical", "Common" },               stockRange = { min = 3, max = 8 } },
        { item = "PhobosChemistryPathways.CrudeSoap",             basePrice = 5,   tags = { "Chemical", "Common" },               stockRange = { min = 4, max = 10 } },
        { item = "PhobosChemistryPathways.Calcite",               basePrice = 4,   tags = { "Chemical", "Common" },               stockRange = { min = 5, max = 12 } },

        -- Acid
        { item = "PhobosChemistryPathways.SulphuricAcidJar",      basePrice = 35,  tags = { "Chemical", "Rare", "Illegal" },     stockRange = { min = 1, max = 2 } },

        -- Salvage
        { item = "PhobosChemistryPathways.LeadScrap",             basePrice = 6,   tags = { "Material", "Common" },               stockRange = { min = 3, max = 8 } },

        -- Biodiesel
        { item = "PhobosChemistryPathways.CrudeBiodiesel",        basePrice = 25,  tags = { "Chemical", "Uncommon" },             stockRange = { min = 2, max = 5 } },
        { item = "PhobosChemistryPathways.WashedBiodiesel",       basePrice = 40,  tags = { "Chemical", "Uncommon" },             stockRange = { min = 1, max = 4 } },

        -- Skill books (calibrated to DT tier scale)
        { item = "PhobosChemistryPathways.BkChemistryPathways",   basePrice = 300, tags = { "Literature", "Rare" },               stockRange = { min = 0, max = 1 } },
        { item = "PhobosChemistryPathways.BookAppliedChemistry1", basePrice = 50,  tags = { "Literature", "Common" },             stockRange = { min = 1, max = 3 } },
        { item = "PhobosChemistryPathways.BookAppliedChemistry2", basePrice = 100, tags = { "Literature", "Uncommon" },            stockRange = { min = 1, max = 2 } },
        { item = "PhobosChemistryPathways.BookAppliedChemistry3", basePrice = 180, tags = { "Literature", "Rare" },               stockRange = { min = 0, max = 1 } },
        { item = "PhobosChemistryPathways.BookAppliedChemistry4", basePrice = 350, tags = { "Literature", "Rare" },               stockRange = { min = 0, max = 1 } },
        { item = "PhobosChemistryPathways.BookAppliedChemistry5", basePrice = 600, tags = { "Literature", "Legendary" },          stockRange = { min = 0, max = 1 } },
    }

    local ok, count = PhobosLib.registerTradeItems(items)

    if ok then
        print(_prefix .. " Registration complete: 1 tag, 1 archetype, " .. tostring(count) .. " items [" .. (isServer() and "server" or "local") .. "]")
    else
        print(_prefix .. " Registration failed [" .. (isServer() and "server" or "local") .. "]")
    end
end

Events.OnGameStart.Add(registerPCPTradeData)
