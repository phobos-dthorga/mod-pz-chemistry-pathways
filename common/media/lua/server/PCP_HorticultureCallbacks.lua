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
require "PCP_CallbackHelpers"

PCP_HorticultureCallbacks = {}

local _TAG = "[PCP:Horticulture]"
local function _debug(msg) PhobosLib.debug("PCP", _TAG, msg) end


---------------------------------------------------------------
-- Shared Helpers (from PCP_CallbackHelpers.lua)
---------------------------------------------------------------

local _stampAndAnnounce = PCP_CallbackHelpers.stampAndAnnounce
local _stampAnnounceAndYield = PCP_CallbackHelpers.stampAnnounceAndYield


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
--- Outputs: 2× HempPaper
function PCP_HorticultureCallbacks.pcpPressPaperSheetPurity(items, result, player)
    if not PCP_PuritySystem.isEnabled() then return end
    local avgPurity = PCP_PuritySystem.averageInputPurity(items)
    local finalPurity = PCP_PuritySystem.calculateOutputPurity(avgPurity, 0.95, player)
    _stampAnnounceAndYield(result, player, finalPurity)
end


---------------------------------------------------------------
-- FERMENTATION CALLBACKS — Stamp creation date for progress UI
---------------------------------------------------------------

--- Stamp the game date on canned hemp buds for fermentation tracking.
function PCP_HorticultureCallbacks.pcpStampFermentDate(items, result, player)
    PhobosLib.stampFermentationDate(result)
end
