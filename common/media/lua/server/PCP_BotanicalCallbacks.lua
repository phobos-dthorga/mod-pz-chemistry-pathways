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
    PCP_BotanicalCallbacks.lua — OnCreate callbacks for the Botanical Chemistry Pathway

    Purity callbacks for hemp processing recipes: retting, fiber extraction,
    textile production, paper-making, medicinal extracts, hempcrete,
    cross-pathway integrations (charcoal, compost, tar treatment), and
    hemp expansion (scutching, oil pressing, loom weaving, oakum).

    Requires: PhobosLib, PCP_PuritySystem
]]

require "PhobosLib"
require "PCP_PuritySystem"
require "PCP_CallbackHelpers"

PCP_BotanicalCallbacks = {}


---------------------------------------------------------------
-- Shared Helpers (from PCP_CallbackHelpers.lua)
---------------------------------------------------------------

local _stampAndAnnounce = PCP_CallbackHelpers.stampAndAnnounce
local _stampAnnounceAndYield = PCP_CallbackHelpers.stampAnnounceAndYield


---------------------------------------------------------------
-- SOURCE CALLBACKS (7) — Assign base purity, no input tracking
---------------------------------------------------------------

--- Spin hemp twine (Field tier, hand-spinning): 40-60
function PCP_BotanicalCallbacks.pcpSpinHempTwinePurity(items, result, player)
    if not PCP_PuritySystem.isEnabled() then return end
    _stampAndAnnounce(result, player, PCP_PuritySystem.randomBasePurityWithSkill(40, 60, player))
end

--- Char hemp hurds (Field tier, pyrolysis): 35-55
--- Output is CrushedCharcoal — same range as pcpCrushCharcoalPurity
--- Propane heat source: return partial propane tank before purity stamp.
function PCP_BotanicalCallbacks.pcpCharHempHurdsPurity(items, result, player)
    PCP_RecipeCallbacks.pcpReturnPartialPropane(items, result, player)
    if not PCP_PuritySystem.isEnabled() then return end
    _stampAndAnnounce(result, player, PCP_PuritySystem.randomBasePurityWithSkill(35, 55, player))
end

--- Chemical retting (Kitchen tier, KOH/NaOH soak): 50-70
function PCP_BotanicalCallbacks.pcpRetHempPurity(items, result, player)
    if not PCP_PuritySystem.isEnabled() then return end
    _stampAndAnnounce(result, player, PCP_PuritySystem.randomBasePurityWithSkill(50, 70, player))
end

--- Prepare hemp poultice (Kitchen tier, medicinal): 45-65
function PCP_BotanicalCallbacks.pcpPrepareHempPoulticePurity(items, result, player)
    if not PCP_PuritySystem.isEnabled() then return end
    _stampAndAnnounce(result, player, PCP_PuritySystem.randomBasePurityWithSkill(45, 65, player))
end

--- Boil hemp pulp (Kitchen tier, crude pulping): 50-70
function PCP_BotanicalCallbacks.pcpBoilHempPulpPurity(items, result, player)
    if not PCP_PuritySystem.isEnabled() then return end
    _stampAndAnnounce(result, player, PCP_PuritySystem.randomBasePurityWithSkill(50, 70, player))
end

--- Mix hempcrete (Mixer, construction): 60-85
--- Same range as pcpMixerConstructionPurity
function PCP_BotanicalCallbacks.pcpMixHempcretePurity(items, result, player)
    if not PCP_PuritySystem.isEnabled() then return end
    _stampAndAnnounce(result, player, PCP_PuritySystem.randomBasePurityWithSkill(60, 85, player))
end

--- Mix reinforced hempcrete (Mixer, construction, reinforced): 65-90
--- Slightly higher range than regular hempcrete (60-85) due to
--- structural reinforcement from tarred rope
function PCP_BotanicalCallbacks.pcpMixReinforcedHempcretePurity(items, result, player)
    if not PCP_PuritySystem.isEnabled() then return end
    _stampAndAnnounce(result, player, PCP_PuritySystem.randomBasePurityWithSkill(65, 90, player))
