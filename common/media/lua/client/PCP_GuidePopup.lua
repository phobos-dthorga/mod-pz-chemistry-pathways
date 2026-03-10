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
-- PCP_GuidePopup.lua
-- Registers a first-time welcome guide for PCP via PhobosLib.
-- Shows on every game start until "Don't show again" is checked.
--
-- NOTE: PZ's ISRichTextPanel eats word spacing at <RGB:...> tag
-- boundaries (paginate line 440/463). Colour changes MUST only
-- appear at <LINE> boundaries, NEVER inline within a sentence.
---------------------------------------------------------------

local function buildGuideContent()
    local t = ""

    -- ── Title ──
    t = t .. "<H1> " .. getText("IGUI_PCP_Guide_Title") .. " <LINE> "
    t = t .. "<CENTRE> <SIZE:small> <RGB:0.6,0.6,0.6> " .. getText("IGUI_PCP_Guide_Subtitle") .. " <LINE> "
    t = t .. "<LINE> "

    -- ── What this mod adds ──
    t = t .. "<SIZE:medium> <LEFT> <RGB:0.5,0.85,1.0> " .. getText("IGUI_PCP_Guide_WhatAddsTitle") .. " <LINE> "
    t = t .. "<SIZE:small> <RGB:0.9,0.9,0.9> "
    t = t .. getText("IGUI_PCP_Guide_WhatAddsBody1") .. " <LINE> "
    t = t .. "<LINE> "
    t = t .. "<RGB:0.9,0.9,0.9> "
    t = t .. getText("IGUI_PCP_Guide_WhatAddsBody2") .. " <LINE> "
    t = t .. "<LINE> "
    t = t .. "<RGB:0.9,0.9,0.9> "
    t = t .. getText("IGUI_PCP_Guide_WhatAddsBody3") .. " <LINE> "
    t = t .. "<LINE> "

    -- ── Crafting categories ──
    t = t .. "<SIZE:medium> <RGB:0.5,0.85,1.0> " .. getText("IGUI_PCP_Guide_WorkstationsTitle") .. " <LINE> "
    t = t .. "<SIZE:small> <RGB:0.9,0.9,0.9> "
    t = t .. getText("IGUI_PCP_Guide_WorkstationsIntro") .. " <LINE> "
    t = t .. "<LINE> "
    -- Field
    t = t .. "<RGB:1.0,0.85,0.3> " .. getText("IGUI_PCP_Guide_FieldChem") .. " <LINE> "
    t = t .. "<RGB:0.9,0.9,0.9> "
    t = t .. getText("IGUI_PCP_Guide_FieldChemDesc") .. " <LINE> "
    -- Kitchen
    t = t .. "<RGB:1.0,0.85,0.3> " .. getText("IGUI_PCP_Guide_KitchenChem") .. " <LINE> "
    t = t .. "<RGB:0.9,0.9,0.9> "
    t = t .. getText("IGUI_PCP_Guide_KitchenChemDesc") .. " <LINE> "
    -- Lab
    t = t .. "<RGB:1.0,0.85,0.3> " .. getText("IGUI_PCP_Guide_LabChem") .. " <LINE> "
    t = t .. "<RGB:0.9,0.9,0.9> "
    t = t .. getText("IGUI_PCP_Guide_LabChemDesc") .. " <LINE> "
    -- Industrial
    t = t .. "<RGB:1.0,0.85,0.3> " .. getText("IGUI_PCP_Guide_IndustrialChem") .. " <LINE> "
    t = t .. "<RGB:0.9,0.9,0.9> "
    t = t .. getText("IGUI_PCP_Guide_IndustrialChemDesc") .. " <LINE> "
    t = t .. "<LINE> "

    -- ── How purity works ──
    t = t .. "<SIZE:medium> <RGB:0.5,0.85,1.0> " .. getText("IGUI_PCP_Guide_PurityTitle") .. " <LINE> "
    t = t .. "<SIZE:small> <RGB:0.9,0.9,0.9> "
    t = t .. getText("IGUI_PCP_Guide_PurityBody") .. " <LINE> "
    t = t .. "<LINE> "
    t = t .. "<RGB:0.9,0.9,0.9> "
    t = t .. getText("IGUI_PCP_Guide_PurityBullet1") .. " <LINE> "
    t = t .. "<RGB:0.9,0.9,0.9> "
    t = t .. getText("IGUI_PCP_Guide_PurityBullet2") .. " <LINE> "
    t = t .. "<RGB:0.9,0.9,0.9> "
    t = t .. getText("IGUI_PCP_Guide_PurityBullet3") .. " <LINE> "
    t = t .. "<RGB:0.9,0.9,0.9> "
    t = t .. getText("IGUI_PCP_Guide_PurityBullet4") .. " <LINE> "
    t = t .. "<LINE> "

    -- ── Getting started ──
    t = t .. "<SIZE:medium> <RGB:0.5,0.85,1.0> " .. getText("IGUI_PCP_Guide_GettingStartedTitle") .. " <LINE> "
    t = t .. "<SIZE:small> <RGB:0.9,0.9,0.9> "
    t = t .. getText("IGUI_PCP_Guide_Step1") .. " <LINE> "
    t = t .. "<RGB:0.9,0.9,0.9> "
    t = t .. getText("IGUI_PCP_Guide_Step2") .. " <LINE> "
    t = t .. "<RGB:0.9,0.9,0.9> "
    t = t .. getText("IGUI_PCP_Guide_Step3") .. " <LINE> "
    t = t .. "<RGB:0.9,0.9,0.9> "
    t = t .. getText("IGUI_PCP_Guide_Step4") .. " <LINE> "
    t = t .. "<LINE> "

    -- ── Safety equipment ──
    t = t .. "<SIZE:medium> <RGB:0.5,0.85,1.0> " .. getText("IGUI_PCP_Guide_SafetyTitle") .. " <LINE> "
    t = t .. "<SIZE:small> <RGB:0.9,0.9,0.9> "
    t = t .. getText("IGUI_PCP_Guide_SafetyIntro") .. " <LINE> "
    t = t .. "<RGB:0.9,0.9,0.9> "
    t = t .. getText("IGUI_PCP_Guide_SafetyBullet1") .. " <LINE> "
    t = t .. "<RGB:0.9,0.9,0.9> "
    t = t .. getText("IGUI_PCP_Guide_SafetyBullet2") .. " <LINE> "
    t = t .. "<RGB:0.9,0.9,0.9> "
    t = t .. getText("IGUI_PCP_Guide_SafetyWarning") .. " <LINE> "
    t = t .. "<LINE> "

    -- ── Sandbox options ──
    t = t .. "<SIZE:medium> <RGB:0.5,0.85,1.0> " .. getText("IGUI_PCP_Guide_CustomTitle") .. " <LINE> "
    t = t .. "<SIZE:small> <RGB:0.9,0.9,0.9> "
    t = t .. getText("IGUI_PCP_Guide_CustomIntro") .. " <LINE> "
    t = t .. "<RGB:0.9,0.9,0.9> "
    t = t .. getText("IGUI_PCP_Guide_CustomBullet1") .. " <LINE> "
    t = t .. "<RGB:0.9,0.9,0.9> "
    t = t .. getText("IGUI_PCP_Guide_CustomBullet2") .. " <LINE> "
    t = t .. "<RGB:0.9,0.9,0.9> "
    t = t .. getText("IGUI_PCP_Guide_CustomBullet3") .. " <LINE> "
    t = t .. "<RGB:0.9,0.9,0.9> "
    t = t .. getText("IGUI_PCP_Guide_CustomBullet4") .. " <LINE> "
    t = t .. "<RGB:0.9,0.9,0.9> "
    t = t .. getText("IGUI_PCP_Guide_CustomInfo") .. " <LINE> "
    t = t .. "<LINE> "

    -- ── Tips ──
    t = t .. "<SIZE:medium> <RGB:0.2,0.9,0.3> " .. getText("IGUI_PCP_Guide_TipsTitle") .. " <LINE> "
    t = t .. "<SIZE:small> <RGB:0.85,0.85,0.85> "
    t = t .. getText("IGUI_PCP_Guide_Tip1") .. " <LINE> "
    t = t .. "<RGB:0.85,0.85,0.85> "
    t = t .. getText("IGUI_PCP_Guide_Tip2") .. " <LINE> "
    t = t .. "<RGB:0.85,0.85,0.85> "
    t = t .. getText("IGUI_PCP_Guide_Tip3") .. " <LINE> "
    t = t .. "<RGB:0.85,0.85,0.85> "
    t = t .. getText("IGUI_PCP_Guide_Tip4") .. " <LINE> "
    t = t .. "<RGB:0.85,0.85,0.85> "
    t = t .. getText("IGUI_PCP_Guide_Tip5") .. " <LINE> "
    t = t .. "<LINE> "

    -- ── Footer ──
    t = t .. "<CENTRE> <SIZE:small> <RGB:0.40,0.40,0.40> "
    t = t .. getText("IGUI_PCP_Guide_FooterWorkshop") .. " <LINE> "
    t = t .. "<RGB:0.40,0.40,0.40> "
    t = t .. getText("IGUI_PCP_Guide_FooterRequires") .. " <LINE> "
    t = t .. "<LINE> "

    return t
end

-- Register with PhobosLib popup system
PhobosLib.registerGuidePopup("PCP", {
    series            = "PIP",
    seriesDisplayName = "Phobos' Industrial Pathways",
    seriesLabel       = "Biomass",
    title             = "Phobos' Industrial Pathways: Biomass  \226\128\148  Quick Guide",
    buildContent      = buildGuideContent,
    width             = 560,
    height            = 620,
})

print("[PCP] GuidePopup: registered [client]")
