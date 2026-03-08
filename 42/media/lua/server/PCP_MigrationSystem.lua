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
-- PCP_MigrationSystem.lua
-- Server-side versioned migrations for PhobosChemistryPathways.
-- Uses PhobosLib_Migrate to register and run upgrade logic.
--
-- v0.18.0 migration:
--   - Teach pot-alternative recipes to players who know lab versions
--   - Teach surviving soap recipes to players who knew deleted variants
--
-- v0.19.0 migration:
--   - Convert modData["PCP_Purity"] to item condition for all PCP items
--   - Remove old PCP_Purity modData key after conversion
--
-- v0.19.1 migrations (internally chained as 0.19.1 → 0.19.2 → 0.19.3):
--   - Rename "PCP_Chemist" → "Chemist" in DynamicTrading save data
--   - Stamp purity on all unstamped PCP items (condition 100 -> 99)
--   - Deep scan: stamp unstamped PCP items including backpacks/bags
--   - World containers handled by client-side lazy stamper (PhobosLib)
--
-- v0.20.0 migration:
--   - Rescale FluidContainer item conditions from old max-10 to max-100
--   - FluidContainer items previously defaulted to ConditionMax=10 in B42;
--     now explicitly set to 100 in PCP_Items.txt. Existing items need
--     their condition values multiplied by 10 to map correctly.
--
-- v1.0.0 migration:
--   - Convert orphaned zReLabItems (from zReVaccin) to ZVV/vanilla
--     equivalents, preserving condition and fluid contents
--
-- v1.3.0 migration:
--   - Backfill HempTincture FluidContainer fluid for pre-existing items
--     (converted from base:normal to FluidContainer in v1.3.0)
--
-- v1.5.0 migration:
--   - Convert old ChewingTobaccoTin/WaterTin/Jar to unified ChewingTobacco
--   - Teach new chewing tobacco recipes (HT1-HT3) to players who knew old ones
--   - Update HORT_TO_PCP map entries for old Horticulture tobacco items
--
-- Requires: PhobosLib >= 1.9.0
---------------------------------------------------------------

require "PhobosLib"

local MOD_ID      = "PCP"
local MOD_VERSION = "1.5.0"

---------------------------------------------------------------
-- Helpers
---------------------------------------------------------------

--- Teach a recipe if the player doesn't already know it.
---@param known any        Java ArrayList from player:getKnownRecipes()
---@param name  string     Recipe name
---@return boolean         true if newly taught
local function teachRecipe(known, name)
    if known:contains(name) then return false end
    known:add(name)
    return true
end

--- Check if the player knows any recipe in a list.
---@param known any        Java ArrayList
---@param names table      Array of recipe name strings
---@return boolean
local function knowsAny(known, names)
    for _, name in ipairs(names) do
        if known:contains(name) then return true end
    end
    return false
end

---------------------------------------------------------------
-- v0.18.0 Migration
---------------------------------------------------------------

--- Lab → Pot recipe mappings (player who knows lab → teach pot)
local LAB_TO_POT = {
    { lab = "PCPPurifyCharcoalWater",      pot = "PCPPurifyCharcoalWaterPot" },
    { lab = "PCPPurifyCharcoalNaOH",       pot = "PCPPurifyCharcoalNaOHPot" },
    { lab = "PCPSynthesizeKNO3Fertilizer",  pot = "PCPSynthesizeKNO3FertilizerPot" },
    { lab = "PCPSynthesizeKNO3Compost",     pot = "PCPSynthesizeKNO3CompostPot" },
    { lab = "PCPPressOilSoybeansLab",       pot = "PCPPressOilSoybeansLabPot" },
    { lab = "PCPPressOilSunflowerLab",      pot = "PCPPressOilSunflowerLabPot" },
    { lab = "PCPPressOilCornLab",           pot = "PCPPressOilCornLabPot" },
    { lab = "PCPPressOilFlaxLab",           pot = "PCPPressOilFlaxLabPot" },
    { lab = "PCPPressOilHempLab",           pot = "PCPPressOilHempLabPot" },
    { lab = "PCPPressOilPeanutLab",         pot = "PCPPressOilPeanutLabPot" },
    { lab = "PCPRenderFat",                 pot = "PCPRenderFatPot" },
    { lab = "PCPWashBiodiesel",             pot = "PCPWashBiodieselPot" },
}

--- Deleted soap variants → surviving base recipe mappings
local SOAP_MIGRATIONS = {
    { deleted = { "PCPMakeSoapCoke", "PCPMakeSoapPropane", "PCPMakeSoapSimple" },
      survivor = "PCPMakeSoap" },
    { deleted = { "PCPMakeSoapNaOHCoke", "PCPMakeSoapNaOHPropane", "PCPMakeSoapNaOHSimple" },
      survivor = "PCPMakeSoapNaOH" },
    { deleted = { "PCPMakeSoapFatCoke", "PCPMakeSoapFatPropane", "PCPMakeSoapFatSimple" },
      survivor = "PCPMakeSoapFat" },
    { deleted = { "PCPMakeSoapFatNaOHCoke", "PCPMakeSoapFatNaOHPropane", "PCPMakeSoapFatNaOHSimple" },
      survivor = "PCPMakeSoapFatNaOH" },
}

