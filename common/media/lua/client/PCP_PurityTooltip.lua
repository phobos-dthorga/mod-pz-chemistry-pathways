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
-- Purity is read from item condition, normalised to 0-100%.
-- With ConditionMax = 100: condition 80 = purity 80%.
-- Items at condition == ConditionMax are considered unstamped
-- and are hidden from the purity display.
--
-- Requires: PhobosLib >= 1.9.0
-- Runs client-side only (42/media/lua/client/).
---------------------------------------------------------------

require "PhobosLib"
require "PCP_Constants"
require "PCP_SandboxIntegration"

---------------------------------------------------------------
-- Purity tier definitions (from shared PCP_Constants)
---------------------------------------------------------------

local TIERS = PCP_Constants.PURITY_TIERS

--- Look up tier for a purity value.
local function getTier(purity)
    for _, tier in ipairs(TIERS) do
        if purity >= tier.min then return tier end
    end
    return TIERS[#TIERS]
end

---------------------------------------------------------------
-- Tooltip provider
---------------------------------------------------------------

PhobosLib.registerTooltipProvider("PhobosChemistryPathways.", function(item)
    -- Guard: impurity system must be enabled
    if not PCP_Sandbox.isPurityEnabled() then return nil end
    if type(item) ~= "userdata" then return nil end

    local getCondMaxFn = item.getConditionMax
    if not getCondMaxFn then return nil end
    local ok, maxCond = pcall(getCondMaxFn, item)
    if not ok or not maxCond or maxCond <= 0 then return nil end

    local getCondFn = item.getCondition
    if not getCondFn then return nil end
    local ok2, condition = pcall(getCondFn, item)
    if not ok2 or not condition then return nil end
    if condition >= maxCond then return nil end  -- unstamped

    -- Normalise condition to 0-100% purity (defensive for any ConditionMax)
    local purity = math.floor(condition / maxCond * 100 + 0.5)
    local tier = getTier(purity)
    local text = "Purity: " .. tier.name .. " (" .. purity .. "%)"
    return {{
        text = text,
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
    PCP_Sandbox.isPurityEnabled
)
