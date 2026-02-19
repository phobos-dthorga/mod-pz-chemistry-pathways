---------------------------------------------------------------
-- PCP_MigrationSystem.lua
-- Server-side versioned migrations for PhobosChemistryPathways.
-- Uses PhobosLib_Migrate to register and run upgrade logic.
--
-- v0.18.0 migration:
--   - Teach pot-alternative recipes to players who know lab versions
--   - Teach surviving soap recipes to players who knew deleted variants
--
-- Requires: PhobosLib >= 1.8.0
---------------------------------------------------------------

require "PhobosLib"

local MOD_ID      = "PCP"
local MOD_VERSION = "0.18.0"

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
-- Register migration
---------------------------------------------------------------

PhobosLib.registerMigration(
    MOD_ID,
    nil,         -- from: any previous version
    "0.18.0",    -- to: this version
    migrate_0_18_0,
    "PCP v0.18.0: Teach pot-alternative and surviving soap recipes"
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
