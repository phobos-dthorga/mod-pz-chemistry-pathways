<!--
  ________________________________________________________________________
 / Copyright (c) 2026 Phobos A. D'thorga                                \
 |                                                                        |
 |           /\_/\                                                         |
 |         =/ o o \=    Phobos' PZ Modding                                |
 |          (  V  )     All rights reserved.                              |
 |     /\  / \   / \                                                      |
 |    /  \/   '-'   \   This source code is part of the Phobos            |
 |   /  /  \  ^  /\  \  mod suite for Project Zomboid (Build 42).         |
 |  (__/    \_/ \/  \__)                                                  |
 |     |   | |  | |     Unauthorised copying, modification, or            |
 |     |___|_|  |_|     distribution of this file is prohibited.          |
 |                                                                        |
 \________________________________________________________________________/
-->

# Architecture & Dependencies

PhobosChemistryPathways (PCP) has two hard dependencies (PhobosLib and Zombie Virus Vaccine) and four optional soft dependencies that are detected at runtime. All cross-mod integrations are guarded by `getActivatedMods():contains()` checks, so players who install only PCP and its required dependencies will never encounter errors from missing optional mods.

## Mod Architecture

The diagram below shows PCP's internal module structure, its hard dependencies, and how each subsystem delegates to PhobosLib.

```mermaid
graph TB
    subgraph HARD["Hard Dependencies (mod.info require)"]
        PL["PhobosLib v1.18.1+<br/>24 modules (13 shared + 11 client/server)"]
        ZR["Zombie Virus Vaccine<br/>Lab equipment entities"]
    end

    subgraph PCP["PhobosChemistryPathways v1.5.0"]
        CORE["Core"]
        REC["301 Recipes<br/>9 recipe files"]
        ITEMS["121 Items<br/>+ 6 Recipe Books"]
        FLUIDS["10 Fluids"]
        SB["66 Sandbox Options"]
        PURITY["Purity System<br/>PCP_PuritySystem.lua"]
        HAZARD["Hazard System<br/>PCP_HazardSystem.lua"]
        SKILL["Skill System<br/>perks + professions + traits"]
        CALLBACKS["216 OnCreate Callbacks<br/>PCP_RecipeCallbacks.lua<br/>PCP_BotanicalCallbacks.lua"]
        TRADING["DT Integration<br/>PCP_DynamicTradingData.lua"]
        MIXER["Concrete Mixer<br/>13 Recipes (6 construction<br/>+ 5 bulk chem + 1 plaster + 1 build)<br/>PCP_MixerCompat.lua"]
        POPUP["Guide + Changelog + Notice Popups<br/>PCP_GuidePopup.lua<br/>PCP_ChangelogPopup.lua"]
        SALT["Salt Extraction<br/>6 Recipes (brine → table salt)<br/>PCP_BrineCollection.lua"]
        REBIND["Entity Rebinding<br/>PCP_EntityRebind.lua"]
        BOTANICAL["Botanical Pathway<br/>31 Recipes (retting, textiles,<br/>paper, medicinals, hempcrete)<br/>PCP_BotanicalCallbacks.lua"]
        HORT["Horticulture Items<br/>45 items (tobacco, hemp buds,<br/>smoking, edibles, cooking)<br/>PCP_HorticultureItems.txt"]
        MIGRATE["Migration System<br/>PCP_MigrationSystem.lua<br/>(Horticulture mod migration)"]
    end

    subgraph SOFT["Soft Dependencies (runtime-detected)"]
        ZSS["ZScienceSkill<br/>Science, Bitch!"]
        EHR["EHR v2.8.1<br/>Extensive Health Rework"]
        DT["DynamicTradingCommon<br/>NPC Trading"]
        NC["NeatCrafting<br/>Neat Crafting"]
        MF["MoodleFramework<br/>Custom Moodles"]
    end

    PL --> CORE
    ZR --> REC

    PURITY -->|"delegates to<br/>PhobosLib_Quality"| PL
    HAZARD -->|"delegates to<br/>PhobosLib_Hazard"| PL
    SKILL -->|"delegates to<br/>PhobosLib_Skill"| PL
    CALLBACKS -->|"uses<br/>PhobosLib_Sandbox<br/>PhobosLib_Fluid"| PL
    TRADING -->|"uses<br/>PhobosLib_Trading"| PL
    FARMING["Farming Compat<br/>PCP_FarmingCompat.lua"]
    FARMING -->|"uses<br/>PhobosLib_FarmingSpray"| PL
    MIXER -->|"uses<br/>PhobosLib_Power"| PL
    POPUP -->|"uses<br/>PhobosLib_Popup"| PL
    SALT -->|"uses<br/>PhobosLib_WorldAction<br/>PhobosLib_Fluid"| PL
    REBIND -->|"uses<br/>PhobosLib_EntityRebind"| PL
    BOTANICAL -->|"uses<br/>PhobosLib_Sandbox<br/>PhobosLib_Fluid"| PL
    MIGRATE -->|"uses<br/>PhobosLib_Migrate<br/>PhobosLib_Sandbox"| PL
    HORT -->|"uses<br/>PhobosLib_Debug<br/>PhobosLib_Fermentation"| PL
    POPUP -->|"uses<br/>PhobosLib_Moodle"| PL

    HAZARD -.->|"EHR.Disease.TryContract<br/>(pcall-wrapped)"| EHR
    SKILL -.->|"registerXPMirror<br/>AC to Science at 50%"| ZSS
    TRADING -.->|"registerTradeItems<br/>(76 items, 1 tag, 1 archetype)"| DT
    REC -.->|"PhobosLib_RecipeFilter<br/>(NC_FilterBar hook)"| NC
    HORT -.->|"Medicated moodle<br/>(pcall-wrapped)"| MF

    style HARD fill:#264,color:#fff
    style SOFT fill:#446,color:#fff
```

