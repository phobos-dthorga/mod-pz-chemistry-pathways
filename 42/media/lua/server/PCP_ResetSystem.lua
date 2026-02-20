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
-- PCP_ResetSystem.lua
-- Server-side tiered reset/cleanup system for PCP.
-- Reads one-shot sandbox booleans at game start, executes the
-- requested tier, guards against re-execution via world modData,
-- and sends result notifications to the client.
--
-- Requires: PhobosLib >= 1.4.1 (Reset + Sandbox modules)
---------------------------------------------------------------

require "PhobosLib"

local PCP_Reset = {}

---------------------------------------------------------------
-- Tier Definitions
---------------------------------------------------------------

PCP_Reset.TIERS = {
    {
        id          = "StripPurity",
        sandboxVar  = "ResetStripPurity",
        label       = "Strip Purity Data",
        execute     = function(player)
            local count = PhobosLib.stripModDataKey(player, "PCP_Purity")
            return true, "Stripped purity data from " .. count .. " item(s)."
        end,
    },
    {
        id          = "ForgetRecipes",
        sandboxVar  = "ResetForgetRecipes",
        label       = "Forget PCP Recipes",
        execute     = function(player)
            local count = PhobosLib.forgetRecipesByPrefix(player, "PCP")
            return true, "Forgot " .. count .. " PCP recipe(s)."
        end,
    },
    {
        id          = "ResetSkillXP",
        sandboxVar  = "ResetSkillXP",
        label       = "Reset Applied Chemistry XP",
        execute     = function(player)
            local perkEnum = nil
            pcall(function()
                if Perks and Perks.AppliedChemistry then
                    perkEnum = Perks.AppliedChemistry
                end
            end)
            if not perkEnum then
                return false, "Applied Chemistry perk not found. XP not reset."
            end
            local ok = PhobosLib.resetPerkXP(player, perkEnum)
            if ok then
                return true, "Applied Chemistry XP reset to 0."
            else
                return false, "Applied Chemistry XP reset FAILED. PZ may not expose the required API."
            end
        end,
    },
    {
        id          = "NuclearRemove",
        sandboxVar  = "ResetNuclearRemove",
        label       = "Remove All PCP Items",
        execute     = function(player)
            local count = PhobosLib.removeItemsByModule(player, "PhobosChemistryPathways")
            return true, "Removed " .. count .. " PCP item(s) from inventory."
        end,
    },
}

---------------------------------------------------------------
-- Tier Execution
---------------------------------------------------------------

--- Execute a single tier for a player.
---@param tierIndex number  1-based index into TIERS
---@param player any        IsoGameCharacter
---@return boolean ok, string message
function PCP_Reset.executeTier(tierIndex, player)
    local tier = PCP_Reset.TIERS[tierIndex]
    if not tier then return false, "Invalid tier index: " .. tostring(tierIndex) end

    local ok, msg = false, "Unknown error"
    local success, err = pcall(function()
        ok, msg = tier.execute(player)
    end)

    if not success then
        ok = false
        msg = tier.label .. " failed with error: " .. tostring(err)
    end

    print("[PCP] Reset: Tier " .. tier.id .. " → " .. (ok and "OK" or "FAIL") .. " → " .. msg)
    return ok, msg
end

--- Execute all 4 tiers in sequence (Nuclear All).
---@param player any  IsoGameCharacter
---@return boolean allOk, string summary
function PCP_Reset.executeAll(player)
    local results = {}
    local allOk = true

    for i = 1, #PCP_Reset.TIERS do
        local ok, msg = PCP_Reset.executeTier(i, player)
        table.insert(results, (ok and "[OK] " or "[FAIL] ") .. msg)
        if not ok then allOk = false end
    end

    return allOk, table.concat(results, "\n")
end

---------------------------------------------------------------
-- Notification Helpers
---------------------------------------------------------------

--- Send a reset result notification to a player's client.
--- In SP, server and client are the same process.
---@param player any
---@param tierId string
---@param ok boolean
---@param msg string
local function notifyPlayer(player, tierId, ok, msg)
    pcall(function()
        sendServerCommand(player, "PCP", "resetResult", {
            tier   = tierId,
            status = ok and "ok" or "fail",
            msg    = msg,
        })
    end)
end

---------------------------------------------------------------
-- World modData Guard
---------------------------------------------------------------

local function getWorldFlag(key)
    local val = nil
    pcall(function()
        val = getGameTime():getModData()[key]
    end)
    return val
end

local function setWorldFlag(key, value)
    pcall(function()
        getGameTime():getModData()[key] = value
    end)
end

---------------------------------------------------------------
-- Player Iteration
---------------------------------------------------------------

--- Get all players to process (MP: online players, SP: player 0).
---@return table  Array of IsoGameCharacter
local function getAllPlayers()
    local players = {}

    pcall(function()
        if isClient() then
            -- Dedicated client should never run reset logic
            return
        end

        local online = getOnlinePlayers()
        if online and online:size() > 0 then
            -- MP server: iterate all online players
            for i = 0, online:size() - 1 do
                table.insert(players, online:get(i))
            end
        else
            -- SP: get player 0
            local p = getSpecificPlayer(0)
            if p then
                table.insert(players, p)
            end
        end
    end)

    return players
end

---------------------------------------------------------------
-- OnGameStart Hook
---------------------------------------------------------------

local function onGameStart()
    -- Only run on server or SP host, never on a dedicated client
    if isClient() then
        print("[PCP] ResetSystem: skipped (client context)")
        return
    end

    print("[PCP] ResetSystem: checking sandbox reset flags...")
    local anyTriggered = false

    -- Check Nuclear All first (it subsumes all other tiers)
    local nuclearVar = "ResetNuclearAll"
    local nuclearFlag = "PCP_Reset_NuclearAll_done"
    local nuclearEnabled = PhobosLib.getSandboxVar("PCP", nuclearVar, false) == true

    if nuclearEnabled and not getWorldFlag(nuclearFlag) then
        anyTriggered = true
        print("[PCP] ResetSystem: Nuclear All triggered — executing all tiers...")

        local players = getAllPlayers()
        for _, player in ipairs(players) do
            local ok, summary = PCP_Reset.executeAll(player)
            notifyPlayer(player, "NuclearAll", ok, summary)
        end

        setWorldFlag(nuclearFlag, true)
        PhobosLib.consumeSandboxFlag("PCP", nuclearVar)
    else
        -- Check individual tiers
        for _, tier in ipairs(PCP_Reset.TIERS) do
            local worldFlag = "PCP_Reset_" .. tier.id .. "_done"
            local enabled = PhobosLib.getSandboxVar("PCP", tier.sandboxVar, false) == true

            if enabled and not getWorldFlag(worldFlag) then
                anyTriggered = true
                print("[PCP] ResetSystem: Tier " .. tier.id .. " triggered...")

                local players = getAllPlayers()
                for _, player in ipairs(players) do
                    local ok, msg = PCP_Reset.executeTier(
                        -- find tier index by id
                        (function()
                            for i, t in ipairs(PCP_Reset.TIERS) do
                                if t.id == tier.id then return i end
                            end
                            return 1
                        end)(),
                        player
                    )
                    notifyPlayer(player, tier.id, ok, msg)
                end

                setWorldFlag(worldFlag, true)
                PhobosLib.consumeSandboxFlag("PCP", tier.sandboxVar)
            end
        end
    end

    if not anyTriggered then
        print("[PCP] ResetSystem: no reset flags active")
    end

    print("[PCP] ResetSystem: loaded [" .. (isServer() and "server" or "local") .. "]")
end

Events.OnGameStart.Add(onGameStart)
