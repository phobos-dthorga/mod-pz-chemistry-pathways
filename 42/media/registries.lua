--[[
    PhobosChemistryPathways — Registry Declarations
    ================================================
    Build 42.13+ requires all custom identifiers to be registered here
    BEFORE scripts and Lua files load.  This file is loaded by the engine
    automatically from  media/registries.lua  and runs before everything else.

    See: https://pzwiki.net/wiki/Registries
]]

-- Character Traits
CharacterTrait.register("base:pcp_chemist_trait")
CharacterTrait.register("base:pcp_chemistry_enthusiast")
CharacterTrait.register("base:pcp_chem_aversion")

-- Character Professions
CharacterProfession.register("base:pcp_chemist")
CharacterProfession.register("base:pcp_pharmacist")
