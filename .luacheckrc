-- .luacheckrc — PhobosChemistryPathways (PCP)
-- Lua 5.1 (Kahlua) for Project Zomboid Build 42

std = "lua51"

-- PZ mods define globals at top level (e.g. PCP_PuritySystem = {})
allow_defined_top = true

-- PZ modding uses long lines freely
max_line_length = false

-- PZ callback signatures have fixed args that aren't always used
unused_args = false

-- pcall returns ok,result; ok is often checked only implicitly
unused_secondaries = false

-- Suppress local variable code quality warnings (2XX–5XX).
-- The primary value of luacheck for PZ modding is catching undefined
-- globals (1XX) — typos in function names, missing requires, etc.
-- Local variable warnings (unused vars, shadowing, empty branches)
-- are non-critical in the PZ modding context where pcall patterns,
-- monkey-patching, and callback signatures create many false positives.
ignore = {
    "21.",   -- unused variable / argument / loop variable
    "22.",   -- variable accessed but never set
    "23.",   -- variable set but never used
    "31.",   -- value assigned is unused
    "4..",   -- shadowing / redefinition
    "5..",   -- code quality (unreachable code, empty blocks)
}

-- PCP's own global namespaces + PZ globals that PCP writes to
globals = {
    "PCP_ApplyPoulticeAction",
    "PCP_BotanicalCallbacks",
    "PCP_CollectBrineAction",
    "PCP_HazardSystem",
    "PCP_HorticultureCallbacks",
    "PCP_PuritySystem",
    "PCP_RecipeCallbacks",
    "PCP_Sandbox",
    "PCP_Reset",
    "PCP_TakeTinctureAction",
    -- PZ globals PCP writes to (skill book registration, DT integration)
    "DynamicTrading",
    "SkillBook",
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

    -- PZ engine core
    "ScriptManager",

    -- PZ engine functions
    "getActivatedMods",
    "getCore",
    "getDebug",
    "getGameTime",
    "getOnlinePlayers",
    "getPlayer",
    "getSpecificPlayer",
    "getSandboxOptions",
    "getText",
    "getTextManager",
    "getTimestampMs",
    "getWorld",
    "instanceof",
    "instanceItem",
    "forageSystem",
    "isClient",
    "isServer",
    "luautils",
    "sendItemStats",
    "sendAddItemToContainer",
    "sendRemoveItemFromContainer",
    "sendServerCommand",

    -- PZ UI classes
    "HaloTextHelper",
    "ISBaseTimedAction",
    "ISButton",
    "ISCollapsableWindow",
    "ISModalRichText",
    "ISRichTextPanel",
    "ISTimedActionQueue",
    "ISWorldObjectContextMenu",

    -- PZ distribution globals (loot tables)
    "ProceduralDistributions",
    "SuburbsDistributions",
    "VehicleDistributions",

    -- PZ registration globals
    "CharacterTrait",
    "CharacterProfession",

    -- Cross-mod (optional, runtime-guarded)
    "MF",
    "ZScienceSkill",
}

-- Translation files define globals like ItemName_EN, Sandbox_EN, etc.
-- These are PZ convention — exclude from warnings
files["42/media/lua/shared/Translate/**/*.txt"] = { allow_defined_top = true }
files["42/media/lua/client/Translate/**/*.txt"] = { allow_defined_top = true }
