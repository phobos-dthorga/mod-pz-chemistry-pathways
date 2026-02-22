--  ________________________________________________________________________
-- / Copyright (c) 2026 Phobos A. D'thorga                                \
-- |                                                                        |
-- |           /\_/\                                                         |
-- |         =/ o o \=    Phobos' PZ Modding                                |
-- |          (  V  )     All rights reserved.                              |
-- |     /\  / \   / \                                                      |
-- |    /  \/   '-'   \   This source code is part of the Phobos            |
-- |   /  /  \  ^  /\  \  mod suite for Project Zomboid (Build 42).         |
-- |  (__/    \_/ \/  \__)                                                  |
-- |     |   | |  | |     Unauthorised copying, modification, or            |
-- |     |___|_|  |_|     distribution of this file is prohibited.          |
-- |                                                                        |
-- \________________________________________________________________________/
--

---------------------------------------------------------------
-- PCP_ChangelogPopup.lua
-- Registers a "What's New" changelog popup for PCP via PhobosLib.
-- Shows once per major/minor version change. Patch bumps ignored.
--
-- To update for a future release:
--   1. Bump PCP_VERSION below.
--   2. Add a new version block at the top of buildChangelogContent().
--   3. Push to Workshop.
---------------------------------------------------------------

local PCP_VERSION = "0.24.0"