--- Execute v0.18.0 migration for a single player.
---@param player any  IsoGameCharacter
---@return boolean ok, string msg
local function migrate_0_18_0(player)
    local known = player:getKnownRecipes()
    if not known then return false, "Could not access known recipes." end

    local potCount = 0
    local soapCount = 0

    -- 1. Lab → Pot: teach pot variant if player knows the lab version
    for _, mapping in ipairs(LAB_TO_POT) do
        if known:contains(mapping.lab) then
            if teachRecipe(known, mapping.pot) then
                potCount = potCount + 1
            end
        end
    end

    -- 2. Soap collapse: teach surviving base if player knew any deleted variant
    for _, group in ipairs(SOAP_MIGRATIONS) do
        if knowsAny(known, group.deleted) then
            if teachRecipe(known, group.survivor) then
                soapCount = soapCount + 1
            end
        end
    end

    local total = potCount + soapCount
    if total == 0 then
        return true, "No recipe migration needed."
    end

    local parts = {}
    if potCount > 0 then table.insert(parts, potCount .. " pot recipe(s)") end
    if soapCount > 0 then table.insert(parts, soapCount .. " soap recipe(s)") end
    return true, "Taught " .. table.concat(parts, ", ") .. "."
end

---------------------------------------------------------------
-- v0.19.0 Migration
---------------------------------------------------------------

--- Convert modData["PCP_Purity"] to item condition for all PCP items.
--- After v0.19.0, purity is stored as item condition (ConditionMax = 100).
--- This migration preserves purity values from pre-0.19.0 saves.
---@param player any  IsoGameCharacter
---@return boolean ok, string msg
local function migrate_0_19_0(player)
    local inv = player:getInventory()
    if not inv then return false, "Could not access player inventory." end

    local items = inv:getItems()
    if not items then return false, "Could not access inventory items." end

    local converted = 0

    for i = 0, items:size() - 1 do
        local item = items:get(i)
        if item then
            local fullType = item:getFullType()
            if fullType and string.find(fullType, "PhobosChemistryPathways.", 1, true) then
                local md = item:getModData()
                if md then
                    local purity = md["PCP_Purity"]
                    if purity and type(purity) == "number" then
                        local maxCond = item:getConditionMax()
                        if maxCond and maxCond > 0 then
                            -- ConditionMax = 100, so purity maps directly to condition
                            local cond = math.max(0, math.min(maxCond, math.floor(purity + 0.5)))
                            item:setCondition(cond)
                            converted = converted + 1
                        end
                        md["PCP_Purity"] = nil  -- Remove old modData key
                    end
                end
            end
        end
    end

    if converted == 0 then
        return true, "No purity data to convert."
    end
    return true, "Converted " .. converted .. " item(s) from modData purity to condition."
end

---------------------------------------------------------------
-- v0.19.1 Migration
---------------------------------------------------------------

--- Rename "PCP_Chemist" → "Chemist" in DynamicTrading save data.
--- Traders spawned before v0.19.0 have the old archetype ID baked
--- into DT's ModData. The radio panel falls back to the raw string
--- when it can't find DynamicTrading.Archetypes["PCP_Chemist"].
--- This is a world-level migration (player param unused).
---@param player any  IsoGameCharacter (unused — operates on world ModData)
---@return boolean ok, string msg
local function migrate_0_19_1(player)
    -- Skip if DynamicTrading is not installed
    local dtActive = false
    pcall(function()
        dtActive = PhobosLib.isDynamicTradingActive()
    end)
    if not dtActive then
        return true, "DynamicTrading not active, skipped."
    end

    -- Access DT's live ModData
    local data = nil
    pcall(function()
        data = DynamicTrading.Manager.GetData()
    end)
    if not data or not data.Traders then
        return true, "No DT trader data found, skipped."
    end

    local patched = 0
    for id, trader in pairs(data.Traders) do
        if trader.archetype == "PCP_Chemist" then
            trader.archetype = "Chemist"
            patched = patched + 1
        end
    end

    if patched > 0 then
        pcall(function()
            ModData.transmit("DynamicTrading_Engine_v1.3")
        end)
    end

    if patched == 0 then
        return true, "No DT traders to patch."
    end
    return true, "Renamed " .. patched .. " trader(s) from PCP_Chemist to Chemist."
end

---------------------------------------------------------------
-- v0.19.2 Migration
---------------------------------------------------------------

