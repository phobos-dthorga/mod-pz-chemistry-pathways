-- .luacheckrc — PhobosChemistryPathways (PCP)
-- Lua 5.1 (Kahlua) for Project Zomboid Build 42

std = "lua51"

-- PZ mods define globals at top level (e.g. PCP_PuritySystem = {})
allow_defined_top = true

-- PZ modding uses long lines freely
max_line_length = false

-- PCP's own global namespaces
globals = {
    "PCP_BotanicalCallbacks",
    "PCP_CollectBrineAction",
    "PCP_HazardSystem",
    "PCP_HorticultureCallbacks",
    "PCP_PuritySystem",
    "PCP_RecipeCallbacks",
    "PCP_Sandbox",
    "PCP_Reset",
}

read_globals = {
    -- PhobosLib (loaded via require)
    "PhobosLib",

    -- PZ engine core
    "Events",
    "SandboxVars",
    "Perks",
    "ModData",
    "FluidType",
    "UIFont",

    -- PZ engine functions
    "getActivatedMods",
    "getCore",
    "getDebug",
    "getGameTime",
    "getPlayer",
    "getSpecificPlayer",
    "getSandboxOptions",
    "getText",
    "getTextManager",
    "getTimestampMs",
    "getWorld",
    "instanceof",
    "instanceItem",
    "isClient",
    "isServer",
    "sendItemStats",
    "sendAddItemToContainer",
    "sendRemoveItemFromContainer",

    -- PZ UI classes
    "ISBaseTimedAction",
    "ISButton",
    "ISCollapsableWindow",
    "ISRichTextPanel",
    "ISTimedActionQueue",
    "ISWorldObjectContextMenu",

    -- PZ distribution globals (loot tables)
    "ProceduralDistributions",
    "SuburbsDistributions",

    -- PZ registration globals
    "CharacterTrait",
    "CharacterProfession",
    "SkillBook",

    -- Cross-mod (optional, runtime-guarded)
    "DynamicTrading",
    "ZScienceSkill",
}

-- Translation files define globals like ItemName_EN, Sandbox_EN, etc.
-- These are PZ convention — exclude from warnings
files["42/media/lua/shared/Translate/**/*.txt"] = { allow_defined_top = true }
files["42/media/lua/client/Translate/**/*.txt"] = { allow_defined_top = true }