end


---------------------------------------------------------------
-- PROPAGATION CALLBACKS (7+3) — Read input purity, apply factor
---------------------------------------------------------------

--- Braid hemp rope from twine (factor 0.95)
function PCP_BotanicalCallbacks.pcpBraidHempRopePurity(items, result, player)
    if not PCP_PuritySystem.isEnabled() then return end
    local input = PCP_PuritySystem.averageInputPurity(items)
    local purity = PCP_PuritySystem.calculateOutputPurity(input, 0.95, player)
    _stampAndAnnounce(result, player, purity)
end

--- Extract bast fiber from retted stalk (factor 0.95)
--- Dual output: 2-3× HempBastFiber (result) + HempHurd (secondary)
function PCP_BotanicalCallbacks.pcpExtractBastFiberPurity(items, result, player)
    if not PCP_PuritySystem.isEnabled() then return end
    local input = PCP_PuritySystem.averageInputPurity(items)
    local purity = PCP_PuritySystem.calculateOutputPurity(input, 0.95, player)
    _stampAnnounceAndYield(result, player, purity)
    -- Also stamp + yield secondary output (HempHurd)
    local hurdType = "PhobosChemistryPathways.HempHurd"
    local hurdCount = PCP_PuritySystem.countUnstampedOutputs(player, hurdType)
    PCP_PuritySystem.stampOutputs(player, hurdType, purity)
    PCP_PuritySystem.applyYieldIfMultiOutput(player, hurdType, hurdCount, purity)
end

--- Weave hemp cloth from fiber (factor 0.90, hand-weaving degradation)
function PCP_BotanicalCallbacks.pcpWeaveHempClothPurity(items, result, player)
    if not PCP_PuritySystem.isEnabled() then return end
    local input = PCP_PuritySystem.averageInputPurity(items)
    local purity = PCP_PuritySystem.calculateOutputPurity(input, PCP_PuritySystem.EQUIP_FACTORS.mortar, player)
    _stampAndAnnounce(result, player, purity)
end

--- Make hemp canvas from cloth (factor 0.95)
function PCP_BotanicalCallbacks.pcpMakeHempCanvasPurity(items, result, player)
    if not PCP_PuritySystem.isEnabled() then return end
    local input = PCP_PuritySystem.averageInputPurity(items)
    local purity = PCP_PuritySystem.calculateOutputPurity(input, 0.95, player)
    _stampAndAnnounce(result, player, purity)
end

--- Chemical pulping with NaOH (Lab tier, chemistry set factor 1.00)
--- Outputs: 3× HempPulp
function PCP_BotanicalCallbacks.pcpChemicalPulpingPurity(items, result, player)
    if not PCP_PuritySystem.isEnabled() then return end
    local input = PCP_PuritySystem.averageInputPurity(items)
    local purity = PCP_PuritySystem.calculateOutputPurity(input, PCP_PuritySystem.EQUIP_FACTORS.chemistrySet, player)
    _stampAnnounceAndYield(result, player, purity)
end

--- Press hemp paper from pulp (factor 0.95)
--- Outputs: 3× HempPaper
function PCP_BotanicalCallbacks.pcpPressHempPaperPurity(items, result, player)
    if not PCP_PuritySystem.isEnabled() then return end
    local input = PCP_PuritySystem.averageInputPurity(items)
    local purity = PCP_PuritySystem.calculateOutputPurity(input, 0.95, player)
    _stampAnnounceAndYield(result, player, purity)
end

--- Prepare hemp tincture with alcohol (Lab tier, chemistry set factor 1.00)
function PCP_BotanicalCallbacks.pcpPrepareHempTincturePurity(items, result, player)
    if not PCP_PuritySystem.isEnabled() then return end
    local input = PCP_PuritySystem.averageInputPurity(items)
    local purity = PCP_PuritySystem.calculateOutputPurity(input, PCP_PuritySystem.EQUIP_FACTORS.chemistrySet, player)
    _stampAndAnnounce(result, player, purity)
