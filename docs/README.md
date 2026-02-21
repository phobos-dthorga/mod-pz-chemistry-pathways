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

Visual documentation for PhobosChemistryPathways (PCP), covering recipe chains, sandbox configuration, skill progression, and mod architecture. All diagrams use [Mermaid.js](https://mermaid.js.org/) and render natively on GitHub.

## Table of Contents

| Guide | Description |
|-------|-------------|
| [Recipe Pathways](diagrams/recipe-pathways.md) | Complete crafting chain flowcharts for all 7 pathways |
| [Recipe Variants](diagrams/recipe-variants.md) | Recipe variant naming conventions and troubleshooting |
| [Sandbox Settings Guide](diagrams/sandbox-gating.md) | How 13 sandbox options control recipe visibility, behaviour, and maintenance |
| [Skill Progression](diagrams/skill-progression.md) | Applied Chemistry skill tiers, XP curve, occupations, and traits |
| [Architecture & Dependencies](diagrams/architecture.md) | Dependency graph, PhobosLib modules, and cross-mod integration |
| [Mermaid Sources](mermaid-src/README.md) | Standalone `.mmd` files for CLI re-rendering |

## Exported Images

The `images/` directory contains pre-rendered PNG exports of all diagrams, suitable for embedding in Steam Workshop descriptions, Discord posts, or other contexts where Mermaid rendering is not available.

To regenerate images from the Mermaid sources, see the [batch render instructions](mermaid-src/README.md).

## Mermaid Sources

The `mermaid-src/` directory contains standalone `.mmd` files -- the same diagrams embedded in the guides above, extracted into individual files for batch processing with the [Mermaid CLI](https://github.com/mermaid-js/mermaid-cli).
