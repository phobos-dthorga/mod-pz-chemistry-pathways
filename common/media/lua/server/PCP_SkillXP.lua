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
-- PCP_SkillXP.lua
-- Cross-skill XP mirroring for PhobosChemistryPathways.
-- When ZScienceSkill is detected, registers a persistent XP
-- mirror: Applied Chemistry → Science at 50% rate.
--
-- Uses PhobosLib.registerXPMirror() for the heavy lifting.
---------------------------------------------------------------

require "PhobosLib"

local function initSkillXPMirror()
    if isClient() then return end  -- MP: only register on server or singleplayer
    -- Only register mirror if ZScienceSkill is loaded and Science perk exists
    if PhobosLib.isModActive("ZScienceSkill") and PhobosLib.perkExists("Science") then
        local ok = PhobosLib.registerXPMirror("AppliedChemistry", "Science", 0.5)
        if ok then
            print("[PCP] ZScienceSkill detected — AppChem → Science XP mirror (50%) [" .. (isServer() and "server" or "local") .. "]")
        end
    end
end

Events.OnGameStart.Add(initSkillXPMirror)
