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
-- PCP_PuritySystem.lua
-- PCP-specific purity/impurity tracking system.
-- Purity is stored as item condition (ConditionMax = 100).
-- Condition maps 1:1 to purity (condition 80 = purity 80%).
--
-- Previous versions used modData["PCP_Purity"]; v0.19.0
-- migrates to condition and removes the modData key.
--
-- Requires: PhobosLib (for sandbox helpers and utility methods)
---------------------------------------------------------------

require "PhobosLib"
require "PCP_Constants"
require "PCP_SandboxIntegration"

PCP_PuritySystem = {}

local _TAG = "[PCP:Purity]"
local function _debug(msg) PhobosLib.debug("PCP", _TAG, msg) end
local function _trace(msg) PhobosLib.trace("PCP", _TAG, msg) end

---------------------------------------------------------------
-- Constants
---------------------------------------------------------------

--- Default purity for items without tracking (mid-save safe).
PCP_PuritySystem.DEFAULT = 50

--- Purity tier definitions — canonical source is PCP_Constants.PURITY_TIERS (shared).
PCP_PuritySystem.TIERS = PCP_Constants.PURITY_TIERS

--- Yield multiplier table (sorted highest-min first).
--- Maps purity ranges to yield fractions.
PCP_PuritySystem.YIELD_TABLE = {
    {min = 80, mult = 1.00},  -- Lab-Grade: full yield
    {min = 60, mult = 0.90},  -- Pure: 90%
    {min = 40, mult = 0.80},  -- Standard: 80%
    {min = 20, mult = 0.60},  -- Impure: 60%
    {min = 0,  mult = 0.40},  -- Contaminated: 40%
}

--- Equipment factors for purity propagation.
--- Higher = better purity transfer/improvement.
PCP_PuritySystem.EQUIP_FACTORS = {
    mortar        = 0.90,  -- slight degradation
    metalDrum     = 0.95,  -- minor degradation from scale
    chemistrySet  = 1.00,  -- neutral transfer
    centrifuge    = 1.10,  -- improvement
    microscope    = 1.15,  -- moderate improvement
    spectrometer  = 1.15,  -- moderate improvement
    chromatograph = 1.25,  -- significant improvement
}

--- Multiplicative variance percentage (±15% per craft).
--- Applied as: result * (1.0 + random(-15, +15) / 100).
PCP_PuritySystem.VARIANCE_PCT = 15


---------------------------------------------------------------
-- Sandbox Integration
---------------------------------------------------------------

--- Check if the impurity system is enabled (master toggle).
--- Delegates to PCP_Sandbox.isPurityEnabled() (shared).
---@return boolean
function PCP_PuritySystem.isEnabled()
    return PCP_Sandbox.isPurityEnabled()
end

--- Get the severity setting (1=Mild, 2=Standard, 3=Harsh).
---@return number
function PCP_PuritySystem.getSeverity()
    return PhobosLib.getSandboxVar("PCP", "ImpuritySeverity", 2)
end

--- Check if purity announcements are enabled.
---@return boolean
function PCP_PuritySystem.shouldAnnounce()
    return PhobosLib.getSandboxVar("PCP", "ShowPurityOnCraft", true) == true
end


---------------------------------------------------------------
-- Condition-Based Purity (normalised to 0-100% regardless of ConditionMax)
---------------------------------------------------------------

--- Get purity of an item from its condition, normalised to 0-100%.
--- Returns DEFAULT (50) if item has no ConditionMax.
---@param item any
---@return number  purity 0-100
function PCP_PuritySystem.getPurity(item)
    if not item then return PCP_PuritySystem.DEFAULT end
    local ok, result = pcall(function()
        local maxCond = item:getConditionMax()
        if not maxCond or maxCond <= 0 then return PCP_PuritySystem.DEFAULT end
        return math.floor(item:getCondition() / maxCond * 100 + 0.5)
    end)
    if ok then return result end
    return PCP_PuritySystem.DEFAULT
end

--- Set purity on an item via condition (purity 0-100, scaled to ConditionMax).
--- No-op if impurity system is disabled or item has no ConditionMax.
---@param item any
---@param value number  purity 0-100
---@return boolean
function PCP_PuritySystem.setPurity(item, value)
    if not PCP_PuritySystem.isEnabled() then return false end
    if not item then return false end
    value = math.max(0, math.min(100, math.floor(value + 0.5)))
    local ok = pcall(function()
        local maxCond = item:getConditionMax()
        if maxCond and maxCond > 0 then
            local scaledValue = math.floor(value / 100 * maxCond + 0.5)
            scaledValue = math.max(0, math.min(maxCond - 1, scaledValue))
            item:setCondition(scaledValue)
            pcall(sendItemStats, item)  -- sync to client for immediate UI refresh
        end
    end)
    return ok
