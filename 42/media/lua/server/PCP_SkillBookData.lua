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
-- XP-multiplier books (right-click -> Read).
--
-- MUST live in server/, NOT shared/.  PZ loads shared/ before
-- server/, and vanilla XPSystem_SkillBook.lua (in server/
-- XpSystem/) resets SkillBook = {} on load -- wiping any
-- entries registered earlier from shared/.
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
