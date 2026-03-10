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
-- PCP_DynamicTradingStamp.lua
-- Server-side monkey-patch for Dynamic Trading integration.
--
-- Problem: DT's GenerateItemCondition() priority chain skips
-- condition for FluidContainers (sets fluidAmount instead) and
-- books (no customData at all).  Items arrive at condition 100
-- (ConditionMax), which the PCP tooltip hides as "unstamped".
-- Expert items from the Chemist archetype also arrive at 100.
--
-- Fix: After DT creates items via AddItemWithCondition, stamp
-- condition 99 on any PCP item still at ConditionMax (100).
-- Items already < 100 (from DT's condition roll on Normal
-- items via non-expert vendors) keep their value as-is.
--
-- 99 = Lab-Grade tier, visible in tooltip.  Real-world
-- analytical-grade reagents are stamped ~99.8%, never 100%.
--
-- Only runs when DynamicTrading is loaded.
-- Only stamps PhobosChemistryPathways.* items.
-- Only active when the impurity system sandbox option is on.
--
-- Part of PhobosChemistryPathways >= 0.19.2
-- Requires PhobosLib >= 1.8.0
---------------------------------------------------------------

require "PCP_PuritySystem"

local _TAG = "[PCP:DTStamp]"
local _patched = false

local function patchAddItemWithCondition()
    if _patched then return end
    if not DynamicTrading or not DynamicTrading.ServerHelpers then return end

    local original = DynamicTrading.ServerHelpers.AddItemWithCondition
    if not original then return end

    DynamicTrading.ServerHelpers.AddItemWithCondition = function(container, fullType, count, customData)
        local items = original(container, fullType, count, customData)

        -- Only stamp PCP items when impurity system is enabled
        if not PCP_PuritySystem.isEnabled() then return items end
        if not fullType or not string.find(fullType, "PhobosChemistryPathways.", 1, true) then
            return items
        end

        if items then
            for i = 0, items:size() - 1 do
                local item = items:get(i)
                local maxCond = item:getConditionMax()
                if maxCond and maxCond > 0 and item:getCondition() == maxCond then
                    -- Expert/FluidContainer/Book at max -- stamp as Lab-Grade (99%)
                    -- Scale 99% to item's ConditionMax (defensive for any max)
                    local stampVal = math.floor(99 / 100 * maxCond + 0.5)
                    stampVal = math.min(maxCond - 1, stampVal)
                    item:setCondition(stampVal)
                end
                -- Items already < max (DT rolled 20-100% on Normal items)
                -- keep their condition as the purity value
            end
        end

        return items
    end

    _patched = true
    print(_TAG .. " Patched AddItemWithCondition for purity stamping")
end

Events.OnGameStart.Add(patchAddItemWithCondition)
