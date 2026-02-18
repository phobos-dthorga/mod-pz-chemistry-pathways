---------------------------------------------------------------
-- PCP_RecipeFilter.lua
-- Client-side recipe visibility filters for PhobosChemistryPathways.
-- Uses PhobosLib.registerRecipeFilters() to hide/show recipe
-- variants based on sandbox settings:
--   - RequireHeatSources (ON/OFF)
--   - EnableHealthHazards (ON/OFF)
--   - EnableAdvancedLabRecipes (ON/OFF)
--
-- B42 craftRecipe "OnTest" is a server-side execution gate,
-- NOT a UI visibility gate. This module provides the actual
-- crafting menu filtering via PhobosLib_RecipeFilter.
--
-- Part of PhobosChemistryPathways >= 0.14.0
-- Requires PhobosLib >= 1.5.0
---------------------------------------------------------------

require "PhobosLib"
require "PCP_SandboxIntegration"

local filters = {}

---------------------------------------------------------------
-- Heat-required variants (show only when RequireHeatSources = ON)
-- These are the "normal" recipes that need a BlowTorch/heat source.
---------------------------------------------------------------
local heatRequired = {
    "PCPPurifyCharcoalWater",
    "PCPPurifyCharcoalNaOH",
    "PCPSynthesizeKNO3Fertilizer",
    "PCPSynthesizeKNO3Compost",
    "PCPPressOilSoybeansLab",
    "PCPPressOilSunflowerLab",
    "PCPPressOilCornLab",
    "PCPPressOilFlaxLab",
    "PCPPressOilHempLab",
    "PCPPressOilPeanutLab",
    "PCPRenderFat",
    "PCPTransesterifyOil",
    "PCPTransesterifyFat",
    "PCPTransesterifyOilBulk",
    "PCPTransesterifyOilBulkCoke",
    "PCPTransesterifyOilBulkPropane",
    "PCPTransesterifyFatBulk",
    "PCPTransesterifyFatBulkCoke",
    "PCPTransesterifyFatBulkPropane",
    "PCPTransesterifyOilNaOH",
    "PCPTransesterifyFatNaOH",
    "PCPTransesterifyOilBulkNaOH",
    "PCPTransesterifyOilBulkNaOHCoke",
    "PCPTransesterifyOilBulkNaOHPropane",
    "PCPTransesterifyFatBulkNaOH",
    "PCPTransesterifyFatBulkNaOHCoke",
    "PCPTransesterifyFatBulkNaOHPropane",
    "PCPWashBiodiesel",
    "PCPWashBiodieselBulk",
    "PCPWashBiodieselBulkCoke",
    "PCPWashBiodieselBulkPropane",
    "PCPPurifyMethanolChromatograph",
    "PCPProduceBoneChar",
    "PCPProduceBoneCharCoke",
    "PCPProduceBoneCharPropane",
    "PCPProduceBoneCharSkull",
    "PCPProduceBoneCharSkullCoke",
    "PCPProduceBoneCharSkullPropane",
    "PCPMakeSoap",
    "PCPMakeSoapCoke",
    "PCPMakeSoapPropane",
    "PCPMakeSoapNaOH",
    "PCPMakeSoapNaOHCoke",
    "PCPMakeSoapNaOHPropane",
    "PCPMakeSoapFat",
    "PCPMakeSoapFatCoke",
    "PCPMakeSoapFatPropane",
    "PCPMakeSoapFatNaOH",
    "PCPMakeSoapFatNaOHCoke",
    "PCPMakeSoapFatNaOHPropane",
    "PCPCalcineCalcite",
    "PCPCalcineCalciteCoke",
    "PCPCalcineCalcitePropane",
    "PCPCastFishingWeights",
    "PCPCastFishingWeightsCoke",
    "PCPCastFishingWeightsPropane",
}
for _, name in ipairs(heatRequired) do
    filters[name] = PCP_Sandbox.isHeatRequired
end

---------------------------------------------------------------
-- No-heat variants (show only when RequireHeatSources = OFF)
-- Simplified versions without BlowTorch requirement.
---------------------------------------------------------------
local noHeatRequired = {
    "PCPPurifyCharcoalWaterSimple",
    "PCPPurifyCharcoalNaOHSimple",
    "PCPSynthesizeKNO3FertilizerSimple",
    "PCPSynthesizeKNO3CompostSimple",
    "PCPPressOilSoybeansLabSimple",
    "PCPPressOilSunflowerLabSimple",
    "PCPPressOilCornLabSimple",
    "PCPPressOilFlaxLabSimple",
    "PCPPressOilHempLabSimple",
    "PCPPressOilPeanutLabSimple",
    "PCPRenderFatSimple",
    "PCPTransesterifyOilSimple",
    "PCPTransesterifyFatSimple",
    "PCPTransesterifyOilBulkSimple",
    "PCPTransesterifyFatBulkSimple",
    "PCPTransesterifyOilNaOHSimple",
    "PCPTransesterifyFatNaOHSimple",
    "PCPTransesterifyOilBulkNaOHSimple",
    "PCPTransesterifyFatBulkNaOHSimple",
    "PCPWashBiodieselSimple",
    "PCPWashBiodieselBulkSimple",
    "PCPPurifyMethanolChromatographSimple",
    "PCPProduceBoneCharSimple",
    "PCPProduceBoneCharSkullSimple",
    "PCPMakeSoapSimple",
    "PCPMakeSoapNaOHSimple",
    "PCPMakeSoapFatSimple",
    "PCPMakeSoapFatNaOHSimple",
    "PCPCalcineCalciteSimple",
    "PCPCastFishingWeightsSimple",
}
for _, name in ipairs(noHeatRequired) do
    filters[name] = function() return not PCP_Sandbox.isHeatRequired() end