--- Stamp purity on all unstamped PCP items in player inventory.
--- Items at condition == ConditionMax (100) get stamped to 99
--- (Lab-Grade).  This covers items from DT purchases (where
--- FluidContainers and books never had condition set), loot items,
--- and Chemist expert items that were all invisible to the purity
--- tooltip (which hides condition == ConditionMax as "unstamped").
---@param player any  IsoGameCharacter
---@return boolean ok, string msg
local function migrate_0_19_2(player)
    local inv = player:getInventory()
    if not inv then return false, "Could not access player inventory." end
    local items = inv:getItems()
    if not items then return false, "Could not access inventory items." end

    -- Check if impurity system is enabled
    local enabled = false
    pcall(function()
        enabled = PCP_PuritySystem and PCP_PuritySystem.isEnabled()
    end)
    if not enabled then
        return true, "Impurity system disabled, skipped."
    end

    local stamped = 0
    for i = 0, items:size() - 1 do
        local item = items:get(i)
        if item then
            local fullType = item:getFullType()
            if fullType and string.find(fullType, "PhobosChemistryPathways.", 1, true) then
                local maxCond = item:getConditionMax()
                if maxCond and maxCond > 0 and item:getCondition() == maxCond then
                    item:setCondition(99)
                    stamped = stamped + 1
                end
            end
        end
    end

    if stamped == 0 then
        return true, "No unstamped PCP items found."
    end
    return true, "Stamped " .. stamped .. " item(s) to Lab-Grade (99%)."
end

---------------------------------------------------------------
-- v0.19.3 Migration
---------------------------------------------------------------

--- Deep scan: stamp unstamped PCP items including backpacks/bags.
--- v0.19.2 only scanned player:getInventory():getItems() (main 40
--- slots).  This migration uses PhobosLib.iterateInventoryDeep()
--- to recurse into all sub-containers (worn backpacks, bags).
--- World containers (safehouse, vehicles) are handled separately
--- by PhobosLib.registerLazyConditionStamp() on the client side.
---@param player any  IsoGameCharacter
---@return boolean ok, string msg
local function migrate_0_19_3(player)
    -- Check if impurity system is enabled
    local enabled = false
    pcall(function()
        enabled = PCP_PuritySystem and PCP_PuritySystem.isEnabled()
    end)
    if not enabled then
        return true, "Impurity system disabled, skipped."
    end

    local stamped = 0
    PhobosLib.iterateInventoryDeep(player, function(item, container)
        local fullType = item:getFullType()
        if fullType and string.find(fullType, "PhobosChemistryPathways.", 1, true) then
            local maxCond = item:getConditionMax()
            if maxCond and maxCond > 0 and item:getCondition() == maxCond then
                item:setCondition(99)
                stamped = stamped + 1
            end
        end
    end)

    if stamped == 0 then
        return true, "No unstamped PCP items found (deep scan)."
    end
    return true, "Stamped " .. stamped .. " item(s) to Lab-Grade (99%) [deep scan]."
end

---------------------------------------------------------------
-- v0.20.0 Migration
---------------------------------------------------------------

--- Known PCP FluidContainer item fullTypes.
--- Used by the v0.20.0 migration to identify items that previously
--- had ConditionMax = 10 (B42 FluidContainer default) and need
--- their condition rescaled to the new ConditionMax = 100.
local FLUID_ITEMS = {
    ["PhobosChemistryPathways.SulphuricAcidJar"] = true,
    ["PhobosChemistryPathways.SulphuricAcidBottle"] = true,
    ["PhobosChemistryPathways.SulphuricAcidCrucible"] = true,
    ["PhobosChemistryPathways.SulphuricAcidClayJar"] = true,
    ["PhobosChemistryPathways.CrudeVegetableOil"] = true,
    ["PhobosChemistryPathways.CrudeVegetableOilClayJar"] = true,
    ["PhobosChemistryPathways.CrudeVegetableOilBucket"] = true,
    ["PhobosChemistryPathways.RenderedFat"] = true,
    ["PhobosChemistryPathways.RenderedFatClayJar"] = true,
    ["PhobosChemistryPathways.RenderedFatBucket"] = true,
    ["PhobosChemistryPathways.WoodMethanol"] = true,
    ["PhobosChemistryPathways.WoodTar"] = true,
    ["PhobosChemistryPathways.CrudeBiodiesel"] = true,
    ["PhobosChemistryPathways.CrudeBiodieselClayJar"] = true,
    ["PhobosChemistryPathways.CrudeBiodieselBucket"] = true,
    ["PhobosChemistryPathways.Glycerol"] = true,
    ["PhobosChemistryPathways.WashedBiodiesel"] = true,
    ["PhobosChemistryPathways.WashedBiodieselClayJar"] = true,
    ["PhobosChemistryPathways.WashedBiodieselBucket"] = true,
    ["PhobosChemistryPathways.RefinedBiodieselCan"] = true,
}

