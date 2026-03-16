# PCP Art Style Guidelines

Plain-language reference for human and AI contributors creating icons for **Phobos' Industrial Pathways: Biomass** and related Phobos PZ mods.

---

## Format Requirements

| Property | Value |
|----------|-------|
| **Dimensions** | 128 x 128 pixels |
| **Colour mode** | RGBA (32-bit with alpha channel) |
| **File format** | PNG |
| **Background** | Fully transparent |
| **Naming** | `Item_PCP_<PascalCaseName>.png` for items |
|  | `profession_pcp_<lowercase>.png` for professions |

---

## Visual Style

- **Isometric pixel art** — 2D sprites viewed from a slight top-down isometric angle, consistent with Project Zomboid's vanilla inventory icons.
- **Clean dark outlines** — Every item should have crisp, well-defined dark edges that make it readable at small sizes.
- **Soft interior shading** — Flat fills with minimal gradients. Where shading is used, it should be subtle and follow the isometric light source (top-left).
- **Muted post-apocalyptic colour palette** — Favour earthy, desaturated tones. Avoid neon, hyper-saturated, or "clean" modern colours.
- **Single item, centered** — One item per icon, placed centrally with small padding on all sides (roughly 4-8 px).
- **No text, labels, or UI elements** — Icons should contain only the item itself. No item names, stat numbers, or decorative borders.

---

## Composition Guidelines

- Items should look like they belong in a crafting/inventory menu alongside vanilla PZ items.
- For liquids in jars/bottles: show the container with visible liquid level and colour.
- For stackable materials (powders, fibres, scraps): show a small pile or bundle, not a single particle.
- For tools/equipment: show the complete item in a neutral resting position.
- For profession portraits: show a character bust (head + shoulders) with profession-relevant props.

---

## Reference Icons

The following existing PCP icons represent the target quality standard. New icons should match their style:

| Icon | Why It's Good |
|------|--------------|
| `Item_PCP_HempRope.png` | Clean braided rope with clear outlines and natural tan palette |
| `Item_PCP_BoneChar.png` | Granular material pile with good isometric shading |
| `Item_PCP_LeadScrap.png` | Metallic salvage chunks with scratched surface detail |
| `Item_PCP_SmokingPipeGlass.png` | Glass transparency rendered in pixel art style |
| `Item_PCP_CrudeSoap.png` | Simple organic shape with muted tones |
| `Item_PCP_HempSnare.png` | Multi-part item (stick + rope) clearly rendered at small scale |

---

## Anti-Patterns (What NOT to Do)

- **No photorealism** — 3D-rendered or photo-quality images clash with PZ's art direction.
- **No white/opaque backgrounds** — Every icon must have a transparent background. No white fills, no shadows on a surface.
- **No soft illustration style** — Watercolour washes, soft-focus blurs, or pastel gradients without outlines look out of place.
- **No bright/saturated colours** — Neon greens, electric blues, or pure-white highlights feel wrong in the PZ apocalyptic aesthetic.
- **No tiny/placeholder icons** — Icons smaller than 128x128 or with minimal detail (a few coloured pixels) are not acceptable.

---

## Generation Pipeline (AI-Assisted)

For AI-generated icons using OpenAI's image API:

1. **Model**: `gpt-image-1`
2. **Source size**: `1024x1024` (the API generates at this resolution)
3. **Background**: `"transparent"` parameter
4. **Quality**: `"high"`
5. **Resize**: Use Pillow (PIL) `Image.LANCZOS` downscale to 128x128
6. **Prompt prefix** (for items):
   ```
   A single item icon for a 2D top-down survival video game inventory.
   Isometric pixel-art style, 128x128 pixels, transparent background.
   Clean dark outlines, soft shading, item centered in frame with small padding.
   No text, no labels, no UI elements. Consistent with Project Zomboid art style.
   ```
7. **Prompt prefix** (for professions):
   ```
   A character portrait icon for a 2D survival video game profession select screen.
   Isometric pixel-art style, 128x128 pixels, transparent background.
   Clean dark outlines, soft shading, character bust centered.
   No text, no labels, no UI elements. Consistent with Project Zomboid art style.
   Post-apocalyptic appearance, muted colour palette.
   ```