end

---------------------------------------------------------------
-- Hazard-enabled variants (show only when EnableHealthHazards = ON)
-- Safe + Unsafe twin pairs for hazardous processes.
---------------------------------------------------------------
local hazardEnabled = {
    "PCPExtractBatteryAcidSafe",
    "PCPExtractBatteryAcidUnsafe",
    "PCPAcidWashElectronicsSafe",
    "PCPAcidWashElectronicsUnsafe",
    "PCPMeltPlasticToGlueSafe",
    "PCPMeltPlasticToGlueUnsafe",
}
for _, name in ipairs(hazardEnabled) do
    filters[name] = PCP_Sandbox.isHealthHazardsEnabled
end

---------------------------------------------------------------
-- No-hazard originals (show only when EnableHealthHazards = OFF)
-- Original single-recipe versions without safe/unsafe split.
---------------------------------------------------------------
local noHazard = {
    "PCPExtractBatteryAcid",
    "PCPMeltPlasticToGlue",
    "PCPAcidWashElectronics",
}
for _, name in ipairs(noHazard) do
    filters[name] = function() return not PCP_Sandbox.isHealthHazardsEnabled() end
end

---------------------------------------------------------------
-- Heat + Hazard combined gates
-- Recipes that need BOTH RequireHeatSources=ON AND EnableHealthHazards=ON
---------------------------------------------------------------
local heatAndHazard = {
    "PCPDistillMethanolSafe",
    "PCPDistillMethanolUnsafe",
    "PCPSynthesizeKOHSafe",
    "PCPSynthesizeKOHUnsafe",
    "PCPExtractSulphurFromAcidCanSafe",
    "PCPExtractSulphurFromAcidCanUnsafe",
    "PCPExtractSulphurFromAcidFluidSafe",
    "PCPExtractSulphurFromAcidFluidUnsafe",
}
for _, name in ipairs(heatAndHazard) do
    filters[name] = function()
        return PCP_Sandbox.isHeatRequired() and PCP_Sandbox.isHealthHazardsEnabled()
    end
end

---------------------------------------------------------------
-- No-heat + Hazard combined gates
-- RequireHeatSources=OFF AND EnableHealthHazards=ON
---------------------------------------------------------------
local noHeatAndHazard = {
    "PCPDistillMethanolSimpleSafe",
    "PCPDistillMethanolSimpleUnsafe",
    "PCPSynthesizeKOHSimpleSafe",
    "PCPSynthesizeKOHSimpleUnsafe",
    "PCPExtractSulphurFromAcidCanSimpleSafe",
    "PCPExtractSulphurFromAcidCanSimpleUnsafe",
    "PCPExtractSulphurFromAcidFluidSimpleSafe",
    "PCPExtractSulphurFromAcidFluidSimpleUnsafe",
}
for _, name in ipairs(noHeatAndHazard) do
    filters[name] = function()
        return (not PCP_Sandbox.isHeatRequired()) and PCP_Sandbox.isHealthHazardsEnabled()
    end
end

---------------------------------------------------------------
-- Heat + No-hazard combined gates
-- RequireHeatSources=ON AND EnableHealthHazards=OFF
---------------------------------------------------------------
local heatAndNoHazard = {
    "PCPExtractSulphurFromAcidCan",
    "PCPExtractSulphurFromAcidFluid",
    "PCPDistillMethanol",
    "PCPSynthesizeKOH",
}
for _, name in ipairs(heatAndNoHazard) do
    filters[name] = function()
        return PCP_Sandbox.isHeatRequired() and (not PCP_Sandbox.isHealthHazardsEnabled())
    end
end

---------------------------------------------------------------
-- No-heat + No-hazard combined gates
-- RequireHeatSources=OFF AND EnableHealthHazards=OFF
---------------------------------------------------------------
local noHeatAndNoHazard = {
    "PCPExtractSulphurFromAcidCanSimple",
    "PCPExtractSulphurFromAcidFluidSimple",
    "PCPDistillMethanolSimple",
    "PCPSynthesizeKOHSimple",
}
for _, name in ipairs(noHeatAndNoHazard) do
    filters[name] = function()
        return (not PCP_Sandbox.isHeatRequired()) and (not PCP_Sandbox.isHealthHazardsEnabled())
    end
end

---------------------------------------------------------------
-- Advanced lab recipes (show only when EnableAdvancedLabRecipes = ON)
---------------------------------------------------------------
local advancedLab = {
    "PCPAnalyzeOilMicroscope",
    "PCPTestFuelSpectrometer",
}
for _, name in ipairs(advancedLab) do
    filters[name] = PCP_Sandbox.isAdvancedLabEnabled
end

---------------------------------------------------------------
-- Register all filters with PhobosLib
---------------------------------------------------------------
PhobosLib.registerRecipeFilters(filters)