--- Rescale FluidContainer item conditions from old max-10 to max-100.
--- FluidContainer items in B42 defaulted to ConditionMax=10 before
--- PCP_Items.txt was updated with explicit ConditionMax=100.
--- Existing items in saves have condition values in the 0-10 range
--- that need to be multiplied by 10 to map correctly.
---@param player any  IsoGameCharacter
---@return boolean ok, string msg
local function migrate_0_20_0(player)
    -- Check if impurity system is enabled
    local enabled = false
    pcall(function()
        enabled = PCP_PuritySystem and PCP_PuritySystem.isEnabled()
    end)
    if not enabled then
        return true, "Impurity system disabled, skipped."
    end

    local rescaled = 0
    PhobosLib.iterateInventoryDeep(player, function(item, container)
        local fullType = item:getFullType()
        if not fullType or not FLUID_ITEMS[fullType] then return end

        local condition = item:getCondition()
        -- Only rescale items with condition in the old max-10 range (0-10).
        -- Items with condition > 10 were either already fixed or are
        -- newly created with the correct ConditionMax = 100.
        if condition >= 0 and condition <= 10 then
            local newCond = math.min(99, math.max(1, math.floor(condition * 10 + 0.5)))
            item:setCondition(newCond)
            rescaled = rescaled + 1
        end
    end)

    if rescaled == 0 then
        return true, "No FluidContainer items to rescale."
    end
    return true, "Rescaled " .. rescaled .. " FluidContainer item(s) from max-10 to max-100."
end

---------------------------------------------------------------
-- Register migrations
---------------------------------------------------------------

PhobosLib.registerMigration(
    MOD_ID,
    nil,         -- from: any previous version
    "0.18.0",    -- to: this version
    migrate_0_18_0,
    "PCP v0.18.0: Teach pot-alternative and surviving soap recipes"
)

PhobosLib.registerMigration(
    MOD_ID,
    "0.18.0",    -- from: v0.18.0
    "0.19.0",    -- to: this version
    migrate_0_19_0,
    "PCP v0.19.0: Convert modData purity to item condition"
)

PhobosLib.registerMigration(
    MOD_ID,
    "0.19.0",    -- from: v0.19.0
    "0.19.1",    -- to: this version
    migrate_0_19_1,
    "PCP v0.19.1: Rename PCP_Chemist to Chemist in DynamicTrading"
)

PhobosLib.registerMigration(
    MOD_ID,
    "0.19.1",    -- from: v0.19.1
    "0.19.2",    -- to: this version
    migrate_0_19_2,
    "PCP v0.19.2: Stamp purity on existing PCP items (condition 100 -> 99)"
)

PhobosLib.registerMigration(
    MOD_ID,
    "0.19.2",    -- from: v0.19.2
    "0.19.3",    -- to: this version
    migrate_0_19_3,
    "PCP v0.19.3: Deep scan stamp (includes backpacks/bags)"
)

PhobosLib.registerMigration(
    MOD_ID,
    "0.19.3",    -- from: v0.19.3
    "0.20.0",    -- to: this version
    migrate_0_20_0,
    "PCP v0.20.0: Rescale FluidContainer purity from max-10 to max-100"
)

---------------------------------------------------------------
-- v0.25.0 Migration (informational)
---------------------------------------------------------------

--- Log entity rebinding activation.
--- The actual rebinding is handled lazily by MapObjects hooks
--- in PCP_EntityRebind.lua (fires on every chunk load).
--- This migration records that the version requiring rebinding
--- has been reached, for auditability in the migration log.
---@param player any  IsoGameCharacter (unused)
---@return boolean ok, string msg
local function migrate_0_25_0(player)
    return true, "Entity rebinding active — pre-existing workstations rebound on chunk load."
end

PhobosLib.registerMigration(
    MOD_ID,
    "0.20.0",    -- from: v0.20.0
    "0.25.0",    -- to: this version
    migrate_0_25_0,
    "PCP v0.25.0: Activate entity rebinding for pre-existing workstations"
)

---------------------------------------------------------------
-- v1.0.0 Migration
---------------------------------------------------------------

--- zReLabItems fullType → ZVV/vanilla replacement fullType.
--- Maps every known zReVaccin consumable to its closest equivalent.
local ZRE_TO_ZVV = {
    ["zReLabItems.LabFlask"]              = "LabItems.LabFlask",
    ["zReLabItems.LabFlaskDirty"]         = "LabItems.LabFlaskDirty",
    ["zReLabItems.ChSodiumHydroxideBag"]  = "LabItems.ChSodiumHydroxideBag",
    ["zReLabItems.ChSulfuricAcidCan"]     = "LabItems.ChSulfuricAcidCan",
    ["zReLabItems.LabCorks"]              = "Base.Cork",
    ["zReLabItems.zReV2_6ECO_gloves"]     = "Base.Gloves_Surgical",
}

