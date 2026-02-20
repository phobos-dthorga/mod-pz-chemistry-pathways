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
local function _stampAndAnnounce(result, player, purity)
    PCP_PuritySystem.setPurity(result, purity)
    PCP_PuritySystem.stampOutputs(player, result:getFullType(), purity)
    PCP_PuritySystem.announcePurity(player, purity)
end


---------------------------------------------------------------
-- SOURCE CALLBACKS (9) — Assign base purity, no input tracking
---------------------------------------------------------------

--- Mortar oil pressing: 30-50
function PCP_RecipeCallbacks.pcpOilMortarPurity(items, result, player)
    if not PCP_PuritySystem.isEnabled() then return end
    _stampAndAnnounce(result, player, PCP_PuritySystem.randomBasePurity(30, 50))
end

--- Chemistry Set oil extraction: 50-70
function PCP_RecipeCallbacks.pcpOilLabPurity(items, result, player)
    if not PCP_PuritySystem.isEnabled() then return end
    _stampAndAnnounce(result, player, PCP_PuritySystem.randomBasePurity(50, 70))
end

--- MetalDrum bulk oil pressing: 40-60
function PCP_RecipeCallbacks.pcpOilBulkPurity(items, result, player)
    if not PCP_PuritySystem.isEnabled() then return end
    _stampAndAnnounce(result, player, PCP_PuritySystem.randomBasePurity(40, 60))
end

--- Convert bottled vegetable oil: 55-70
function PCP_RecipeCallbacks.pcpConvertOilPurity(items, result, player)
    if not PCP_PuritySystem.isEnabled() then return end
    _stampAndAnnounce(result, player, PCP_PuritySystem.randomBasePurity(55, 70))
end

--- Render fat (Chemistry Set): 45-65
function PCP_RecipeCallbacks.pcpRenderFatPurity(items, result, player)
    if not PCP_PuritySystem.isEnabled() then return end
    _stampAndAnnounce(result, player, PCP_PuritySystem.randomBasePurity(45, 65))
end

--- Distill methanol (Chemistry Set): 40-60
function PCP_RecipeCallbacks.pcpDistillMethanolPurity(items, result, player)
    if not PCP_PuritySystem.isEnabled() then return end
    _stampAndAnnounce(result, player, PCP_PuritySystem.randomBasePurity(40, 60))
end

--- Crush charcoal (Mortar): 35-55
function PCP_RecipeCallbacks.pcpCrushCharcoalPurity(items, result, player)
    if not PCP_PuritySystem.isEnabled() then return end
    _stampAndAnnounce(result, player, PCP_PuritySystem.randomBasePurity(35, 55))
end

--- Extract battery acid (Surface): 40-60
function PCP_RecipeCallbacks.pcpExtractAcidPurity(items, result, player)
    if not PCP_PuritySystem.isEnabled() then return end
    _stampAndAnnounce(result, player, PCP_PuritySystem.randomBasePurity(40, 60))
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
function PCP_RecipeCallbacks.pcpTransesterifyLabPurity(items, result, player)
    if not PCP_PuritySystem.isEnabled() then return end
    local input = PCP_PuritySystem.averageInputPurity(items)
    local purity = PCP_PuritySystem.calculateOutputPurity(input, PCP_PuritySystem.EQUIP_FACTORS.chemistrySet)
    _stampAndAnnounce(result, player, purity)
end

--- Transesterify — MetalDrum bulk tier (factor 0.95)
function PCP_RecipeCallbacks.pcpTransesterifyBulkPurity(items, result, player)
    if not PCP_PuritySystem.isEnabled() then return end
    local input = PCP_PuritySystem.averageInputPurity(items)
    local purity = PCP_PuritySystem.calculateOutputPurity(input, PCP_PuritySystem.EQUIP_FACTORS.metalDrum)
    _stampAndAnnounce(result, player, purity)
end

--- Wash biodiesel — Lab/Chemistry Set tier (factor 1.00)
function PCP_RecipeCallbacks.pcpWashBiodieselLabPurity(items, result, player)
    if not PCP_PuritySystem.isEnabled() then return end
    local input = PCP_PuritySystem.averageInputPurity(items)
    local purity = PCP_PuritySystem.calculateOutputPurity(input, PCP_PuritySystem.EQUIP_FACTORS.chemistrySet)
    _stampAndAnnounce(result, player, purity)
