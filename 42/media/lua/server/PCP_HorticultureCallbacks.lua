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
    PCP_HorticultureCallbacks.lua — OnCreate callbacks for the Horticulture Pathway

    Purity callbacks for horticulture papermaking recipes. Most horticulture
    recipes are simple assembly (tobacco packing, bud canning, pipe loading,
    rolling) and do not track purity.

    Only the papermaking chain tracks purity:
      - FormWetPaperSheet: source (55–75), cooked pulp → wet sheet
      - PressPaperSheet:   propagation (×0.95), wet sheet → finished paper

    Requires: PhobosLib, PCP_PuritySystem
]]

require "PhobosLib"
require "PCP_PuritySystem"

PCP_HorticultureCallbacks = {}


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
-- SOURCE CALLBACKS — Assign base purity, no input tracking
---------------------------------------------------------------

--- Form wet paper sheet (Kitchen tier): 55–75
--- Source callback because purity is lost in the cooking step
--- (PaperPulpPot is a food item without ConditionMax tracking).
function PCP_HorticultureCallbacks.pcpFormWetPaperSheetPurity(items, result, player)
    if not PCP_PuritySystem.isEnabled() then return end
    _stampAndAnnounce(result, player, PCP_PuritySystem.randomBasePurityWithSkill(55, 75, player))
end


---------------------------------------------------------------
-- PROPAGATION CALLBACKS — Average input purity, apply factor
---------------------------------------------------------------

--- Press paper sheet: propagate from MouldAndDecklePaperSheet (×0.95)
function PCP_HorticultureCallbacks.pcpPressPaperSheetPurity(items, result, player)
    if not PCP_PuritySystem.isEnabled() then return end
    local avgPurity = PCP_PuritySystem.averageStampedQuality(items)
    local finalPurity = PCP_PuritySystem.calculateOutputQuality(avgPurity, 0.95, player)
    _stampAndAnnounce(result, player, finalPurity)
end