end

--- Get tier info for a purity value.
---@param value number
---@return table  {name, r, g, b}
function PCP_PuritySystem.getTierInfo(value)
    return PhobosLib.getQualityTier(value, PCP_PuritySystem.TIERS)
end

--- Average purity across recipe input items via condition (normalised to 0-100%).
--- Only counts stamped items (condition < conditionMax). Vanilla/unstamped items
--- are excluded to prevent diluting PCP reagent purities upward.
--- Delegates to PhobosLib.averageStampedQuality().
---@param items any  Java ArrayList from OnCreate
---@return number
function PCP_PuritySystem.averageInputPurity(items)
    return PhobosLib.averageStampedQuality(items, PCP_PuritySystem.DEFAULT)
end

--- Get the multiplicative skill multiplier for a player.
--- Returns 1.0 at level 0; at level 10, returns (1.0 + maxEffect) where
--- maxEffect is determined by the sandbox SkillPurityInfluence setting:
---   None=×1.00, Low=×1.22, Standard=×1.44, High=×1.66.
---@param player any  IsoPlayer
---@return number     Multiplier (≥1.0)
function PCP_PuritySystem.getSkillMultiplier(player)
    local maxEffect = PCP_Sandbox.getSkillPurityMaxEffect()
    if maxEffect <= 0 then return 1.0 end
    return PhobosLib.getSkillMultiplier(player, Perks.AppliedChemistry, maxEffect)
end

--- Calculate output purity with severity-adjusted equipment factor,
--- multiplicative skill scaling, and ±15% multiplicative variance.
--- Formula: input * adjustedFactor * skillMult * varianceMult, clamped [0, 99].
---@param inputPurity number  Average input purity
---@param equipFactor number  Base equipment factor (from EQUIP_FACTORS)
---@param player any          IsoPlayer (for skill multiplier)
---@return number             Output purity (0-99)
function PCP_PuritySystem.calculateOutputPurity(inputPurity, equipFactor, player)
    local severity = PCP_PuritySystem.getSeverity()
    local adjusted = PhobosLib.adjustFactorBySeverity(equipFactor, severity)
    local skillMult = PCP_PuritySystem.getSkillMultiplier(player)
    local result = PhobosLib.calculateOutputQualityV2(
        inputPurity, adjusted, skillMult, PCP_PuritySystem.VARIANCE_PCT)
    if PhobosLib.isDebugEnabled("PCP") then
        _debug("calculateOutputPurity: input=" .. tostring(inputPurity)
            .. " equipFactor=" .. tostring(equipFactor)
            .. " severity=" .. tostring(severity)
            .. " adjusted=" .. tostring(adjusted)
            .. " skillMult=" .. tostring(skillMult)
            .. " -> output=" .. tostring(result))
    end
    return result
end

--- Generate random base purity for source recipes (no skill influence).
---@param min number
---@param max number
---@return number
function PCP_PuritySystem.randomBasePurity(min, max)
    return PhobosLib.randomBaseQuality(min, max)
end

--- Skill-aware random base purity for source recipes.
--- Applies multiplicative skill scaling and ±15% multiplicative variance.
---@param min number
---@param max number
---@param player any  IsoPlayer (for skill multiplier)
---@return number
function PCP_PuritySystem.randomBasePurityWithSkill(min, max, player)
    local skillMult = PCP_PuritySystem.getSkillMultiplier(player)
    return PhobosLib.randomBaseQualityV2(min, max, skillMult, PCP_PuritySystem.VARIANCE_PCT)
end

--- Announce purity via speech bubble (if enabled).
---@param player any
---@param value number
function PCP_PuritySystem.announcePurity(player, value)
    if not PCP_PuritySystem.isEnabled() then return end
    if not PCP_PuritySystem.shouldAnnounce() then return end
    PhobosLib.announceQuality(player, value, PCP_PuritySystem.TIERS, "Purity")
end