end

--- Wash biodiesel — MetalDrum bulk tier (factor 0.95)
function PCP_RecipeCallbacks.pcpWashBiodieselBulkPurity(items, result, player)
    if not PCP_PuritySystem.isEnabled() then return end
    local input = PCP_PuritySystem.averageInputPurity(items)
    local purity = PCP_PuritySystem.calculateOutputPurity(input, PCP_PuritySystem.EQUIP_FACTORS.metalDrum)
    _stampAndAnnounce(result, player, purity)
end

--- Centrifuge wash (factor 1.10)
function PCP_RecipeCallbacks.pcpCentrifugeWashPurity(items, result, player)
    if not PCP_PuritySystem.isEnabled() then return end
    local input = PCP_PuritySystem.averageInputPurity(items)
    local purity = PCP_PuritySystem.calculateOutputPurity(input, PCP_PuritySystem.EQUIP_FACTORS.centrifuge)
    _stampAndAnnounce(result, player, purity)
end

--- Centrifuge glycerol separation (factor 1.10)
function PCP_RecipeCallbacks.pcpCentrifugeGlycerolPurity(items, result, player)
    if not PCP_PuritySystem.isEnabled() then return end
    local input = PCP_PuritySystem.averageInputPurity(items)
    local purity = PCP_PuritySystem.calculateOutputPurity(input, PCP_PuritySystem.EQUIP_FACTORS.centrifuge)
    _stampAndAnnounce(result, player, purity)
end

--- Chromatograph purify biodiesel (factor 1.25) + fuel penalty
function PCP_RecipeCallbacks.pcpChromatographBiodieselPurity(items, result, player)
    if not PCP_PuritySystem.isEnabled() then return end
    local input = PCP_PuritySystem.averageInputPurity(items)
    local purity = PCP_PuritySystem.calculateOutputPurity(input, PCP_PuritySystem.EQUIP_FACTORS.chromatograph)
    _stampAndAnnounce(result, player, purity)
    PCP_PuritySystem.applyFuelPenalty(result, purity)
end

--- Chromatograph purify methanol (source override 80-95)
function PCP_RecipeCallbacks.pcpChromatographMethanolPurity(items, result, player)
    if not PCP_PuritySystem.isEnabled() then return end
    _stampAndAnnounce(result, player, PCP_PuritySystem.randomBasePurity(80, 95))
end

--- Make soap — all variants (cosmetic tracking, factor 1.00, no penalty)
function PCP_RecipeCallbacks.pcpMakeSoapPurity(items, result, player)
    if not PCP_PuritySystem.isEnabled() then return end
    local input = PCP_PuritySystem.averageInputPurity(items)
    local purity = PCP_PuritySystem.calculateOutputPurity(input, PCP_PuritySystem.EQUIP_FACTORS.chemistrySet)
    _stampAndAnnounce(result, player, purity)
end


---------------------------------------------------------------
-- TERMINAL CALLBACKS (4) — Propagation + yield penalty
---------------------------------------------------------------

--- Refine biodiesel into fuel — drain Petrol based on purity
function PCP_RecipeCallbacks.pcpRefineBiodieselPurity(items, result, player)
    if not PCP_PuritySystem.isEnabled() then return end
    local input = PCP_PuritySystem.averageInputPurity(items)
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
function PCP_RecipeCallbacks.pcpMicroscopeAnalyzePurity(items, result, player)
    if not PCP_PuritySystem.isEnabled() then return end
    local input = PCP_PuritySystem.averageInputPurity(items)
    local purity = PCP_PuritySystem.calculateOutputPurity(input, PCP_PuritySystem.EQUIP_FACTORS.microscope)
    _stampAndAnnounce(result, player, purity)
end

--- Spectrometer test (factor 1.15) + fuel penalty
function PCP_RecipeCallbacks.pcpSpectrometerTestPurity(items, result, player)
    if not PCP_PuritySystem.isEnabled() then return end
    local input = PCP_PuritySystem.averageInputPurity(items)
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
function PCP_RecipeCallbacks.pcpAcidWashPurity(items, result, player)
    if not PCP_PuritySystem.isEnabled() then return end
    local input = PCP_PuritySystem.averageInputPurity(items)
    local purity = PCP_PuritySystem.calculateOutputPurity(input, PCP_PuritySystem.EQUIP_FACTORS.chemistrySet)
    _stampAndAnnounce(result, player, purity)
