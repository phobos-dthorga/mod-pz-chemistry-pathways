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
-- PCP_PurityRebalanceNotice.lua
-- One-time notice popup: informs players about the v1.11.0
-- purity & yield system overhaul.
-- Shows once per world, to all players.
--
-- Requires: PhobosLib >= 1.16.0 (registerNoticePopup)
---------------------------------------------------------------

require "PhobosLib"

--- Always show once (the PhobosLib notice system handles the
--- "already dismissed" guard via world modData).
---@param player any  IsoPlayer
---@return boolean
local function shouldShow(player)
    return true
end

--- Build rich-text content for the notice popup.
---@return string  Rich text
local function buildContent()
    local t = ""

    -- Header
    t = t .. "<H1> <CENTRE> " .. getText("IGUI_PCP_Notice_PurityV2_Header") .. " <LINE> "
    t = t .. "<CENTRE> <SIZE:small> <RGB:0.6,0.6,0.6> "
    t = t .. getText("IGUI_PCP_Notice_PurityV2_Subtitle") .. " <LINE> <LINE> "

    -- Skill influence
    t = t .. "<LEFT> <SIZE:medium> <RGB:1.0,0.85,0.3> "
    t = t .. getText("IGUI_PCP_Notice_PurityV2_SkillTitle") .. " <LINE> "
    t = t .. "<SIZE:small> <RGB:0.9,0.9,0.9> "
    t = t .. getText("IGUI_PCP_Notice_PurityV2_SkillBody") .. " <LINE> <LINE> "

    -- Yield
    t = t .. "<SIZE:medium> <RGB:1.0,0.85,0.3> "
    t = t .. getText("IGUI_PCP_Notice_PurityV2_YieldTitle") .. " <LINE> "
    t = t .. "<SIZE:small> <RGB:0.9,0.9,0.9> "
    t = t .. getText("IGUI_PCP_Notice_PurityV2_YieldBody") .. " <LINE> <LINE> "

    -- Variance
    t = t .. "<SIZE:medium> <RGB:1.0,0.85,0.3> "
    t = t .. getText("IGUI_PCP_Notice_PurityV2_VarianceTitle") .. " <LINE> "
    t = t .. "<SIZE:small> <RGB:0.9,0.9,0.9> "
    t = t .. getText("IGUI_PCP_Notice_PurityV2_VarianceBody") .. " <LINE> <LINE> "

    -- Summary
    t = t .. "<SIZE:medium> <RGB:0.5,0.85,1.0> "
    t = t .. getText("IGUI_PCP_Notice_PurityV2_SummaryTitle") .. " <LINE> "
    t = t .. "<SIZE:small> <RGB:0.9,0.9,0.9> "
    t = t .. getText("IGUI_PCP_Notice_PurityV2_SummaryBody") .. " <LINE> <LINE> "

    return t
end

-- Register with PhobosLib notice popup system
PhobosLib.registerNoticePopup("PCP", "purity_v2_rebalance", {
    series            = "PIP",
    seriesDisplayName = "Phobos' Industrial Pathways",
    seriesLabel       = "Biomass",
    title             = "Phobos' Industrial Pathways: Biomass  \226\128\148  Purity Rebalance",
    buildContent      = buildContent,
    shouldShow        = shouldShow,
    width             = 560,
    height            = 480,
})

print("[PCP] PurityRebalanceNotice: registered [client]")
