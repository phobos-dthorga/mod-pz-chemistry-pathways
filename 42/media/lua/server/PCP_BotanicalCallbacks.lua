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
    textile production, paper-making, medicinal extracts, hempcrete, and
    cross-pathway integrations (charcoal, compost, tar treatment).

    Requires: PhobosLib, PCP_PuritySystem
]]

require "PhobosLib"
require "PCP_PuritySystem"

PCP_BotanicalCallbacks = {}


---------------------------------------------------------------
-- Internal Helpers (duplicated from PCP_RecipeCallbacks.lua)
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


---------------------------------------------------------------
-- SOURCE CALLBACKS (5) — Assign base purity, no input tracking
---------------------------------------------------------------

--- Spin hemp twine (Field tier, hand-spinning): 40-60
function PCP_BotanicalCallbacks.pcpSpinHempTwinePurity(items, result, player)
    if not PCP_PuritySystem.isEnabled() then return end
    _stampAndAnnounce(result, player, PCP_PuritySystem.randomBasePurityWithSkill(40, 60, player))
end

--- Char hemp hurds (Field tier, pyrolysis): 35-55
--- Output is CrushedCharcoal — same range as pcpCrushCharcoalPurity
function PCP_BotanicalCallbacks.pcpCharHempHurdsPurity(items, result, player)
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
-- PROPAGATION CALLBACKS (7) — Read input purity, apply factor
---------------------------------------------------------------

--- Braid hemp rope from twine (factor 0.95)
function PCP_BotanicalCallbacks.pcpBraidHempRopePurity(items, result, player)
    if not PCP_PuritySystem.isEnabled() then return end
    local input = PCP_PuritySystem.averageInputPurity(items)
    local purity = PCP_PuritySystem.calculateOutputPurity(input, 0.95, player)
    _stampAndAnnounce(result, player, purity)
end

--- Extract bast fiber from retted stalk (factor 0.95)
--- Dual output: HempBastFiber (result) + HempHurd (secondary)
function PCP_BotanicalCallbacks.pcpExtractBastFiberPurity(items, result, player)
    if not PCP_PuritySystem.isEnabled() then return end
    local input = PCP_PuritySystem.averageInputPurity(items)
    local purity = PCP_PuritySystem.calculateOutputPurity(input, 0.95, player)
    _stampAndAnnounce(result, player, purity)
    -- Also stamp secondary output (HempHurd)
    PCP_PuritySystem.stampOutputs(player, "PhobosChemistryPathways.HempHurd", purity)
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
function PCP_BotanicalCallbacks.pcpChemicalPulpingPurity(items, result, player)
    if not PCP_PuritySystem.isEnabled() then return end
    local input = PCP_PuritySystem.averageInputPurity(items)
    local purity = PCP_PuritySystem.calculateOutputPurity(input, PCP_PuritySystem.EQUIP_FACTORS.chemistrySet, player)
    _stampAndAnnounce(result, player, purity)
end

--- Press hemp paper from pulp (factor 0.95)
function PCP_BotanicalCallbacks.pcpPressHempPaperPurity(items, result, player)
    if not PCP_PuritySystem.isEnabled() then return end
    local input = PCP_PuritySystem.averageInputPurity(items)
    local purity = PCP_PuritySystem.calculateOutputPurity(input, 0.95, player)
    _stampAndAnnounce(result, player, purity)
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