end


---------------------------------------------------------------
-- COMBINED PROPANE + PURITY CALLBACKS (7)
-- Each calls pcpReturnPartialPropane first, then purity logic.
---------------------------------------------------------------

--- Transesterify oil bulk + propane (MetalDrum, factor 0.95)
function PCP_RecipeCallbacks.pcpTransesterifyOilBulkPropanePurity(items, result, player)
    PCP_RecipeCallbacks.pcpReturnPartialPropane(items, result, player)
    if not PCP_PuritySystem.isEnabled() then return end
    local input = PCP_PuritySystem.averageInputPurity(items)
    local purity = PCP_PuritySystem.calculateOutputPurity(input, PCP_PuritySystem.EQUIP_FACTORS.metalDrum)
    _stampAndAnnounce(result, player, purity)
end

--- Transesterify fat bulk + propane (MetalDrum, factor 0.95)
function PCP_RecipeCallbacks.pcpTransesterifyFatBulkPropanePurity(items, result, player)
    PCP_RecipeCallbacks.pcpReturnPartialPropane(items, result, player)
    if not PCP_PuritySystem.isEnabled() then return end
    local input = PCP_PuritySystem.averageInputPurity(items)
    local purity = PCP_PuritySystem.calculateOutputPurity(input, PCP_PuritySystem.EQUIP_FACTORS.metalDrum)
    _stampAndAnnounce(result, player, purity)
end

--- Wash biodiesel bulk + propane (MetalDrum, factor 0.95)
function PCP_RecipeCallbacks.pcpWashBiodieselBulkPropanePurity(items, result, player)
    PCP_RecipeCallbacks.pcpReturnPartialPropane(items, result, player)
    if not PCP_PuritySystem.isEnabled() then return end
    local input = PCP_PuritySystem.averageInputPurity(items)
    local purity = PCP_PuritySystem.calculateOutputPurity(input, PCP_PuritySystem.EQUIP_FACTORS.metalDrum)
    _stampAndAnnounce(result, player, purity)
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
function PCP_RecipeCallbacks.pcpMakeSoapPropanePurity(items, result, player)
    PCP_RecipeCallbacks.pcpReturnPartialPropane(items, result, player)
    if not PCP_PuritySystem.isEnabled() then return end
    local input = PCP_PuritySystem.averageInputPurity(items)
    local purity = PCP_PuritySystem.calculateOutputPurity(input, PCP_PuritySystem.EQUIP_FACTORS.chemistrySet)
    _stampAndAnnounce(result, player, purity)
end

--- Make soap (fat) + propane (cosmetic, factor 1.00)
function PCP_RecipeCallbacks.pcpMakeSoapFatPropanePurity(items, result, player)
    PCP_RecipeCallbacks.pcpReturnPartialPropane(items, result, player)
    if not PCP_PuritySystem.isEnabled() then return end
    local input = PCP_PuritySystem.averageInputPurity(items)
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

--- R3: Calcite Fertilizer (surface, source 30-50)
function PCP_RecipeCallbacks.pcpCalciteFertilizerPurity(items, result, player)
    if not PCP_PuritySystem.isEnabled() then return end
    _stampAndAnnounce(result, player, PCP_PuritySystem.randomBasePurity(30, 50))
end

--- R3b: Sulphur-Enhanced Calcite Fertilizer (surface, source 35-55)
function PCP_RecipeCallbacks.pcpCalciteFertilizerSulphurPurity(items, result, player)
    if not PCP_PuritySystem.isEnabled() then return end
    _stampAndAnnounce(result, player, PCP_PuritySystem.randomBasePurity(35, 55))
end

--- R3c: Potash Fertilizer (surface, source 30-50)
function PCP_RecipeCallbacks.pcpPotashFertilizerPurity(items, result, player)
    if not PCP_PuritySystem.isEnabled() then return end
    _stampAndAnnounce(result, player, PCP_PuritySystem.randomBasePurity(30, 50))
end

