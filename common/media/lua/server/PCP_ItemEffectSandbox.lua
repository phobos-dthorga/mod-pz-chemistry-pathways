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
-- PCP_ItemEffectSandbox.lua
-- Server-side runtime patching of item script properties
-- based on sandbox settings.
--
-- On Events.OnGameStart, reads all hemp/medicinal effect
-- sandbox values via PCP_Sandbox getters and patches item
-- scripts using ScriptManager.instance:getItem():DoParam().
--
-- This allows server admins to customise every individual
-- effect value for every hemp product without editing scripts.
--
-- NOTE: Only patches item-script-based effects (smoking,
-- eating items). Timed action effects (poultice, tincture)
-- read sandbox values at perform-time via PCP_Sandbox getters.
--
-- Requires PhobosLib >= 1.17.0
-- Part of PhobosChemistryPathways >= 1.4.0
---------------------------------------------------------------

require "PhobosLib"
require "PCP_SandboxIntegration"

local _TAG = "[PCP:ItemEffectSandbox]"

---------------------------------------------------------------
-- Internal helpers
---------------------------------------------------------------

--- Patch an item script's properties via DoParam.
---@param fullType string   Fully qualified item type (e.g. "PhobosChemistryPathways.SmokingPipeHemp")
---@param params table      Array of "PropertyName = value" strings
local function patchItem(fullType, params)
    local ok, err = pcall(function()
        local script = ScriptManager.instance:getItem(fullType)
        if not script then
            print(_TAG .. " WARN: item script not found: " .. tostring(fullType))
            return
        end
        for _, param in ipairs(params) do
            script:DoParam(param)
        end
    end)
    if not ok then
        print(_TAG .. " ERROR patching " .. tostring(fullType) .. ": " .. tostring(err))
    end
end

--- Build a standard effect parameter list for a smoking/eating item.
---@param fatigue number    fatigueChange value
---@param stress number     StressChange value
---@param unhappy number    UnhappyChange value
---@param boredom number    BoredomChange value
---@param pain number       painReduction value
---@return table            Array of DoParam-compatible strings
local function buildEffectParams(fatigue, stress, unhappy, boredom, pain)
    return {
        "fatigueChange = " .. tostring(fatigue),
        "StressChange = " .. tostring(stress),
        "UnhappyChange = " .. tostring(unhappy),
        "BoredomChange = " .. tostring(boredom),
        "painReduction = " .. tostring(pain),
    }
end

---------------------------------------------------------------
-- Main patching function
---------------------------------------------------------------

local function applyItemEffectPatches()
    local enabled = PCP_Sandbox.areHempEffectsEnabled()

    print(_TAG .. " applying item effect patches (enabled=" .. tostring(enabled) .. ")")

    -- Hemp Pipes: SmokingPipeHemp, SmokingPipeGlassHemp, CanPipeHemp
    local pipeParams
    if enabled then
        pipeParams = buildEffectParams(
            PCP_Sandbox.getHempPipeFatigue(),
            PCP_Sandbox.getHempPipeStress(),
            PCP_Sandbox.getHempPipeUnhappy(),
            PCP_Sandbox.getHempPipeBoredom(),
            PCP_Sandbox.getHempPipePain()
        )
    else
        pipeParams = buildEffectParams(0, 0, 0, 0, 0)
    end
    patchItem("PhobosChemistryPathways.SmokingPipeHemp", pipeParams)
    patchItem("PhobosChemistryPathways.SmokingPipeGlassHemp", pipeParams)
    patchItem("PhobosChemistryPathways.CanPipeHemp", pipeParams)

    -- Hemp Cigar: CigarHemp
    local cigarParams
    if enabled then
        cigarParams = buildEffectParams(
            PCP_Sandbox.getHempCigarFatigue(),
            PCP_Sandbox.getHempCigarStress(),
            PCP_Sandbox.getHempCigarUnhappy(),
            PCP_Sandbox.getHempCigarBoredom(),
            PCP_Sandbox.getHempCigarPain()
        )
    else
        cigarParams = buildEffectParams(0, 0, 0, 0, 0)
    end
    patchItem("PhobosChemistryPathways.CigarHemp", cigarParams)

    -- Hemp Cigarette: CigaretteHemp, CigarettePackHemp
    local cigaretteParams
    if enabled then
        cigaretteParams = buildEffectParams(
            PCP_Sandbox.getHempCigaretteFatigue(),
            PCP_Sandbox.getHempCigaretteStress(),
            PCP_Sandbox.getHempCigaretteUnhappy(),
            PCP_Sandbox.getHempCigaretteBoredom(),
            PCP_Sandbox.getHempCigarettePain()
        )
    else
        cigaretteParams = buildEffectParams(0, 0, 0, 0, 0)
    end
    patchItem("PhobosChemistryPathways.CigaretteHemp", cigaretteParams)
    patchItem("PhobosChemistryPathways.CigarettePackHemp", cigaretteParams)

    -- Decarbed Buds: HempBudsDecarbed
    local decarbedParams
    if enabled then
        decarbedParams = buildEffectParams(
            PCP_Sandbox.getDecarbedBudsFatigue(),
            PCP_Sandbox.getDecarbedBudsStress(),
            PCP_Sandbox.getDecarbedBudsUnhappy(),
            PCP_Sandbox.getDecarbedBudsBoredom(),
            PCP_Sandbox.getDecarbedBudsPain()
        )
    else
        decarbedParams = buildEffectParams(0, 0, 0, 0, 0)
    end
    patchItem("PhobosChemistryPathways.HempBudsDecarbed", decarbedParams)

    -- Hemp Butter: HempButter
    local butterParams
    if enabled then
        butterParams = buildEffectParams(
            PCP_Sandbox.getHempButterFatigue(),
            PCP_Sandbox.getHempButterStress(),
            PCP_Sandbox.getHempButterUnhappy(),
            PCP_Sandbox.getHempButterBoredom(),
            PCP_Sandbox.getHempButterPain()
        )
    else
        butterParams = buildEffectParams(0, 0, 0, 0, 0)
    end
    patchItem("PhobosChemistryPathways.HempButter", butterParams)

    -- Hemp-Infused Oil: HempInfusedOil
    local oilParams
    if enabled then
        oilParams = buildEffectParams(
            PCP_Sandbox.getHempOilFatigue(),
            PCP_Sandbox.getHempOilStress(),
            PCP_Sandbox.getHempOilUnhappy(),
            PCP_Sandbox.getHempOilBoredom(),
            PCP_Sandbox.getHempOilPain()
        )
    else
        oilParams = buildEffectParams(0, 0, 0, 0, 0)
    end
    patchItem("PhobosChemistryPathways.HempInfusedOil", oilParams)

    -- Sugar Syrup: SimpleSugarSyrup (not gated by EnableHempEffects)
    local syrupParams = {
        "UnhappyChange = " .. tostring(PCP_Sandbox.getSugarSyrupUnhappy()),
        "BoredomChange = " .. tostring(PCP_Sandbox.getSugarSyrupBoredom()),
    }
    patchItem("PhobosChemistryPathways.SimpleSugarSyrup", syrupParams)

    print(_TAG .. " item effect patches applied")
end

---------------------------------------------------------------
-- Event hook
---------------------------------------------------------------

Events.OnGameStart.Add(function()
    pcall(applyItemEffectPatches)
end)

print(_TAG .. " loaded")
