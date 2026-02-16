--[[
    PCP_RecipeCallbacks.lua — OnCreate callbacks for PhobosChemistryPathways

    These functions are called by craftRecipe OnCreate to handle post-craft logic
    that cannot be expressed in the recipe definition alone (e.g., returning a
    partially consumed drainable item, stamping purity on crafted items).

    Requires: PhobosLib, PCP_PuritySystem
]]

require "PhobosLib"
require "PCP_PuritySystem"

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
        player:getInventory():AddItem(newTank)
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
