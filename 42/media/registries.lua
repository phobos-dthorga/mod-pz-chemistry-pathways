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

--[[
    PhobosChemistryPathways — Registry Declarations
    ================================================
    Build 42.13+ requires all custom identifiers to be registered here
    BEFORE scripts and Lua files load.  This file is loaded by the engine
    automatically from  media/registries.lua  and runs before everything else.

    See: https://pzwiki.net/wiki/Registries
]]

-- Character Traits
CharacterTrait.register("pcp:pcp_chemist_trait")
CharacterTrait.register("pcp:pcp_chemistry_enthusiast")
CharacterTrait.register("pcp:pcp_chem_aversion")

-- Character Professions
CharacterProfession.register("pcp:pcp_chemist")
CharacterProfession.register("pcp:pcp_pharmacist")
