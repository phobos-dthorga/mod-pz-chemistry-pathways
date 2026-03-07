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

--- Get the skill purity influence divisor from sandbox settings.
--- Maps the enum (1=None, 2=Low, 3=Standard, 4=High) to a divisor
--- for PhobosLib.getSkillBonus(). Returns 0 for "None" (disabled).
-- @return number  divisor (0=disabled, 5=low, 2=standard, 1=high)
function PCP_Sandbox.getSkillPurityDivisor()
    local val = PhobosLib.getSandboxVar("PCP", "SkillPurityInfluence", 3)
    if val == 1 then return 0 end     -- None: disabled
    if val == 2 then return 5 end     -- Low:  level 10 → +2
    if val == 3 then return 2 end     -- Standard: level 10 → +5
    if val == 4 then return 1 end     -- High: level 10 → +10
    return 2                          -- fallback to Standard
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

--- Check if the Horticulture item migration flag is set.
-- @return boolean  true if migration requested (default false)
function PCP_Sandbox.isHorticultureMigrationRequested()
    return PhobosLib.getSandboxVar("PCP", "MigrateHorticultureItems", false) == true
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

--- Check if debug logging is enabled for PCP.
-- @return boolean  true if enabled (default false)
function PCP_Sandbox.isDebugEnabled()
    return PhobosLib.getSandboxVar("PCP", "EnableDebugLogging", false) == true
end

---------------------------------------------------------------
-- Hemp Effect Sandbox Queries
---------------------------------------------------------------

--- Check if hemp psychoactive/medicinal effects are enabled.
-- @return boolean  true if enabled (default true)
function PCP_Sandbox.areHempEffectsEnabled()
    return PhobosLib.getSandboxVar("PCP", "EnableHempEffects", true) == true
end

-- Hemp Pipe effects (SmokingPipeHemp, SmokingPipeGlassHemp, CanPipeHemp)
function PCP_Sandbox.getHempPipeFatigue()    return PhobosLib.getSandboxVar("PCP", "HempPipeFatigue", 16) end
function PCP_Sandbox.getHempPipeStress()     return PhobosLib.getSandboxVar("PCP", "HempPipeStress", -30) end
function PCP_Sandbox.getHempPipeUnhappy()    return PhobosLib.getSandboxVar("PCP", "HempPipeUnhappy", -40) end
function PCP_Sandbox.getHempPipeBoredom()    return PhobosLib.getSandboxVar("PCP", "HempPipeBoredom", -28) end
function PCP_Sandbox.getHempPipePain()       return PhobosLib.getSandboxVar("PCP", "HempPipePain", 28) end

-- Hemp Cigar effects (CigarHemp)
function PCP_Sandbox.getHempCigarFatigue()   return PhobosLib.getSandboxVar("PCP", "HempCigarFatigue", 30) end
function PCP_Sandbox.getHempCigarStress()    return PhobosLib.getSandboxVar("PCP", "HempCigarStress", -20) end
function PCP_Sandbox.getHempCigarUnhappy()   return PhobosLib.getSandboxVar("PCP", "HempCigarUnhappy", -80) end
function PCP_Sandbox.getHempCigarBoredom()   return PhobosLib.getSandboxVar("PCP", "HempCigarBoredom", -60) end
function PCP_Sandbox.getHempCigarPain()      return PhobosLib.getSandboxVar("PCP", "HempCigarPain", 56) end

-- Hemp Cigarette effects (CigaretteHemp, CigarettePackHemp)
function PCP_Sandbox.getHempCigaretteFatigue() return PhobosLib.getSandboxVar("PCP", "HempCigaretteFatigue", 8) end
function PCP_Sandbox.getHempCigaretteStress()  return PhobosLib.getSandboxVar("PCP", "HempCigaretteStress", -8) end
function PCP_Sandbox.getHempCigaretteUnhappy() return PhobosLib.getSandboxVar("PCP", "HempCigaretteUnhappy", -20) end
function PCP_Sandbox.getHempCigaretteBoredom() return PhobosLib.getSandboxVar("PCP", "HempCigaretteBoredom", -14) end
function PCP_Sandbox.getHempCigarettePain()    return PhobosLib.getSandboxVar("PCP", "HempCigarettePain", 14) end