8. **Verification**: After generation, confirm RGBA mode, transparent pixels present, and 128x128 dimensions using Pillow.

---

## Furniture Sprites (Tilesheets)

Custom placeable furniture uses PZ's tilesheet system — 2D isometric sprites on a grid, not 3D models. These are separate from inventory icons.

### Format Requirements (Furniture)

| Property | Value |
|----------|-------|
| **Cell size (1x)** | 128 x 256 pixels |
| **Cell size (2x)** | 256 x 512 pixels |
| **Colour mode** | RGBA (32-bit with alpha channel) |
| **File format** | PNG (source), `.pack` (compiled for PZ) |
| **Background** | Fully transparent |
| **Grid layout** | 8 columns, N rows (matching PZ convention) |
| **Facing order** | S, E, N, W (left to right in grid row) |
| **Naming** | `{item_id}_{facing}_{resolution}.png` for individual facings |

### Visual Style (Furniture)

- **True isometric perspective** — ~45° from above, matching PZ's world tile rendering (not the flatter inventory icon angle).
- **Bottom-aligned** — The base of the object sits at the bottom of the cell. This ensures correct ground alignment when placed.
- **Consistent scale** — A single-tile object should fill roughly 60-80% of the cell width and 40-70% of the cell height, depending on the item's proportions.
- **All four facings must be consistent** — Same object, same proportions, just rotated 90° between S/E/N/W. Asymmetric details (valves, gauges, labels) should rotate correctly.
- **Same art rules as inventory icons** — Clean dark outlines, soft shading, muted palette, no text/labels.

### Prompt Prefix (Furniture)

```
A single piece of furniture or equipment for a 2D isometric survival video game.
Isometric view at approximately 45 degrees from above, transparent background.
The object occupies a single floor tile (1x1 grid cell) and is taller than it is wide.
Clean dark outlines, soft interior shading with light from the top-left.
Muted post-apocalyptic colour palette — earthy, desaturated tones.
No text, no labels, no UI elements, no floor or ground surface.
Consistent with Project Zomboid Build 42 tile art style.
Facing: {direction description}.
```

### Generation Pipeline (Furniture)

1. **Define item** in `scripts/furniture_items.json` (name, facings, weight, description)
2. **Generate sprites**: `py scripts/generate_furniture_sprite.py [ItemId]`
   - Calls gpt-image-1 once per facing (4 calls for S/E/N/W items)
   - Outputs raw 1024x1024 + cropped/resized 1x and 2x PNGs to `scripts/sprite_output/`
3. **Assemble tilesheet**: `py scripts/build_tilesheet.py`
   - Combines all facing PNGs into grid tilesheets (1x and 2x)
   - Outputs to `common/media/texturepacks/pcp_tiles_01_src.png` (and 2x variant)
4. **Generate tile definitions**: `py scripts/generate_tiles_txt.py`
   - Produces `common/media/pcp_tiles.tiles.txt` with all tile property blocks
   - Prints sprite name mapping for entity `SpriteConfig` references
5. **Compile .pack** (if required by PZ): Use TileZed or manual compilation
6. **Register** in `mod.info`: `tiledef=pcp_tiles 4200` and `pack=pcp_tiles`

### Tilesheet File Locations

| File | Location |
|------|----------|
| Item config | `scripts/furniture_items.json` |
| Source sprites | `scripts/sprite_output/` (gitignored) |
| Tilesheet source PNG | `common/media/texturepacks/pcp_tiles_01_src.png` |
| Tile definitions | `common/media/pcp_tiles.tiles.txt` |
| Compiled atlas (1x) | `common/media/texturepacks/pcp_tiles.pack` |
| Compiled atlas (2x) | `common/media/texturepacks/pcp_tiles2x.pack` |

---

## File Location

All item textures live in:
```
common/media/textures/
```

Generation scripts live in:
```
scripts/
```

Each generation batch should have its own script (e.g., `generate_hemp_expansion_icons.py`) for reproducibility.
