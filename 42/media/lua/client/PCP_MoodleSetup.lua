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
-- PCP_MoodleSetup.lua
-- Client-side registration of the "Medicated" custom moodle
-- via PhobosLib's Moodle Framework wrapper.
--
-- Only executes when Moodle Framework is installed (soft dep).
-- The moodle is "good only" — values above 0.5 show positive
-- levels (Slightly Medicated → Heavily Medicated).
--
-- Moodle icon: media/ui/Medicated.png (30x30 PNG)
-- Translations: Moodles_EN.txt
--
-- Requires PhobosLib >= 1.17.0
-- Part of PhobosChemistryPathways >= 1.4.0
---------------------------------------------------------------

require "PhobosLib"

local _TAG = "[PCP:MoodleSetup]"

---------------------------------------------------------------
-- Moodle registration
---------------------------------------------------------------

local function registerMedicatedMoodle()
    if not PhobosLib.isMoodleFrameworkActive() then
        print(_TAG .. " Moodle Framework not active, skipping registration")
        return
    end

    -- Register the moodle with PhobosLib wrapper
    PhobosLib.registerMoodle({
        name     = "Medicated",
        goodOnly = true,
    })

    print(_TAG .. " Medicated moodle registered")
end

---------------------------------------------------------------
-- Threshold configuration
---------------------------------------------------------------

--- Configure moodle thresholds on player creation.
--- Called per-player so split-screen and MP are handled correctly.
---
--- Moodle Framework thresholds define when each level activates:
---   Bad levels: value < threshold (not used for good-only moodles)
---   Good levels: value > threshold
---
--- Our "Medicated" moodle uses good levels only:
---   Level 1 (Slightly): value > 0.55
---   Level 2 (Medicated): value > 0.65
---   Level 3 (Well): value > 0.75
---   Level 4 (Heavily): value > 0.85
local function onCreatePlayer(playerNum)
    if not PhobosLib.isMoodleFrameworkActive() then return end

    pcall(function()
        local moodle = MF.getMoodle("Medicated", playerNum)
        if moodle then
            -- setThresholds(bad4, bad3, bad2, bad1, good1, good2, good3, good4)
            -- Bad thresholds set below 0 (never triggered for good-only moodle)
            moodle:setThresholds(
                -1.0, -1.0, -1.0, -1.0,   -- bad levels: disabled
                0.55, 0.65, 0.75, 0.85     -- good levels: Slightly → Heavily
            )
            print(_TAG .. " thresholds configured for player " .. tostring(playerNum))
        end
    end)
end

---------------------------------------------------------------
-- Event hooks
---------------------------------------------------------------

registerMedicatedMoodle()

Events.OnCreatePlayer.Add(onCreatePlayer)

print(_TAG .. " loaded")
