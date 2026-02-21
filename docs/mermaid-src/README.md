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

# Mermaid Source Files

Standalone `.mmd` diagram sources for CLI rendering.
These are the same diagrams embedded in [`../diagrams/*.md`](../diagrams/), extracted for batch processing.

## Files

| File | Diagram |
|------|---------|
| `recipe-overview.mmd` | Complete recipe pathway flowchart (all 185 recipes) |
| `blackpowder-detail.mmd` | Blackpowder synthesis chain (Steps 1-7) |
| `biodiesel-detail.mmd` | Biodiesel production chain (Steps 1-5) |
| `bonechar.mmd` | Bone char pyrolysis pathway |
| `sandbox-recipe-gating.mmd` | Recipe gating sandbox options |
| `sandbox-purity-yield.mmd` | Purity and yield sandbox options |
| `skill-progression.mmd` | Occupations and traits |
| `learning-paths.mmd` | Recipe learning methods |
| `architecture.mmd` | Mod architecture and dependencies |
| `crossmod-integration.mmd` | Cross-mod integration checks |
| `purity-system.mmd` | Purity propagation across recipe chains |

## Re-render all to PNG

```bash
npm install -g @mermaid-js/mermaid-cli
for f in *.mmd; do mmdc -i "$f" -o "../images/${f%.mmd}.png" -b white -s 2; done
```