--- R4: Cure Soap (surface, source 50-70)
function PCP_RecipeCallbacks.pcpCureSoapPurity(items, result, player)
    if not PCP_PuritySystem.isEnabled() then return end
    _stampAndAnnounce(result, player, PCP_PuritySystem.randomBasePurity(50, 70))
end

--- R5: Sterilize Bandage (ChemistrySet, propagation 1.00)
function PCP_RecipeCallbacks.pcpSterilizeBandagePurity(items, result, player)
    if not PCP_PuritySystem.isEnabled() then return end
    local input = PCP_PuritySystem.averageInputPurity(items)
    local purity = PCP_PuritySystem.calculateOutputPurity(input, PCP_PuritySystem.EQUIP_FACTORS.chemistrySet)
    _stampAndAnnounce(result, player, purity)
end

--- R6: Cast Fishing Weights (Furnace, source 40-60)
function PCP_RecipeCallbacks.pcpCastFishingWeightsPurity(items, result, player)
    if not PCP_PuritySystem.isEnabled() then return end
    _stampAndAnnounce(result, player, PCP_PuritySystem.randomBasePurity(40, 60))
end

--- R6: Cast Fishing Weights + propane (Furnace, source 40-60)
function PCP_RecipeCallbacks.pcpCastFishingWeightsPropanePurity(items, result, player)
    PCP_RecipeCallbacks.pcpReturnPartialPropane(items, result, player)
    if not PCP_PuritySystem.isEnabled() then return end
    _stampAndAnnounce(result, player, PCP_PuritySystem.randomBasePurity(40, 60))
end

--- R7: Melt Plastic into Glue (ChemistrySet, source 50-70)
function PCP_RecipeCallbacks.pcpMeltPlasticGluePurity(items, result, player)
    if not PCP_PuritySystem.isEnabled() then return end
    _stampAndAnnounce(result, player, PCP_PuritySystem.randomBasePurity(50, 70))
end

-- R7: Melt Plastic into Glue — Safe (filter degrade)
function PCP_RecipeCallbacks.pcpMeltPlasticGlueSafePurity(items, result, player)
    _safeWrapper(PCP_RecipeCallbacks.pcpMeltPlasticGluePurity, items, result, player)
end

-- R7: Melt Plastic into Glue — Unsafe (plastic_fumes)
function PCP_RecipeCallbacks.pcpMeltPlasticGlueUnsafePurity(items, result, player)
    _unsafeWrapper(PCP_RecipeCallbacks.pcpMeltPlasticGluePurity, "plastic_fumes", items, result, player)
end

--- R8: Recover Precision Components (surface, source 60-80)
function PCP_RecipeCallbacks.pcpRecoverComponentsPurity(items, result, player)
    if not PCP_PuritySystem.isEnabled() then return end
    _stampAndAnnounce(result, player, PCP_PuritySystem.randomBasePurity(60, 80))
end

--- R9: Make Tar-Pitch Torch (surface, source 40-60)
function PCP_RecipeCallbacks.pcpMakeTarTorchPurity(items, result, player)
    if not PCP_PuritySystem.isEnabled() then return end
    _stampAndAnnounce(result, player, PCP_PuritySystem.randomBasePurity(40, 60))
end

--- Bug fix: Bulk Refine Biodiesel (surface, propagation 0.95)
function PCP_RecipeCallbacks.pcpRefineBiodieselBulkPurity(items, result, player)
    if not PCP_PuritySystem.isEnabled() then return end
    local input = PCP_PuritySystem.averageInputPurity(items)
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
    _stampAndAnnounce(result, player, PCP_PuritySystem.randomBasePurity(40, 60))
end

--- Render fat (Cooking Pot): 30-50
function PCP_RecipeCallbacks.pcpRenderFatPotPurity(items, result, player)
    if not PCP_PuritySystem.isEnabled() then return end
    _stampAndAnnounce(result, player, PCP_PuritySystem.randomBasePurity(30, 50))
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
function PCP_RecipeCallbacks.pcpWashBiodieselPotPurity(items, result, player)
    if not PCP_PuritySystem.isEnabled() then return end
    local input = PCP_PuritySystem.averageInputPurity(items)
    local purity = PCP_PuritySystem.calculateOutputPurity(input, 0.90)
    _stampAndAnnounce(result, player, purity)
end