local function buildChangelogContent()
    local t = ""

    -- ════════════════════════════════════════════════════════════════ --
    -- Header
    -- ════════════════════════════════════════════════════════════════ --
    t = t .. "<H1> <CENTRE> Phobos' Chemistry Pathways <LINE> "
    t = t .. "<CENTRE> <SIZE:small> <RGB:0.55,0.65,0.85> Version " .. PCP_VERSION
          .. "  |  February 2026 <LINE> <LINE> "

    -- ════════════════════════════════════════════════════════════════ --
    -- v0.24  ·  current release
    -- ════════════════════════════════════════════════════════════════ --
    t = t .. "<LEFT> <SIZE:medium> <RGB:0.40,0.80,1.00> "
    t = t .. "--- v0.24  ( You are here ) "
    t = t .. "<SIZE:small> <RGB:0.55,0.65,0.85>  Feb 2026 <LINE> <LINE> "

    t = t .. "<SIZE:small> <RGB:1.00,0.75,0.20> "
    t = t .. "> Welcome Guide + Changelog Popups <LINE> "
    t = t .. "<RGB:0.88,0.88,0.88> "
    t = t .. "New players now see a Quick Guide introducing PCP's mechanics, "
    t = t .. "crafting tiers, and purity system on first game start. "
    t = t .. "Returning players see this What's New window after each "
    t = t .. "minor or major version update. Both popups are powered "
    t = t .. "by a new generic PhobosLib popup system. <LINE> "
    t = t .. "<LINE> "

    t = t .. "<RGB:1.00,0.75,0.20> > Bug Fix: Mixer Item IDs <LINE> "
    t = t .. "<RGB:0.88,0.88,0.88> "
    t = t .. "Fixed two invalid item references in mixer recipes that "
    t = t .. "caused Java exceptions at world load: blackpowder output "
    t = t .. "now correctly references GunPowder, and wood vinegar "
    t = t .. "output now correctly references Vinegar2. <LINE> "
    t = t .. "<LINE> "

    -- ════════════════════════════════════════════════════════════════ --
    -- v0.23
    -- ════════════════════════════════════════════════════════════════ --
    t = t .. "<LEFT> <SIZE:medium> <RGB:0.45,0.70,0.90> "
    t = t .. "--- v0.23 "
    t = t .. "<SIZE:small> <RGB:0.55,0.65,0.85>  Feb 2026 <LINE> <LINE> "

    t = t .. "<SIZE:small> <RGB:1.00,0.75,0.20> "
    t = t .. "> Functional Concrete Mixer <LINE> "
    t = t .. "<RGB:0.88,0.88,0.88> "
    t = t .. "The decorative concrete mixer is now a powered CraftBench "
    t = t .. "workstation requiring electricity (generator or grid power). "
    t = t .. "13 new recipes: 6 construction mixes (concrete, clay cement, "
    t = t .. "mortar, stucco, reinforced concrete, fireclay) and 6 bulk "
    t = t .. "chemistry alternatives (blackpowder, biodiesel, soap, compost, "
    t = t .. "plaster, wood vinegar) at lower purity than lab synthesis. "
    t = t .. "Build your own mixer with Metalworking 4. <LINE> "
    t = t .. "<LINE> "

    t = t .. "<RGB:0.80,0.80,0.80> "
    t = t .. "4 new items: MortarMix, StuccoMix, ReinforcedConcrete, Fireclay <LINE> "
    t = t .. "3 new sandbox options for mixer configuration <LINE> "
    t = t .. "New crafting category: Industrial Chemistry <LINE> "
    t = t .. "Generator fuel drain proportional to recipe duration <LINE> "
    t = t .. "<LINE> "

    -- ════════════════════════════════════════════════════════════════ --
    -- v0.22
    -- ════════════════════════════════════════════════════════════════ --
    t = t .. "<SIZE:medium> <RGB:0.45,0.65,0.75> "
    t = t .. "--- v0.22 "
    t = t .. "<SIZE:small> <RGB:0.55,0.65,0.85>  Feb 2026 <LINE> <LINE> "

    t = t .. "<SIZE:small> <RGB:1.00,0.75,0.20> "
    t = t .. "> Wave 1+2 Recipes + Agriculture Pathways <LINE> "
    t = t .. "<RGB:0.88,0.88,0.88> "
    t = t .. "Major content expansion: agriculture recipes (composting, "
    t = t .. "wood vinegar distillation, chemical tanning, farming sprays), "
    t = t .. "water purification, fire-starting reagents, leather tanning. "
    t = t .. "New hazard/DT fixes, farming spray integration. <LINE> "
    t = t .. "<LINE> "

    t = t .. "<RGB:0.80,0.80,0.80> "
    t = t .. "185 recipes, 39 items, 13 sandbox options <LINE> "
    t = t .. "PhobosLib tooltip nil guards and farming spray module <LINE> "
    t = t .. "<LINE> "

    -- ════════════════════════════════════════════════════════════════ --
    -- v0.21
    -- ════════════════════════════════════════════════════════════════ --
    t = t .. "<SIZE:medium> <RGB:0.40,0.55,0.60> "
    t = t .. "--- v0.21 "
    t = t .. "<SIZE:small> <RGB:0.55,0.65,0.85>  Feb 2026 <LINE> <LINE> "

    t = t .. "<SIZE:small> <RGB:0.80,0.80,0.80> "
    t = t .. "Dynamic Trading multi-vendor integration <LINE> "
    t = t .. "Vessel replacement system for empty FluidContainers <LINE> "
    t = t .. "LazyStamp system for container-opening purity stamping <LINE> "
    t = t .. "Purity tooltip with quality tier display <LINE> "
    t = t .. "<LINE> "

    -- ════════════════════════════════════════════════════════════════ --
    -- v0.20
    -- ════════════════════════════════════════════════════════════════ --
    t = t .. "<SIZE:medium> <RGB:0.38,0.50,0.55> "
    t = t .. "--- v0.20 "
    t = t .. "<SIZE:small> <RGB:0.55,0.65,0.85>  Feb 2026 <LINE> <LINE> "

    t = t .. "<SIZE:small> <RGB:0.72,0.72,0.72> "
    t = t .. "FluidContainer rescale migration (ConditionMax 10 -> 100) <LINE> "
    t = t .. "Purity = item condition system overhaul <LINE> "
    t = t .. "<LINE> "

    -- ════════════════════════════════════════════════════════════════ --
    -- Earlier
    -- ════════════════════════════════════════════════════════════════ --
    t = t .. "<SIZE:medium> <RGB:0.35,0.45,0.50> "
    t = t .. "--- Earlier versions "
    t = t .. "<SIZE:small> <RGB:0.55,0.65,0.85> <LINE> <LINE> "

    t = t .. "<SIZE:small> <RGB:0.58,0.58,0.58> "
    t = t .. "v0.19: Consolidated migration framework <LINE> "
    t = t .. "v0.18: First migration system, recipe filter hooks <LINE> "
    t = t .. "v0.17 and earlier: Core chemistry pathways, item definitions <LINE> "
    t = t .. "<LINE> "

    -- ════════════════════════════════════════════════════════════════ --
    -- Footer
    -- ════════════════════════════════════════════════════════════════ --
    t = t .. "<CENTRE> <SIZE:small> <RGB:0.40,0.40,0.40> "
    t = t .. "Workshop: search  Phobos Chemistry Pathways  <LINE> "
    t = t .. "Bug reports and feedback welcome in the Workshop comments. <LINE> "
    t = t .. "<LINE> "

    return t
end

-- Register with PhobosLib popup system
PhobosLib.registerChangelogPopup("PCP", {
    title          = "Phobos' Chemistry Pathways  \226\128\148  What's New",
    buildContent   = buildChangelogContent,
    currentVersion = PCP_VERSION,
    width          = 620,
    height         = 680,
})

print("[PCP] ChangelogPopup: registered [client] (v" .. PCP_VERSION .. ")")
