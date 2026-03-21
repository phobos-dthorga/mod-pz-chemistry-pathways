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
-- PCP_MedicinalActions.lua
-- Client-side timed actions for applying hemp poultice and
-- taking hemp tincture, with inventory context menu hooks.
--
-- Poultice: Bandage animation, reduces pain on all body parts,
--           reduces stress, consumes the item.
-- Tincture: Drink animation, drains 0.1L per dose (5 doses per
--           0.5L bottle), reduces pain/stress/unhappiness/boredom,
--           adds mild drowsiness.
--
-- Both trigger the "Medicated" custom moodle via PhobosLib
-- when Moodle Framework is installed (soft dependency).
--
-- Effect values are read at perform-time from PCP_Sandbox
-- getters, allowing full sandbox customisation.
--
-- Requires PhobosLib >= 1.17.0
-- Part of PhobosChemistryPathways >= 1.4.0
---------------------------------------------------------------

require "PhobosLib"
require "PCP_SandboxIntegration"
require "TimedActions/ISBaseTimedAction"

local _TAG = "[PCP:MedicinalActions]"

--- Dose size in litres for tincture (0.1L = 5 doses per 0.5L bottle).
local TINCTURE_DOSE = 0.1

---------------------------------------------------------------
-- Shared helpers
---------------------------------------------------------------

--- Reduce pain on all body parts by a fixed amount.
--- Uses the B42 BodyDamage API via safecall for safety.
---@param character any    IsoGameCharacter
---@param amount number    Pain reduction per body part
local function reduceAllPain(character, amount)
    if not character or amount <= 0 then return end
    PhobosLib.safecall(function()
        local bd = character:getBodyDamage()
        if not bd then return end
        for i = 0, bd:getBodyParts():size() - 1 do
            local bp = bd:getBodyParts():get(i)
            if bp then
                local current = bp:getAdditionalPain()
                if current > 0 then
                    bp:setAdditionalPain(math.max(0, current - amount))
                end
            end
        end
    end)
end

--- Reduce a character stat by a normalised amount (0.0-1.0).
---@param character any    IsoGameCharacter
---@param statName string  "stress", "unhappiness", "boredom", "fatigue"
---@param amount number    Reduction amount (positive = reduce)
local function reduceStat(character, statName, amount)
    if not character or amount <= 0 then return end
    PhobosLib.safecall(function()
        local stats = character:getStats()
        if not stats then return end
        if statName == "stress" then
            local current = stats:getStress()
            stats:setStress(math.max(0, current - amount))
        elseif statName == "fatigue" then
            local current = stats:getFatigue()
            stats:setFatigue(math.min(1, current + amount))
        end
    end)
end

--- Reduce unhappiness on a character.
---@param character any    IsoGameCharacter
---@param amount number    Reduction amount (positive = reduce unhappiness)
local function reduceUnhappiness(character, amount)
    if not character or amount <= 0 then return end
    PhobosLib.safecall(function()
        local bd = character:getBodyDamage()
        if not bd then return end
        local current = bd:getUnhappynessLevel()
        bd:setUnhappynessLevel(math.max(0, current - amount))
    end)
end

--- Reduce boredom on a character.
---@param character any    IsoGameCharacter
---@param amount number    Reduction amount (positive = reduce boredom)
local function reduceBoredom(character, amount)
    if not character or amount <= 0 then return end
    PhobosLib.safecall(function()
        local bd = character:getBodyDamage()
        if not bd then return end
        local current = bd:getBoredomLevel()
        bd:setBoredomLevel(math.max(0, current - amount))
    end)
end

---------------------------------------------------------------
-- Timed Action: PCP_ApplyPoulticeAction
---------------------------------------------------------------

PCP_ApplyPoulticeAction = ISBaseTimedAction:derive("PCP_ApplyPoulticeAction")

function PCP_ApplyPoulticeAction:new(character, poulticeItem)
    local o = ISBaseTimedAction.new(self, character)
    o.poulticeItem = poulticeItem
    o.maxTime = 200
    return o
