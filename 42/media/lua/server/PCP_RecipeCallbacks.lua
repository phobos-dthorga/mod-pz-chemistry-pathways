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

--[[
    PCP_RecipeCallbacks.lua — OnCreate callbacks for PhobosChemistryPathways

    These functions are called by craftRecipe OnCreate to handle post-craft logic
    that cannot be expressed in the recipe definition alone (e.g., returning a
    partially consumed drainable item, stamping purity on crafted items).

    Requires: PhobosLib, PCP_PuritySystem
]]

require "PhobosLib"
require "PCP_PuritySystem"
require "PCP_HazardSystem"

PCP_RecipeCallbacks = {}


---------------------------------------------------------------
-- Propane Partial Return (unchanged from Phase 1)
---------------------------------------------------------------

--- pcpReturnPartialPropane
--- Called by OnCreate on propane-fueled MetalDrum/surface craft recipes.
--- The recipe consumes the PropaneTank (mode:destroy), and this callback
--- recreates it with reduced fuel level (~4% consumed per use = ~25 uses
--- per full tank).
---
--- @param items   ArrayList  The input items consumed by the recipe
--- @param result  InventoryItem  The output item created by the recipe
--- @param player  IsoGameCharacter  The player performing the recipe
---
function PCP_RecipeCallbacks.pcpReturnPartialPropane(items, result, player)
    local FUEL_PER_USE = 0.04  -- 4% of tank per craft = ~25 crafts per full tank
    local originalDelta = 1.0  -- default: full tank (delta 1.0 = 100%)

    -- Search consumed inputs for the PropaneTank to read its original fuel level
    if items then
        for i = 0, items:size() - 1 do
            local item = items:get(i)
            if item and item:getFullType() == "Base.PropaneTank" then
                -- Use PhobosLib.pcallMethod for B42 API resilience
                -- DrainableComboItem uses getDelta/setDelta in B42
                local delta = PhobosLib.pcallMethod(item, "getDelta")
                if delta then
                    originalDelta = delta
                end
                break
            end
        end
    end

    -- Calculate remaining fuel
    local remaining = math.max(0, originalDelta - FUEL_PER_USE)

    -- Create a new PropaneTank with reduced fuel
    local newTank = instanceItem("Base.PropaneTank")
    if newTank then
        PhobosLib.pcallMethod(newTank, "setDelta", remaining)
        if player then
            player:getInventory():AddItem(newTank)
        end
    end
end


---------------------------------------------------------------
-- Internal Helpers for Purity Callbacks
---------------------------------------------------------------

