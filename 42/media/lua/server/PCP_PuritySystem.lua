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

PCP_PuritySystem = {}

---------------------------------------------------------------
-- Constants
---------------------------------------------------------------

--- Default purity for items without tracking (mid-save safe).
PCP_PuritySystem.DEFAULT = 50

--- Purity tier definitions (sorted highest-min first).
--- Each tier has: name, min threshold, and RGB colour.
--- DUPLICATED in PCP_PurityTooltip.lua (client) -- keep both in sync.
--- See GitHub Issue: "refactor: Extract shared constants (purity tiers)"
PCP_PuritySystem.TIERS = {
    {name = "Lab-Grade",     min = 80, r = 0.4, g = 0.6, b = 1.0},  -- blue
    {name = "Pure",          min = 60, r = 0.6, g = 1.0, b = 0.6},  -- green
    {name = "Standard",      min = 40, r = 1.0, g = 1.0, b = 0.4},  -- yellow
    {name = "Impure",        min = 20, r = 1.0, g = 0.6, b = 0.2},  -- orange
    {name = "Contaminated",  min = 0,  r = 1.0, g = 0.2, b = 0.2},  -- red
}

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

--- Random variance range (+/-5 per craft).
PCP_PuritySystem.VARIANCE = 5


---------------------------------------------------------------
-- Sandbox Integration
---------------------------------------------------------------

--- Check if the impurity system is enabled (master toggle).
---@return boolean
function PCP_PuritySystem.isEnabled()
    return PhobosLib.getSandboxVar("PCP", "EnableImpuritySystem", false) == true
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
-- Condition-Based Purity (ConditionMax = 100 -> 1:1 mapping)
---------------------------------------------------------------

--- Get purity of an item from its condition.
--- Returns DEFAULT (50) if item has no ConditionMax.
---@param item any
---@return number  purity 0-100
function PCP_PuritySystem.getPurity(item)
    if not item then return PCP_PuritySystem.DEFAULT end
    local ok, result = pcall(function()
        local maxCond = item:getConditionMax()
        if not maxCond or maxCond <= 0 then return PCP_PuritySystem.DEFAULT end
        return item:getCondition()
    end)
    if ok then return result end
    return PCP_PuritySystem.DEFAULT
end

--- Set purity on an item via condition (clamped 0-100).
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
            item:setCondition(value)
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

--- Average purity across recipe input items via condition.
--- Items without ConditionMax are counted as DEFAULT.
---@param items any  Java ArrayList from OnCreate
---@return number
function PCP_PuritySystem.averageInputPurity(items)
    if not items then return PCP_PuritySystem.DEFAULT end
    local total = 0
    local count = 0
    local ok, _ = pcall(function()
        for i = 0, items:size() - 1 do
            local item = items:get(i)
            if item then
                local maxCond = item:getConditionMax()
                if maxCond and maxCond > 0 then
                    total = total + item:getCondition()
                    count = count + 1
                else
                    -- Item has no ConditionMax; count as default
                    total = total + PCP_PuritySystem.DEFAULT
                    count = count + 1
                end
            end
        end
    end)
    if count == 0 then return PCP_PuritySystem.DEFAULT end
    return total / count
end

--- Calculate output purity with severity-adjusted equipment factor.
---@param inputPurity number  Average input purity
---@param equipFactor number  Base equipment factor (from EQUIP_FACTORS)
---@return number             Output purity (0-100)
function PCP_PuritySystem.calculateOutputPurity(inputPurity, equipFactor)
    local severity = PCP_PuritySystem.getSeverity()
    local adjusted = PhobosLib.adjustFactorBySeverity(equipFactor, severity)
    return PhobosLib.calculateOutputQuality(inputPurity, adjusted, PCP_PuritySystem.VARIANCE)
end

--- Generate random base purity for source recipes.
---@param min number
---@param max number
---@return number
function PCP_PuritySystem.randomBasePurity(min, max)
    return PhobosLib.randomBaseQuality(min, max)
end

--- Announce purity via speech bubble (if enabled).
---@param player any
---@param value number
function PCP_PuritySystem.announcePurity(player, value)
    if not PCP_PuritySystem.isEnabled() then return end
    if not PCP_PuritySystem.shouldAnnounce() then return end
    PhobosLib.announceQuality(player, value, PCP_PuritySystem.TIERS, "Purity")
end

--- Apply fuel penalty by draining fluid from RefinedBiodieselCan.
---@param result any     The output item
---@param value number   Purity value
function PCP_PuritySystem.applyFuelPenalty(result, value)
    if not PCP_PuritySystem.isEnabled() then return end
    PhobosLib.applyFluidQualityPenalty(result, value, PCP_PuritySystem.YIELD_TABLE)
end

--- Remove excess items for yield penalty (e.g. GunPowder).
---@param player any
---@param itemType string  Full type (e.g. "Base.GunPowder")
---@param baseCount number Nominal recipe output count
---@param purity number    Purity value
function PCP_PuritySystem.removeExcess(player, itemType, baseCount, purity)
    if not PCP_PuritySystem.isEnabled() then return end
    local yieldMult = PhobosLib.getQualityYield(purity, PCP_PuritySystem.YIELD_TABLE)
    local keepCount = math.max(1, math.floor(baseCount * yieldMult + 0.5))
    PhobosLib.removeExcessItems(player, itemType, baseCount, keepCount)
end

--- Stamp purity (condition) on all unstamped copies of a result type.
--- "Unstamped" = condition at ConditionMax (freshly created items).
---@param player any
---@param resultType string
---@param value number  purity 0-100
function PCP_PuritySystem.stampOutputs(player, resultType, value)
    if not PCP_PuritySystem.isEnabled() then return end
    if not player then return end
    value = math.max(0, math.min(100, math.floor(value + 0.5)))
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
                        it:setCondition(value)
                    end
                end
            end
        end
    end)
end
