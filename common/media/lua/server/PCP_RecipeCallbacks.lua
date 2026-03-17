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

--- Stamp purity on result + all same-type outputs, announce, then apply yield.
--- Counts unstamped items BEFORE stamping to get accurate recipe output count.
--- Used by PROPAGATION callbacks producing multi-output PCP items (Rule 1).
local function _stampAnnounceAndYield(result, player, purity)
    if not result then return end
    local ok, ft = pcall(result.getFullType, result)
    if not ok or not ft or not string.find(ft, "PhobosChemistryPathways.", 1, true) then return end
    local baseCount = PCP_PuritySystem.countUnstampedOutputs(player, ft)
    PCP_PuritySystem.setPurity(result, purity)
    PCP_PuritySystem.stampOutputs(player, ft, purity)
    PCP_PuritySystem.announcePurity(player, purity)
    PCP_PuritySystem.applyYieldIfMultiOutput(player, ft, baseCount, purity)
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

--- Apply fuel penalty (drain fluid) to recently-filled FluidContainers by fluid name.
--- Reverse-iterates inventory to find containers most recently added by the recipe.
--- Used for terminal fuel recipes (refine, chromatograph, spectrometer).
---@param player any        The player character
---@param fluidName string  The fluid name to search for (e.g. "Petrol")
---@param purity number     Purity value for yield lookup
---@param count number      Max containers to apply penalty to
local function _applyFluidFuelPenalty(player, fluidName, purity, count)
    if not PCP_PuritySystem.isEnabled() then return end
    if not player or not fluidName then return end
    count = count or 1
    local applied = 0
    pcall(function()
        local inv = player:getInventory()
        if not inv then return end
        local items = inv:getItems()
        for i = items:size() - 1, 0, -1 do
            if applied >= count then break end
            local it = items:get(i)
            if it then
                local fc = PhobosLib.tryGetFluidContainer(it)
                if fc then
                    local fname = PhobosLib.tryGetFluidName(fc)
                    if fname and fname == fluidName then
                        PhobosLib.applyFluidQualityPenalty(it, purity, PCP_PuritySystem.YIELD_TABLE)
                        applied = applied + 1
                    end
                end
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
    local purity = PCP_PuritySystem.randomBasePurityWithSkill(30, 50, player)
    PhobosLib.stampFluidContainerQuality(player, "CrudeVegetableOil", "PCP_Purity_CrudeVegetableOil", purity, 1)
    PCP_PuritySystem.announcePurity(player, purity)
end

--- Chemistry Set oil extraction: 50-70
function PCP_RecipeCallbacks.pcpOilLabPurity(items, result, player)
    if not PCP_PuritySystem.isEnabled() then return end
    local purity = PCP_PuritySystem.randomBasePurityWithSkill(50, 70, player)
    PhobosLib.stampFluidContainerQuality(player, "CrudeVegetableOil", "PCP_Purity_CrudeVegetableOil", purity, 2)
    PCP_PuritySystem.announcePurity(player, purity)
end

--- MetalDrum bulk oil pressing: 40-60
function PCP_RecipeCallbacks.pcpOilBulkPurity(items, result, player)
    if not PCP_PuritySystem.isEnabled() then return end
    local purity = PCP_PuritySystem.randomBasePurityWithSkill(40, 60, player)
    PhobosLib.stampFluidContainerQuality(player, "CrudeVegetableOil", "PCP_Purity_CrudeVegetableOil", purity, 1)
    PCP_PuritySystem.announcePurity(player, purity)
end

--- Convert bottled vegetable oil: 55-70
function PCP_RecipeCallbacks.pcpConvertOilPurity(items, result, player)
    if not PCP_PuritySystem.isEnabled() then return end
    local purity = PCP_PuritySystem.randomBasePurityWithSkill(55, 70, player)
    PhobosLib.stampFluidContainerQuality(player, "CrudeVegetableOil", "PCP_Purity_CrudeVegetableOil", purity, 2)
    PCP_PuritySystem.announcePurity(player, purity)
end

--- Render fat (Chemistry Set): 45-65
function PCP_RecipeCallbacks.pcpRenderFatPurity(items, result, player)
    if not PCP_PuritySystem.isEnabled() then return end
    local purity = PCP_PuritySystem.randomBasePurityWithSkill(45, 65, player)
    PhobosLib.stampFluidContainerQuality(player, "RenderedFat", "PCP_Purity_RenderedFat", purity, 2)
    PCP_PuritySystem.announcePurity(player, purity)
end

--- Distill methanol (Chemistry Set): 40-60
function PCP_RecipeCallbacks.pcpDistillMethanolPurity(items, result, player)
    if not PCP_PuritySystem.isEnabled() then return end
    local purity = PCP_PuritySystem.randomBasePurityWithSkill(40, 60, player)
    PhobosLib.stampFluidContainerQuality(player, "WoodMethanol", "PCP_Purity_WoodMethanol", purity, 2)
    PCP_PuritySystem.announcePurity(player, purity)
end

--- Crush charcoal (Mortar): 35-55
function PCP_RecipeCallbacks.pcpCrushCharcoalPurity(items, result, player)
    if not PCP_PuritySystem.isEnabled() then return end
    _stampAndAnnounce(result, player, PCP_PuritySystem.randomBasePurityWithSkill(35, 55, player))
end

--- Extract battery acid (Surface): 40-60
--- Result = LeadScrap (solid PCP item), acid outputs are +fluid containers
function PCP_RecipeCallbacks.pcpExtractAcidPurity(items, result, player)
    if not PCP_PuritySystem.isEnabled() then return end
    local purity = PCP_PuritySystem.randomBasePurityWithSkill(40, 60, player)
    _stampAndAnnounce(result, player, purity)
    PhobosLib.stampFluidContainerQuality(player, "SulphuricAcid", "PCP_Purity_SulphuricAcid", purity, 2)
end

--- Bone char production (MetalDrum): 50-70
function PCP_RecipeCallbacks.pcpBoneCharPurity(items, result, player)
    if not PCP_PuritySystem.isEnabled() then return end
    _stampAndAnnounce(result, player, PCP_PuritySystem.randomBasePurityWithSkill(50, 70, player))
end


---------------------------------------------------------------
-- PROPAGATION CALLBACKS (15) — Read input purity, apply factor
---------------------------------------------------------------

--- Purify charcoal water wash (Chemistry Set, factor 1.05)
--- Outputs: 2× PurifiedCharcoal + 1× Potash
function PCP_RecipeCallbacks.pcpPurifyCharcoalPurity(items, result, player)
    if not PCP_PuritySystem.isEnabled() then return end
    local input = PCP_PuritySystem.averageInputPurity(items)
    local purity = PCP_PuritySystem.calculateOutputPurity(input, 1.05, player)
    _stampAnnounceAndYield(result, player, purity)
end

--- Purify charcoal NaOH wash (Chemistry Set, factor 1.15)
--- Outputs: 6× PurifiedCharcoal + 3× Potash
function PCP_RecipeCallbacks.pcpPurifyCharcoalNaOHPurity(items, result, player)
    if not PCP_PuritySystem.isEnabled() then return end
    local input = PCP_PuritySystem.averageInputPurity(items)
    local purity = PCP_PuritySystem.calculateOutputPurity(input, 1.15, player)
    _stampAnnounceAndYield(result, player, purity)
end

--- Prepare diluted compost (Chemistry Set, factor 1.00)
--- Outputs: 3-4× DilutedCompost
function PCP_RecipeCallbacks.pcpCompostPurity(items, result, player)
    if not PCP_PuritySystem.isEnabled() then return end
    local input = PCP_PuritySystem.averageInputPurity(items)
    local purity = PCP_PuritySystem.calculateOutputPurity(input, PCP_PuritySystem.EQUIP_FACTORS.chemistrySet, player)
    _stampAnnounceAndYield(result, player, purity)
end

--- Extract sulphur (Chemistry Set, factor 1.00)
--- Outputs: 4× SulphurPowder
function PCP_RecipeCallbacks.pcpExtractSulphurPurity(items, result, player)
    if not PCP_PuritySystem.isEnabled() then return end
    local input = PCP_PuritySystem.averageInputPurity(items)
    local purity = PCP_PuritySystem.calculateOutputPurity(input, PCP_PuritySystem.EQUIP_FACTORS.chemistrySet, player)
    _stampAnnounceAndYield(result, player, purity)
end

--- Synthesize KNO3 (Chemistry Set, factor 1.00)
--- Outputs: 4-6× PotassiumNitratePowder
function PCP_RecipeCallbacks.pcpSynthesizeKNO3Purity(items, result, player)
    if not PCP_PuritySystem.isEnabled() then return end
    local input = PCP_PuritySystem.averageInputPurity(items)
    local purity = PCP_PuritySystem.calculateOutputPurity(input, PCP_PuritySystem.EQUIP_FACTORS.chemistrySet, player)
    _stampAnnounceAndYield(result, player, purity)
end

--- Synthesize KOH (Chemistry Set, factor 1.00)
--- Outputs: 3× PotassiumHydroxide + 2× Calcite
function PCP_RecipeCallbacks.pcpSynthesizeKOHPurity(items, result, player)
    if not PCP_PuritySystem.isEnabled() then return end
    local input = PCP_PuritySystem.averageInputPurity(items)
    local purity = PCP_PuritySystem.calculateOutputPurity(input, PCP_PuritySystem.EQUIP_FACTORS.chemistrySet, player)
    _stampAnnounceAndYield(result, player, purity)
end

--- Transesterify — Lab/Chemistry Set tier (factor 1.00)
--- Fluid inputs: CrudeVegetableOil OR RenderedFat + WoodMethanol; solid: KOH
--- Fluid outputs: 3× CrudeBiodiesel + 2× Glycerol
function PCP_RecipeCallbacks.pcpTransesterifyLabPurity(items, result, player)
    if not PCP_PuritySystem.isEnabled() then return end
    local input = _averagePurities({
        _recoverAnyFluidPurity(player, {"PCP_Purity_CrudeVegetableOil", "PCP_Purity_RenderedFat"}),
        PhobosLib.recoverDrainedFluidQuality(player, "PCP_Purity_WoodMethanol", -1),
        PCP_PuritySystem.averageInputPurity(items)
    })
    local purity = PCP_PuritySystem.calculateOutputPurity(input, PCP_PuritySystem.EQUIP_FACTORS.chemistrySet, player)
    PhobosLib.stampFluidContainerQuality(player, "CrudeBiodiesel", "PCP_Purity_CrudeBiodiesel", purity, 3)
    PhobosLib.stampFluidContainerQuality(player, "Glycerol", "PCP_Purity_Glycerol", purity, 2)
    PCP_PuritySystem.announcePurity(player, purity)
end

--- Transesterify — MetalDrum bulk tier (factor 0.95)
--- Fluid inputs: CrudeVegetableOil OR RenderedFat + WoodMethanol; solid: KOH
--- Fluid outputs: 1× CrudeBiodiesel (bucket) + 5× Glycerol
function PCP_RecipeCallbacks.pcpTransesterifyBulkPurity(items, result, player)
    if not PCP_PuritySystem.isEnabled() then return end
    local input = _averagePurities({
        _recoverAnyFluidPurity(player, {"PCP_Purity_CrudeVegetableOil", "PCP_Purity_RenderedFat"}),
        PhobosLib.recoverDrainedFluidQuality(player, "PCP_Purity_WoodMethanol", -1),
        PCP_PuritySystem.averageInputPurity(items)
    })
    local purity = PCP_PuritySystem.calculateOutputPurity(input, PCP_PuritySystem.EQUIP_FACTORS.metalDrum, player)
    PhobosLib.stampFluidContainerQuality(player, "CrudeBiodiesel", "PCP_Purity_CrudeBiodiesel", purity, 1)
    PhobosLib.stampFluidContainerQuality(player, "Glycerol", "PCP_Purity_Glycerol", purity, 5)
    PCP_PuritySystem.announcePurity(player, purity)
end

--- Wash biodiesel — Lab/Chemistry Set tier (factor 1.00)
--- Fluid input: CrudeBiodiesel → output: 3× WashedBiodiesel
function PCP_RecipeCallbacks.pcpWashBiodieselLabPurity(items, result, player)
    if not PCP_PuritySystem.isEnabled() then return end
    local input = PhobosLib.recoverDrainedFluidQuality(player, "PCP_Purity_CrudeBiodiesel", PCP_PuritySystem.DEFAULT)
    local purity = PCP_PuritySystem.calculateOutputPurity(input, PCP_PuritySystem.EQUIP_FACTORS.chemistrySet, player)
    PhobosLib.stampFluidContainerQuality(player, "WashedBiodiesel", "PCP_Purity_WashedBiodiesel", purity, 3)
    PCP_PuritySystem.announcePurity(player, purity)
end

--- Wash biodiesel — MetalDrum bulk tier (factor 0.95)
--- Fluid input: CrudeBiodiesel → output: 1× WashedBiodiesel (bucket)
function PCP_RecipeCallbacks.pcpWashBiodieselBulkPurity(items, result, player)
    if not PCP_PuritySystem.isEnabled() then return end
    local input = PhobosLib.recoverDrainedFluidQuality(player, "PCP_Purity_CrudeBiodiesel", PCP_PuritySystem.DEFAULT)
    local purity = PCP_PuritySystem.calculateOutputPurity(input, PCP_PuritySystem.EQUIP_FACTORS.metalDrum, player)
    PhobosLib.stampFluidContainerQuality(player, "WashedBiodiesel", "PCP_Purity_WashedBiodiesel", purity, 1)
    PCP_PuritySystem.announcePurity(player, purity)
end

--- Centrifuge wash (factor 1.10)
--- Fluid input: CrudeBiodiesel → output: 4× WashedBiodiesel
function PCP_RecipeCallbacks.pcpCentrifugeWashPurity(items, result, player)
    if not PCP_PuritySystem.isEnabled() then return end
    local input = PhobosLib.recoverDrainedFluidQuality(player, "PCP_Purity_CrudeBiodiesel", PCP_PuritySystem.DEFAULT)
    local purity = PCP_PuritySystem.calculateOutputPurity(input, PCP_PuritySystem.EQUIP_FACTORS.centrifuge, player)
    PhobosLib.stampFluidContainerQuality(player, "WashedBiodiesel", "PCP_Purity_WashedBiodiesel", purity, 4)
    PCP_PuritySystem.announcePurity(player, purity)
end

--- Centrifuge glycerol separation (factor 1.10)
--- Fluid input: CrudeBiodiesel → output: 2× WashedBiodiesel + 3× Glycerol
function PCP_RecipeCallbacks.pcpCentrifugeGlycerolPurity(items, result, player)
    if not PCP_PuritySystem.isEnabled() then return end
    local input = PhobosLib.recoverDrainedFluidQuality(player, "PCP_Purity_CrudeBiodiesel", PCP_PuritySystem.DEFAULT)
    local purity = PCP_PuritySystem.calculateOutputPurity(input, PCP_PuritySystem.EQUIP_FACTORS.centrifuge, player)
    PhobosLib.stampFluidContainerQuality(player, "WashedBiodiesel", "PCP_Purity_WashedBiodiesel", purity, 2)
    PhobosLib.stampFluidContainerQuality(player, "Glycerol", "PCP_Purity_Glycerol", purity, 3)
    PCP_PuritySystem.announcePurity(player, purity)
end

--- Chromatograph purify biodiesel (factor 1.25) + fuel penalty
--- Fluid input: WashedBiodiesel → output: 2× Petrol gas cans
function PCP_RecipeCallbacks.pcpChromatographBiodieselPurity(items, result, player)
    if not PCP_PuritySystem.isEnabled() then return end
    local input = PhobosLib.recoverDrainedFluidQuality(player, "PCP_Purity_WashedBiodiesel", PCP_PuritySystem.DEFAULT)
    local purity = PCP_PuritySystem.calculateOutputPurity(input, PCP_PuritySystem.EQUIP_FACTORS.chromatograph, player)
    _applyFluidFuelPenalty(player, "Petrol", purity, 2)
    PCP_PuritySystem.announcePurity(player, purity)
end

--- Chromatograph purify methanol (source override 80-95)
--- Output: 3× WoodMethanol
function PCP_RecipeCallbacks.pcpChromatographMethanolPurity(items, result, player)
    if not PCP_PuritySystem.isEnabled() then return end
    local purity = PCP_PuritySystem.randomBasePurityWithSkill(80, 95, player)
    PhobosLib.stampFluidContainerQuality(player, "WoodMethanol", "PCP_Purity_WoodMethanol", purity, 3)
    PCP_PuritySystem.announcePurity(player, purity)
end

--- Make soap — all variants (factor 1.00, yield on multi-output)
--- Glycerol variants: fluid Glycerol + solid KOH/NaOH → 3-4× CrudeSoap
--- Fat variants: solid Lard/Butter + solid KOH/NaOH → 3× CrudeSoap
function PCP_RecipeCallbacks.pcpMakeSoapPurity(items, result, player)
    if not PCP_PuritySystem.isEnabled() then return end
    local input = _averagePurities({
        PhobosLib.recoverDrainedFluidQuality(player, "PCP_Purity_Glycerol", -1),
        PCP_PuritySystem.averageInputPurity(items)
    })
    local purity = PCP_PuritySystem.calculateOutputPurity(input, PCP_PuritySystem.EQUIP_FACTORS.chemistrySet, player)
    _stampAnnounceAndYield(result, player, purity)
end


---------------------------------------------------------------
-- TERMINAL CALLBACKS (4) — Propagation + yield penalty
---------------------------------------------------------------

--- Refine biodiesel into fuel — drain Petrol based on purity
--- Fluid input: WashedBiodiesel → output: 1× Petrol gas can
function PCP_RecipeCallbacks.pcpRefineBiodieselPurity(items, result, player)
    if not PCP_PuritySystem.isEnabled() then return end
    local input = PhobosLib.recoverDrainedFluidQuality(player, "PCP_Purity_WashedBiodiesel", PCP_PuritySystem.DEFAULT)
    local purity = PCP_PuritySystem.calculateOutputPurity(input, PCP_PuritySystem.EQUIP_FACTORS.chemistrySet, player)
    _applyFluidFuelPenalty(player, "Petrol", purity, 1)
    PCP_PuritySystem.announcePurity(player, purity)
end

--- Mix blackpowder — remove excess GunPowder based on purity.
--- RULE 2 EXCEPTION: Flagship recipe. Yield applies to vanilla GunPowder output
--- because blackpowder quality is the core gameplay loop for this pathway.
function PCP_RecipeCallbacks.pcpMixBlackpowderPurity(items, result, player)
    if not PCP_PuritySystem.isEnabled() then return end
    local input = PCP_PuritySystem.averageInputPurity(items)
    local purity = PCP_PuritySystem.calculateOutputPurity(input, PCP_PuritySystem.EQUIP_FACTORS.chemistrySet, player)
    _stampAndAnnounce(result, player, purity)
    PCP_PuritySystem.removeExcess(player, "Base.GunPowder", 10, purity)
end

--- Microscope analysis (factor 1.15)
--- Fluid inputs: CrudeVegetableOil + WoodMethanol; solid: KOH/NaOH
--- Fluid outputs: 4× CrudeBiodiesel + 2× Glycerol
function PCP_RecipeCallbacks.pcpMicroscopeAnalyzePurity(items, result, player)
    if not PCP_PuritySystem.isEnabled() then return end
    local input = _averagePurities({
        PhobosLib.recoverDrainedFluidQuality(player, "PCP_Purity_CrudeVegetableOil", -1),
        PhobosLib.recoverDrainedFluidQuality(player, "PCP_Purity_WoodMethanol", -1),
        PCP_PuritySystem.averageInputPurity(items)
    })
    local purity = PCP_PuritySystem.calculateOutputPurity(input, PCP_PuritySystem.EQUIP_FACTORS.microscope, player)
    PhobosLib.stampFluidContainerQuality(player, "CrudeBiodiesel", "PCP_Purity_CrudeBiodiesel", purity, 4)
    PhobosLib.stampFluidContainerQuality(player, "Glycerol", "PCP_Purity_Glycerol", purity, 2)
    PCP_PuritySystem.announcePurity(player, purity)
end

--- Spectrometer test (factor 1.15) + fuel penalty
--- Fluid input: WashedBiodiesel → output: 2× Petrol gas cans
function PCP_RecipeCallbacks.pcpSpectrometerTestPurity(items, result, player)
    if not PCP_PuritySystem.isEnabled() then return end
    local input = PhobosLib.recoverDrainedFluidQuality(player, "PCP_Purity_WashedBiodiesel", PCP_PuritySystem.DEFAULT)
    local purity = PCP_PuritySystem.calculateOutputPurity(input, PCP_PuritySystem.EQUIP_FACTORS.spectrometer, player)
    _applyFluidFuelPenalty(player, "Petrol", purity, 2)
    PCP_PuritySystem.announcePurity(player, purity)
end


---------------------------------------------------------------
-- UTILITY CALLBACKS (2)
---------------------------------------------------------------

--- Cut plastic scrap (Surface, source 40-60)
function PCP_RecipeCallbacks.pcpCutPlasticPurity(items, result, player)
    if not PCP_PuritySystem.isEnabled() then return end
    _stampAndAnnounce(result, player, PCP_PuritySystem.randomBasePurityWithSkill(40, 60, player))
end

--- Acid wash electronics (Chemistry Set, propagation factor 1.00)
--- Fluid input: SulphuricAcid; Outputs: 4× AcidWashedElectronics
function PCP_RecipeCallbacks.pcpAcidWashPurity(items, result, player)
    if not PCP_PuritySystem.isEnabled() then return end
    local input = _averagePurities({
        PhobosLib.recoverDrainedFluidQuality(player, "PCP_Purity_SulphuricAcid", -1),
        PCP_PuritySystem.averageInputPurity(items)
    })
    local purity = PCP_PuritySystem.calculateOutputPurity(input, PCP_PuritySystem.EQUIP_FACTORS.chemistrySet, player)
    _stampAnnounceAndYield(result, player, purity)
end


---------------------------------------------------------------
-- COMBINED PROPANE + PURITY CALLBACKS (7)
-- Each calls pcpReturnPartialPropane first, then purity logic.
---------------------------------------------------------------

--- Transesterify oil bulk + propane (MetalDrum, factor 0.95)
--- Fluid inputs: CrudeVegetableOil + WoodMethanol; solid: KOH
--- Fluid outputs: 1× CrudeBiodiesel (bucket) + 5× Glycerol
function PCP_RecipeCallbacks.pcpTransesterifyOilBulkPropanePurity(items, result, player)
    PCP_RecipeCallbacks.pcpReturnPartialPropane(items, result, player)
    if not PCP_PuritySystem.isEnabled() then return end
    local input = _averagePurities({
        PhobosLib.recoverDrainedFluidQuality(player, "PCP_Purity_CrudeVegetableOil", -1),
        PhobosLib.recoverDrainedFluidQuality(player, "PCP_Purity_WoodMethanol", -1),
        PCP_PuritySystem.averageInputPurity(items)
    })
    local purity = PCP_PuritySystem.calculateOutputPurity(input, PCP_PuritySystem.EQUIP_FACTORS.metalDrum, player)
    PhobosLib.stampFluidContainerQuality(player, "CrudeBiodiesel", "PCP_Purity_CrudeBiodiesel", purity, 1)
    PhobosLib.stampFluidContainerQuality(player, "Glycerol", "PCP_Purity_Glycerol", purity, 5)
    PCP_PuritySystem.announcePurity(player, purity)
end

--- Transesterify fat bulk + propane (MetalDrum, factor 0.95)
--- Fluid inputs: RenderedFat + WoodMethanol; solid: KOH
--- Fluid outputs: 1× CrudeBiodiesel (bucket) + 5× Glycerol
function PCP_RecipeCallbacks.pcpTransesterifyFatBulkPropanePurity(items, result, player)
    PCP_RecipeCallbacks.pcpReturnPartialPropane(items, result, player)
    if not PCP_PuritySystem.isEnabled() then return end
    local input = _averagePurities({
        PhobosLib.recoverDrainedFluidQuality(player, "PCP_Purity_RenderedFat", -1),
        PhobosLib.recoverDrainedFluidQuality(player, "PCP_Purity_WoodMethanol", -1),
        PCP_PuritySystem.averageInputPurity(items)
    })
    local purity = PCP_PuritySystem.calculateOutputPurity(input, PCP_PuritySystem.EQUIP_FACTORS.metalDrum, player)
    PhobosLib.stampFluidContainerQuality(player, "CrudeBiodiesel", "PCP_Purity_CrudeBiodiesel", purity, 1)
    PhobosLib.stampFluidContainerQuality(player, "Glycerol", "PCP_Purity_Glycerol", purity, 5)
    PCP_PuritySystem.announcePurity(player, purity)
end

--- Wash biodiesel bulk + propane (MetalDrum, factor 0.95)
--- Fluid input: CrudeBiodiesel → output: 1× WashedBiodiesel (bucket)
function PCP_RecipeCallbacks.pcpWashBiodieselBulkPropanePurity(items, result, player)
    PCP_RecipeCallbacks.pcpReturnPartialPropane(items, result, player)
    if not PCP_PuritySystem.isEnabled() then return end
    local input = PhobosLib.recoverDrainedFluidQuality(player, "PCP_Purity_CrudeBiodiesel", PCP_PuritySystem.DEFAULT)
    local purity = PCP_PuritySystem.calculateOutputPurity(input, PCP_PuritySystem.EQUIP_FACTORS.metalDrum, player)
    PhobosLib.stampFluidContainerQuality(player, "WashedBiodiesel", "PCP_Purity_WashedBiodiesel", purity, 1)
    PCP_PuritySystem.announcePurity(player, purity)
end

--- Bone char + propane (MetalDrum, source 50-70)
function PCP_RecipeCallbacks.pcpBoneCharPropanePurity(items, result, player)
    PCP_RecipeCallbacks.pcpReturnPartialPropane(items, result, player)
    if not PCP_PuritySystem.isEnabled() then return end
    _stampAndAnnounce(result, player, PCP_PuritySystem.randomBasePurityWithSkill(50, 70, player))
end

--- Bone char skull + propane (MetalDrum, source 50-70)
function PCP_RecipeCallbacks.pcpBoneCharSkullPropanePurity(items, result, player)
    PCP_RecipeCallbacks.pcpReturnPartialPropane(items, result, player)
    if not PCP_PuritySystem.isEnabled() then return end
    _stampAndAnnounce(result, player, PCP_PuritySystem.randomBasePurityWithSkill(50, 70, player))
end

--- Make soap (glycerol) + propane (factor 1.00, yield on multi-output)
--- Fluid input: Glycerol; solid: KOH → 3-4× CrudeSoap
function PCP_RecipeCallbacks.pcpMakeSoapPropanePurity(items, result, player)
    PCP_RecipeCallbacks.pcpReturnPartialPropane(items, result, player)
    if not PCP_PuritySystem.isEnabled() then return end
    local input = _averagePurities({
        PhobosLib.recoverDrainedFluidQuality(player, "PCP_Purity_Glycerol", -1),
        PCP_PuritySystem.averageInputPurity(items)
    })
    local purity = PCP_PuritySystem.calculateOutputPurity(input, PCP_PuritySystem.EQUIP_FACTORS.chemistrySet, player)
    _stampAnnounceAndYield(result, player, purity)
end

--- Make soap (fat) + propane (factor 1.00, yield on multi-output)
--- Fluid input: RenderedFat; solid: KOH → 3-4× CrudeSoap
function PCP_RecipeCallbacks.pcpMakeSoapFatPropanePurity(items, result, player)
    PCP_RecipeCallbacks.pcpReturnPartialPropane(items, result, player)
    if not PCP_PuritySystem.isEnabled() then return end
    local input = _averagePurities({
        PhobosLib.recoverDrainedFluidQuality(player, "PCP_Purity_RenderedFat", -1),
        PCP_PuritySystem.averageInputPurity(items)
    })
    local purity = PCP_PuritySystem.calculateOutputPurity(input, PCP_PuritySystem.EQUIP_FACTORS.chemistrySet, player)
    _stampAnnounceAndYield(result, player, purity)
end


---------------------------------------------------------------
-- HEALTH HAZARD CALLBACKS (20)
-- Safe variants: purity + filter degradation
-- Unsafe variants: purity + hazard effect dispatch
---------------------------------------------------------------

-- Distill Methanol — Safe (filter degrade)
function PCP_RecipeCallbacks.pcpDistillMethanolSafePurity(items, result, player)
    PCP_HazardSystem.safeWrapper(PCP_RecipeCallbacks.pcpDistillMethanolPurity, items, result, player)
end

-- Distill Methanol — Unsafe (methanol_vapor)
function PCP_RecipeCallbacks.pcpDistillMethanolUnsafePurity(items, result, player)
    PCP_HazardSystem.unsafeWrapper(PCP_RecipeCallbacks.pcpDistillMethanolPurity, "methanol_vapor", items, result, player)
end

-- Synthesize KOH — Safe (filter degrade)
function PCP_RecipeCallbacks.pcpSynthesizeKOHSafePurity(items, result, player)
    PCP_HazardSystem.safeWrapper(PCP_RecipeCallbacks.pcpSynthesizeKOHPurity, items, result, player)
end

-- Synthesize KOH — Unsafe (caustic_vapor)
function PCP_RecipeCallbacks.pcpSynthesizeKOHUnsafePurity(items, result, player)
    PCP_HazardSystem.unsafeWrapper(PCP_RecipeCallbacks.pcpSynthesizeKOHPurity, "caustic_vapor", items, result, player)
end

-- Extract Sulphur — Safe (filter degrade)
function PCP_RecipeCallbacks.pcpExtractSulphurSafePurity(items, result, player)
    PCP_HazardSystem.safeWrapper(PCP_RecipeCallbacks.pcpExtractSulphurPurity, items, result, player)
end

-- Extract Sulphur — Unsafe (acid_fumes)
function PCP_RecipeCallbacks.pcpExtractSulphurUnsafePurity(items, result, player)
    PCP_HazardSystem.unsafeWrapper(PCP_RecipeCallbacks.pcpExtractSulphurPurity, "acid_fumes", items, result, player)
end

-- Extract Battery Acid — Safe (filter degrade)
function PCP_RecipeCallbacks.pcpExtractAcidSafePurity(items, result, player)
    PCP_HazardSystem.safeWrapper(PCP_RecipeCallbacks.pcpExtractAcidPurity, items, result, player)
end

-- Extract Battery Acid — Unsafe (acid_mist)
function PCP_RecipeCallbacks.pcpExtractAcidUnsafePurity(items, result, player)
    PCP_HazardSystem.unsafeWrapper(PCP_RecipeCallbacks.pcpExtractAcidPurity, "acid_mist", items, result, player)
end

-- Acid Wash Electronics — Safe (filter degrade)
function PCP_RecipeCallbacks.pcpAcidWashSafePurity(items, result, player)
    PCP_HazardSystem.safeWrapper(PCP_RecipeCallbacks.pcpAcidWashPurity, items, result, player)
end

-- Acid Wash Electronics — Unsafe (acid_mist)
function PCP_RecipeCallbacks.pcpAcidWashUnsafePurity(items, result, player)
    PCP_HazardSystem.unsafeWrapper(PCP_RecipeCallbacks.pcpAcidWashPurity, "acid_mist", items, result, player)
end


---------------------------------------------------------------
-- RECYCLING RECIPE CALLBACKS (12)
-- New downstream recipes for by-products and dead-end items.
---------------------------------------------------------------

--- R1: Make Wood Glue from tar (surface, source 40-60)
function PCP_RecipeCallbacks.pcpMakeWoodGluePurity(items, result, player)
    if not PCP_PuritySystem.isEnabled() then return end
    _stampAndAnnounce(result, player, PCP_PuritySystem.randomBasePurityWithSkill(40, 60, player))
end

--- R2: Calcine Calcite into Quicklime (DomeKiln, source 40-60)
function PCP_RecipeCallbacks.pcpCalcineCalcitePurity(items, result, player)
    if not PCP_PuritySystem.isEnabled() then return end
    _stampAndAnnounce(result, player, PCP_PuritySystem.randomBasePurityWithSkill(40, 60, player))
end

--- R2: Calcine Calcite + propane (DomeKiln, source 40-60)
function PCP_RecipeCallbacks.pcpCalcineCalcitePropanePurity(items, result, player)
    PCP_RecipeCallbacks.pcpReturnPartialPropane(items, result, player)
    if not PCP_PuritySystem.isEnabled() then return end
    _stampAndAnnounce(result, player, PCP_PuritySystem.randomBasePurityWithSkill(40, 60, player))
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

--- Bulk Refine Biodiesel (surface, propagation 0.95) + fuel penalty
--- Fluid input: WashedBiodiesel → output: 2× Petrol gas cans
function PCP_RecipeCallbacks.pcpRefineBiodieselBulkPurity(items, result, player)
    if not PCP_PuritySystem.isEnabled() then return end
    local input = PhobosLib.recoverDrainedFluidQuality(player, "PCP_Purity_WashedBiodiesel", PCP_PuritySystem.DEFAULT)
    local purity = PCP_PuritySystem.calculateOutputPurity(input, PCP_PuritySystem.EQUIP_FACTORS.metalDrum, player)
    _applyFluidFuelPenalty(player, "Petrol", purity, 2)
    PCP_PuritySystem.announcePurity(player, purity)
end


---------------------------------------------------------------
-- COOKING POT SOURCE CALLBACKS (3) — Lower purity for pot tier
---------------------------------------------------------------

--- Cooking pot oil extraction: 40-60
function PCP_RecipeCallbacks.pcpOilLabPotPurity(items, result, player)
    if not PCP_PuritySystem.isEnabled() then return end
    local purity = PCP_PuritySystem.randomBasePurityWithSkill(40, 60, player)
    PhobosLib.stampFluidContainerQuality(player, "CrudeVegetableOil", "PCP_Purity_CrudeVegetableOil", purity, 2)
    PCP_PuritySystem.announcePurity(player, purity)
end

--- Render fat (Cooking Pot): 30-50
function PCP_RecipeCallbacks.pcpRenderFatPotPurity(items, result, player)
    if not PCP_PuritySystem.isEnabled() then return end
    local purity = PCP_PuritySystem.randomBasePurityWithSkill(30, 50, player)
    PhobosLib.stampFluidContainerQuality(player, "RenderedFat", "PCP_Purity_RenderedFat", purity, 2)
    PCP_PuritySystem.announcePurity(player, purity)
end


---------------------------------------------------------------
-- COOKING POT PROPAGATION CALLBACKS (3) — Lower factor for pot tier
---------------------------------------------------------------

--- Purify charcoal water/NaOH (Cooking Pot): 60-80
--- SOURCE callback — no yield (Rule 1: yield requires stamped inputs).
function PCP_RecipeCallbacks.pcpPurifyCharcoalPotPurity(items, result, player)
    if not PCP_PuritySystem.isEnabled() then return end
    _stampAndAnnounce(result, player, PCP_PuritySystem.randomBasePurityWithSkill(60, 80, player))
end

--- Synthesize KNO3 fertilizer (Cooking Pot): 35-55
--- SOURCE callback — no yield (Rule 1: yield requires stamped inputs).
function PCP_RecipeCallbacks.pcpSynthesizeKNO3PotPurity(items, result, player)
    if not PCP_PuritySystem.isEnabled() then return end
    _stampAndAnnounce(result, player, PCP_PuritySystem.randomBasePurityWithSkill(35, 55, player))
end

--- Synthesize KNO3 compost (Cooking Pot): 30-50
--- SOURCE callback — no yield (Rule 1: yield requires stamped inputs).
function PCP_RecipeCallbacks.pcpSynthesizeKNO3CompostPotPurity(items, result, player)
    if not PCP_PuritySystem.isEnabled() then return end
    _stampAndAnnounce(result, player, PCP_PuritySystem.randomBasePurityWithSkill(30, 50, player))
end

--- Wash biodiesel (Cooking Pot, factor 0.90)
--- Fluid input: CrudeBiodiesel → output: 3× WashedBiodiesel
function PCP_RecipeCallbacks.pcpWashBiodieselPotPurity(items, result, player)
    if not PCP_PuritySystem.isEnabled() then return end
    local input = PhobosLib.recoverDrainedFluidQuality(player, "PCP_Purity_CrudeBiodiesel", PCP_PuritySystem.DEFAULT)
    local purity = PCP_PuritySystem.calculateOutputPurity(input, 0.90, player)
    PhobosLib.stampFluidContainerQuality(player, "WashedBiodiesel", "PCP_Purity_WashedBiodiesel", purity, 3)
    PCP_PuritySystem.announcePurity(player, purity)
end


---------------------------------------------------------------
-- AGRICULTURE & DOWNSTREAM CALLBACKS (4)
-- New pathways connecting PCP intermediates to vanilla systems.
---------------------------------------------------------------

--- A1: Grind BoneChar -> BoneMeal: propagation through mortar (factor 0.90).
--- Outputs: 4× BoneMeal
function PCP_RecipeCallbacks.pcpGrindBoneMealPurity(items, result, player)
    if not PCP_PuritySystem.isEnabled() then return end
    local input = PCP_PuritySystem.averageInputPurity(items)
    local purity = PCP_PuritySystem.calculateOutputPurity(input, PCP_PuritySystem.EQUIP_FACTORS.mortar, player)
    _stampAnnounceAndYield(result, player, purity)
end

--- B1: Activate Carbon (KOH process): propagation through chemistry set (factor 1.00).
--- Outputs: 4× ActivatedCarbon
function PCP_RecipeCallbacks.pcpActivateCarbonPurity(items, result, player)
    if not PCP_PuritySystem.isEnabled() then return end
    local input = PCP_PuritySystem.averageInputPurity(items)
    local purity = PCP_PuritySystem.calculateOutputPurity(input, PCP_PuritySystem.EQUIP_FACTORS.chemistrySet, player)
    _stampAnnounceAndYield(result, player, purity)
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

--- E1: Fire Starter Blocks -- vanilla output, no yield penalty (Rule 2).
--- Kept as callback stub for hazard wrappers and future extensions.
function PCP_RecipeCallbacks.pcpMakeFireStarterYield(items, result, player)
    -- Rule 2: purity does NOT affect yield when output is a final vanilla product.
end

--- E4: Duct Tape -- award Tailoring XP
function PCP_RecipeCallbacks.pcpMakeDuctTapeXP(items, result, player)
    if not player then return end
    PhobosLib.addXP(player, Perks.Tailoring, 3)
end

--- E5: Matchbox -- vanilla output, no yield penalty (Rule 2).
--- Kept as callback stub for hazard wrappers (Safe/Unsafe variants).
function PCP_RecipeCallbacks.pcpMakeMatchboxYield(items, result, player)
    -- Rule 2: purity does NOT affect yield when output is a final vanilla product.
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

--- F2: Chemical Tanning -- vanilla output, no yield penalty (Rule 2).
--- Kept as callback stub for future extensions.
function PCP_RecipeCallbacks.pcpChemicalTanningYield(items, result, player)
    -- Rule 2: purity does NOT affect yield when output is a final vanilla product.
end


---------------------------------------------------------------
-- CONCRETE MIXER CALLBACKS (7)
-- Source purity for bulk mixer operations. Lower ranges than
-- lab equivalents to reflect industrial-scale tradeoffs.
--
-- NOTE: PCP_Sandbox.getConcreteMixerYieldBonus() (default 1.25)
-- exists but is not wired here. Mixer recipes are SOURCE callbacks
-- (no stamped inputs), so Rule 1 yield does not apply. The bonus
-- would require a dedicated mechanism (e.g. purity range boost)
-- to be meaningful. See GitHub issue for future design work.
---------------------------------------------------------------

--- Mixer construction items (mortar, stucco, reinforced concrete, fireclay): 60-85
function PCP_RecipeCallbacks.pcpMixerConstructionPurity(items, result, player)
    if not PCP_PuritySystem.isEnabled() then return end
    _stampAndAnnounce(result, player, PCP_PuritySystem.randomBasePurityWithSkill(60, 85, player))
end

--- Mixer blackpowder (bulk): 25-45 (lower than lab 50-70)
--- NOTE: Output is Base.GunPowder (vanilla), so _stampAndAnnounce is a no-op.
--- Purity stamp is cosmetic only (speech bubble).
function PCP_RecipeCallbacks.pcpMixerBlackpowderPurity(items, result, player)
    if not PCP_PuritySystem.isEnabled() then return end
    _stampAndAnnounce(result, player, PCP_PuritySystem.randomBasePurityWithSkill(25, 45, player))
end

--- Mixer biodiesel (bulk): 35-55 (lower than lab)
--- Fluid outputs: 1× CrudeBiodiesel (bucket) + 1× Glycerol
function PCP_RecipeCallbacks.pcpMixerBiodieselPurity(items, result, player)
    if not PCP_PuritySystem.isEnabled() then return end
    local purity = PCP_PuritySystem.randomBasePurityWithSkill(35, 55, player)
    PhobosLib.stampFluidContainerQuality(player, "CrudeBiodiesel", "PCP_Purity_CrudeBiodiesel", purity, 1)
    PhobosLib.stampFluidContainerQuality(player, "Glycerol", "PCP_Purity_Glycerol", purity, 1)
    PCP_PuritySystem.announcePurity(player, purity)
end

--- Mixer soap (bulk): 40-60 (lower than lab)
function PCP_RecipeCallbacks.pcpMixerSoapPurity(items, result, player)
    if not PCP_PuritySystem.isEnabled() then return end
    _stampAndAnnounce(result, player, PCP_PuritySystem.randomBasePurityWithSkill(40, 60, player))
end

--- Mixer compost (bulk): 30-50
function PCP_RecipeCallbacks.pcpMixerCompostPurity(items, result, player)
    if not PCP_PuritySystem.isEnabled() then return end
    _stampAndAnnounce(result, player, PCP_PuritySystem.randomBasePurityWithSkill(30, 50, player))
end

--- Mixer wood vinegar: 30-50
function PCP_RecipeCallbacks.pcpMixerVinegarPurity(items, result, player)
    if not PCP_PuritySystem.isEnabled() then return end
    _stampAndAnnounce(result, player, PCP_PuritySystem.randomBasePurityWithSkill(30, 50, player))
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
    local purity = PCP_PuritySystem.calculateOutputPurity(input, 0.95, player)
    _stampAndAnnounce(result, player, purity)
end

--- Crystallize salt: propagation + yield (input BrineConcentrate, factor 0.95)
--- Base output 2 CoarseSalt; low purity may reduce to 1.
function PCP_RecipeCallbacks.pcpCrystallizeSaltPurity(items, result, player)
    if not PCP_PuritySystem.isEnabled() then return end
    local input = PCP_PuritySystem.averageInputPurity(items)
    local purity = PCP_PuritySystem.calculateOutputPurity(input, 0.95, player)
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
