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
-- PCP_PurityTooltip.lua
-- Client-side tooltip and lazy stamping for PCP purity system.
--
-- Registers a PhobosLib tooltip provider that appends a coloured
-- purity line (e.g. "Purity: Lab-Grade (99%)") below the vanilla
-- item tooltip for PhobosChemistryPathways items.
--
-- Also registers a lazy condition stamper to stamp unstamped PCP
-- items in world containers when the player opens them.
--
-- Purity is read from item condition (ConditionMax = 100).
-- Condition maps 1:1 to purity (condition 80 = purity 80%).
-- Items at condition == ConditionMax are considered unstamped
-- and are hidden from the purity display.
--
-- Requires: PhobosLib >= 1.9.0
-- Runs client-side only (42/media/lua/client/).
---------------------------------------------------------------

require "PhobosLib"

---------------------------------------------------------------
-- Purity tier definitions
---------------------------------------------------------------

--- Tier definitions -- DUPLICATED from PCP_PuritySystem.lua (server).
--- Client cannot require server modules, so tiers are defined in both places.
--- If you change tiers here, update PCP_PuritySystem.lua to match (and vice versa).
--- See GitHub Issue: "refactor: Extract shared constants (purity tiers)"
local TIERS = {
    {name = "Lab-Grade",     min = 80, r = 0.4, g = 0.6, b = 1.0},
    {name = "Pure",          min = 60, r = 0.6, g = 1.0, b = 0.6},
    {name = "Standard",      min = 40, r = 1.0, g = 1.0, b = 0.4},
    {name = "Impure",        min = 20, r = 1.0, g = 0.6, b = 0.2},
    {name = "Contaminated",  min = 0,  r = 1.0, g = 0.2, b = 0.2},
}

--- Look up tier for a purity value.
local function getTier(purity)
    for _, tier in ipairs(TIERS) do
        if purity >= tier.min then return tier end
    end
    return TIERS[#TIERS]
end

---------------------------------------------------------------
-- Sandbox guard (shared by tooltip and lazy stamper)
---------------------------------------------------------------

local function isPurityEnabled()
    return SandboxVars and SandboxVars.PCP
       and SandboxVars.PCP.EnableImpuritySystem == true
end

---------------------------------------------------------------
-- Tooltip provider
---------------------------------------------------------------

PhobosLib.registerTooltipProvider("PhobosChemistryPathways.", function(item)
    -- Guard: impurity system must be enabled
    if not isPurityEnabled() then return nil end

    local maxCond = item:getConditionMax()
    if not maxCond or maxCond <= 0 then return nil end

    local purity = item:getCondition()
    if purity >= maxCond then return nil end  -- Skip unstamped (condition == ConditionMax)

    local tier = getTier(purity)
    return {{
        text = "Purity: " .. tier.name .. " (" .. math.floor(purity) .. "%)",
        r = tier.r,
        g = tier.g,
        b = tier.b,
    }}
end)

---------------------------------------------------------------
-- Lazy container stamper
---------------------------------------------------------------

PhobosLib.registerLazyConditionStamp(
    "PhobosChemistryPathways.",
    99,
    isPurityEnabled
)
