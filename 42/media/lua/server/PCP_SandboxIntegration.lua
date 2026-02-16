---------------------------------------------------------------
-- PCP_SandboxIntegration.lua
-- Server-side sandbox variable integration for PhobosChemistryPathways.
-- Reads SandboxVars.PCP.* and provides recipe callbacks.
-- Requires PhobosLib for safe sandbox access.
---------------------------------------------------------------

require "PhobosLib"

local PCP_Sandbox = {}

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

--- OnTest callback for advanced lab recipes.
-- Returns false if the sandbox option is disabled, preventing the recipe
-- from appearing in the crafting menu.
-- @param recipe    the recipe object
-- @param player    the player character
-- @return boolean  true if the recipe should be available
function PCP_Sandbox.onTestAdvancedLab(recipe, player)
    return PCP_Sandbox.isAdvancedLabEnabled()
end

--- Check if heat sources are required for bulk heated reactions.
-- @return boolean  true if heat sources required (default true)
function PCP_Sandbox.isHeatRequired()
    return PhobosLib.getSandboxVar("PCP", "RequireHeatSources", true) == true
end

--- OnTest callback for heated recipe variants (with BlowTorch).
-- Shows the heated version only when RequireHeatSources is ON.
function PCP_Sandbox.onTestHeatRequired(recipe, player)
    return PCP_Sandbox.isHeatRequired()
end

--- OnTest callback for simplified recipe variants (no BlowTorch).
-- Shows the simplified version only when RequireHeatSources is OFF.
function PCP_Sandbox.onTestNoHeatRequired(recipe, player)
    return not PCP_Sandbox.isHeatRequired()
end

---------------------------------------------------------------
-- Cross-Mod Integration: ZScienceSkill ("Science, Bitch!" mod)
-- Detected at runtime via PhobosLib.isModActive().
-- When active, Phase 2 (Applied Chemistry skill) will award
-- Science XP alongside chemistry XP at 50% rate.
-- Currently dormant — detection function only.
---------------------------------------------------------------

--- Check if the "Science, Bitch!" (ZScienceSkill) mod is active.
-- @return boolean  true if ZScienceSkill is loaded
function PCP_Sandbox.isZScienceActive()
    return PhobosLib.isModActive("ZScienceSkill")
end

-- Register the OnTest functions globally so recipes can reference them.
if not RecipeCodeOnTest then RecipeCodeOnTest = {} end
RecipeCodeOnTest.pcpAdvancedLabCheck = PCP_Sandbox.onTestAdvancedLab
RecipeCodeOnTest.pcpHeatRequiredCheck = PCP_Sandbox.onTestHeatRequired
RecipeCodeOnTest.pcpNoHeatRequiredCheck = PCP_Sandbox.onTestNoHeatRequired