--- Stamp purity on result + all same-type outputs, then announce.
--- Silently no-ops for non-PCP items (vanilla items don't support condition-as-purity).
local function _stampAndAnnounce(result, player, purity)
    if not result then return end
    local ok, ft = pcall(result.getFullType, result)
    if not ok or not ft or not string.find(ft, "PhobosChemistryPathways.", 1, true) then return end
    PCP_PuritySystem.setPurity(result, purity)
    PCP_PuritySystem.stampOutputs(player, ft, purity)
    PCP_PuritySystem.announcePurity(player, purity)
end

--- Recover purity from one of several alternative drained fluid containers.
--- Used when a recipe accepts alternative fluid types (e.g. CrudeVegetableOil OR RenderedFat).
--- Returns the first match found, or -1 if none.
local function _recoverAnyFluidPurity(player, keys)
    for _, key in ipairs(keys) do
        local val = PhobosLib.recoverDrainedFluidQuality(player, key, -1)
        if val >= 0 then return val end
    end
    return -1
end

--- Average multiple purity values, ignoring missing (negative) entries.
--- Falls back to PCP_PuritySystem.DEFAULT if no valid values found.
local function _averagePurities(values)
    local sum, count = 0, 0
    for _, v in ipairs(values) do
        if type(v) == "number" and v >= 0 then
            sum = sum + v
            count = count + 1
        end
    end
    return count > 0 and (sum / count) or PCP_PuritySystem.DEFAULT
end

--- Stamp fluid purity modData on all items of a given fullType in player inventory.
--- Bridges purity from FluidContainer outputs to downstream -fluid recipe inputs.
--- Call after _stampAndAnnounce to propagate purity through the -fluid recipe chain.
local function _stampFluidOutputPurity(player, fullType, purity, fluidKey)
    if not player or not fullType or not fluidKey then return end
    pcall(function()
        local inv = player:getInventory()
        if not inv then return end
        local items = inv:getItems()
        for i = 0, items:size() - 1 do
            local it = items:get(i)
            if it and it:getFullType() == fullType then
                PhobosLib.setModDataValue(it, fluidKey, purity)
            end
        end
    end)
end


---------------------------------------------------------------
-- SOURCE CALLBACKS (9) — Assign base purity, no input tracking
---------------------------------------------------------------

--- Mortar oil pressing: 30-50
function PCP_RecipeCallbacks.pcpOilMortarPurity(items, result, player)
    if not PCP_PuritySystem.isEnabled() then return end
    local purity = PCP_PuritySystem.randomBasePurity(30, 50)
    _stampAndAnnounce(result, player, purity)
    _stampFluidOutputPurity(player, result:getFullType(), purity, "PCP_Purity_CrudeVegetableOil")
end

--- Chemistry Set oil extraction: 50-70
function PCP_RecipeCallbacks.pcpOilLabPurity(items, result, player)
    if not PCP_PuritySystem.isEnabled() then return end
    local purity = PCP_PuritySystem.randomBasePurity(50, 70)
    _stampAndAnnounce(result, player, purity)
    _stampFluidOutputPurity(player, result:getFullType(), purity, "PCP_Purity_CrudeVegetableOil")
end

--- MetalDrum bulk oil pressing: 40-60
function PCP_RecipeCallbacks.pcpOilBulkPurity(items, result, player)
    if not PCP_PuritySystem.isEnabled() then return end
    local purity = PCP_PuritySystem.randomBasePurity(40, 60)
    _stampAndAnnounce(result, player, purity)
    _stampFluidOutputPurity(player, result:getFullType(), purity, "PCP_Purity_CrudeVegetableOil")
end

--- Convert bottled vegetable oil: 55-70
function PCP_RecipeCallbacks.pcpConvertOilPurity(items, result, player)
    if not PCP_PuritySystem.isEnabled() then return end
    local purity = PCP_PuritySystem.randomBasePurity(55, 70)
    _stampAndAnnounce(result, player, purity)
    _stampFluidOutputPurity(player, result:getFullType(), purity, "PCP_Purity_CrudeVegetableOil")
end

--- Render fat (Chemistry Set): 45-65
function PCP_RecipeCallbacks.pcpRenderFatPurity(items, result, player)
    if not PCP_PuritySystem.isEnabled() then return end
    local purity = PCP_PuritySystem.randomBasePurity(45, 65)
    _stampAndAnnounce(result, player, purity)
    _stampFluidOutputPurity(player, result:getFullType(), purity, "PCP_Purity_RenderedFat")
end

--- Distill methanol (Chemistry Set): 40-60
function PCP_RecipeCallbacks.pcpDistillMethanolPurity(items, result, player)
    if not PCP_PuritySystem.isEnabled() then return end
    local purity = PCP_PuritySystem.randomBasePurity(40, 60)
    _stampAndAnnounce(result, player, purity)
    _stampFluidOutputPurity(player, result:getFullType(), purity, "PCP_Purity_WoodMethanol")
end

--- Crush charcoal (Mortar): 35-55
function PCP_RecipeCallbacks.pcpCrushCharcoalPurity(items, result, player)
    if not PCP_PuritySystem.isEnabled() then return end
    _stampAndAnnounce(result, player, PCP_PuritySystem.randomBasePurity(35, 55))
end

--- Extract battery acid (Surface): 40-60
function PCP_RecipeCallbacks.pcpExtractAcidPurity(items, result, player)
    if not PCP_PuritySystem.isEnabled() then return end
    local purity = PCP_PuritySystem.randomBasePurity(40, 60)
    _stampAndAnnounce(result, player, purity)
    _stampFluidOutputPurity(player, result:getFullType(), purity, "PCP_Purity_SulphuricAcid")
end

--- Bone char production (MetalDrum): 50-70
function PCP_RecipeCallbacks.pcpBoneCharPurity(items, result, player)
    if not PCP_PuritySystem.isEnabled() then return end
    _stampAndAnnounce(result, player, PCP_PuritySystem.randomBasePurity(50, 70))
end


---------------------------------------------------------------
-- PROPAGATION CALLBACKS (15) — Read input purity, apply factor
---------------------------------------------------------------

--- Purify charcoal water wash (Chemistry Set, factor 1.05)
function PCP_RecipeCallbacks.pcpPurifyCharcoalPurity(items, result, player)
    if not PCP_PuritySystem.isEnabled() then return end
    local input = PCP_PuritySystem.averageInputPurity(items)
    local purity = PCP_PuritySystem.calculateOutputPurity(input, 1.05)
    _stampAndAnnounce(result, player, purity)
end

--- Purify charcoal NaOH wash (Chemistry Set, factor 1.15)
function PCP_RecipeCallbacks.pcpPurifyCharcoalNaOHPurity(items, result, player)
    if not PCP_PuritySystem.isEnabled() then return end
    local input = PCP_PuritySystem.averageInputPurity(items)
    local purity = PCP_PuritySystem.calculateOutputPurity(input, 1.15)
    _stampAndAnnounce(result, player, purity)
end

--- Prepare diluted compost (Chemistry Set, factor 1.00)
function PCP_RecipeCallbacks.pcpCompostPurity(items, result, player)
    if not PCP_PuritySystem.isEnabled() then return end
    local input = PCP_PuritySystem.averageInputPurity(items)
    local purity = PCP_PuritySystem.calculateOutputPurity(input, PCP_PuritySystem.EQUIP_FACTORS.chemistrySet)
    _stampAndAnnounce(result, player, purity)
end

--- Extract sulphur (Chemistry Set, factor 1.00)
function PCP_RecipeCallbacks.pcpExtractSulphurPurity(items, result, player)
    if not PCP_PuritySystem.isEnabled() then return end
    local input = PCP_PuritySystem.averageInputPurity(items)
    local purity = PCP_PuritySystem.calculateOutputPurity(input, PCP_PuritySystem.EQUIP_FACTORS.chemistrySet)
    _stampAndAnnounce(result, player, purity)
end

--- Synthesize KNO3 (Chemistry Set, factor 1.00)
function PCP_RecipeCallbacks.pcpSynthesizeKNO3Purity(items, result, player)
    if not PCP_PuritySystem.isEnabled() then return end
    local input = PCP_PuritySystem.averageInputPurity(items)
    local purity = PCP_PuritySystem.calculateOutputPurity(input, PCP_PuritySystem.EQUIP_FACTORS.chemistrySet)
    _stampAndAnnounce(result, player, purity)
end

--- Synthesize KOH (Chemistry Set, factor 1.00)
function PCP_RecipeCallbacks.pcpSynthesizeKOHPurity(items, result, player)
    if not PCP_PuritySystem.isEnabled() then return end
    local input = PCP_PuritySystem.averageInputPurity(items)
    local purity = PCP_PuritySystem.calculateOutputPurity(input, PCP_PuritySystem.EQUIP_FACTORS.chemistrySet)
    _stampAndAnnounce(result, player, purity)
end

--- Transesterify — Lab/Chemistry Set tier (factor 1.00)
--- Fluid inputs: CrudeVegetableOil OR RenderedFat + WoodMethanol; solid: KOH
function PCP_RecipeCallbacks.pcpTransesterifyLabPurity(items, result, player)
    if not PCP_PuritySystem.isEnabled() then return end
    local input = _averagePurities({
        _recoverAnyFluidPurity(player, {"PCP_Purity_CrudeVegetableOil", "PCP_Purity_RenderedFat"}),
        PhobosLib.recoverDrainedFluidQuality(player, "PCP_Purity_WoodMethanol", -1),
        PCP_PuritySystem.averageInputPurity(items)
    })
    local purity = PCP_PuritySystem.calculateOutputPurity(input, PCP_PuritySystem.EQUIP_FACTORS.chemistrySet)
    _stampAndAnnounce(result, player, purity)
    _stampFluidOutputPurity(player, result:getFullType(), purity, "PCP_Purity_CrudeBiodiesel")
    _stampFluidOutputPurity(player, "PhobosChemistryPathways.Glycerol", purity, "PCP_Purity_Glycerol")
end

--- Transesterify — MetalDrum bulk tier (factor 0.95)
--- Fluid inputs: CrudeVegetableOil OR RenderedFat + WoodMethanol; solid: KOH
function PCP_RecipeCallbacks.pcpTransesterifyBulkPurity(items, result, player)
    if not PCP_PuritySystem.isEnabled() then return end
    local input = _averagePurities({
        _recoverAnyFluidPurity(player, {"PCP_Purity_CrudeVegetableOil", "PCP_Purity_RenderedFat"}),
        PhobosLib.recoverDrainedFluidQuality(player, "PCP_Purity_WoodMethanol", -1),
        PCP_PuritySystem.averageInputPurity(items)
    })
    local purity = PCP_PuritySystem.calculateOutputPurity(input, PCP_PuritySystem.EQUIP_FACTORS.metalDrum)
    _stampAndAnnounce(result, player, purity)
    _stampFluidOutputPurity(player, result:getFullType(), purity, "PCP_Purity_CrudeBiodiesel")
    _stampFluidOutputPurity(player, "PhobosChemistryPathways.Glycerol", purity, "PCP_Purity_Glycerol")
end

--- Wash biodiesel — Lab/Chemistry Set tier (factor 1.00)
--- Fluid input: CrudeBiodiesel → output: WashedBiodiesel
function PCP_RecipeCallbacks.pcpWashBiodieselLabPurity(items, result, player)
    if not PCP_PuritySystem.isEnabled() then return end
    local input = PhobosLib.recoverDrainedFluidQuality(player, "PCP_Purity_CrudeBiodiesel", PCP_PuritySystem.DEFAULT)
    local purity = PCP_PuritySystem.calculateOutputPurity(input, PCP_PuritySystem.EQUIP_FACTORS.chemistrySet)
    _stampAndAnnounce(result, player, purity)
    _stampFluidOutputPurity(player, result:getFullType(), purity, "PCP_Purity_WashedBiodiesel")
end

--- Wash biodiesel — MetalDrum bulk tier (factor 0.95)
--- Fluid input: CrudeBiodiesel → output: WashedBiodiesel
function PCP_RecipeCallbacks.pcpWashBiodieselBulkPurity(items, result, player)
    if not PCP_PuritySystem.isEnabled() then return end
    local input = PhobosLib.recoverDrainedFluidQuality(player, "PCP_Purity_CrudeBiodiesel", PCP_PuritySystem.DEFAULT)
    local purity = PCP_PuritySystem.calculateOutputPurity(input, PCP_PuritySystem.EQUIP_FACTORS.metalDrum)
    _stampAndAnnounce(result, player, purity)
    _stampFluidOutputPurity(player, result:getFullType(), purity, "PCP_Purity_WashedBiodiesel")
end

--- Centrifuge wash (factor 1.10)
--- Fluid input: CrudeBiodiesel → output: WashedBiodiesel
function PCP_RecipeCallbacks.pcpCentrifugeWashPurity(items, result, player)
    if not PCP_PuritySystem.isEnabled() then return end
    local input = PhobosLib.recoverDrainedFluidQuality(player, "PCP_Purity_CrudeBiodiesel", PCP_PuritySystem.DEFAULT)
    local purity = PCP_PuritySystem.calculateOutputPurity(input, PCP_PuritySystem.EQUIP_FACTORS.centrifuge)
    _stampAndAnnounce(result, player, purity)
    _stampFluidOutputPurity(player, result:getFullType(), purity, "PCP_Purity_WashedBiodiesel")
end

--- Centrifuge glycerol separation (factor 1.10)
--- Fluid input: CrudeBiodiesel → output: Glycerol
function PCP_RecipeCallbacks.pcpCentrifugeGlycerolPurity(items, result, player)
    if not PCP_PuritySystem.isEnabled() then return end
    local input = PhobosLib.recoverDrainedFluidQuality(player, "PCP_Purity_CrudeBiodiesel", PCP_PuritySystem.DEFAULT)
    local purity = PCP_PuritySystem.calculateOutputPurity(input, PCP_PuritySystem.EQUIP_FACTORS.centrifuge)
    _stampAndAnnounce(result, player, purity)
    _stampFluidOutputPurity(player, result:getFullType(), purity, "PCP_Purity_Glycerol")
end

--- Chromatograph purify biodiesel (factor 1.25) + fuel penalty
--- Fluid input: WashedBiodiesel → output: WashedBiodiesel (purified)
function PCP_RecipeCallbacks.pcpChromatographBiodieselPurity(items, result, player)
    if not PCP_PuritySystem.isEnabled() then return end
    local input = PhobosLib.recoverDrainedFluidQuality(player, "PCP_Purity_WashedBiodiesel", PCP_PuritySystem.DEFAULT)
    local purity = PCP_PuritySystem.calculateOutputPurity(input, PCP_PuritySystem.EQUIP_FACTORS.chromatograph)
    _stampAndAnnounce(result, player, purity)
    _stampFluidOutputPurity(player, result:getFullType(), purity, "PCP_Purity_WashedBiodiesel")
    PCP_PuritySystem.applyFuelPenalty(result, purity)
end

--- Chromatograph purify methanol (source override 80-95)
--- Output: WoodMethanol (purified)
function PCP_RecipeCallbacks.pcpChromatographMethanolPurity(items, result, player)
    if not PCP_PuritySystem.isEnabled() then return end
    local purity = PCP_PuritySystem.randomBasePurity(80, 95)
    _stampAndAnnounce(result, player, purity)
    _stampFluidOutputPurity(player, result:getFullType(), purity, "PCP_Purity_WoodMethanol")
end

--- Make soap — all variants (cosmetic tracking, factor 1.00, no penalty)
--- Glycerol variants: fluid Glycerol + solid KOH/NaOH
--- Fat variants: solid Lard/Butter + solid KOH/NaOH (no PCP fluid)
function PCP_RecipeCallbacks.pcpMakeSoapPurity(items, result, player)
    if not PCP_PuritySystem.isEnabled() then return end
    local input = _averagePurities({
        PhobosLib.recoverDrainedFluidQuality(player, "PCP_Purity_Glycerol", -1),
        PCP_PuritySystem.averageInputPurity(items)
    })
    local purity = PCP_PuritySystem.calculateOutputPurity(input, PCP_PuritySystem.EQUIP_FACTORS.chemistrySet)
    _stampAndAnnounce(result, player, purity)
end


---------------------------------------------------------------
-- TERMINAL CALLBACKS (4) — Propagation + yield penalty
---------------------------------------------------------------

--- Refine biodiesel into fuel — drain Petrol based on purity
--- Fluid input: WashedBiodiesel → output: RefinedBiodieselCan
function PCP_RecipeCallbacks.pcpRefineBiodieselPurity(items, result, player)
    if not PCP_PuritySystem.isEnabled() then return end
    local input = PhobosLib.recoverDrainedFluidQuality(player, "PCP_Purity_WashedBiodiesel", PCP_PuritySystem.DEFAULT)
    local purity = PCP_PuritySystem.calculateOutputPurity(input, PCP_PuritySystem.EQUIP_FACTORS.chemistrySet)
    _stampAndAnnounce(result, player, purity)
    PCP_PuritySystem.applyFuelPenalty(result, purity)
end

--- Mix blackpowder — remove excess GunPowder based on purity
function PCP_RecipeCallbacks.pcpMixBlackpowderPurity(items, result, player)
    if not PCP_PuritySystem.isEnabled() then return end
    local input = PCP_PuritySystem.averageInputPurity(items)
    local purity = PCP_PuritySystem.calculateOutputPurity(input, PCP_PuritySystem.EQUIP_FACTORS.chemistrySet)
    _stampAndAnnounce(result, player, purity)
    PCP_PuritySystem.removeExcess(player, "Base.GunPowder", 10, purity)
end

--- Microscope analysis (factor 1.15)
--- Fluid inputs: CrudeVegetableOil + WoodMethanol; solid: KOH/NaOH
--- Output: CrudeBiodiesel + Glycerol
function PCP_RecipeCallbacks.pcpMicroscopeAnalyzePurity(items, result, player)
    if not PCP_PuritySystem.isEnabled() then return end
    local input = _averagePurities({
        PhobosLib.recoverDrainedFluidQuality(player, "PCP_Purity_CrudeVegetableOil", -1),
        PhobosLib.recoverDrainedFluidQuality(player, "PCP_Purity_WoodMethanol", -1),
        PCP_PuritySystem.averageInputPurity(items)
    })
    local purity = PCP_PuritySystem.calculateOutputPurity(input, PCP_PuritySystem.EQUIP_FACTORS.microscope)
    _stampAndAnnounce(result, player, purity)
    _stampFluidOutputPurity(player, result:getFullType(), purity, "PCP_Purity_CrudeBiodiesel")
    _stampFluidOutputPurity(player, "PhobosChemistryPathways.Glycerol", purity, "PCP_Purity_Glycerol")
end

--- Spectrometer test (factor 1.15) + fuel penalty
--- Fluid input: WashedBiodiesel → output: RefinedBiodieselCan
function PCP_RecipeCallbacks.pcpSpectrometerTestPurity(items, result, player)
    if not PCP_PuritySystem.isEnabled() then return end
    local input = PhobosLib.recoverDrainedFluidQuality(player, "PCP_Purity_WashedBiodiesel", PCP_PuritySystem.DEFAULT)
    local purity = PCP_PuritySystem.calculateOutputPurity(input, PCP_PuritySystem.EQUIP_FACTORS.spectrometer)
    _stampAndAnnounce(result, player, purity)
    PCP_PuritySystem.applyFuelPenalty(result, purity)
end


---------------------------------------------------------------
-- UTILITY CALLBACKS (2)
---------------------------------------------------------------

--- Cut plastic scrap (Surface, source 40-60)
function PCP_RecipeCallbacks.pcpCutPlasticPurity(items, result, player)
    if not PCP_PuritySystem.isEnabled() then return end
    _stampAndAnnounce(result, player, PCP_PuritySystem.randomBasePurity(40, 60))
end

--- Acid wash electronics (Chemistry Set, propagation factor 1.00)
--- Fluid input: SulphuricAcid
function PCP_RecipeCallbacks.pcpAcidWashPurity(items, result, player)
    if not PCP_PuritySystem.isEnabled() then return end
    local input = _averagePurities({
        PhobosLib.recoverDrainedFluidQuality(player, "PCP_Purity_SulphuricAcid", -1),
        PCP_PuritySystem.averageInputPurity(items)
    })
    local purity = PCP_PuritySystem.calculateOutputPurity(input, PCP_PuritySystem.EQUIP_FACTORS.chemistrySet)
    _stampAndAnnounce(result, player, purity)
end


---------------------------------------------------------------
-- COMBINED PROPANE + PURITY CALLBACKS (7)
-- Each calls pcpReturnPartialPropane first, then purity logic.
---------------------------------------------------------------

--- Transesterify oil bulk + propane (MetalDrum, factor 0.95)
--- Fluid inputs: CrudeVegetableOil + WoodMethanol; solid: KOH
function PCP_RecipeCallbacks.pcpTransesterifyOilBulkPropanePurity(items, result, player)
    PCP_RecipeCallbacks.pcpReturnPartialPropane(items, result, player)
    if not PCP_PuritySystem.isEnabled() then return end
    local input = _averagePurities({
        PhobosLib.recoverDrainedFluidQuality(player, "PCP_Purity_CrudeVegetableOil", -1),
        PhobosLib.recoverDrainedFluidQuality(player, "PCP_Purity_WoodMethanol", -1),
        PCP_PuritySystem.averageInputPurity(items)
    })
    local purity = PCP_PuritySystem.calculateOutputPurity(input, PCP_PuritySystem.EQUIP_FACTORS.metalDrum)
    _stampAndAnnounce(result, player, purity)
    _stampFluidOutputPurity(player, result:getFullType(), purity, "PCP_Purity_CrudeBiodiesel")
    _stampFluidOutputPurity(player, "PhobosChemistryPathways.Glycerol", purity, "PCP_Purity_Glycerol")
end

--- Transesterify fat bulk + propane (MetalDrum, factor 0.95)
--- Fluid inputs: RenderedFat + WoodMethanol; solid: KOH
function PCP_RecipeCallbacks.pcpTransesterifyFatBulkPropanePurity(items, result, player)
    PCP_RecipeCallbacks.pcpReturnPartialPropane(items, result, player)
    if not PCP_PuritySystem.isEnabled() then return end
    local input = _averagePurities({
        PhobosLib.recoverDrainedFluidQuality(player, "PCP_Purity_RenderedFat", -1),
        PhobosLib.recoverDrainedFluidQuality(player, "PCP_Purity_WoodMethanol", -1),
        PCP_PuritySystem.averageInputPurity(items)
    })
    local purity = PCP_PuritySystem.calculateOutputPurity(input, PCP_PuritySystem.EQUIP_FACTORS.metalDrum)
    _stampAndAnnounce(result, player, purity)
    _stampFluidOutputPurity(player, result:getFullType(), purity, "PCP_Purity_CrudeBiodiesel")
    _stampFluidOutputPurity(player, "PhobosChemistryPathways.Glycerol", purity, "PCP_Purity_Glycerol")
end

--- Wash biodiesel bulk + propane (MetalDrum, factor 0.95)
--- Fluid input: CrudeBiodiesel → output: WashedBiodiesel
function PCP_RecipeCallbacks.pcpWashBiodieselBulkPropanePurity(items, result, player)
    PCP_RecipeCallbacks.pcpReturnPartialPropane(items, result, player)
    if not PCP_PuritySystem.isEnabled() then return end
    local input = PhobosLib.recoverDrainedFluidQuality(player, "PCP_Purity_CrudeBiodiesel", PCP_PuritySystem.DEFAULT)
    local purity = PCP_PuritySystem.calculateOutputPurity(input, PCP_PuritySystem.EQUIP_FACTORS.metalDrum)
    _stampAndAnnounce(result, player, purity)
    _stampFluidOutputPurity(player, result:getFullType(), purity, "PCP_Purity_WashedBiodiesel")
end

--- Bone char + propane (MetalDrum, source 50-70)
function PCP_RecipeCallbacks.pcpBoneCharPropanePurity(items, result, player)
    PCP_RecipeCallbacks.pcpReturnPartialPropane(items, result, player)
    if not PCP_PuritySystem.isEnabled() then return end
    _stampAndAnnounce(result, player, PCP_PuritySystem.randomBasePurity(50, 70))
end

--- Bone char skull + propane (MetalDrum, source 50-70)
function PCP_RecipeCallbacks.pcpBoneCharSkullPropanePurity(items, result, player)
    PCP_RecipeCallbacks.pcpReturnPartialPropane(items, result, player)
    if not PCP_PuritySystem.isEnabled() then return end
    _stampAndAnnounce(result, player, PCP_PuritySystem.randomBasePurity(50, 70))
end

--- Make soap (glycerol) + propane (cosmetic, factor 1.00)
--- Fluid input: Glycerol; solid: KOH
function PCP_RecipeCallbacks.pcpMakeSoapPropanePurity(items, result, player)
    PCP_RecipeCallbacks.pcpReturnPartialPropane(items, result, player)
    if not PCP_PuritySystem.isEnabled() then return end
    local input = _averagePurities({
        PhobosLib.recoverDrainedFluidQuality(player, "PCP_Purity_Glycerol", -1),
        PCP_PuritySystem.averageInputPurity(items)
    })
    local purity = PCP_PuritySystem.calculateOutputPurity(input, PCP_PuritySystem.EQUIP_FACTORS.chemistrySet)
    _stampAndAnnounce(result, player, purity)
end

--- Make soap (fat) + propane (cosmetic, factor 1.00)
--- Fluid input: RenderedFat; solid: KOH
function PCP_RecipeCallbacks.pcpMakeSoapFatPropanePurity(items, result, player)
    PCP_RecipeCallbacks.pcpReturnPartialPropane(items, result, player)
    if not PCP_PuritySystem.isEnabled() then return end
    local input = _averagePurities({
        PhobosLib.recoverDrainedFluidQuality(player, "PCP_Purity_RenderedFat", -1),
        PCP_PuritySystem.averageInputPurity(items)
    })
    local purity = PCP_PuritySystem.calculateOutputPurity(input, PCP_PuritySystem.EQUIP_FACTORS.chemistrySet)
    _stampAndAnnounce(result, player, purity)
end


---------------------------------------------------------------
-- HEALTH HAZARD CALLBACKS (20)
-- Safe variants: purity + filter degradation
-- Unsafe variants: purity + hazard effect dispatch
---------------------------------------------------------------

--- DRY helper: wrap an existing purity callback with safe filter degradation.
local function _safeWrapper(purityFn, items, result, player)
    purityFn(items, result, player)
    if PCP_HazardSystem.isEnabled() then
        PCP_HazardSystem.degradeFilterFromInputs(items)
    end
end

--- DRY helper: wrap an existing purity callback with unsafe hazard dispatch.
local function _unsafeWrapper(purityFn, hazardId, items, result, player)
    purityFn(items, result, player)
    PCP_HazardSystem.applyUnsafeEffect(player, hazardId)
end


-- Distill Methanol — Safe (filter degrade)
function PCP_RecipeCallbacks.pcpDistillMethanolSafePurity(items, result, player)
    _safeWrapper(PCP_RecipeCallbacks.pcpDistillMethanolPurity, items, result, player)
end

-- Distill Methanol — Unsafe (methanol_vapor)
function PCP_RecipeCallbacks.pcpDistillMethanolUnsafePurity(items, result, player)
    _unsafeWrapper(PCP_RecipeCallbacks.pcpDistillMethanolPurity, "methanol_vapor", items, result, player)
end

-- Synthesize KOH — Safe (filter degrade)
function PCP_RecipeCallbacks.pcpSynthesizeKOHSafePurity(items, result, player)
    _safeWrapper(PCP_RecipeCallbacks.pcpSynthesizeKOHPurity, items, result, player)
end

-- Synthesize KOH — Unsafe (caustic_vapor)
function PCP_RecipeCallbacks.pcpSynthesizeKOHUnsafePurity(items, result, player)
    _unsafeWrapper(PCP_RecipeCallbacks.pcpSynthesizeKOHPurity, "caustic_vapor", items, result, player)
end

-- Extract Sulphur — Safe (filter degrade)
function PCP_RecipeCallbacks.pcpExtractSulphurSafePurity(items, result, player)
    _safeWrapper(PCP_RecipeCallbacks.pcpExtractSulphurPurity, items, result, player)
end

-- Extract Sulphur — Unsafe (acid_fumes)
function PCP_RecipeCallbacks.pcpExtractSulphurUnsafePurity(items, result, player)
    _unsafeWrapper(PCP_RecipeCallbacks.pcpExtractSulphurPurity, "acid_fumes", items, result, player)
end

-- Extract Battery Acid — Safe (filter degrade)
function PCP_RecipeCallbacks.pcpExtractAcidSafePurity(items, result, player)
    _safeWrapper(PCP_RecipeCallbacks.pcpExtractAcidPurity, items, result, player)
end

-- Extract Battery Acid — Unsafe (acid_mist)
function PCP_RecipeCallbacks.pcpExtractAcidUnsafePurity(items, result, player)
    _unsafeWrapper(PCP_RecipeCallbacks.pcpExtractAcidPurity, "acid_mist", items, result, player)
end

-- Acid Wash Electronics — Safe (filter degrade)
function PCP_RecipeCallbacks.pcpAcidWashSafePurity(items, result, player)
    _safeWrapper(PCP_RecipeCallbacks.pcpAcidWashPurity, items, result, player)
end

-- Acid Wash Electronics — Unsafe (acid_mist)
function PCP_RecipeCallbacks.pcpAcidWashUnsafePurity(items, result, player)
    _unsafeWrapper(PCP_RecipeCallbacks.pcpAcidWashPurity, "acid_mist", items, result, player)
end


---------------------------------------------------------------
-- RECYCLING RECIPE CALLBACKS (12)
-- New downstream recipes for by-products and dead-end items.
---------------------------------------------------------------

--- R1: Make Wood Glue from tar (surface, source 40-60)
function PCP_RecipeCallbacks.pcpMakeWoodGluePurity(items, result, player)
    if not PCP_PuritySystem.isEnabled() then return end
    _stampAndAnnounce(result, player, PCP_PuritySystem.randomBasePurity(40, 60))
end

--- R2: Calcine Calcite into Quicklime (DomeKiln, source 40-60)
function PCP_RecipeCallbacks.pcpCalcineCalcitePurity(items, result, player)
    if not PCP_PuritySystem.isEnabled() then return end
    _stampAndAnnounce(result, player, PCP_PuritySystem.randomBasePurity(40, 60))
end

--- R2: Calcine Calcite + propane (DomeKiln, source 40-60)
function PCP_RecipeCallbacks.pcpCalcineCalcitePropanePurity(items, result, player)
    PCP_RecipeCallbacks.pcpReturnPartialPropane(items, result, player)
    if not PCP_PuritySystem.isEnabled() then return end
    _stampAndAnnounce(result, player, PCP_PuritySystem.randomBasePurity(40, 60))
end

--- R7: Melt Plastic into Glue — Safe (filter degrade only, no purity on vanilla output)
function PCP_RecipeCallbacks.pcpMeltPlasticGlueSafe(items, result, player)
    if PCP_HazardSystem.isEnabled() then
        PCP_HazardSystem.degradeFilterFromInputs(items)
    end
end

--- R7: Melt Plastic into Glue — Unsafe (plastic_fumes only, no purity on vanilla output)
function PCP_RecipeCallbacks.pcpMeltPlasticGlueUnsafe(items, result, player)
    PCP_HazardSystem.applyUnsafeEffect(player, "plastic_fumes")
end

--- Bug fix: Bulk Refine Biodiesel (surface, propagation 0.95)
--- Fluid input: WashedBiodiesel → output: RefinedBiodieselCan
function PCP_RecipeCallbacks.pcpRefineBiodieselBulkPurity(items, result, player)
    if not PCP_PuritySystem.isEnabled() then return end
    local input = PhobosLib.recoverDrainedFluidQuality(player, "PCP_Purity_WashedBiodiesel", PCP_PuritySystem.DEFAULT)
    local purity = PCP_PuritySystem.calculateOutputPurity(input, PCP_PuritySystem.EQUIP_FACTORS.metalDrum)
    _stampAndAnnounce(result, player, purity)
    PCP_PuritySystem.applyFuelPenalty(result, purity)
end


---------------------------------------------------------------
-- COOKING POT SOURCE CALLBACKS (3) — Lower purity for pot tier
---------------------------------------------------------------

--- Cooking pot oil extraction: 40-60
function PCP_RecipeCallbacks.pcpOilLabPotPurity(items, result, player)
    if not PCP_PuritySystem.isEnabled() then return end
    local purity = PCP_PuritySystem.randomBasePurity(40, 60)
    _stampAndAnnounce(result, player, purity)
    _stampFluidOutputPurity(player, result:getFullType(), purity, "PCP_Purity_CrudeVegetableOil")
end

--- Render fat (Cooking Pot): 30-50
function PCP_RecipeCallbacks.pcpRenderFatPotPurity(items, result, player)
    if not PCP_PuritySystem.isEnabled() then return end
    local purity = PCP_PuritySystem.randomBasePurity(30, 50)
    _stampAndAnnounce(result, player, purity)
    _stampFluidOutputPurity(player, result:getFullType(), purity, "PCP_Purity_RenderedFat")
end


---------------------------------------------------------------
-- COOKING POT PROPAGATION CALLBACKS (3) — Lower factor for pot tier
---------------------------------------------------------------

--- Purify charcoal water/NaOH (Cooking Pot): 60-80
function PCP_RecipeCallbacks.pcpPurifyCharcoalPotPurity(items, result, player)
    if not PCP_PuritySystem.isEnabled() then return end
    _stampAndAnnounce(result, player, PCP_PuritySystem.randomBasePurity(60, 80))
end

--- Synthesize KNO3 fertilizer (Cooking Pot): 35-55
function PCP_RecipeCallbacks.pcpSynthesizeKNO3PotPurity(items, result, player)
    if not PCP_PuritySystem.isEnabled() then return end
    _stampAndAnnounce(result, player, PCP_PuritySystem.randomBasePurity(35, 55))
end

--- Synthesize KNO3 compost (Cooking Pot): 30-50
function PCP_RecipeCallbacks.pcpSynthesizeKNO3CompostPotPurity(items, result, player)
    if not PCP_PuritySystem.isEnabled() then return end
    _stampAndAnnounce(result, player, PCP_PuritySystem.randomBasePurity(30, 50))
end

--- Wash biodiesel (Cooking Pot, factor 0.90)
--- Fluid input: CrudeBiodiesel → output: WashedBiodiesel
function PCP_RecipeCallbacks.pcpWashBiodieselPotPurity(items, result, player)
    if not PCP_PuritySystem.isEnabled() then return end
    local input = PhobosLib.recoverDrainedFluidQuality(player, "PCP_Purity_CrudeBiodiesel", PCP_PuritySystem.DEFAULT)
    local purity = PCP_PuritySystem.calculateOutputPurity(input, 0.90)
    _stampAndAnnounce(result, player, purity)
    _stampFluidOutputPurity(player, result:getFullType(), purity, "PCP_Purity_WashedBiodiesel")
end


---------------------------------------------------------------
-- AGRICULTURE & DOWNSTREAM CALLBACKS (4)
-- New pathways connecting PCP intermediates to vanilla systems.
---------------------------------------------------------------

--- A1: Grind BoneChar -> BoneMeal: propagation through mortar (factor 0.90).
function PCP_RecipeCallbacks.pcpGrindBoneMealPurity(items, result, player)
    if not PCP_PuritySystem.isEnabled() then return end
    local input = PCP_PuritySystem.averageInputPurity(items)
    local purity = PCP_PuritySystem.calculateOutputPurity(input, PCP_PuritySystem.EQUIP_FACTORS.mortar)
    _stampAndAnnounce(result, player, purity)
end

--- B1: Activate Carbon (KOH process): propagation through chemistry set (factor 1.00).
function PCP_RecipeCallbacks.pcpActivateCarbonPurity(items, result, player)
    if not PCP_PuritySystem.isEnabled() then return end
    local input = PCP_PuritySystem.averageInputPurity(items)
    local purity = PCP_PuritySystem.calculateOutputPurity(input, PCP_PuritySystem.EQUIP_FACTORS.chemistrySet)
    _stampAndAnnounce(result, player, purity)
end

--- D1: Synthesize Epoxy — Safe (filter degrade only, no purity on vanilla output)
function PCP_RecipeCallbacks.pcpSynthesizeEpoxySafePurity(items, result, player)
    if PCP_HazardSystem.isEnabled() then
        PCP_HazardSystem.degradeFilterFromInputs(items)
    end
end

--- D1: Synthesize Epoxy — Unsafe (resin_fumes only, no purity on vanilla output)
function PCP_RecipeCallbacks.pcpSynthesizeEpoxyUnsafePurity(items, result, player)
    PCP_HazardSystem.applyUnsafeEffect(player, "resin_fumes")
end


---------------------------------------------------------------
-- VANILLA OUTPUT CALLBACKS (7)
-- Yield scaling (purity->yield), secondary XP, and hazard
-- callbacks for recipes that output vanilla items directly.
---------------------------------------------------------------

--- E1: Fire Starter Blocks -- input purity of fat/oil scales yield 2-4
--- Fluid input: CrudeVegetableOil or RenderedFat (triglyceride feedstock)
function PCP_RecipeCallbacks.pcpMakeFireStarterYield(items, result, player)
    if not PCP_PuritySystem.isEnabled() then return end
    local input = _recoverAnyFluidPurity(player, {"PCP_Purity_CrudeVegetableOil", "PCP_Purity_RenderedFat"})
    if input < 0 then input = PCP_PuritySystem.DEFAULT end
    if input <= 0 then return end
    PCP_PuritySystem.removeExcess(player, "Base.DryFirestarterBlock", 4, input)
end

--- E4: Duct Tape -- award Tailoring XP
function PCP_RecipeCallbacks.pcpMakeDuctTapeXP(items, result, player)
    if not player then return end
    PhobosLib.addXP(player, Perks.Tailoring, 3)
end

--- E5: Matchbox -- input purity of SulphurPowder + KNO3 scales yield 2-4
function PCP_RecipeCallbacks.pcpMakeMatchboxYield(items, result, player)
    if not PCP_PuritySystem.isEnabled() then return end
    local input = PCP_PuritySystem.averageInputPurity(items)
    if input <= 0 then return end
    PCP_PuritySystem.removeExcess(player, "Base.Matchbox", 4, input)
end

--- E5-Safe: Matchbox -- purity->yield + filter degrade
function PCP_RecipeCallbacks.pcpMakeMatchboxSafe(items, result, player)
    PCP_RecipeCallbacks.pcpMakeMatchboxYield(items, result, player)
    if PCP_HazardSystem.isEnabled() then
        PCP_HazardSystem.degradeFilterFromInputs(items)
    end
end

--- E5-Unsafe: Matchbox -- purity->yield + acid_fumes hazard
function PCP_RecipeCallbacks.pcpMakeMatchboxUnsafe(items, result, player)
    PCP_RecipeCallbacks.pcpMakeMatchboxYield(items, result, player)
    PCP_HazardSystem.applyUnsafeEffect(player, "acid_fumes")
end

--- F1: Distill Vinegar -- award Cooking XP
function PCP_RecipeCallbacks.pcpDistillVinegarXP(items, result, player)
    if not player then return end
    PhobosLib.addXP(player, Perks.Cooking, 5)
end

--- F2: Chemical Tanning -- KOH purity affects yield 1-2
function PCP_RecipeCallbacks.pcpChemicalTanningYield(items, result, player)
    if not PCP_PuritySystem.isEnabled() then return end
    local input = PCP_PuritySystem.averageInputPurity(items)
    if input <= 0 then return end
    PCP_PuritySystem.removeExcess(player, "Base.BrainTan", 2, input)
end


---------------------------------------------------------------
-- CONCRETE MIXER CALLBACKS (7)
-- Source purity for bulk mixer operations. Lower ranges than
-- lab equivalents to reflect industrial-scale tradeoffs.
---------------------------------------------------------------

--- Mixer construction items (mortar, stucco, reinforced concrete, fireclay): 60-85
function PCP_RecipeCallbacks.pcpMixerConstructionPurity(items, result, player)
    if not PCP_PuritySystem.isEnabled() then return end
    _stampAndAnnounce(result, player, PCP_PuritySystem.randomBasePurity(60, 85))
end

--- Mixer blackpowder (bulk): 25-45 (lower than lab 50-70)
function PCP_RecipeCallbacks.pcpMixerBlackpowderPurity(items, result, player)
    if not PCP_PuritySystem.isEnabled() then return end
    _stampAndAnnounce(result, player, PCP_PuritySystem.randomBasePurity(25, 45))
end

--- Mixer biodiesel (bulk): 35-55 (lower than lab)
--- Output: CrudeBiodieselBucket + Glycerol
function PCP_RecipeCallbacks.pcpMixerBiodieselPurity(items, result, player)
    if not PCP_PuritySystem.isEnabled() then return end
    local purity = PCP_PuritySystem.randomBasePurity(35, 55)
    _stampAndAnnounce(result, player, purity)
    _stampFluidOutputPurity(player, result:getFullType(), purity, "PCP_Purity_CrudeBiodiesel")
    _stampFluidOutputPurity(player, "PhobosChemistryPathways.Glycerol", purity, "PCP_Purity_Glycerol")
end

--- Mixer soap (bulk): 40-60 (lower than lab)
function PCP_RecipeCallbacks.pcpMixerSoapPurity(items, result, player)
    if not PCP_PuritySystem.isEnabled() then return end
    _stampAndAnnounce(result, player, PCP_PuritySystem.randomBasePurity(40, 60))
end

--- Mixer compost (bulk): 30-50
function PCP_RecipeCallbacks.pcpMixerCompostPurity(items, result, player)
    if not PCP_PuritySystem.isEnabled() then return end
    _stampAndAnnounce(result, player, PCP_PuritySystem.randomBasePurity(30, 50))
end

--- Mixer wood vinegar: 30-50
function PCP_RecipeCallbacks.pcpMixerVinegarPurity(items, result, player)
    if not PCP_PuritySystem.isEnabled() then return end
    _stampAndAnnounce(result, player, PCP_PuritySystem.randomBasePurity(30, 50))
end


---------------------------------------------------------------
-- SALT EXTRACTION CALLBACKS (3)
-- Concentration, crystallization, and purification of brine
-- into table salt. Kitchen-tier (factor 0.95).
---------------------------------------------------------------

--- Concentrate brine: propagation (input BrineJar purity, factor 0.95).
--- BrineJar is a FluidContainer consumed via -fluid syntax — the drained
--- container remains in inventory with purity stamped in modData.
--- Use recoverDrainedFluidQuality instead of averageInputPurity.
function PCP_RecipeCallbacks.pcpConcentrateBrinePurity(items, result, player)
    if not PCP_PuritySystem.isEnabled() then return end
    local input = PhobosLib.recoverDrainedFluidQuality(player, "PCP_Purity_Brine", PCP_PuritySystem.DEFAULT)
    local purity = PCP_PuritySystem.calculateOutputPurity(input, 0.95)
    _stampAndAnnounce(result, player, purity)
end

--- Crystallize salt: propagation + yield (input BrineConcentrate, factor 0.95)
--- Base output 2 CoarseSalt; low purity may reduce to 1.
function PCP_RecipeCallbacks.pcpCrystallizeSaltPurity(items, result, player)
    if not PCP_PuritySystem.isEnabled() then return end
    local input = PCP_PuritySystem.averageInputPurity(items)
    local purity = PCP_PuritySystem.calculateOutputPurity(input, 0.95)
    _stampAndAnnounce(result, player, purity)
    PCP_PuritySystem.removeExcess(player, "PhobosChemistryPathways.CoarseSalt", 2, purity)
end

--- Purify salt: terminal (vanilla Base.Salt output).
--- Reads CoarseSalt purity for speech bubble; no stamp on vanilla item.
function PCP_RecipeCallbacks.pcpPurifySaltPurity(items, result, player)
    if not PCP_PuritySystem.isEnabled() then return end
    local input = PCP_PuritySystem.averageInputPurity(items)
    if input > 0 then
        PCP_PuritySystem.announcePurity(player, input)
    end
end