--- Convert orphaned zReLabItems to ZVV/vanilla equivalents.
--- When PCP switched its hard dependency from zReVaccin 3 to
--- Zombie Virus Vaccine (ZVV), items from the old zReLabItems
--- module become orphaned in existing saves.  This migration
--- replaces each known zReLabItems item with its ZVV or vanilla
--- equivalent, preserving condition (purity) and fluid contents.
---@param player any  IsoGameCharacter
---@return boolean ok, string msg
local function migrate_1_0_0(player)
    local converted = 0
    local removed   = 0

    PhobosLib.iterateInventoryDeep(player, function(item, container)
        local fullType = item:getFullType()
        if not fullType then return end

        -- Check if it's a known zReLabItems item with a mapped replacement
        local replacement = ZRE_TO_ZVV[fullType]
        if replacement == nil then
            -- Not in the map — check if it's still a zReLabItems item
            if not string.find(fullType, "zReLabItems.", 1, true) then
                return  -- not a zReLabItems item at all, skip
            end
            -- Unknown zReLabItems item — will be removed with no replacement
        end

        if replacement then
            -- Create the ZVV / vanilla equivalent
            local newItem = instanceItem(replacement)
            if newItem then
                -- Preserve condition (purity proxy) as a percentage
                local cond    = item:getCondition()
                local maxCond = item:getConditionMax()
                if cond and maxCond and maxCond > 0 and cond < maxCond then
                    local newMax = newItem:getConditionMax()
                    local pct    = cond / maxCond
                    newItem:setCondition(math.floor(pct * newMax + 0.5))
                end

                -- Preserve fluid contents for FluidContainer items
                local ok1, fc    = pcall(function() return item:getFluidContainer() end)
                local ok2, newFc = pcall(function() return newItem:getFluidContainer() end)
                if ok1 and fc and ok2 and newFc then
                    local amount = fc:getAmount()
                    if amount and amount > 0 then
                        local fluidOk, fluidName = pcall(function()
                            local pf = fc:getPrimaryFluid()
                            return pf and pf:getName()
                        end)
                        if fluidOk and fluidName then
                            pcall(function() newFc:addFluid(fluidName, amount) end)
                        end
                    end
                end

                container:AddItem(newItem)
                pcall(function() sendItemStats(newItem) end)
                pcall(function() sendAddItemToContainer(container, newItem) end)
                converted = converted + 1
            end
        else
            removed = removed + 1
        end

        -- Remove the orphaned zReLabItems item
        container:Remove(item)
        pcall(function() sendRemoveItemFromContainer(container, item) end)
    end)

    if converted == 0 and removed == 0 then
        return true, "No orphaned zReVaccin items found."
    end

    local parts = {}
    if converted > 0 then
        table.insert(parts, "Converted " .. converted .. " zReVaccin item(s) to ZVV equivalents")
    end
    if removed > 0 then
        table.insert(parts, "Removed " .. removed .. " unrecognised zReVaccin item(s)")
    end
    return true, table.concat(parts, ". ") .. "."
end

PhobosLib.registerMigration(
    MOD_ID,
    "0.25.0",    -- from: v0.25.0
    "1.0.0",     -- to: this version
    migrate_1_0_0,
    "PCP v1.0.0: Convert zReVaccin items to Zombie Virus Vaccine equivalents"
)

---------------------------------------------------------------
-- v1.2.0 Migration — Horticulture item conversion
---------------------------------------------------------------