## Cross-Mod Integration

Each soft dependency is detected at game start. When present, PCP registers its data with the external mod's API. When absent, the integration code is silently skipped with zero errors.

```mermaid
graph TB
    START["Game Start"] --> CHECK_ZSS{"isModActive<br/>ZScienceSkill?"}
    START --> CHECK_EHR{"isModActive<br/>EHR?"}

    CHECK_ZSS -->|"Yes"| ZSS_INIT["Register XP Mirror<br/>AC -> Science at 50%<br/>(PCP_SkillXP.lua)"]
    CHECK_ZSS -->|"Yes"| ZSS_DATA["Register 83 Item + 8 Fluid<br/>Specimens | API: ZScienceSkill.Data.add<br/>(PCP_ZScienceData.lua)"]
    CHECK_ZSS -->|"No"| ZSS_SKIP["No action<br/>Zero errors"]

    CHECK_EHR -->|"Yes"| EHR_INIT["Hazard callbacks use<br/>EHR.Disease.TryContract<br/>(pcall-wrapped)"]
    CHECK_EHR -->|"No"| EHR_SKIP["Hazard callbacks use<br/>vanilla stat penalties<br/>(Sickness, Pain, Stress)"]

    START --> CHECK_DT{"isModActive<br/>DynamicTradingCommon?"}
    START --> CHECK_NC{"NC_FilterBar<br/>exists?"}

    CHECK_DT -->|"Yes"| DT_INIT["Register Chemist Archetype<br/>+ 76 Items across 9 Vendors<br/>(PCP_DynamicTradingData.lua)"]
    CHECK_DT -->|"No"| DT_SKIP["No action<br/>Zero errors"]

    CHECK_NC -->|"Yes"| NC_INIT["Hook NC_FilterBar:shouldIncludeRecipe<br/>for recipe visibility filters<br/>(PhobosLib_RecipeFilter.lua)"]
    CHECK_NC -->|"No"| NC_SKIP["Use vanilla ISRecipeScrollingListBox<br/>+ ISTiledIconPanel overrides"]
```

## File Locations

| Directory | Contents |
|-----------|----------|
| `42/media/scripts/` | Item definitions, recipe definitions, fluid definitions, sandbox options, perks, professions, traits, entity definitions |
| `42/media/lua/client/` | Tooltip providers, recipe filters, vessel replacement, lazy stamping, farming compat, Dynamic Trading stamp, mixer compat, guide/changelog popups, brine collection |
| `42/media/lua/server/` | Skill book registration, recipe callbacks, purity system, hazard system, entity rebinding |
| `42/media/lua/shared/` | Skill XP mirroring, ZScience data registration, Dynamic Trading data, registries |
| `42/media/lua/shared/Translate/EN/` | English translation strings for items, recipes, sandbox options, tooltips |
