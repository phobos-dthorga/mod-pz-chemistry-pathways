# Mermaid Source Files

Standalone `.mmd` diagram sources for CLI rendering.
These are the same diagrams embedded in [`../diagrams/*.md`](../diagrams/), extracted for batch processing.

## Files

| File | Diagram |
|------|---------|
| `recipe-overview.mmd` | All 7 crafting pathways (top-level overview) |
| `blackpowder-detail.mmd` | Blackpowder chain steps 1-7 with quantities |
| `biodiesel-detail.mmd` | Biodiesel pipeline with 3 equipment tiers |
| `sandbox-gating.mmd` | 7 sandbox options decision tree |
| `skill-progression.mmd` | Character creation (occupations, traits) |
| `architecture.mmd` | Dependency hierarchy (hard + soft deps) |
| `crossmod-integration.mmd` | ZScienceSkill + EHR detection flow |
| `purity-system.mmd` | Source / Propagation / Terminal purity flow |
| `learning-paths.mmd` | 4 recipe learning methods |
| `bonechar.mmd` | Bone char pyrolysis pathway |

## Re-render all to PNG

```bash
npm install -g @mermaid-js/mermaid-cli
for f in *.mmd; do mmdc -i "$f" -o "../images/${f%.mmd}.png" -b white -s 2; done
```