end

function PCP_ApplyPoulticeAction:isValid()
    if not self.poulticeItem or not self.poulticeItem:getContainer() then return false end
    return true
end

function PCP_ApplyPoulticeAction:waitToStart()
    return false
end

function PCP_ApplyPoulticeAction:start()
    self:setActionAnim("Bandage")
    self:setOverrideHandModels(nil, "Bandage")
end

function PCP_ApplyPoulticeAction:update()
    if self.poulticeItem then
        self.poulticeItem:setJobDelta(self:getJobDelta())
    end
end

function PCP_ApplyPoulticeAction:stop()
    if self.poulticeItem then
        self.poulticeItem:setJobDelta(0.0)
    end
    ISBaseTimedAction.stop(self)
end

function PCP_ApplyPoulticeAction:perform()
    if self.poulticeItem then
        self.poulticeItem:setJobDelta(0.0)
    end

    -- Read sandbox values at perform-time
    local painAmount  = PCP_Sandbox.getPoulticePain()
    local stressAmount = PCP_Sandbox.getPoulticeStress() * 0.01

    -- Apply effects
    reduceAllPain(self.character, painAmount)
    reduceStat(self.character, "stress", stressAmount)

    -- Consume the poultice
    PhobosLib.safecall(function()
        local inv = self.character:getInventory()
        if inv then inv:Remove(self.poulticeItem) end
    end)

    -- Trigger Medicated moodle (no-ops if MF absent)
    PhobosLib.safecall(function()
        local playerNum = self.character:getPlayerNum()
        local duration = PCP_Sandbox.getPoulticeMoodleDuration()
        PhobosLib.stackMoodleValue(playerNum, "Medicated", 0.7, duration)
    end)

    -- Speech bubble feedback
    PhobosLib.say(self.character, getText("IGUI_PCP_Medicated_Applied"))

    -- Refresh inventory
    PhobosLib.safecall(function()
        local inv = self.character:getInventory()
        if inv then inv:setDrawDirty(true) end
    end)

    ISBaseTimedAction.perform(self)
end

---------------------------------------------------------------
-- Timed Action: PCP_TakeTinctureAction
---------------------------------------------------------------

PCP_TakeTinctureAction = ISBaseTimedAction:derive("PCP_TakeTinctureAction")

function PCP_TakeTinctureAction:new(character, tinctureItem)
    local o = ISBaseTimedAction.new(self, character)
    o.tinctureItem = tinctureItem
    o.maxTime = 300
    return o
end

function PCP_TakeTinctureAction:isValid()
    if not self.tinctureItem or not self.tinctureItem:getContainer() then return false end
    -- Check there's enough fluid to take a dose
    local fc = PhobosLib.tryGetFluidContainer(self.tinctureItem)
    if not fc then return false end
    local amt = PhobosLib.tryGetAmount(fc)
    if not amt or amt < TINCTURE_DOSE * 0.5 then return false end
    return true
end

function PCP_TakeTinctureAction:waitToStart()
    return false
end

function PCP_TakeTinctureAction:start()
    self.sound = self.character:playSound("DrinkingFromBottleGlass")
    self:setActionAnim("Drink")
    self:setOverrideHandModels(nil, "BottleCrafted")
end

function PCP_TakeTinctureAction:update()
    if self.tinctureItem then
        self.tinctureItem:setJobDelta(self:getJobDelta())
    end
end

function PCP_TakeTinctureAction:stop()
    self:stopSound()
    if self.tinctureItem then
        self.tinctureItem:setJobDelta(0.0)
    end
    ISBaseTimedAction.stop(self)
end

function PCP_TakeTinctureAction:stopSound()
    if self.sound and self.character:getEmitter():isPlaying(self.sound) then
        self.character:stopOrTriggerSound(self.sound)
    end
end