end


---------------------------------------------------------------
-- CROSS-PATHWAY CALLBACKS (2) — Botanical-to-existing links
---------------------------------------------------------------

--- Tar hemp rope — propagation from rope + tar inputs (factor 0.95)
function PCP_BotanicalCallbacks.pcpTarHempRopePurity(items, result, player)
    if not PCP_PuritySystem.isEnabled() then return end
    local input = PCP_PuritySystem.averageInputPurity(items)
    local purity = PCP_PuritySystem.calculateOutputPurity(input, 0.95, player)
    _stampAndAnnounce(result, player, purity)
end

--- Compost hemp hurds — source 30-50 (same range as mixer compost)
function PCP_BotanicalCallbacks.pcpCompostHempHurdsPurity(items, result, player)
    if not PCP_PuritySystem.isEnabled() then return end
    _stampAndAnnounce(result, player, PCP_PuritySystem.randomBasePurityWithSkill(30, 50, player))
end


---------------------------------------------------------------
-- HEMP EXPANSION — SOURCE CALLBACKS (3)
---------------------------------------------------------------

--- Scutch hemp fiber (Scutching Board, mechanical): 30-50
function PCP_BotanicalCallbacks.pcpScutchHempFiberPurity(items, result, player)
    if not PCP_PuritySystem.isEnabled() then return end
    _stampAndAnnounce(result, player, PCP_PuritySystem.randomBasePurityWithSkill(30, 50, player))
end

--- Press oil Hand Press (station, Farming tier): 45-65
function PCP_BotanicalCallbacks.pcpPressOilHandPressPurity(items, result, player)
    if not PCP_PuritySystem.isEnabled() then return end
    _stampAndAnnounce(result, player, PCP_PuritySystem.randomBasePurityWithSkill(45, 65, player))
end

--- Compost seed cake (Field tier): 40-60
function PCP_BotanicalCallbacks.pcpCompostSeedCakePurity(items, result, player)
    if not PCP_PuritySystem.isEnabled() then return end
    _stampAndAnnounce(result, player, PCP_PuritySystem.randomBasePurityWithSkill(40, 60, player))
end


---------------------------------------------------------------
-- HEMP EXPANSION — PROPAGATION CALLBACKS (3)
---------------------------------------------------------------

--- Weave hemp cloth on loom (factor 1.05, station bonus): input-averaged
function PCP_BotanicalCallbacks.pcpWeaveHempClothLoomPurity(items, result, player)
    if not PCP_PuritySystem.isEnabled() then return end
    local input = PCP_PuritySystem.averageInputPurity(items)
    local purity = PCP_PuritySystem.calculateOutputPurity(input, 1.05, player)
    _stampAndAnnounce(result, player, purity)
end

--- Weave hemp canvas on loom (factor 1.05, station bonus): input-averaged
function PCP_BotanicalCallbacks.pcpWeaveHempCanvasLoomPurity(items, result, player)
    if not PCP_PuritySystem.isEnabled() then return end
    local input = PCP_PuritySystem.averageInputPurity(items)
    local purity = PCP_PuritySystem.calculateOutputPurity(input, 1.05, player)
    _stampAndAnnounce(result, player, purity)
end

--- Make oakum (tar treatment): input-averaged
--- Outputs: 3× Oakum
function PCP_BotanicalCallbacks.pcpMakeOakumPurity(items, result, player)
    if not PCP_PuritySystem.isEnabled() then return end
    local input = PCP_PuritySystem.averageInputPurity(items)
    local purity = PCP_PuritySystem.calculateOutputPurity(input, 0.95, player)
    _stampAnnounceAndYield(result, player, purity)
end


