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
-- PCP_ImpurityDefaultMigration.lua
-- One-time server-side migration: auto-enables EnableImpuritySystem
-- for existing worlds where it was false (old v1.0.0 default).
-- Sets a world modData flag for the client notice popup.
--
-- Runs on Events.OnGameStart (server context).
-- Guard key prevents re-execution on subsequent loads.
---------------------------------------------------------------

require "PhobosLib"

local _TAG = "[PCP:ImpurityMigration]"

local GUARD_KEY  = "PCP_impurity_default_migrated"
local CHANGE_KEY = "PCP_impurity_default_changed"

local function onGameStart()
    -- Skip on dedicated server clients (server handles this)
    if isClient() then return end

    local worldMD = nil
    pcall(function() worldMD = getGameTime():getModData() end)
    if not worldMD then return end

    -- Already migrated — skip
    if worldMD[GUARD_KEY] then return end

    -- Read current sandbox value
    local currentVal = PhobosLib.getSandboxVar("PCP", "EnableImpuritySystem", true)

    if currentVal == false then
        -- Old default detected — enable it
        PhobosLib.setSandboxVar("PCP", "EnableImpuritySystem", true)
        worldMD[CHANGE_KEY] = true
        print(_TAG .. " EnableImpuritySystem changed from false to true")
    end

    -- Mark migration as done (regardless of whether we changed anything)
    worldMD[GUARD_KEY] = true
end

Events.OnGameStart.Add(onGameStart)

print(_TAG .. " loaded [" .. (isServer() and "server" or "local") .. "]")
