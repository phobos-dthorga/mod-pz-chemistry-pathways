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

---------------------------------------------------------------
-- PCP_CallbackHelpers.lua
-- Shared helpers for PCP recipe OnCreate callbacks.
--
-- Provides stamp-and-announce routines used by all callback
-- modules (RecipeCallbacks, BotanicalCallbacks, Horticulture).
-- Placed in shared/ so both server and client can require it.
--
-- Requires: PhobosLib, PCP_PuritySystem, PCP_Constants
---------------------------------------------------------------

require "PhobosLib"
require "PCP_PuritySystem"
require "PCP_Constants"

PCP_CallbackHelpers = {}

local _TAG = "[PCP:CallbackHelpers]"
local function _debug(msg) PhobosLib.debug("PCP", _TAG, msg) end

--- Stamp purity on result + all same-type outputs, then announce.
--- Silently no-ops for non-PCP items (vanilla items don't support condition-as-purity).
---@param result any       The output item from OnCreate
---@param player any       IsoPlayer
---@param purity number    Purity value (0-100)
function PCP_CallbackHelpers.stampAndAnnounce(result, player, purity)
    if not result then return end
    local ok, ft = pcall(result.getFullType, result)
    if not ok or not ft or not string.find(ft, PCP_Constants.MOD_PREFIX, 1, true) then return end
    _debug("stampAndAnnounce: " .. tostring(ft) .. " purity=" .. tostring(purity))
    PCP_PuritySystem.setPurity(result, purity)
    PCP_PuritySystem.stampOutputs(player, ft, purity)
    PCP_PuritySystem.announcePurity(player, purity)
end

--- Stamp purity on result + all same-type outputs, announce, then apply yield.
--- Counts unstamped items BEFORE stamping to get accurate recipe output count.
--- Used by PROPAGATION callbacks producing multi-output PCP items (Rule 1).
---@param result any       The output item from OnCreate
---@param player any       IsoPlayer
---@param purity number    Purity value (0-100)
function PCP_CallbackHelpers.stampAnnounceAndYield(result, player, purity)
    if not result then return end
    local ok, ft = pcall(result.getFullType, result)
    if not ok or not ft or not string.find(ft, PCP_Constants.MOD_PREFIX, 1, true) then return end
    local baseCount = PCP_PuritySystem.countUnstampedOutputs(player, ft)
    _debug("stampAnnounceAndYield: " .. tostring(ft) .. " purity=" .. tostring(purity) .. " baseCount=" .. tostring(baseCount))
    PCP_PuritySystem.setPurity(result, purity)
    PCP_PuritySystem.stampOutputs(player, ft, purity)
    PCP_PuritySystem.announcePurity(player, purity)
    PCP_PuritySystem.applyYieldIfMultiOutput(player, ft, baseCount, purity)
end