function PCP_TakeTinctureAction:perform()
    if self.sound then
        self:stopSound()
    end
    if self.tinctureItem then
        self.tinctureItem:setJobDelta(0.0)
    end

    -- Drain one dose of fluid
    PhobosLib.safecall(function()
        local fc = PhobosLib.tryGetFluidContainer(self.tinctureItem)
        if fc then
            PhobosLib.tryDrainFluid(fc, TINCTURE_DOSE)
        end
    end)

    -- Read sandbox values at perform-time
    local painAmount    = PCP_Sandbox.getTincturePain()
    local stressAmount  = PCP_Sandbox.getTinctureStress() * 0.01
    local unhappyAmount = PCP_Sandbox.getTinctureUnhappy()
    local boredomAmount = PCP_Sandbox.getTinctureBoredom()
    local fatigueAmount = PCP_Sandbox.getTinctureFatigue() * 0.01

    -- Apply effects
    reduceAllPain(self.character, painAmount)
    reduceStat(self.character, "stress", stressAmount)
    reduceUnhappiness(self.character, unhappyAmount)
    reduceBoredom(self.character, boredomAmount)
    reduceStat(self.character, "fatigue", fatigueAmount)  -- adds drowsiness

    -- Trigger Medicated moodle (no-ops if MF absent)
    PhobosLib.safecall(function()
        local playerNum = self.character:getPlayerNum()
        local duration = PCP_Sandbox.getTinctureMoodleDuration()
        PhobosLib.stackMoodleValue(playerNum, "Medicated", 0.85, duration)
    end)

    -- Speech bubble feedback
    PhobosLib.say(self.character, getText("IGUI_PCP_Medicated_Tincture"))

    -- Sync item for MP and refresh UI
    PhobosLib.safecall(function() self.tinctureItem:syncItemFields() end)
    PhobosLib.safecall(sendItemStats, self.tinctureItem)
    PhobosLib.safecall(function()
        local inv = self.character:getInventory()
        if inv then inv:setDrawDirty(true) end
    end)

    ISBaseTimedAction.perform(self)
end

---------------------------------------------------------------
-- Context Menu Registration
---------------------------------------------------------------

--- Inventory context menu handler for medicinal items.
---@param playerNum number
---@param context any        ISContextMenu
---@param items table        Array of clicked items or item stacks
local function onFillInventoryObjectContextMenu(playerNum, context, items)
    if not items then return end

    local player = getSpecificPlayer(playerNum)
    if not player then return end

    -- Check if hemp effects are enabled
    if not PCP_Sandbox.areHempEffectsEnabled() then return end

    for _, itemOrStack in ipairs(items) do
        -- Unpack item from potential stack wrapper
        local item = itemOrStack
        if type(itemOrStack) == "table" then
            item = itemOrStack.items and itemOrStack.items[1]
        end

        if item then
            local fullType = nil
            PhobosLib.safecall(function() fullType = item:getFullType() end)

            if fullType then
                -- Hemp Poultice: "Apply Poultice"
                if fullType == "PhobosChemistryPathways.HempPoultice" then
                    local label = getText("ContextMenu_PCP_ApplyPoultice")
                    context:addOption(label, player, function(pl)
                        ISTimedActionQueue.add(PCP_ApplyPoulticeAction:new(pl, item))
                    end)
                end

                -- Hemp Tincture: "Take Tincture" (only if fluid remaining)
                if fullType == "PhobosChemistryPathways.HempTincture" then
                    local fc = PhobosLib.tryGetFluidContainer(item)
                    local amt = fc and PhobosLib.tryGetAmount(fc)
                    if amt and amt >= TINCTURE_DOSE * 0.5 then
                        local dosesLeft = math.floor(amt / TINCTURE_DOSE + 0.5)
                        local label = getText("ContextMenu_PCP_TakeTincture")
                            .. " (" .. tostring(dosesLeft) .. ")"
                        context:addOption(label, player, function(pl)
                            ISTimedActionQueue.add(PCP_TakeTinctureAction:new(pl, item))
                        end)
                    end
                end
            end
        end
    end
end

Events.OnFillInventoryObjectContextMenu.Add(onFillInventoryObjectContextMenu)

print(_TAG .. " medicinal actions registered")
