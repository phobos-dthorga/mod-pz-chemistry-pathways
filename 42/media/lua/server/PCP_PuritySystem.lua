---------------------------------------------------------------
-- PCP_PuritySystem.lua
-- PCP-specific purity/impurity tracking system.
-- Thin wrapper around PhobosLib.Quality with PCP constants,
-- sandbox integration, and convenience methods.
--
-- All generic quality logic lives in PhobosLib_Quality.lua.
-- This file provides PCP-specific configuration only.
--
-- Requires: PhobosLib (with Quality module)
---------------------------------------------------------------

require "PhobosLib"

PCP_PuritySystem = {}

---------------------------------------------------------------
-- Constants
---------------------------------------------------------------

--- modData key used to store purity on items.
PCP_PuritySystem.KEY = "PCP_Purity"

--- Default purity for items without tracking (mid-save safe).
PCP_PuritySystem.DEFAULT = 50

--- Purity tier definitions (sorted highest-min first).
--- Each tier has: name, min threshold, and RGB colour.
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

--- Random variance range (±5 per craft).
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
-- Convenience Wrappers (delegate to PhobosLib)
---------------------------------------------------------------

--- Get purity of an item (default 50 = Standard).
---@param item any
---@return number
function PCP_PuritySystem.getPurity(item)
    return PhobosLib.getQuality(item, PCP_PuritySystem.KEY, PCP_PuritySystem.DEFAULT)
end

--- Set purity on an item (clamped 0-100).
---@param item any
---@param value number
---@return boolean
function PCP_PuritySystem.setPurity(item, value)
    return PhobosLib.setQuality(item, PCP_PuritySystem.KEY, value)
end

--- Get tier info for a purity value.
---@param value number
---@return table  {name, r, g, b}
function PCP_PuritySystem.getTierInfo(value)
    return PhobosLib.getQualityTier(value, PCP_PuritySystem.TIERS)
end

--- Average purity across recipe input items.
---@param items any  Java ArrayList from OnCreate
---@return number
function PCP_PuritySystem.averageInputPurity(items)
    return PhobosLib.averageInputQuality(items, PCP_PuritySystem.KEY, PCP_PuritySystem.DEFAULT)
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

--- Stamp purity on all unstamped copies of a result type.
---@param player any
---@param resultType string
---@param value number
function PCP_PuritySystem.stampOutputs(player, resultType, value)
    PhobosLib.stampAllOutputs(player, resultType, PCP_PuritySystem.KEY, value)
end