--- [B42] Horticulture (Base.*) → PCP (PhobosChemistryPathways.*) map.
--- Horticulture defines ALL its items under the Base module.
--- When unsubscribed, those items become orphaned in saves.
--- This map converts them to PCP equivalents, preserving state.
local HORT_TO_PCP = {
    -- Direct equivalents (existing PCP botanical items)
    ["Base.HempStalks"]                    = "PhobosChemistryPathways.RettedHempStalk",
    ["Base.PaperPulp"]                     = "PhobosChemistryPathways.HempPulp",
    ["Base.PaperSheet"]                    = "PhobosChemistryPathways.HempPaper",
    ["Base.PaperSheetWet"]                 = "PhobosChemistryPathways.HempPaper",
    ["Base.PaperSheetPressed"]             = "PhobosChemistryPathways.HempPaper",
    ["Base.OilHemp"]                       = "PhobosChemistryPathways.HempTincture",
    ["Base.HempLeaves"]                    = "PhobosChemistryPathways.HempBastFiber",
    -- Tobacco
    ["Base.TobaccoWet"]                    = "PhobosChemistryPathways.TobaccoWet",
    ["Base.TobaccoChewing_Tin"]            = "PhobosChemistryPathways.ChewingTobacco",
    ["Base.TobaccoChewing_WaterTin"]       = "PhobosChemistryPathways.ChewingTobacco",
    ["Base.TobaccoChewing_Jar"]            = "PhobosChemistryPathways.ChewingTobacco",
    -- Hemp buds
    ["Base.HempBuds"]                      = "PhobosChemistryPathways.HempBuds",
    ["Base.HempBuds_Cured"]               = "PhobosChemistryPathways.HempBudsCured",
    ["Base.HempBuds_Decarbed"]            = "PhobosChemistryPathways.HempBudsDecarbed",
    ["Base.CannedHempBuds"]               = "PhobosChemistryPathways.CannedHempBuds",
    ["Base.CannedHempBuds_Cured"]         = "PhobosChemistryPathways.CannedHempBudsCured",
    ["Base.CannedHempBuds_Decarbed"]      = "PhobosChemistryPathways.CannedHempBudsDecarbed",
    ["Base.CannedHempBuds_Open"]          = "PhobosChemistryPathways.CannedHempBudsOpen",
    ["Base.CannedHempBuds_Decarbed_Open"] = "PhobosChemistryPathways.CannedHempBudsDecarbedOpen",
    ["Base.HempLoose"]                     = "PhobosChemistryPathways.HempLoose",
    -- Papermaking
    ["Base.PaperPulp_Pot"]                = "PhobosChemistryPathways.PaperPulpPot",
    ["Base.PaperPulp_PotForged"]          = "PhobosChemistryPathways.PaperPulpPotForged",
    ["Base.MouldAndDeckle"]               = "PhobosChemistryPathways.MouldAndDeckle",
    ["Base.MouldAndDeckle_PaperSheet"]    = "PhobosChemistryPathways.MouldAndDecklePaperSheet",
    ["Base.RawRollingPapers"]             = "PhobosChemistryPathways.RollingPapers",
    -- Smoking
    ["Base.SmokingPipeGlass"]             = "PhobosChemistryPathways.SmokingPipeGlass",
    ["Base.SmokingPipe_Hemp"]             = "PhobosChemistryPathways.SmokingPipeHemp",
    ["Base.SmokingPipeGlass_Hemp"]        = "PhobosChemistryPathways.SmokingPipeGlassHemp",
    ["Base.SmokingPipeGlass_Tobacco"]     = "PhobosChemistryPathways.SmokingPipeGlassTobacco",
    ["Base.CanPipe_Hemp"]                 = "PhobosChemistryPathways.CanPipeHemp",
    ["Base.CigarHemp"]                    = "PhobosChemistryPathways.CigarHemp",
    ["Base.CigarRolled"]                  = "PhobosChemistryPathways.CigarRolled",
    ["Base.CigaretteHemp"]               = "PhobosChemistryPathways.CigaretteHemp",
    ["Base.CigarettePack_Hemp"]          = "PhobosChemistryPathways.CigarettePackHemp",
    ["Base.CigarettePack_Rolled"]        = "PhobosChemistryPathways.CigarettePackRolled",
    -- Cooking
    ["Base.Saucepan_Syrup"]              = "PhobosChemistryPathways.SaucepanSyrup",
    ["Base.SaucepanCopper_Syrup"]        = "PhobosChemistryPathways.SaucepanCopperSyrup",
    ["Base.SimpleSugarSyrup"]            = "PhobosChemistryPathways.SimpleSugarSyrup",
}

