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
-- PCP_ChangelogPopup.lua
-- Registers a "What's New" changelog popup for PCP via PhobosLib.
-- Shows once per major/minor version change. Patch bumps ignored.
--
-- To update for a future release:
--   1. Bump PCP_VERSION below.
--   2. Add a new version block at the top of buildChangelogContent(),
--      wrapped in:  if isNewerThan("X.YY", lastSeenVersion) then ... end
--   3. Push to Workshop.
---------------------------------------------------------------

local PCP_VERSION = "1.10.0"

--- Returns true if `version` (e.g. "0.23") is strictly newer than `baseline`.
--- If baseline is nil, returns true (show everything).
local function isNewerThan(version, baseline)
    if not baseline then return true end
    local aMaj, aMin = string.match(version, "^(%d+)%.(%d+)")
    local bMaj, bMin = string.match(baseline, "^(%d+)%.(%d+)")
    if not aMaj or not bMaj then return true end
    aMaj, aMin = tonumber(aMaj), tonumber(aMin)
    bMaj, bMin = tonumber(bMaj), tonumber(bMin)
    if aMaj ~= bMaj then return aMaj > bMaj end
    return aMin > bMin
end

local function buildChangelogContent(lastSeenVersion)
    local t = ""

    -- ════════════════════════════════════════════════════════════════ --
    -- Header
    -- ════════════════════════════════════════════════════════════════ --
    t = t .. "<H1> <CENTRE> " .. getText("IGUI_PCP_Changelog_Title") .. " <LINE> "
    t = t .. "<CENTRE> <SIZE:small> <RGB:0.55,0.65,0.85> " .. getText("IGUI_PCP_Changelog_VersionPrefix")
          .. " " .. PCP_VERSION .. "  |  " .. getText("IGUI_PCP_Changelog_VersionDate") .. " <LINE> <LINE> "

    -- ════════════════════════════════════════════════════════════════ --
    -- v1.10  ·  zReVaccin → ZVV Migration Tool
    -- ════════════════════════════════════════════════════════════════ --
    if isNewerThan("1.10", lastSeenVersion) then
    t = t .. "<LEFT> <SIZE:medium> <RGB:0.40,0.80,1.00> "
    t = t .. getText("IGUI_PCP_Changelog_V1_10_Marker") .. " "
    t = t .. "<SIZE:small> <RGB:0.55,0.65,0.85>  " .. getText("IGUI_PCP_Changelog_V1_10_Date") .. " <LINE> <LINE> "

    t = t .. "<SIZE:small> <RGB:1.00,0.75,0.20> "
    t = t .. getText("IGUI_PCP_Changelog_V1_10_MigrationTitle") .. " <LINE> "
    t = t .. "<RGB:0.88,0.88,0.88> "
    t = t .. getText("IGUI_PCP_Changelog_V1_10_MigrationBody") .. " <LINE> <LINE> "
    end

    -- ════════════════════════════════════════════════════════════════ --
    -- v1.9  ·  Item Model & Recipe Fixes
    -- ════════════════════════════════════════════════════════════════ --
    if isNewerThan("1.9", lastSeenVersion) then
    t = t .. "<LEFT> <SIZE:medium> <RGB:0.40,0.80,1.00> "
    t = t .. getText("IGUI_PCP_Changelog_V1_9_Marker") .. " "
    t = t .. "<SIZE:small> <RGB:0.55,0.65,0.85>  " .. getText("IGUI_PCP_Changelog_V1_9_Date") .. " <LINE> <LINE> "

    t = t .. "<SIZE:small> <RGB:1.00,0.75,0.20> "
    t = t .. getText("IGUI_PCP_Changelog_V1_9_ModelsTitle") .. " <LINE> "
    t = t .. "<RGB:0.88,0.88,0.88> "
    t = t .. getText("IGUI_PCP_Changelog_V1_9_ModelsBody") .. " <LINE> "
    t = t .. "<LINE> "

    t = t .. "<SIZE:small> <RGB:1.00,0.75,0.20> "
    t = t .. getText("IGUI_PCP_Changelog_V1_9_CheeseclothTitle") .. " <LINE> "
    t = t .. "<RGB:0.88,0.88,0.88> "
    t = t .. getText("IGUI_PCP_Changelog_V1_9_CheeseclothBody") .. " <LINE> "
    t = t .. "<LINE> "

    t = t .. "<SIZE:small> <RGB:1.00,0.75,0.20> "
    t = t .. getText("IGUI_PCP_Changelog_V1_9_RecipesTitle") .. " <LINE> "
    t = t .. "<RGB:0.88,0.88,0.88> "
    t = t .. getText("IGUI_PCP_Changelog_V1_9_RecipesBody") .. " <LINE> "
    t = t .. "<LINE> "

    t = t .. "<RGB:0.80,0.80,0.80> "
    t = t .. getText("IGUI_PCP_Changelog_V1_9_Stats1") .. " <LINE> "
    t = t .. getText("IGUI_PCP_Changelog_V1_9_Stats2") .. " <LINE> "
    t = t .. "<LINE> "
    end

    -- ════════════════════════════════════════════════════════════════ --
    -- v1.8.1  ·  Hemp Recipe Input Fix
    -- ════════════════════════════════════════════════════════════════ --
    if isNewerThan("1.8", lastSeenVersion) then
    t = t .. "<LEFT> <SIZE:medium> <RGB:0.40,0.80,1.00> "
    t = t .. getText("IGUI_PCP_Changelog_V1_8_1_Marker") .. " "
    t = t .. "<SIZE:small> <RGB:0.55,0.65,0.85>  " .. getText("IGUI_PCP_Changelog_V1_8_1_Date") .. " <LINE> <LINE> "

    t = t .. "<SIZE:small> <RGB:1.00,0.75,0.20> "
    t = t .. getText("IGUI_PCP_Changelog_V1_8_1_HempTitle") .. " <LINE> "
    t = t .. "<RGB:0.88,0.88,0.88> "
    t = t .. getText("IGUI_PCP_Changelog_V1_8_1_HempBody") .. " <LINE> "
    t = t .. "<LINE> "
    end

    -- ════════════════════════════════════════════════════════════════ --
    -- v1.8  ·  Gardening Sprays, Hemp Fix, Icons
    -- ════════════════════════════════════════════════════════════════ --
    if isNewerThan("1.8", lastSeenVersion) then
    t = t .. "<LEFT> <SIZE:medium> <RGB:0.40,0.80,1.00> "
    t = t .. getText("IGUI_PCP_Changelog_V1_8_Marker") .. " "
    t = t .. "<SIZE:small> <RGB:0.55,0.65,0.85>  " .. getText("IGUI_PCP_Changelog_V1_8_Date") .. " <LINE> <LINE> "

    t = t .. "<SIZE:small> <RGB:1.00,0.75,0.20> "
    t = t .. getText("IGUI_PCP_Changelog_V1_8_SprayTitle") .. " <LINE> "
    t = t .. "<RGB:0.88,0.88,0.88> "
    t = t .. getText("IGUI_PCP_Changelog_V1_8_SprayBody") .. " <LINE> "
    t = t .. "<LINE> "

    t = t .. "<SIZE:small> <RGB:1.00,0.75,0.20> "
    t = t .. getText("IGUI_PCP_Changelog_V1_8_HempTitle") .. " <LINE> "
    t = t .. "<RGB:0.88,0.88,0.88> "
    t = t .. getText("IGUI_PCP_Changelog_V1_8_HempBody") .. " <LINE> "
    t = t .. "<LINE> "

    t = t .. "<SIZE:small> <RGB:1.00,0.75,0.20> "
    t = t .. getText("IGUI_PCP_Changelog_V1_8_IconsTitle") .. " <LINE> "
    t = t .. "<RGB:0.88,0.88,0.88> "
    t = t .. getText("IGUI_PCP_Changelog_V1_8_IconsBody") .. " <LINE> "
    t = t .. "<LINE> "

    t = t .. "<RGB:0.80,0.80,0.80> "
    t = t .. getText("IGUI_PCP_Changelog_V1_8_Stats1") .. " <LINE> "
    t = t .. getText("IGUI_PCP_Changelog_V1_8_Stats2") .. " <LINE> "
    t = t .. "<LINE> "
    end

    -- ════════════════════════════════════════════════════════════════ --
    -- v1.6  ·  PZ 42.15 Translation Migration
    -- ════════════════════════════════════════════════════════════════ --
    if isNewerThan("1.6", lastSeenVersion) then
    t = t .. "<LEFT> <SIZE:medium> <RGB:0.40,0.80,1.00> "
    t = t .. getText("IGUI_PCP_Changelog_V1_6_Marker") .. " "
    t = t .. "<SIZE:small> <RGB:0.55,0.65,0.85>  " .. getText("IGUI_PCP_Changelog_V1_6_Date") .. " <LINE> <LINE> "

    t = t .. "<SIZE:small> <RGB:1.00,0.75,0.20> "
    t = t .. getText("IGUI_PCP_Changelog_V1_6_TransTitle") .. " <LINE> "
    t = t .. "<RGB:0.88,0.88,0.88> "
    t = t .. getText("IGUI_PCP_Changelog_V1_6_TransBody") .. " <LINE> "
    t = t .. "<LINE> "

    t = t .. "<RGB:0.80,0.80,0.80> "
    t = t .. getText("IGUI_PCP_Changelog_V1_6_Stats1") .. " <LINE> "
    t = t .. getText("IGUI_PCP_Changelog_V1_6_Stats2") .. " <LINE> "
    t = t .. "<LINE> "
    end

    -- ════════════════════════════════════════════════════════════════ --
    -- v1.5  ·  Chewing Tobacco Curing & Tags
    -- ════════════════════════════════════════════════════════════════ --
    if isNewerThan("1.5", lastSeenVersion) then
    t = t .. "<LEFT> <SIZE:medium> <RGB:0.40,0.80,1.00> "
    t = t .. getText("IGUI_PCP_Changelog_V1_5_Marker") .. " "
    t = t .. "<SIZE:small> <RGB:0.55,0.65,0.85>  " .. getText("IGUI_PCP_Changelog_V1_5_Date") .. " <LINE> <LINE> "

    t = t .. "<SIZE:small> <RGB:1.00,0.75,0.20> "
    t = t .. getText("IGUI_PCP_Changelog_V1_5_ChewingTitle") .. " <LINE> "
    t = t .. "<RGB:0.88,0.88,0.88> "
    t = t .. getText("IGUI_PCP_Changelog_V1_5_ChewingBody") .. " <LINE> "
    t = t .. "<LINE> "

    t = t .. "<RGB:1.00,0.75,0.20> "
    t = t .. getText("IGUI_PCP_Changelog_V1_5_TagsTitle") .. " <LINE> "
    t = t .. "<RGB:0.88,0.88,0.88> "
    t = t .. getText("IGUI_PCP_Changelog_V1_5_TagsBody") .. " <LINE> "
    t = t .. "<LINE> "

    t = t .. "<RGB:1.00,0.75,0.20> "
    t = t .. getText("IGUI_PCP_Changelog_V1_5_SprayTitle") .. " <LINE> "
    t = t .. "<RGB:0.88,0.88,0.88> "
    t = t .. getText("IGUI_PCP_Changelog_V1_5_SprayBody") .. " <LINE> "
    t = t .. "<LINE> "

    t = t .. "<RGB:0.80,0.80,0.80> "
    t = t .. getText("IGUI_PCP_Changelog_V1_5_Stats1") .. " <LINE> "
    t = t .. getText("IGUI_PCP_Changelog_V1_5_Stats2") .. " <LINE> "
    t = t .. "<LINE> "
    end

    -- ════════════════════════════════════════════════════════════════ --
    -- v1.4  ·  Medicinal Effects & Moodle
    -- ════════════════════════════════════════════════════════════════ --
    if isNewerThan("1.4", lastSeenVersion) then
    t = t .. "<LEFT> <SIZE:medium> <RGB:0.40,0.80,1.00> "
    t = t .. getText("IGUI_PCP_Changelog_V1_4_Marker") .. " "
    t = t .. "<SIZE:small> <RGB:0.55,0.65,0.85>  " .. getText("IGUI_PCP_Changelog_V1_4_Date") .. " <LINE> <LINE> "

    t = t .. "<SIZE:small> <RGB:1.00,0.75,0.20> "
    t = t .. getText("IGUI_PCP_Changelog_V1_4_MedicinalTitle") .. " <LINE> "
    t = t .. "<RGB:0.88,0.88,0.88> "
    t = t .. getText("IGUI_PCP_Changelog_V1_4_MedicinalBody") .. " <LINE> "
    t = t .. "<LINE> "

    t = t .. "<RGB:1.00,0.75,0.20> "
    t = t .. getText("IGUI_PCP_Changelog_V1_4_FermentTitle") .. " <LINE> "
    t = t .. "<RGB:0.88,0.88,0.88> "
    t = t .. getText("IGUI_PCP_Changelog_V1_4_FermentBody") .. " <LINE> "
    t = t .. "<LINE> "

    t = t .. "<RGB:1.00,0.75,0.20> "
    t = t .. getText("IGUI_PCP_Changelog_V1_4_SandboxTitle") .. " <LINE> "
    t = t .. "<RGB:0.88,0.88,0.88> "
    t = t .. getText("IGUI_PCP_Changelog_V1_4_SandboxBody") .. " <LINE> "
    t = t .. "<LINE> "

    t = t .. "<RGB:1.00,0.75,0.20> "
    t = t .. getText("IGUI_PCP_Changelog_V1_4_BugfixTitle") .. " <LINE> "
    t = t .. "<RGB:0.88,0.88,0.88> "
    t = t .. getText("IGUI_PCP_Changelog_V1_4_BugfixBody") .. " <LINE> "
    t = t .. "<LINE> "

    t = t .. "<RGB:0.80,0.80,0.80> "
    t = t .. getText("IGUI_PCP_Changelog_V1_4_Stats1") .. " <LINE> "
    t = t .. getText("IGUI_PCP_Changelog_V1_4_Stats2") .. " <LINE> "
    t = t .. "<LINE> "
    end

    -- ════════════════════════════════════════════════════════════════ --
    -- v1.3  (Hemp Expansion + Audit)
    -- ════════════════════════════════════════════════════════════════ --
    if isNewerThan("1.3", lastSeenVersion) then
    t = t .. "<LEFT> <SIZE:medium> <RGB:0.40,0.80,1.00> "
    t = t .. getText("IGUI_PCP_Changelog_V1_3_Marker") .. " "
    t = t .. "<SIZE:small> <RGB:0.55,0.65,0.85>  " .. getText("IGUI_PCP_Changelog_V1_3_Date") .. " <LINE> <LINE> "

    t = t .. "<SIZE:small> <RGB:1.00,0.75,0.20> "
    t = t .. getText("IGUI_PCP_Changelog_V1_3_HempTitle") .. " <LINE> "
    t = t .. "<RGB:0.88,0.88,0.88> "
    t = t .. getText("IGUI_PCP_Changelog_V1_3_HempBody") .. " <LINE> "
    t = t .. "<LINE> "

    t = t .. "<RGB:1.00,0.75,0.20> "
    t = t .. getText("IGUI_PCP_Changelog_V1_3_HazardTitle") .. " <LINE> "
    t = t .. "<RGB:0.88,0.88,0.88> "
    t = t .. getText("IGUI_PCP_Changelog_V1_3_HazardBody") .. " <LINE> "
    t = t .. "<LINE> "

    t = t .. "<RGB:1.00,0.75,0.20> "
    t = t .. getText("IGUI_PCP_Changelog_V1_3_AuditTitle") .. " <LINE> "
    t = t .. "<RGB:0.88,0.88,0.88> "
    t = t .. getText("IGUI_PCP_Changelog_V1_3_AuditBody") .. " <LINE> "
    t = t .. "<LINE> "

    t = t .. "<RGB:0.80,0.80,0.80> "
    t = t .. getText("IGUI_PCP_Changelog_V1_3_Stats1") .. " <LINE> "
    t = t .. getText("IGUI_PCP_Changelog_V1_3_Stats2") .. " <LINE> "
    t = t .. "<LINE> "
    end

    -- ════════════════════════════════════════════════════════════════ --
    -- v1.2  (Botanical + Horticulture)
    -- ════════════════════════════════════════════════════════════════ --
    if isNewerThan("1.2", lastSeenVersion) then
    t = t .. "<LEFT> <SIZE:medium> <RGB:0.40,0.78,0.95> "
    t = t .. getText("IGUI_PCP_Changelog_V1_2_Marker") .. " "
    t = t .. "<SIZE:small> <RGB:0.55,0.65,0.85>  " .. getText("IGUI_PCP_Changelog_V1_2_Date") .. " <LINE> <LINE> "

    t = t .. "<SIZE:small> <RGB:1.00,0.75,0.20> "
    t = t .. getText("IGUI_PCP_Changelog_V1_2_BotanicalTitle") .. " <LINE> "
    t = t .. "<RGB:0.88,0.88,0.88> "
    t = t .. getText("IGUI_PCP_Changelog_V1_2_BotanicalBody") .. " <LINE> "
    t = t .. "<LINE> "

    t = t .. "<RGB:1.00,0.75,0.20> "
    t = t .. getText("IGUI_PCP_Changelog_V1_2_HorticultureTitle") .. " <LINE> "
    t = t .. "<RGB:0.88,0.88,0.88> "
    t = t .. getText("IGUI_PCP_Changelog_V1_2_HorticultureBody") .. " <LINE> "
    t = t .. "<LINE> "

    t = t .. "<RGB:1.00,0.75,0.20> "
    t = t .. getText("IGUI_PCP_Changelog_V1_2_SoftDepTitle") .. " <LINE> "
    t = t .. "<RGB:0.88,0.88,0.88> "
    t = t .. getText("IGUI_PCP_Changelog_V1_2_SoftDepBody") .. " <LINE> "
    t = t .. "<LINE> "

    t = t .. "<RGB:0.80,0.80,0.80> "
    t = t .. getText("IGUI_PCP_Changelog_V1_2_Stats1") .. " <LINE> "
    t = t .. getText("IGUI_PCP_Changelog_V1_2_Stats2") .. " <LINE> "
    t = t .. "<LINE> "

    t = t .. "<RGB:1.00,0.75,0.20> "
    t = t .. getText("IGUI_PCP_Changelog_V1_2_RebrandTitle") .. " <LINE> "
    t = t .. "<RGB:0.88,0.88,0.88> "
    t = t .. getText("IGUI_PCP_Changelog_V1_2_RebrandBody") .. " <LINE> "
    t = t .. "<LINE> "
    end

    -- ════════════════════════════════════════════════════════════════ --
    -- v1.1  ·  Skill Purity Influence
    -- ════════════════════════════════════════════════════════════════ --
    if isNewerThan("1.1", lastSeenVersion) then
    t = t .. "<LEFT> <SIZE:medium> <RGB:0.40,0.78,0.95> "
    t = t .. getText("IGUI_PCP_Changelog_V1_1_Marker") .. " "
    t = t .. "<SIZE:small> <RGB:0.55,0.65,0.85>  " .. getText("IGUI_PCP_Changelog_V1_1_Date") .. " <LINE> <LINE> "

    t = t .. "<SIZE:small> <RGB:1.00,0.75,0.20> "
    t = t .. getText("IGUI_PCP_Changelog_V1_1_Title") .. " <LINE> "
    t = t .. "<RGB:0.88,0.88,0.88> "
    t = t .. getText("IGUI_PCP_Changelog_V1_1_Body") .. " <LINE> "
    t = t .. "<LINE> "
    end

    -- ════════════════════════════════════════════════════════════════ --
    -- v1.0  (ZVV migration)
    -- ════════════════════════════════════════════════════════════════ --
    if isNewerThan("1.0", lastSeenVersion) then
    t = t .. "<LEFT> <SIZE:medium> <RGB:0.40,0.80,1.00> "
    t = t .. getText("IGUI_PCP_Changelog_V1_0_Marker") .. " "
    t = t .. "<SIZE:small> <RGB:0.55,0.65,0.85>  " .. getText("IGUI_PCP_Changelog_V1_0_Date") .. " <LINE> <LINE> "

    t = t .. "<SIZE:small> <RGB:1.00,0.40,0.40> "
    t = t .. getText("IGUI_PCP_Changelog_V1_0_BreakingTitle") .. " <LINE> "
    t = t .. "<RGB:0.88,0.88,0.88> "
    t = t .. getText("IGUI_PCP_Changelog_V1_0_BreakingBody") .. " <LINE> "
    t = t .. "<LINE> "

    t = t .. "<RGB:1.00,0.75,0.20> " .. getText("IGUI_PCP_Changelog_V1_0_MigrationTitle") .. " <LINE> "
    t = t .. "<RGB:0.88,0.88,0.88> "
    t = t .. getText("IGUI_PCP_Changelog_V1_0_MigrationBody") .. " <LINE> "
    t = t .. "<LINE> "
    end

    -- ════════════════════════════════════════════════════════════════ --
    -- v0.26
    -- ════════════════════════════════════════════════════════════════ --
    if isNewerThan("0.26", lastSeenVersion) then
    t = t .. "<LEFT> <SIZE:medium> <RGB:0.45,0.70,0.90> "
    t = t .. getText("IGUI_PCP_Changelog_V0_26_Marker") .. " "
    t = t .. "<SIZE:small> <RGB:0.55,0.65,0.85>  " .. getText("IGUI_PCP_Changelog_V0_26_Date") .. " <LINE> <LINE> "

    t = t .. "<SIZE:small> <RGB:1.00,0.75,0.20> "
    t = t .. getText("IGUI_PCP_Changelog_V0_26_Title") .. " <LINE> "
    t = t .. "<RGB:0.88,0.88,0.88> "
    t = t .. getText("IGUI_PCP_Changelog_V0_26_Body") .. " <LINE> "
    t = t .. "<LINE> "
    end

    -- ════════════════════════════════════════════════════════════════ --
    -- v0.25
    -- ════════════════════════════════════════════════════════════════ --
    if isNewerThan("0.25", lastSeenVersion) then
    t = t .. "<LEFT> <SIZE:medium> <RGB:0.45,0.65,0.85> "
    t = t .. getText("IGUI_PCP_Changelog_V0_25_Marker") .. " "
    t = t .. "<SIZE:small> <RGB:0.55,0.65,0.85>  " .. getText("IGUI_PCP_Changelog_V0_25_Date") .. " <LINE> <LINE> "

    t = t .. "<SIZE:small> <RGB:1.00,0.75,0.20> "
    t = t .. getText("IGUI_PCP_Changelog_V0_25_Title") .. " <LINE> "
    t = t .. "<RGB:0.88,0.88,0.88> "
    t = t .. getText("IGUI_PCP_Changelog_V0_25_Body") .. " <LINE> "
    t = t .. "<LINE> "

    t = t .. "<RGB:0.80,0.80,0.80> "
    t = t .. getText("IGUI_PCP_Changelog_V0_25_Stats1") .. " <LINE> "
    t = t .. getText("IGUI_PCP_Changelog_V0_25_Stats2") .. " <LINE> "
    t = t .. "<LINE> "
    end

    -- ════════════════════════════════════════════════════════════════ --
    -- v0.24
    -- ════════════════════════════════════════════════════════════════ --
    if isNewerThan("0.24", lastSeenVersion) then
    t = t .. "<LEFT> <SIZE:medium> <RGB:0.45,0.65,0.75> "
    t = t .. getText("IGUI_PCP_Changelog_V0_24_Marker") .. " "
    t = t .. "<SIZE:small> <RGB:0.55,0.65,0.85>  " .. getText("IGUI_PCP_Changelog_V0_24_Date") .. " <LINE> <LINE> "

    t = t .. "<SIZE:small> <RGB:1.00,0.75,0.20> "
    t = t .. getText("IGUI_PCP_Changelog_V0_24_Title") .. " <LINE> "
    t = t .. "<RGB:0.88,0.88,0.88> "
    t = t .. getText("IGUI_PCP_Changelog_V0_24_Body") .. " <LINE> "
    t = t .. "<LINE> "

    t = t .. "<RGB:1.00,0.75,0.20> " .. getText("IGUI_PCP_Changelog_V0_24_BugTitle") .. " <LINE> "
    t = t .. "<RGB:0.88,0.88,0.88> "
    t = t .. getText("IGUI_PCP_Changelog_V0_24_BugBody") .. " <LINE> "
    t = t .. "<LINE> "
    end

    -- ════════════════════════════════════════════════════════════════ --
    -- v0.23
    -- ════════════════════════════════════════════════════════════════ --
    if isNewerThan("0.23", lastSeenVersion) then
    t = t .. "<LEFT> <SIZE:medium> <RGB:0.45,0.70,0.90> "
    t = t .. getText("IGUI_PCP_Changelog_V0_23_Marker") .. " "
    t = t .. "<SIZE:small> <RGB:0.55,0.65,0.85>  " .. getText("IGUI_PCP_Changelog_V0_23_Date") .. " <LINE> <LINE> "

    t = t .. "<SIZE:small> <RGB:1.00,0.75,0.20> "
    t = t .. getText("IGUI_PCP_Changelog_V0_23_Title") .. " <LINE> "
    t = t .. "<RGB:0.88,0.88,0.88> "
    t = t .. getText("IGUI_PCP_Changelog_V0_23_Body") .. " <LINE> "
    t = t .. "<LINE> "

    t = t .. "<RGB:0.80,0.80,0.80> "
    t = t .. getText("IGUI_PCP_Changelog_V0_23_Stats1") .. " <LINE> "
    t = t .. getText("IGUI_PCP_Changelog_V0_23_Stats2") .. " <LINE> "
    t = t .. getText("IGUI_PCP_Changelog_V0_23_Stats3") .. " <LINE> "
    t = t .. getText("IGUI_PCP_Changelog_V0_23_Stats4") .. " <LINE> "
    t = t .. "<LINE> "
    end

    -- ════════════════════════════════════════════════════════════════ --
    -- v0.22
    -- ════════════════════════════════════════════════════════════════ --
    if isNewerThan("0.22", lastSeenVersion) then
    t = t .. "<SIZE:medium> <RGB:0.45,0.65,0.75> "
    t = t .. getText("IGUI_PCP_Changelog_V0_22_Marker") .. " "
    t = t .. "<SIZE:small> <RGB:0.55,0.65,0.85>  " .. getText("IGUI_PCP_Changelog_V0_22_Date") .. " <LINE> <LINE> "

    t = t .. "<SIZE:small> <RGB:1.00,0.75,0.20> "
    t = t .. getText("IGUI_PCP_Changelog_V0_22_Title") .. " <LINE> "
    t = t .. "<RGB:0.88,0.88,0.88> "
    t = t .. getText("IGUI_PCP_Changelog_V0_22_Body") .. " <LINE> "
    t = t .. "<LINE> "

    t = t .. "<RGB:0.80,0.80,0.80> "
    t = t .. getText("IGUI_PCP_Changelog_V0_22_Stats1") .. " <LINE> "
    t = t .. getText("IGUI_PCP_Changelog_V0_22_Stats2") .. " <LINE> "
    t = t .. "<LINE> "
    end

    -- ════════════════════════════════════════════════════════════════ --
    -- v0.21
    -- ════════════════════════════════════════════════════════════════ --
    if isNewerThan("0.21", lastSeenVersion) then
    t = t .. "<SIZE:medium> <RGB:0.40,0.55,0.60> "
    t = t .. getText("IGUI_PCP_Changelog_V0_21_Marker") .. " "
    t = t .. "<SIZE:small> <RGB:0.55,0.65,0.85>  " .. getText("IGUI_PCP_Changelog_V0_21_Date") .. " <LINE> <LINE> "

    t = t .. "<SIZE:small> <RGB:0.80,0.80,0.80> "
    t = t .. getText("IGUI_PCP_Changelog_V0_21_Stats1") .. " <LINE> "
    t = t .. getText("IGUI_PCP_Changelog_V0_21_Stats2") .. " <LINE> "
    t = t .. getText("IGUI_PCP_Changelog_V0_21_Stats3") .. " <LINE> "
    t = t .. getText("IGUI_PCP_Changelog_V0_21_Stats4") .. " <LINE> "
    t = t .. "<LINE> "
    end

    -- ════════════════════════════════════════════════════════════════ --
    -- v0.20
    -- ════════════════════════════════════════════════════════════════ --
    if isNewerThan("0.20", lastSeenVersion) then
    t = t .. "<SIZE:medium> <RGB:0.38,0.50,0.55> "
    t = t .. getText("IGUI_PCP_Changelog_V0_20_Marker") .. " "
    t = t .. "<SIZE:small> <RGB:0.55,0.65,0.85>  " .. getText("IGUI_PCP_Changelog_V0_20_Date") .. " <LINE> <LINE> "

    t = t .. "<SIZE:small> <RGB:0.72,0.72,0.72> "
    t = t .. getText("IGUI_PCP_Changelog_V0_20_Stats1") .. " <LINE> "
    t = t .. getText("IGUI_PCP_Changelog_V0_20_Stats2") .. " <LINE> "
    t = t .. "<LINE> "
    end

    -- ════════════════════════════════════════════════════════════════ --
    -- Earlier
    -- ════════════════════════════════════════════════════════════════ --
    if isNewerThan("0.19", lastSeenVersion) then
    t = t .. "<SIZE:medium> <RGB:0.35,0.45,0.50> "
    t = t .. getText("IGUI_PCP_Changelog_Earlier_Marker") .. " "
    t = t .. "<SIZE:small> <RGB:0.55,0.65,0.85> <LINE> <LINE> "

    t = t .. "<SIZE:small> <RGB:0.58,0.58,0.58> "
    t = t .. getText("IGUI_PCP_Changelog_Earlier_Stats1") .. " <LINE> "
    t = t .. getText("IGUI_PCP_Changelog_Earlier_Stats2") .. " <LINE> "
    t = t .. getText("IGUI_PCP_Changelog_Earlier_Stats3") .. " <LINE> "
    t = t .. "<LINE> "
    end

    -- ════════════════════════════════════════════════════════════════ --
    -- Footer
    -- ════════════════════════════════════════════════════════════════ --
    t = t .. "<CENTRE> <SIZE:small> <RGB:0.40,0.40,0.40> "
    t = t .. getText("IGUI_PCP_Changelog_FooterWorkshop") .. " <LINE> "
    t = t .. getText("IGUI_PCP_Changelog_FooterFeedback") .. " <LINE> "
    t = t .. "<LINE> "

    return t
end

-- Register with PhobosLib popup system
PhobosLib.registerChangelogPopup("PCP", {
    series            = "PIP",
    seriesDisplayName = "Phobos' Industrial Pathways",
    seriesLabel       = "Biomass",
    title             = "Phobos' Industrial Pathways: Biomass  \226\128\148  What's New",
    buildContent      = buildChangelogContent,
    currentVersion    = PCP_VERSION,
    width             = 620,
    height            = 680,
})

print("[PCP] ChangelogPopup: registered [client] (v" .. PCP_VERSION .. ")")
