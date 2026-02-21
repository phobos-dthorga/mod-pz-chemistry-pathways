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

# Skill Progression

PhobosChemistryPathways adds a custom `AppliedChemistry` perk under the Crafting parent with a steeper XP curve (75-9000 per level). Two occupations and two traits provide starting skill levels and recipe grants at character creation. Five skill book volumes distributed as loot cover levels 1-10.

## Occupations & Traits

Two occupations (Chemist and Pharmacist) and two mutually exclusive traits (Chemistry Enthusiast and Chemical Aversion) determine starting Applied Chemistry levels and pre-learned recipes.

```mermaid
graph TB
    subgraph OCC["Occupations"]
        CHEM["Chemist<br/>Cost: -4 points<br/>AC: 3, Doctor: 1<br/>13 granted recipes"]
        PHARM["Pharmacist<br/>Cost: -2 points<br/>AC: 2, Doctor: 2<br/>5 granted recipes"]
    end

    subgraph TRAITS["Traits"]
        ENT["Chemistry Enthusiast<br/>Cost: +4 points<br/>AC: +1<br/>2 granted recipes"]
        AVR["Chemical Aversion<br/>Cost: -2 points<br/>AC: -1"]
        PROF["Chemist Profession Trait<br/>(auto-granted, not selectable)"]
    end

    ENT <-.->|"mutually exclusive"| AVR
    CHEM -->|"auto-grants"| PROF

    subgraph START["Starting Skill Levels"]
        CS["Chemist start:<br/>AC 3 + trait bonuses"]
        PS["Pharmacist start:<br/>AC 2 + trait bonuses"]
        DS["Default start:<br/>AC 0 + trait bonuses"]
    end

    CHEM --> CS
    PHARM --> PS
    ENT -.-> DS
```

## Learning Paths

There are three ways to learn PCP recipes: finding and reading the Chemistry Handbook (teaches all 185 recipes), reaching the auto-learn threshold for each recipe tier, or choosing an occupation/trait at character creation for pre-learned recipes. Tier 7 (advanced lab) recipes can only be learned from the handbook.

```mermaid
graph LR
    HB["Find Handbook<br/>(loot)"] --> LEARN["Learn all 185 recipes"]
    LEVEL["Reach AutoLearnAll level"] --> AUTO["Recipes auto-unlock<br/>(most tiers)"]
    CREATE["Choose Occupation/Trait"] --> GRANT["Pre-learned recipes<br/>(character creation)"]
    T7["Tier 7 recipes"] --> HB_ONLY["Handbook ONLY<br/>(no AutoLearnAll)"]

    style T7 fill:#c44,color:#fff
    style HB_ONLY fill:#c44,color:#fff
```

## Skill Tiers

All 185 recipes are distributed across 7 skill tiers. Higher tiers require more Applied Chemistry XP and gate access to increasingly complex chemistry.

| Tier | AC Level | Unlocks |
|------|----------|---------|
| 0 | 0 | Basic crushing, composting, and simple fat rendering |
| 1 | 1 | Charcoal purification, oil extraction (mortar and pestle), basic soap |
| 2 | 2 | KNO3 synthesis, battery acid extraction, bone char pyrolysis |
| 3 | 3 | Sulphur extraction, methanol distillation, biodiesel transesterification |
| 4 | 4 | Blackpowder mixing, biodiesel washing, recycling recipes |
| 5 | 5 | Refined biodiesel, advanced recycling, agriculture sprays |
| 6 | 6 | Centrifuge and chromatograph recipes, chemical tanning |
| 7 | 7 | Microscope and spectrometer recipes (handbook-only, gated by EnableAdvancedLabRecipes) |
