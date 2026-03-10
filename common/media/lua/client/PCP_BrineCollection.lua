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
-- PCP_BrineCollection.lua
-- Client-side brine water collection from wells via context menu.
--
-- Registers a world object action on well sprites using
-- PhobosLib_WorldAction, and defines a timed action for
-- collecting brine into any accepted empty FluidContainer.
--
-- Part of PhobosChemistryPathways >= 0.24.0
-- Requires PhobosLib >= 1.12.0
---------------------------------------------------------------

require "PhobosLib"
require "PCP_SandboxIntegration"
require "TimedActions/ISBaseTimedAction"

local _TAG = "[PCP:BrineCollection]"

--- Accepted container types for brine collection.
--- Crafting-oriented vessels only; excludes canteens, water bottles, etc.
local _ACCEPTED_CONTAINERS = {
    -- Small (capacity ~1.0L)
    "Base.EmptyJar",
    "Base.JarCrafted",
    "Base.BottleCrafted",
    "Base.CeramicCrucibleSmall",
    "Base.ClayJarGlazed",
    -- Buckets (capacity ~10.0L)
    "Base.BucketForged",
    "Base.Bucket",
    "Base.BucketEmpty",
    "Base.BucketCarved",
    "Base.BucketWood",
}

--- Purity tiers for speech bubble (duplicated from PCP_PurityTooltip.lua).
--- Client cannot require server modules; keep in sync manually.
local _TIERS = {
    {name = "Lab-Grade",     min = 80, r = 0.4, g = 0.6, b = 1.0},
    {name = "Pure",          min = 60, r = 0.6, g = 1.0, b = 0.6},
    {name = "Standard",      min = 40, r = 1.0, g = 1.0, b = 0.4},
    {name = "Impure",        min = 20, r = 1.0, g = 0.6, b = 0.2},
    {name = "Contaminated",  min = 0,  r = 1.0, g = 0.2, b = 0.2},
}

---------------------------------------------------------------
-- Timed Action: PCP_CollectBrineAction
---------------------------------------------------------------

PCP_CollectBrineAction = ISBaseTimedAction:derive("PCP_CollectBrineAction")

function PCP_CollectBrineAction:new(character, wellObj, containerItem)
    local o = ISBaseTimedAction.new(self, character)
    o.wellObj = wellObj
    o.containerItem = containerItem
    o.maxTime = 150
    return o
end

function PCP_CollectBrineAction:isValid()
    if not self.containerItem or not self.containerItem:getContainer() then return false end
    if not self.wellObj then return false end
    return true
end

function PCP_CollectBrineAction:waitToStart()
    self.character:faceThisObject(self.wellObj)
    return self.character:shouldBeTurning()
end

function PCP_CollectBrineAction:start()
    self.sound = self.character:playSound("GetWaterFromLake")
    self:setActionAnim("fill_container_tap")
    self:setOverrideHandModels(nil, "Jar")
end

function PCP_CollectBrineAction:update()
    if self.containerItem then
        self.containerItem:setJobDelta(self:getJobDelta())
    end
end

function PCP_CollectBrineAction:stop()
    self:stopSound()
    if self.containerItem then
        self.containerItem:setJobDelta(0.0)
    end
    ISBaseTimedAction.stop(self)
end

--- Stop the looping sound if currently playing.
--- ISBaseTimedAction does NOT provide this — each action must define its own.
--- Pattern from vanilla ISAddFluidFromItemAction.
function PCP_CollectBrineAction:stopSound()
    if self.sound and self.character:getEmitter():isPlaying(self.sound) then
        self.character:stopOrTriggerSound(self.sound)
    end
end

function PCP_CollectBrineAction:perform()
    if self.sound then
        self:stopSound()
    end
    if self.containerItem then
        self.containerItem:setJobDelta(0.0)
    end

    -- Fill the container with Brine fluid to its full capacity
    pcall(function()
        local fc = PhobosLib.tryGetFluidContainer(self.containerItem)
        if not fc then return end
        local capacity = PhobosLib.tryGetCapacity(fc) or 1.0
        PhobosLib.tryAddFluid(fc, "Brine", capacity)
    end)

    -- Sync item fields locally (vanilla pattern: addFluid → syncItemFields → sendItemStats).
    -- Required for the recipe system to detect the new fluid contents.
    pcall(function() self.containerItem:syncItemFields() end)

    -- Stamp purity (client-side; PCP_PuritySystem is server-only).
    -- Wrapped in pcall so purity failure never prevents the fill.
    pcall(function()
        local enabled = PhobosLib.getSandboxVar("PCP", "EnableImpuritySystem", true) == true
        if enabled then
            local divisor = PCP_Sandbox.getSkillPurityDivisor()
            local purity
            if divisor == 0 then
                purity = PhobosLib.randomBaseQuality(35, 55)
            else
                purity = PhobosLib.randomBaseQualityWithSkill(35, 55, self.character, Perks.AppliedChemistry, divisor)
            end
            PhobosLib.setConditionPercent(self.containerItem, purity)

            -- Stamp modData for recipe callback recovery after -fluid draining
            PhobosLib.setModDataValue(self.containerItem, "PCP_Purity_Brine", purity)

            -- Speech bubble announcement
            local tier = PhobosLib.getQualityTier(purity, _TIERS)
            if tier then
                PhobosLib.say(self.character, tier.name .. " (" .. tostring(math.floor(purity + 0.5)) .. "%)")
            end
        end
    end)

    -- Sync for MP
    pcall(sendItemStats, self.containerItem)

    -- Refresh inventory UI
    local inv = self.character:getInventory()
    if inv then inv:setDrawDirty(true) end

    ISBaseTimedAction.perform(self)
end

---------------------------------------------------------------
-- Context Menu Registration
---------------------------------------------------------------

--- Register the brine collection action on wells.
--- Well sprites: camping_01_16 (standard well entity).
local function registerBrineCollection()
    if not PhobosLib.registerWorldObjectAction then
        print(_TAG .. " PhobosLib.registerWorldObjectAction not available (PhobosLib >= 1.14.0 required)")
        return
    end

    PhobosLib.registerWorldObjectAction({
        sprites = {"camping_01_16"},
        label   = getText("ContextMenu_PCP_CollectBrine"),
        test    = function(player, obj)
            local container = PhobosLib.findEmptyFluidContainer(player, _ACCEPTED_CONTAINERS)
            if container then return true end
            return false, { getText("Tooltip_PCP_NeedEmptyContainer") }
        end,
        action  = function(player, obj)
            local container = PhobosLib.findEmptyFluidContainer(player, _ACCEPTED_CONTAINERS)
            if not container then return end

            local sq = obj:getSquare()
            if not sq then return end

            if luautils.walkAdj(player, sq, false) then
                ISTimedActionQueue.add(PCP_CollectBrineAction:new(player, obj, container))
            end
        end,
        tooltip = getText("Tooltip_PCP_CollectBrineAction"),
    })

    print(_TAG .. " well brine collection registered")
end

registerBrineCollection()
