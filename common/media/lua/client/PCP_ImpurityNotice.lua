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
-- PCP_ImpurityNotice.lua
-- One-time notice popup: explains the EnableImpuritySystem
-- default change to existing users.
-- Shows only to admins on servers.
-- All user-facing text pulled from IG_UI_EN.txt via getText().
--
-- Requires: PhobosLib >= 1.16.0 (registerNoticePopup, isPlayerAdmin)
---------------------------------------------------------------

require "PhobosLib"

local CHANGE_KEY = "PCP_impurity_default_changed"

--- Only show if the server-side migration actually changed the setting,
--- and the current player is an admin (SP always, MP admin only).
---@param player any  IsoPlayer
---@return boolean
local function shouldShow(player)
    local worldMD = nil
    PhobosLib.safecall(function() worldMD = getGameTime():getModData() end)
    if not worldMD or not worldMD[CHANGE_KEY] then return false end

    return PhobosLib.isPlayerAdmin(player)
end

--- Build rich-text content for the notice popup.
--- Called at display time — getText() is safe here.
---@return string  Rich text
local function buildContent()
    local t = ""

    -- Header
    t = t .. "<H1> <CENTRE> " .. getText("IGUI_PCP_Notice_Impurity_Header") .. " <LINE> "
    t = t .. "<CENTRE> <SIZE:small> <RGB:0.6,0.6,0.6> "
    t = t .. getText("IGUI_PCP_Notice_Impurity_Subtitle") .. " <LINE> <LINE> "

    -- What changed
    t = t .. "<LEFT> <SIZE:medium> <RGB:1.0,0.85,0.3> "
    t = t .. getText("IGUI_PCP_Notice_Impurity_WhatChangedTitle") .. " <LINE> "
    t = t .. "<SIZE:small> <RGB:0.9,0.9,0.9> "
    t = t .. getText("IGUI_PCP_Notice_Impurity_WhatChangedBody") .. " <LINE> <LINE> "

    -- What it does
    t = t .. "<SIZE:medium> <RGB:1.0,0.85,0.3> "
    t = t .. getText("IGUI_PCP_Notice_Impurity_WhatPurityTitle") .. " <LINE> "
    t = t .. "<SIZE:small> <RGB:0.9,0.9,0.9> "
    t = t .. getText("IGUI_PCP_Notice_Impurity_WhatPurityBody1") .. " <LINE> <LINE> "
    t = t .. "<RGB:0.85,0.85,0.85> "
    t = t .. getText("IGUI_PCP_Notice_Impurity_WhatPurityBody2") .. " <LINE> <LINE> "

    -- Why
    t = t .. "<SIZE:medium> <RGB:1.0,0.85,0.3> "
    t = t .. getText("IGUI_PCP_Notice_Impurity_WhyTitle") .. " <LINE> "
    t = t .. "<SIZE:small> <RGB:0.9,0.9,0.9> "
    t = t .. getText("IGUI_PCP_Notice_Impurity_WhyBody") .. " <LINE> <LINE> "

    -- New setting highlight
    t = t .. "<SIZE:medium> <RGB:0.5,0.85,1.0> "
    t = t .. getText("IGUI_PCP_Notice_Impurity_SkillTitle") .. " <LINE> "
    t = t .. "<SIZE:small> <RGB:0.9,0.9,0.9> "
    t = t .. getText("IGUI_PCP_Notice_Impurity_SkillBody") .. " <LINE> <LINE> "

    -- How to revert
    t = t .. "<SIZE:medium> <RGB:0.7,0.7,0.7> "
    t = t .. getText("IGUI_PCP_Notice_Impurity_RevertTitle") .. " <LINE> "
    t = t .. "<SIZE:small> <RGB:0.7,0.7,0.7> "
    t = t .. getText("IGUI_PCP_Notice_Impurity_RevertBody") .. " <LINE> <LINE> "

    return t
end

-- Register with PhobosLib notice popup system
PhobosLib.registerNoticePopup("PCP", "impurity_enabled", {
    series            = "PIP",
    seriesDisplayName = "Phobos' Industrial Pathways",
    seriesLabel       = "Biomass",
    title             = "Phobos' Industrial Pathways: Biomass  \226\128\148  Settings Update",
    buildContent      = buildContent,
    shouldShow        = shouldShow,
    width             = 560,
    height            = 540,
})

print("[PCP] ImpurityNotice: registered [client]")