-- Decarbed Buds effects (HempBudsDecarbed)
function PCP_Sandbox.getDecarbedBudsFatigue() return PhobosLib.getSandboxVar("PCP", "DecarbedBudsFatigue", 12) end
function PCP_Sandbox.getDecarbedBudsStress()  return PhobosLib.getSandboxVar("PCP", "DecarbedBudsStress", -16) end
function PCP_Sandbox.getDecarbedBudsUnhappy() return PhobosLib.getSandboxVar("PCP", "DecarbedBudsUnhappy", 15) end
function PCP_Sandbox.getDecarbedBudsBoredom() return PhobosLib.getSandboxVar("PCP", "DecarbedBudsBoredom", -20) end
function PCP_Sandbox.getDecarbedBudsPain()    return PhobosLib.getSandboxVar("PCP", "DecarbedBudsPain", 20) end

-- Hemp Poultice effects (timed action)
function PCP_Sandbox.getPoulticePain()   return PhobosLib.getSandboxVar("PCP", "PoulticePain", 30) end
function PCP_Sandbox.getPoulticeStress() return PhobosLib.getSandboxVar("PCP", "PoulticeStress", 30) end

-- Hemp Tincture effects (timed action)
function PCP_Sandbox.getTincturePain()     return PhobosLib.getSandboxVar("PCP", "TincturePain", 50) end
function PCP_Sandbox.getTinctureStress()   return PhobosLib.getSandboxVar("PCP", "TinctureStress", 50) end
function PCP_Sandbox.getTinctureUnhappy()  return PhobosLib.getSandboxVar("PCP", "TinctureUnhappy", 30) end
function PCP_Sandbox.getTinctureBoredom()  return PhobosLib.getSandboxVar("PCP", "TinctureBoredom", 20) end
function PCP_Sandbox.getTinctureFatigue()  return PhobosLib.getSandboxVar("PCP", "TinctureFatigue", 16) end

-- Hemp Butter effects (HempButter)
function PCP_Sandbox.getHempButterFatigue() return PhobosLib.getSandboxVar("PCP", "HempButterFatigue", 10) end
function PCP_Sandbox.getHempButterStress()  return PhobosLib.getSandboxVar("PCP", "HempButterStress", -14) end
function PCP_Sandbox.getHempButterUnhappy() return PhobosLib.getSandboxVar("PCP", "HempButterUnhappy", -6) end
function PCP_Sandbox.getHempButterBoredom() return PhobosLib.getSandboxVar("PCP", "HempButterBoredom", -16) end
function PCP_Sandbox.getHempButterPain()    return PhobosLib.getSandboxVar("PCP", "HempButterPain", 16) end

-- Hemp-Infused Oil effects (HempInfusedOil)
function PCP_Sandbox.getHempOilFatigue() return PhobosLib.getSandboxVar("PCP", "HempOilFatigue", 8) end
function PCP_Sandbox.getHempOilStress()  return PhobosLib.getSandboxVar("PCP", "HempOilStress", -12) end
function PCP_Sandbox.getHempOilUnhappy() return PhobosLib.getSandboxVar("PCP", "HempOilUnhappy", -4) end
function PCP_Sandbox.getHempOilBoredom() return PhobosLib.getSandboxVar("PCP", "HempOilBoredom", -14) end
function PCP_Sandbox.getHempOilPain()    return PhobosLib.getSandboxVar("PCP", "HempOilPain", 14) end

-- Sugar Syrup effects (SimpleSugarSyrup)
function PCP_Sandbox.getSugarSyrupUnhappy() return PhobosLib.getSandboxVar("PCP", "SugarSyrupUnhappy", -8) end
function PCP_Sandbox.getSugarSyrupBoredom() return PhobosLib.getSandboxVar("PCP", "SugarSyrupBoredom", -5) end

-- Moodle durations (game minutes)
function PCP_Sandbox.getPoulticeMoodleDuration()  return PhobosLib.getSandboxVar("PCP", "PoulticeMoodleDuration", 180) end
function PCP_Sandbox.getTinctureMoodleDuration()   return PhobosLib.getSandboxVar("PCP", "TinctureMoodleDuration", 360) end

print("[PCP] Sandbox: queries loaded [" .. (isServer() and "server" or "local") .. "]")
