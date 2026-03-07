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
-- PCP_FermentationTooltip.lua
-- Client-side fermentation registration and tooltip provider.
--
-- Registers CannedHempBuds as a "positive rot" fermentation
-- item with PhobosLib's fermentation system. Appends dynamic
-- progress and canning-date lines to the item tooltip.
--
-- Requires: PhobosLib >= 1.18.0
-- Runs client-side only (42/media/lua/client/).
---------------------------------------------------------------

require "PhobosLib"

---------------------------------------------------------------
-- Registration
---------------------------------------------------------------

PhobosLib.registerFermentation(
    "PhobosChemistryPathways.CannedHempBuds",
    {
        label          = "Curing",
        totalHours     = (14 + 14) * 24,   -- 672 hours = 28 days
        translationKey = "IGUI_PCP_FermentCuring",
    }
)

---------------------------------------------------------------
-- Tooltip provider
---------------------------------------------------------------

PhobosLib.registerTooltipProvider("PhobosChemistryPathways.", function(item)
    local progress = PhobosLib.getFermentationProgress(item)
    if not progress then return nil end

    local lines = {}

    -- Line 1: progress percentage + remaining days
    local text
    local r, g, b

    if progress.complete then
        text = progress.label .. ": Complete"
        r, g, b = 0.6, 1.0, 0.6
    else
        text = progress.label .. ": " .. progress.percent .. "%"
        if progress.remainingDays > 0 then
            text = text .. " (~" .. progress.remainingDays .. " day"
            if progress.remainingDays ~= 1 then text = text .. "s" end
            text = text .. " left)"
        end
        r = 1.0 - (progress.percent / 100) * 0.4
        g = 0.8 + (progress.percent / 100) * 0.2
        b = 0.4
    end

    table.insert(lines, { text = text, r = r, g = g, b = b })

    -- Line 2: canned date (if stamped via OnCreate)
    local dateTable = PhobosLib.getFermentationDate(item)
    if dateTable then
        local dateStr = PhobosLib.formatGameDate(dateTable)
        table.insert(lines, { text = "Canned: " .. dateStr, r = 0.6, g = 0.6, b = 0.6 })
    end

    return lines
end)