--- Core conversion: scan all player containers and convert Horticulture
--- items to PCP equivalents, preserving condition / UsedDelta / food stats.
--- Uses a two-pass approach (collect then convert) to avoid skipping items
--- due to container index shifting during removal.
---@param player any  IsoGameCharacter
---@return number converted, number failed
local function convertHorticultureItems(player)
    local converted = 0
    local failed    = 0

    -- Pass 1: collect matching items (no container modifications)
    local pending = {}
    PhobosLib.iterateInventoryDeep(player, function(item, container)
        local fullType = item:getFullType()
        if not fullType then return end

        local replacement = HORT_TO_PCP[fullType]
        if replacement then
            table.insert(pending, {item = item, container = container, replacement = replacement, fullType = fullType})
        end
    end)

    PhobosLib.debug("PCP", "[PCP:Migration]", "Horticulture: found " .. #pending .. " item(s) to convert")

    -- Pass 2: convert collected items (safe to modify containers now)
    for _, entry in ipairs(pending) do
        local ok, err = pcall(function()
            local newItem = instanceItem(entry.replacement)
            if not newItem then
                PhobosLib.debug("PCP", "[PCP:Migration]", "FAILED: instanceItem(" .. entry.replacement .. ") returned nil for " .. entry.fullType)
                failed = failed + 1
                return
            end

            local item      = entry.item
            local container = entry.container

            -- Drainable items: preserve UsedDelta (best-effort).
            -- Orphaned drainable items from unsubscribed mods can throw
            -- RuntimeException on getUsedDelta/setUsedDelta — inner pcall
            -- ensures conversion continues even if state can't be preserved.
            pcall(function()
                if item.getUsedDelta and newItem.setUsedDelta then
                    local delta = item:getUsedDelta()
                    if delta then newItem:setUsedDelta(delta) end
                end
            end)

            -- Food items: preserve age (best-effort, same defensive pattern)
            pcall(function()
                if instanceof(item, "Food") and instanceof(newItem, "Food") then
                    newItem:setAge(item:getAge())
                end
            end)

            -- Condition: preserve as percentage (safe on all InventoryItem subtypes)
            local cond    = item:getCondition()
            local maxCond = item:getConditionMax()
            if cond and maxCond and maxCond > 0 and cond < maxCond then
                local newMax = newItem:getConditionMax()
                if newMax and newMax > 0 then
                    local pct = cond / maxCond
                    newItem:setCondition(math.max(1, math.floor(pct * newMax + 0.5)))
                end
            end

            -- Wet items: preserve wet state (safe on all InventoryItem subtypes)
            if item:isWet() then
                newItem:setWet(true)
            end

            container:AddItem(newItem)
            pcall(function() sendItemStats(newItem) end)
            pcall(function() sendAddItemToContainer(container, newItem) end)

            container:Remove(item)
            pcall(function() sendRemoveItemFromContainer(container, item) end)

            PhobosLib.debug("PCP", "[PCP:Migration]", "OK: " .. entry.fullType .. " -> " .. entry.replacement)
            converted = converted + 1
        end)
        if not ok then
            print("[PCP] Horticulture migration ERROR on " .. tostring(entry.fullType) .. ": " .. tostring(err))
            failed = failed + 1
        end
    end

    return converted, failed
end

--- v1.2.0 Horticulture migration — now manual-only via sandbox option.
--- Registration kept to maintain the version chain for v1.2.0 → v1.3.0.
---@param _player any  IsoGameCharacter (unused)
---@return boolean ok, string msg
local function migrate_1_2_0(_player)
    return true, "Horticulture migration is manual-only. Enable 'Migrate Horticulture Items' in sandbox settings."
end

PhobosLib.registerMigration(
    MOD_ID,
    "1.0.0",     -- from: v1.0.0
    "1.2.0",     -- to: this version
    migrate_1_2_0,
    "PCP v1.2.0: Convert [B42] Horticulture items to PCP equivalents"
)

---------------------------------------------------------------
-- v1.3.0 Migration — HempTincture FluidContainer backfill
---------------------------------------------------------------

--- HempTincture was converted from base:normal to FluidContainer.
--- Old items loaded from pre-v1.3.0 saves may have empty fluid contents.
--- This migration fills any empty HempTincture FluidContainers to capacity
--- and preserves existing condition (purity).
---@param player any  IsoGameCharacter
---@return boolean ok, string msg
local function migrate_1_3_0(player)
    local filled = 0

    PhobosLib.iterateInventoryDeep(player, function(item, container)
        local fullType = item:getFullType()
        if fullType ~= "PhobosChemistryPathways.HempTincture" then return end

        -- Check if FluidContainer exists and is empty
        local ok, fc = pcall(function() return item:getFluidContainer() end)
        if not ok or not fc then return end

        local amount = 0
        pcall(function() amount = fc:getAmount() or 0 end)
        if amount > 0 then return end  -- already filled, skip

        -- Fill to capacity with HempTincture fluid
        local capacity = 0.5
        pcall(function() capacity = fc:getCapacity() or 0.5 end)
        pcall(function() fc:addFluid("HempTincture", capacity) end)

        -- Sync in MP
        pcall(function() sendItemStats(item) end)

        filled = filled + 1
    end)

    if filled == 0 then
        return true, "No empty HempTincture FluidContainers found."
    end
    return true, "Filled " .. filled .. " HempTincture FluidContainer(s) with fluid."
end

PhobosLib.registerMigration(
    MOD_ID,
    "1.2.0",     -- from: v1.2.0
    "1.3.0",     -- to: this version
    migrate_1_3_0,
    "PCP v1.3.0: Backfill HempTincture FluidContainer fluid for pre-existing items"
)

---------------------------------------------------------------
-- v1.5.0 Migration — Chewing Tobacco redesign
---------------------------------------------------------------

--- Old PCP chewing tobacco fullTypes → new unified ChewingTobacco.
local OLD_CHEW_ITEMS = {
    ["PhobosChemistryPathways.ChewingTobaccoTin"]      = true,
    ["PhobosChemistryPathways.ChewingTobaccoWaterTin"]  = true,
    ["PhobosChemistryPathways.ChewingTobaccoJar"]       = true,
}

--- Old recipe names → new recipe names for knowledge migration.
local OLD_CHEW_RECIPES = {
    "PCPPackChewTobaccoTin",
    "PCPPackChewTobaccoWaterTin",
    "PCPPackChewTobaccoJar",
}

local NEW_CHEW_RECIPES = {
    "PCPPrepareChewingTobaccoMix",
    "PCPSealChewingTobaccoJar",
    "PCPOpenCuredTobaccoJar",
}

--- Convert old ChewingTobaccoTin/WaterTin/Jar to new ChewingTobacco,
--- preserving UsedDelta.  Teach new recipes to players who knew old ones.
---@param player any  IsoGameCharacter
---@return boolean ok, string msg
local function migrate_1_5_0(player)
    local converted = 0

    -- 1. Convert old chewing tobacco items to new unified item
    PhobosLib.iterateInventoryDeep(player, function(item, container)
        local fullType = item:getFullType()
        if not fullType or not OLD_CHEW_ITEMS[fullType] then return end

        local newItem = instanceItem("PhobosChemistryPathways.ChewingTobacco")
        if not newItem then return end

        -- Preserve UsedDelta (amount remaining)
        pcall(function()
            if item.getUsedDelta and newItem.setUsedDelta then
                local delta = item:getUsedDelta()
                if delta then newItem:setUsedDelta(delta) end
            end
        end)

        container:AddItem(newItem)
        pcall(function() sendItemStats(newItem) end)
        pcall(function() sendAddItemToContainer(container, newItem) end)

        container:Remove(item)
        pcall(function() sendRemoveItemFromContainer(container, item) end)

        converted = converted + 1
    end)

    -- 2. Teach new recipes to players who knew any old recipe
    local known = player:getKnownRecipes()
    local recipesLearned = 0
    if known and knowsAny(known, OLD_CHEW_RECIPES) then
        for _, name in ipairs(NEW_CHEW_RECIPES) do
            if teachRecipe(known, name) then
                recipesLearned = recipesLearned + 1
            end
        end
    end

    if converted == 0 and recipesLearned == 0 then
        return true, "No chewing tobacco migration needed."
    end

    local parts = {}
    if converted > 0 then
        table.insert(parts, "Converted " .. converted .. " old chewing tobacco item(s)")
    end
    if recipesLearned > 0 then
        table.insert(parts, "Taught " .. recipesLearned .. " new chewing tobacco recipe(s)")
    end
    return true, table.concat(parts, ". ") .. "."
end

PhobosLib.registerMigration(
    MOD_ID,
    "1.3.0",     -- from: v1.3.0
    "1.5.0",     -- to: this version
    migrate_1_5_0,
    "PCP v1.5.0: Convert old chewing tobacco items and teach new recipes"
)

---------------------------------------------------------------
-- Horticulture manual migration trigger (sandbox button)
---------------------------------------------------------------

--- Run the manual Horticulture migration if the sandbox button is enabled.
--- Uses consumeSandboxFlag to auto-reset the boolean after execution.
--- Re-runnable: no world guard — users can re-trigger if items were missed.
local function runManualHortMigration(players)
    -- Undo any previous consumeSandboxFlag — this migration is designed
    -- to be re-runnable while the toggle is ON.
    PhobosLib.unconsumeSandboxFlag("PCP", "MigrateHorticultureItems")

    -- Check sandbox button
    local requested = false
    pcall(function()
        require "PCP_SandboxIntegration"
        requested = PCP_Sandbox.isHorticultureMigrationRequested()
    end)
    if not requested then return end

    print("[PCP] Horticulture migration: manual trigger activated!")

    local totalConverted = 0
    local totalFailed    = 0

    for _, player in ipairs(players) do
        local converted, failed = convertHorticultureItems(player)
        totalConverted = totalConverted + converted
        totalFailed    = totalFailed + failed
    end

    -- Notify players (suppress popup when nothing to report)
    if totalConverted > 0 or totalFailed > 0 then
        local parts = {}
        if totalConverted > 0 then
            table.insert(parts, "Converted " .. totalConverted .. " Horticulture item(s)")
        end
        if totalFailed > 0 then
            table.insert(parts, totalFailed .. " item(s) could not be converted")
        end
        local msg = table.concat(parts, ". ") .. "."

        print("[PCP] Horticulture migration: " .. msg)
        for _, player in ipairs(players) do
            PhobosLib.notifyMigrationResult(player, MOD_ID, {
                ok = true,
                label = "PCP: Horticulture Item Migration",
                msg = msg,
            })
        end
    else
        print("[PCP] Horticulture migration: no Horticulture items found.")
    end
end

---------------------------------------------------------------
-- OnGameStart Hook
---------------------------------------------------------------

local function getAllPlayers()
    local players = {}
    pcall(function()
        if isClient() then return end
        local online = getOnlinePlayers()
        if online and online:size() > 0 then
            for i = 0, online:size() - 1 do
                table.insert(players, online:get(i))
            end
        else
            local p = getSpecificPlayer(0)
            if p then table.insert(players, p) end
        end
    end)
    return players
end

local function onGameStart()
    if isClient() then
        print("[PCP] MigrationSystem: skipped (client context)")
        return
    end

    print("[PCP] MigrationSystem: checking for pending migrations...")

    local players = getAllPlayers()
    local results = PhobosLib.runMigrations(MOD_ID, MOD_VERSION, players)

    -- Notify each player of results
    for _, result in ipairs(results) do
        for _, player in ipairs(players) do
            PhobosLib.notifyMigrationResult(player, MOD_ID, result)
        end
    end

    if #results == 0 then
        print("[PCP] MigrationSystem: no pending migrations")
    end

    -- Horticulture migration (manual sandbox button only)
    runManualHortMigration(players)

    print("[PCP] MigrationSystem: loaded [" .. (isServer() and "server" or "local") .. "]")
end

Events.OnGameStart.Add(onGameStart)
