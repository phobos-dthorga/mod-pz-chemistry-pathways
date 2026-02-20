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
-- PCP_SkillBookData.lua
-- Registers Applied Chemistry skill books in the PZ global
-- SkillBook table so the engine recognises them as readable
-- XP-multiplier books (right-click → Read).
--
-- The vanilla SkillBook table is defined in:
--   media/lua/server/XpSystem/XPSystem_SkillBook.lua
-- and is checked by ISInventoryPaneContextMenu (client) and
-- ISReadABook (shared).  Without this registration, books
-- with SkillTrained = AppliedChemistry are silently treated
-- as non-readable.
--
-- Multipliers (3/5/8/12/16) match the standard values used
-- by 18 of 22 vanilla crafting skills (Carpentry, Cooking,
-- Farming, etc.).
--
-- Part of PhobosChemistryPathways.
---------------------------------------------------------------

SkillBook["AppliedChemistry"] = {}
SkillBook["AppliedChemistry"].perk = Perks.AppliedChemistry
SkillBook["AppliedChemistry"].maxMultiplier1 = 3
SkillBook["AppliedChemistry"].maxMultiplier2 = 5
SkillBook["AppliedChemistry"].maxMultiplier3 = 8
SkillBook["AppliedChemistry"].maxMultiplier4 = 12
SkillBook["AppliedChemistry"].maxMultiplier5 = 16
