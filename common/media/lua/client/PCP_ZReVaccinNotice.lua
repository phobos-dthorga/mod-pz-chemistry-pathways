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
-- PCP_ZReVaccinNotice.lua
-- Client-side notice popup and server command listeners for
-- the zReVaccin → ZVV comprehensive migration.
--
-- 1. Notice popup: advises players to pick up placed zReVaccin
--    workstations before unsubscribing.
-- 2. Server command listener: shows halo text when the
--    antibodies trait is removed.
--
-- Requires: PhobosLib >= 1.28.0
---------------------------------------------------------------

require "PhobosLib"

---------------------------------------------------------------
-- Notice Popup — workstation pickup advisory
---------------------------------------------------------------

--- Show the notice when zReVaccin is still active (players
--- haven't unsubscribed yet) and the player is an admin.
---@param player any  IsoPlayer
---@return boolean
local function shouldShow(player)
    -- Only show if zReVaccin is currently loaded
    local zreActive = false
    pcall(function()
        zreActive = getActivatedMods():contains("zReModVaccin30bykERHUS")
    end)
    if not zreActive then return false end

    return PhobosLib.isPlayerAdmin(player)
end

--- Build rich-text content for the notice popup.
---@return string
local function buildContent()
    local t = ""

    -- Header
    t = t .. "<H1> <CENTRE> "
    t = t .. getText("IGUI_PCP_ZReVac_Notice_Header") .. " <LINE> "
    t = t .. "<CENTRE> <SIZE:small> <RGB:0.6,0.6,0.6> "
    t = t .. getText("IGUI_PCP_ZReVac_Notice_Subtitle") .. " <LINE> <LINE> "

    -- Workstation warning (prominent)
    t = t .. "<LEFT> <SIZE:medium> <RGB:1.0,0.4,0.4> "
    t = t .. getText("IGUI_PCP_ZReVac_Notice_WorkstationTitle") .. " <LINE> "
    t = t .. "<SIZE:small> <RGB:0.9,0.9,0.9> "
    t = t .. getText("IGUI_PCP_ZReVac_Notice_WorkstationBody") .. " <LINE> <LINE> "

    -- How to migrate
    t = t .. "<SIZE:medium> <RGB:1.0,0.85,0.3> "
    t = t .. getText("IGUI_PCP_ZReVac_Notice_HowToTitle") .. " <LINE> "
    t = t .. "<SIZE:small> <RGB:0.9,0.9,0.9> "
    t = t .. getText("IGUI_PCP_ZReVac_Notice_HowToBody") .. " <LINE> <LINE> "

    -- What gets migrated
    t = t .. "<SIZE:medium> <RGB:0.5,0.85,1.0> "
    t = t .. getText("IGUI_PCP_ZReVac_Notice_ScopeTitle") .. " <LINE> "
    t = t .. "<SIZE:small> <RGB:0.9,0.9,0.9> "
    t = t .. getText("IGUI_PCP_ZReVac_Notice_ScopeBody") .. " <LINE> <LINE> "

    -- Limitations
    t = t .. "<SIZE:medium> <RGB:0.7,0.7,0.7> "
    t = t .. getText("IGUI_PCP_ZReVac_Notice_LimitTitle") .. " <LINE> "
    t = t .. "<SIZE:small> <RGB:0.7,0.7,0.7> "
    t = t .. getText("IGUI_PCP_ZReVac_Notice_LimitBody") .. " <LINE> <LINE> "

    return t
end

PhobosLib.registerNoticePopup("PCP", "zrevaccin_migration", {
    series            = "PIP",
    seriesDisplayName = "Phobos' Industrial Pathways",
    seriesLabel       = "Biomass",
    title             = "Phobos' Industrial Pathways: Biomass  \226\128\148  zReVaccin Migration",
    buildContent      = buildContent,
    shouldShow        = shouldShow,
    width             = 580,
    height            = 620,
})

---------------------------------------------------------------
-- Server Command Listeners
---------------------------------------------------------------

local function onServerCommand(module, command, args)
    if module ~= "PCP" then return end

    local player = getSpecificPlayer(0)
    if not player then return end

    if command == "zrevacTraitRemoved" then
        -- Show halo text advising player to re-vaccinate
        pcall(function()
            if HaloTextHelper and HaloTextHelper.addTextWithArrow then
                HaloTextHelper.addTextWithArrow(
                    player,
                    true,
                    getText("IGUI_PCP_ZReVac_TraitRemovedHalo")
                )
            end
        end)
    end
end

Events.OnServerCommand.Add(onServerCommand)

print("[PCP] ZReVaccinNotice: registered [client]")