--- Apply fuel penalty by draining fluid from output container.
--- Incorporates sandbox YieldMultiplier.
---@param result any     The output item
---@param value number   Purity value
function PCP_PuritySystem.applyFuelPenalty(result, value)
    if not PCP_PuritySystem.isEnabled() then return end
    local sandboxMult = PCP_Sandbox.getYieldMultiplier()
    local yieldMult = PhobosLib.getEffectiveYield(value, PCP_PuritySystem.YIELD_TABLE, sandboxMult)
    if yieldMult >= 1.0 then return end
    local fc = PhobosLib.tryGetFluidContainer(result)
    if not fc then return end
    local capacity = PhobosLib.tryGetCapacity(fc) or 5.0
    local drainAmount = capacity * (1.0 - yieldMult)
    if drainAmount > 0 then
        PhobosLib.tryDrainFluid(fc, drainAmount)
    end
end

--- Remove excess items for yield penalty.
--- Incorporates sandbox YieldMultiplier.
---@param player any
---@param itemType string  Full type (e.g. "Base.GunPowder")
---@param baseCount number Nominal recipe output count
---@param purity number    Purity value
function PCP_PuritySystem.removeExcess(player, itemType, baseCount, purity)
    if not PCP_PuritySystem.isEnabled() then return end
    local sandboxMult = PCP_Sandbox.getYieldMultiplier()
    local yieldMult = PhobosLib.getEffectiveYield(purity, PCP_PuritySystem.YIELD_TABLE, sandboxMult)
    local keepCount = math.max(1, math.floor(baseCount * yieldMult + 0.5))
    PhobosLib.removeExcessItems(player, itemType, baseCount, keepCount)
end

--- Apply yield penalty only if recipe produces multiple items (count ≥ 2).
--- Single-output recipes are exempt: purity propagation is the penalty.
---@param player any
---@param itemType string  Full type (e.g. "PhobosChemistryPathways.BoneMeal")
---@param baseCount number Nominal recipe output count
---@param purity number    Purity value
function PCP_PuritySystem.applyYieldIfMultiOutput(player, itemType, baseCount, purity)
    if baseCount < 2 then return end
    PCP_PuritySystem.removeExcess(player, itemType, baseCount, purity)
end

--- Count unstamped (freshly created) items of a given type in player inventory.
--- "Unstamped" = condition at ConditionMax (not yet purity-stamped).
--- Call BEFORE stampOutputs to get the recipe's actual output count.
---@param player any
---@param resultType string  Full type (e.g. "PhobosChemistryPathways.BoneChar")
---@return number  Count of unstamped items (0 if none)
function PCP_PuritySystem.countUnstampedOutputs(player, resultType)
    if not player or not resultType then return 0 end
    local count = 0
    pcall(function()
        local inv = player:getInventory()
        if not inv then return end
        local items = inv:getItems()
        for i = 0, items:size() - 1 do
            local it = items:get(i)
            if it and it:getFullType() == resultType then
                local maxCond = it:getConditionMax()
                if maxCond and maxCond > 0 and it:getCondition() == maxCond then
                    count = count + 1
                end
            end
        end
    end)
    return count
end

--- Stamp purity (condition) on all unstamped copies of a result type.
--- "Unstamped" = condition at ConditionMax (freshly created items).
--- Purity value (0-100) is scaled to the item's ConditionMax range.
---@param player any
---@param resultType string
---@param value number  purity 0-100
function PCP_PuritySystem.stampOutputs(player, resultType, value)
    if not PCP_PuritySystem.isEnabled() then return end
    if not player then return end
    value = math.max(0, math.min(100, math.floor(value + 0.5)))
    if PhobosLib.isDebugEnabled("PCP") then
        _debug("stampOutputs: type=" .. tostring(resultType) .. " purity=" .. tostring(value))
    end
    pcall(function()
        local inv = player:getInventory()
        if not inv then return end
        local items = inv:getItems()
        for i = 0, items:size() - 1 do
            local it = items:get(i)
            if it and it:getFullType() == resultType then
                local maxCond = it:getConditionMax()
                if maxCond and maxCond > 0 then
                    -- Unstamped = condition equals ConditionMax (fresh from craft)
                    if it:getCondition() == maxCond then
                        local scaledValue = math.floor(value / 100 * maxCond + 0.5)
                        scaledValue = math.max(0, math.min(maxCond - 1, scaledValue))
                        it:setCondition(scaledValue)
                        pcall(sendItemStats, it)  -- sync to client for immediate UI refresh
                    end
                end
            end
        end
    end)
end
