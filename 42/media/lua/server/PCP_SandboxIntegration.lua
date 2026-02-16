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
-- Health Hazard Integration
---------------------------------------------------------------

--- Check if health hazards are enabled.
-- @return boolean  true if enabled (default false)
function PCP_Sandbox.isHealthHazardsEnabled()
    return PhobosLib.getSandboxVar("PCP", "EnableHealthHazards", false) == true
end

--- OnTest: shows recipe when hazards ARE enabled.
function PCP_Sandbox.onTestHazardEnabled(recipe, player)
    return PCP_Sandbox.isHealthHazardsEnabled()
end

--- OnTest: shows recipe when hazards are NOT enabled (originals).
function PCP_Sandbox.onTestNoHazard(recipe, player)
    return not PCP_Sandbox.isHealthHazardsEnabled()
end

--- OnTest: heat required AND hazards enabled.
function PCP_Sandbox.onTestHeatAndHazard(recipe, player)
    return PCP_Sandbox.isHeatRequired() and PCP_Sandbox.isHealthHazardsEnabled()
end

--- OnTest: no heat required AND hazards enabled.
function PCP_Sandbox.onTestNoHeatAndHazard(recipe, player)
    return (not PCP_Sandbox.isHeatRequired()) and PCP_Sandbox.isHealthHazardsEnabled()
end

--- OnTest: heat required AND hazards NOT enabled.
function PCP_Sandbox.onTestHeatAndNoHazard(recipe, player)
    return PCP_Sandbox.isHeatRequired() and (not PCP_Sandbox.isHealthHazardsEnabled())
end

--- OnTest: no heat required AND hazards NOT enabled.
function PCP_Sandbox.onTestNoHeatAndNoHazard(recipe, player)
    return (not PCP_Sandbox.isHeatRequired()) and (not PCP_Sandbox.isHealthHazardsEnabled())
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


-- Register the OnTest functions globally so recipes can reference them.
if not RecipeCodeOnTest then RecipeCodeOnTest = {} end
RecipeCodeOnTest.pcpAdvancedLabCheck = PCP_Sandbox.onTestAdvancedLab
RecipeCodeOnTest.pcpHeatRequiredCheck = PCP_Sandbox.onTestHeatRequired
RecipeCodeOnTest.pcpNoHeatRequiredCheck = PCP_Sandbox.onTestNoHeatRequired
RecipeCodeOnTest.pcpHazardEnabledCheck = PCP_Sandbox.onTestHazardEnabled
RecipeCodeOnTest.pcpNoHazardCheck = PCP_Sandbox.onTestNoHazard
RecipeCodeOnTest.pcpHeatAndHazardCheck = PCP_Sandbox.onTestHeatAndHazard
RecipeCodeOnTest.pcpNoHeatAndHazardCheck = PCP_Sandbox.onTestNoHeatAndHazard
RecipeCodeOnTest.pcpHeatAndNoHazardCheck = PCP_Sandbox.onTestHeatAndNoHazard
RecipeCodeOnTest.pcpNoHeatAndNoHazardCheck = PCP_Sandbox.onTestNoHeatAndNoHazard
