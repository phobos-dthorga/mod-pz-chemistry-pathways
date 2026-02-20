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
-- v0.19.1 migration:
--   - Rename "PCP_Chemist" → "Chemist" in DynamicTrading save data
--     (traders spawned before v0.19.0 ID rename)
--
-- v0.19.2 migration:
--   - Stamp purity on all unstamped PCP items (condition 100 -> 99)
--   - Covers DT purchases, loot, and expert items that were hidden
--
-- Requires: PhobosLib >= 1.8.0
---------------------------------------------------------------

require "PhobosLib"

local MOD_ID      = "PCP"
local MOD_VERSION = "0.19.2"

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

    print("[PCP] MigrationSystem: loaded [" .. (isServer() and "server" or "local") .. "]")
end

Events.OnGameStart.Add(onGameStart)