---------------------------------------------------------------
-- HAZARD WRAPPER CALLBACKS (4) — Safe/Unsafe for caustic retting
-- Uses PCP_HazardSystem public wrappers (promoted from local helpers).
-- Retting (KOH/NaOH) and chemical pulping produce caustic fumes.
---------------------------------------------------------------

require "PCP_HazardSystem"

--- Chemical retting (KOH or NaOH) — Safe (filter degrade)
function PCP_BotanicalCallbacks.pcpRetHempSafePurity(items, result, player)
    PCP_HazardSystem.safeWrapper(PCP_BotanicalCallbacks.pcpRetHempPurity, items, result, player)
end

--- Chemical retting (KOH or NaOH) — Unsafe (caustic_vapor)
function PCP_BotanicalCallbacks.pcpRetHempUnsafePurity(items, result, player)
    PCP_HazardSystem.unsafeWrapper(PCP_BotanicalCallbacks.pcpRetHempPurity, "caustic_vapor", items, result, player)
end

--- Chemical pulping (NaOH) — Safe (filter degrade)
function PCP_BotanicalCallbacks.pcpChemicalPulpingSafePurity(items, result, player)
    PCP_HazardSystem.safeWrapper(PCP_BotanicalCallbacks.pcpChemicalPulpingPurity, items, result, player)
end

--- Chemical pulping (NaOH) — Unsafe (caustic_vapor)
function PCP_BotanicalCallbacks.pcpChemicalPulpingUnsafePurity(items, result, player)
    PCP_HazardSystem.unsafeWrapper(PCP_BotanicalCallbacks.pcpChemicalPulpingPurity, "caustic_vapor", items, result, player)
end


---------------------------------------------------------------
-- LIGHT-HAZARD WRAPPER CALLBACKS (6) — Safe/Unsafe for smoke & dust
-- Uses PCP_HazardSystem light wrappers for mechanical hazards.
-- Charring produces smoke; hempcrete mixing produces mineral dust.
---------------------------------------------------------------

--- Char hemp hurds — Safe (light filter degrade)
function PCP_BotanicalCallbacks.pcpCharHempHurdsSafePurity(items, result, player)
    PCP_HazardSystem.lightSafeWrapper(PCP_BotanicalCallbacks.pcpCharHempHurdsPurity, items, result, player)
end

--- Char hemp hurds — Unsafe (smoke_inhalation)
function PCP_BotanicalCallbacks.pcpCharHempHurdsUnsafePurity(items, result, player)
    PCP_HazardSystem.lightUnsafeWrapper(PCP_BotanicalCallbacks.pcpCharHempHurdsPurity, "smoke_inhalation", items, result, player)
end

--- Mix hempcrete — Safe (light filter degrade)
function PCP_BotanicalCallbacks.pcpMixHempcreteSafePurity(items, result, player)
    PCP_HazardSystem.lightSafeWrapper(PCP_BotanicalCallbacks.pcpMixHempcretePurity, items, result, player)
end

--- Mix hempcrete — Unsafe (mineral_dust)
function PCP_BotanicalCallbacks.pcpMixHempcreteUnsafePurity(items, result, player)
    PCP_HazardSystem.lightUnsafeWrapper(PCP_BotanicalCallbacks.pcpMixHempcretePurity, "mineral_dust", items, result, player)
end

--- Mix reinforced hempcrete — Safe (light filter degrade)
function PCP_BotanicalCallbacks.pcpMixReinforcedHempcreteSafePurity(items, result, player)
    PCP_HazardSystem.lightSafeWrapper(PCP_BotanicalCallbacks.pcpMixReinforcedHempcretePurity, items, result, player)
end

--- Mix reinforced hempcrete — Unsafe (mineral_dust)
function PCP_BotanicalCallbacks.pcpMixReinforcedHempcreteUnsafePurity(items, result, player)
    PCP_HazardSystem.lightUnsafeWrapper(PCP_BotanicalCallbacks.pcpMixReinforcedHempcretePurity, "mineral_dust", items, result, player)
end
