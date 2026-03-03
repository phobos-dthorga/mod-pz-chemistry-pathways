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
-- collecting brine in a glass jar.
--
-- Part of PhobosChemistryPathways >= 0.23.0
-- Requires PhobosLib >= 1.14.0
---------------------------------------------------------------

require "PhobosLib"
require "TimedActions/ISBaseTimedAction"

local _TAG = "[PCP:BrineCollection]"

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

function PCP_CollectBrineAction:new(character, wellObj, jarItem, lidItem)
    local o = ISBaseTimedAction.new(self, character)
    o.wellObj = wellObj
    o.jarItem = jarItem
    o.lidItem = lidItem
    o.maxTime = 150
    return o
end

function PCP_CollectBrineAction:isValid()
    if not self.jarItem or not self.jarItem:getContainer() then return false end
    if not self.lidItem or not self.lidItem:getContainer() then return false end
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
    if self.jarItem then
        self.jarItem:setJobDelta(self:getJobDelta())
    end
end

function PCP_CollectBrineAction:stop()
    self:stopSound()
    if self.jarItem then
        self.jarItem:setJobDelta(0.0)
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
    if self.jarItem then
        self.jarItem:setJobDelta(0.0)
    end

    local inv = self.character:getInventory()

    -- Consume jar and lid
    inv:Remove(self.jarItem)
    pcall(sendRemoveItemFromContainer, inv, self.jarItem)
    inv:Remove(self.lidItem)
    pcall(sendRemoveItemFromContainer, inv, self.lidItem)

    -- Create BrineJar
    local brineJar = instanceItem("PhobosChemistryPathways.BrineJar")
    if brineJar then
        -- Stamp purity via condition (client-side; PCP_PuritySystem is server-only).
        -- Wrapped in pcall so purity failure never prevents item creation.
        pcall(function()
            local enabled = PhobosLib.getSandboxVar("PCP", "EnableImpuritySystem", false) == true
            if enabled then
                local purity = PhobosLib.randomBaseQuality(35, 55)
                PhobosLib.setConditionPercent(brineJar, purity)

                -- Stamp modData for recipe callback recovery after -fluid draining
                PhobosLib.setModDataValue(brineJar, "PCP_FluidPurity", purity)

                -- Speech bubble announcement
                local tier = PhobosLib.getQualityTier(purity, _TIERS)
                if tier then
                    PhobosLib.say(self.character, tier.name .. " (" .. tostring(math.floor(purity + 0.5)) .. "%)")
                end
            end
        end)

        inv:AddItem(brineJar)
        pcall(sendAddItemToContainer, inv, brineJar)
        inv:setDrawDirty(true)
        pcall(sendItemStats, brineJar)
    end

    ISBaseTimedAction.perform(self)
end

---------------------------------------------------------------
-- Context Menu Registration
---------------------------------------------------------------

--- Find a jar (EmptyJar or JarCrafted) and JarLid in the player's inventory.
---@param player any  IsoGameCharacter
---@return any, any   jarItem, lidItem (nil if not found)
local function findJarAndLid(player)
    local jar = PhobosLib.findItemByFullType(player, "Base.EmptyJar")
    if not jar then
        jar = PhobosLib.findItemByFullType(player, "Base.JarCrafted")
    end
    if not jar then return nil, nil end

    local lid = PhobosLib.findItemByFullType(player, "Base.JarLid")
    return jar, lid
end

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
            local jar, lid = findJarAndLid(player)
            if jar and lid then return true end

            -- Return plain-text reasons; PhobosLib formats them red
            local missing = {}
            if not jar then table.insert(missing, getText("Tooltip_PCP_NeedJar")) end
            if not lid then table.insert(missing, getText("Tooltip_PCP_NeedJarLid")) end
            return false, missing
        end,
        action  = function(player, obj)
            local jar, lid = findJarAndLid(player)
            if not jar or not lid then return end

            local sq = obj:getSquare()
            if not sq then return end

            if luautils.walkAdj(player, sq, false) then
                ISTimedActionQueue.add(PCP_CollectBrineAction:new(player, obj, jar, lid))
            end
        end,
        tooltip = getText("Tooltip_PCP_CollectBrineAction"),
    })

    print(_TAG .. " well brine collection registered")
end

registerBrineCollection()
