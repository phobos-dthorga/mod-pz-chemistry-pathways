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
-- PCP_SandboxIntegration.lua
-- Sandbox variable queries and cross-mod detection for
-- PhobosChemistryPathways.
-- Reads SandboxVars.PCP.* via PhobosLib.getSandboxVar().
-- Requires PhobosLib >= 1.5.0.
--
-- NOTE: Recipe visibility gating is handled client-side by
-- PCP_RecipeFilter.lua via PhobosLib.registerRecipeFilter().
-- B42 craftRecipe "OnTest" is a server-side execution gate,
-- NOT a UI visibility gate.
---------------------------------------------------------------

require "PhobosLib"

PCP_Sandbox = {}

---------------------------------------------------------------
-- Sandbox variable queries
---------------------------------------------------------------

--- Get the current yield multiplier from sandbox settings.
-- @return number  The multiplier (default 1.0)
function PCP_Sandbox.getYieldMultiplier()
    return PhobosLib.getSandboxVar("PCP", "YieldMultiplier", 1.0)
end

--- Check if advanced lab recipes (Microscope/Spectrometer) are enabled.
-- @return boolean  true if enabled (default false)
function PCP_Sandbox.isAdvancedLabEnabled()
    return PhobosLib.getSandboxVar("PCP", "EnableAdvancedLabRecipes", false) == true
end

--- Check if heat sources are required for bulk heated reactions.
-- @return boolean  true if heat sources required (default true)
function PCP_Sandbox.isHeatRequired()
    return PhobosLib.getSandboxVar("PCP", "RequireHeatSources", true) == true
end

--- Check if health hazards are enabled.
-- @return boolean  true if enabled (default false)
function PCP_Sandbox.isHealthHazardsEnabled()
    return PhobosLib.getSandboxVar("PCP", "EnableHealthHazards", false) == true
end

--- Check if the concrete mixer workstation is enabled.
-- @return boolean  true if enabled (default true)
function PCP_Sandbox.isConcreteMixerEnabled()
    return PhobosLib.getSandboxVar("PCP", "EnableConcreteMixer", true) == true
end

--- Get the concrete mixer yield bonus multiplier.
-- @return number  The multiplier (default 1.25)
function PCP_Sandbox.getConcreteMixerYieldBonus()
    return PhobosLib.getSandboxVar("PCP", "ConcreteMixerYieldBonus", 1.25)
end

---------------------------------------------------------------
-- Cross-Mod Integration: ZScienceSkill ("Science, Bitch!" mod)
-- Detected at runtime via PhobosLib.isModActive().
-- When active, Applied Chemistry XP mirrors to Science at 50%
-- rate (see PCP_SkillXP.lua) and PCP items become researchable
-- specimens at the microscope (see PCP_ZScienceData.lua).
---------------------------------------------------------------

--- Check if the "Science, Bitch!" (ZScienceSkill) mod is active.
-- @return boolean  true if ZScienceSkill is loaded
function PCP_Sandbox.isZScienceActive()
    return PhobosLib.isModActive("ZScienceSkill")
end

---------------------------------------------------------------
-- Cross-Mod Integration: EHR (Extensive Health Rework)
-- Detected at runtime via PhobosLib.isModActive("EHR").
-- When active and EnableHealthHazards is ON, unsafe recipes
-- trigger EHR diseases. Without EHR, vanilla stat fallback.
---------------------------------------------------------------

--- Check if EHR mod is active (convenience wrapper).
-- @return boolean  true if EHR is loaded and disease system enabled
function PCP_Sandbox.isEHRActive()
    return PhobosLib.isEHRActive()
end

print("[PCP] Sandbox: queries loaded [" .. (isServer() and "server" or "local") .. "]")
