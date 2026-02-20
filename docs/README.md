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

# PhobosChemistryPathways Documentation

Visual guides for understanding mod systems, recipe chains, and configuration options.

## Diagrams

| Diagram | Description |
|---------|-------------|
| [Recipe Pathways](diagrams/recipe-pathways.md) | Complete crafting chain flowcharts for all 7 pathways |
| [Recipe Variants](diagrams/recipe-variants.md) | Why recipes have multiple versions, naming conventions, and sandbox gating |
| [Sandbox Gating](diagrams/sandbox-gating.md) | How 12 sandbox options control recipe visibility and behavior |
| [Skill Progression](diagrams/skill-progression.md) | Applied Chemistry skill tiers, XP curve, occupations, and traits |
| [Architecture](diagrams/architecture.md) | Dependency graph, PhobosLib modules, and cross-mod integration |

All diagrams use [Mermaid.js](https://mermaid.js.org/) syntax and render natively on GitHub.

## Exported Images

Pre-rendered PNG versions of all diagrams are in [`images/`](images/) for use in Steam Workshop descriptions and Discord.

## Mermaid Sources

Standalone `.mmd` source files for CLI re-rendering are in [`mermaid-src/`](mermaid-src/). See the [README](mermaid-src/README.md) for batch render instructions.
