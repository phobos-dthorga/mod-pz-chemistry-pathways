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
-- PCP_GuidePopup.lua
-- Registers a first-time welcome guide for PCP via PhobosLib.
-- Shows on every game start until "Don't show again" is checked.
---------------------------------------------------------------

local function buildGuideContent()
    local V = PhobosLib and PhobosLib.VERSION or "?"
    local t = ""

    -- ── Title ──
    t = t .. "<H1> Phobos' Chemistry Pathways <LINE> "
    t = t .. "<CENTRE> <SIZE:small> <RGB:0.6,0.6,0.6> Quick Guide <LINE> "
    t = t .. "<LINE> "

    -- ── What this mod adds ──
    t = t .. "<SIZE:medium> <LEFT> <RGB:0.5,0.85,1.0> What this mod adds <LINE> "
    t = t .. "<TEXT> <RGB:0.9,0.9,0.9> "
    t = t .. "PCP adds real-world chemistry to Project Zomboid through 7 "
    t = t .. "interconnected pathways: blackpowder synthesis, biodiesel production, "
    t = t .. "fat rendering, soap-making, bone char processing, material recycling, "
    t = t .. "and advanced laboratory processes. <LINE> "
    t = t .. "<LINE> "
    t = t .. "Everything you craft has a <RGB:1.0,0.85,0.3> purity rating "
    t = t .. "<RGB:0.9,0.9,0.9> — higher skill and better equipment "
    t = t .. "produce purer products, which in turn yield better results "
    t = t .. "when used as inputs in downstream recipes. <LINE> "
    t = t .. "<LINE> "

    -- ── Crafting categories ──
    t = t .. "<SIZE:medium> <RGB:0.5,0.85,1.0> Crafting workstations <LINE> "
    t = t .. "<TEXT> <RGB:0.9,0.9,0.9> "
    t = t .. "Recipes are organised into four tiers of workstation: <LINE> "
    t = t .. "<LINE> "
    t = t .. "<RGB:1.0,0.85,0.3> Field Chemistry <RGB:0.9,0.9,0.9> "
    t = t .. " — No special equipment needed. Campfires, basic tools. "
    t = t .. "Great for getting started. <LINE> "
    t = t .. "<RGB:1.0,0.85,0.3> Kitchen Chemistry <RGB:0.9,0.9,0.9> "
    t = t .. " — Cooking pot required. Fat rendering, soap, bone char. <LINE> "
    t = t .. "<RGB:1.0,0.85,0.3> Lab Chemistry <RGB:0.9,0.9,0.9> "
    t = t .. " — zReVaccin chemistry set. Best purity, advanced reactions. <LINE> "
    t = t .. "<RGB:1.0,0.85,0.3> Industrial Chemistry <RGB:0.9,0.9,0.9> "
    t = t .. " — Concrete mixer (requires electricity). Bulk production "
    t = t .. "at lower purity. <LINE> "
    t = t .. "<LINE> "

    -- ── How purity works ──
    t = t .. "<SIZE:medium> <RGB:0.5,0.85,1.0> How purity works <LINE> "
    t = t .. "<TEXT> <RGB:0.9,0.9,0.9> "
    t = t .. "The item condition bar doubles as a purity indicator. "
    t = t .. "A sulphur powder at 75% condition means 75% purity. <LINE> "
    t = t .. "<LINE> "
    t = t .. "- Higher <RGB:1.0,0.85,0.3> Applied Chemistry <RGB:0.9,0.9,0.9> "
    t = t .. "skill improves purity <LINE> "
    t = t .. "- Lab equipment (chemistry set) gives the best purity range <LINE> "
    t = t .. "- Kitchen/field methods give lower purity <LINE> "
    t = t .. "- Input purity affects output purity in multi-step chains <LINE> "
    t = t .. "<LINE> "

    -- ── Getting started ──
    t = t .. "<SIZE:medium> <RGB:0.5,0.85,1.0> Getting started <LINE> "
    t = t .. "<TEXT> <RGB:0.9,0.9,0.9> "
    t = t .. "<RGB:1.0,0.85,0.3> 1. <RGB:0.9,0.9,0.9> "
    t = t .. "Find the <RGB:1.0,0.85,0.3> Chemistry Pathways Handbook "
    t = t .. "<RGB:0.9,0.9,0.9> (loots from shelves, classrooms, labs). "
    t = t .. "Reading it unlocks most recipes. <LINE> "
    t = t .. "<RGB:1.0,0.85,0.3> 2. <RGB:0.9,0.9,0.9> "
    t = t .. "Start with <RGB:1.0,0.85,0.3> Field Chemistry "
    t = t .. "<RGB:0.9,0.9,0.9> recipes — crush charcoal, "
    t = t .. "extract potash from ash, scavenge sulphur from matches. <LINE> "
    t = t .. "<RGB:1.0,0.85,0.3> 3. <RGB:0.9,0.9,0.9> "
    t = t .. "Find a cooking pot for <RGB:1.0,0.85,0.3> Kitchen Chemistry "
    t = t .. "<RGB:0.9,0.9,0.9> — render animal fat, make soap, "
    t = t .. "process bone char. <LINE> "
    t = t .. "<RGB:1.0,0.85,0.3> 4. <RGB:0.9,0.9,0.9> "
    t = t .. "Locate a zReVaccin lab for <RGB:1.0,0.85,0.3> Lab Chemistry "
    t = t .. "<RGB:0.9,0.9,0.9> — synthesise sulphuric acid, "
    t = t .. "potassium nitrate, and full blackpowder at peak purity. <LINE> "
    t = t .. "<LINE> "

    -- ── Safety equipment ──
    t = t .. "<SIZE:medium> <RGB:0.5,0.85,1.0> Safety equipment <LINE> "
    t = t .. "<TEXT> <RGB:0.9,0.9,0.9> "
    t = t .. "Some recipes produce hazardous fumes. You will need: <LINE> "
    t = t .. "- <RGB:1.0,0.85,0.3> Gas mask <RGB:0.9,0.9,0.9> "
    t = t .. "or respirator for toxic recipes <LINE> "
    t = t .. "- <RGB:1.0,0.85,0.3> Safety goggles <RGB:0.9,0.9,0.9> "
    t = t .. "for splash-hazard reactions <LINE> "
    t = t .. "Without PPE, you risk health effects (integrated with "
    t = t .. "Extensive Health Rework if installed). <LINE> "
    t = t .. "<LINE> "

    -- ── Sandbox options ──
    t = t .. "<SIZE:medium> <RGB:0.5,0.85,1.0> Customisation <LINE> "
    t = t .. "<TEXT> <RGB:0.9,0.9,0.9> "
    t = t .. "PCP has 16 sandbox options for fine-tuning difficulty: <LINE> "
    t = t .. "- Toggle the purity/impurity system on or off <LINE> "
    t = t .. "- Adjust yield multipliers <LINE> "
    t = t .. "- Enable/disable individual pathways and features <LINE> "
    t = t .. "- Control concrete mixer fuel drain rate <LINE> "
    t = t .. "Find them in <RGB:1.0,0.85,0.3> Sandbox Options > Phobos Chemistry "
    t = t .. "<RGB:0.9,0.9,0.9> when creating a new game. <LINE> "
    t = t .. "<LINE> "

    -- ── Tips ──
    t = t .. "<SIZE:medium> <RGB:0.2,0.9,0.3> Tips <LINE> "
    t = t .. "<TEXT> <RGB:0.85,0.85,0.85> "
    t = t .. "<RGB:0.2,0.9,0.3> + <RGB:0.85,0.85,0.85> "
    t = t .. "Read all 5 skill books for the full recipe catalogue. <LINE> "
    t = t .. "<RGB:0.2,0.9,0.3> + <RGB:0.85,0.85,0.85> "
    t = t .. "High-purity inputs make high-purity outputs — chain quality matters. <LINE> "
    t = t .. "<RGB:0.2,0.9,0.3> + <RGB:0.85,0.85,0.85> "
    t = t .. "The concrete mixer needs a generator (or grid power) to operate. <LINE> "
    t = t .. "<RGB:0.2,0.9,0.3> + <RGB:0.85,0.85,0.85> "
    t = t .. "Biodiesel can fuel generators and vehicles — full energy independence! <LINE> "
    t = t .. "<RGB:0.2,0.9,0.3> + <RGB:0.85,0.85,0.85> "
    t = t .. "Dynamic Trading vendors stock PCP items if that mod is installed. <LINE> "
    t = t .. "<LINE> "

    -- ── Footer ──
    t = t .. "<CENTRE> <SIZE:small> <RGB:0.40,0.40,0.40> "
    t = t .. "Workshop: search  Phobos Chemistry Pathways  <LINE> "
    t = t .. "Requires: PhobosLib + zReVaccin 3 <LINE> "
    t = t .. "<LINE> "

    return t
end

-- Register with PhobosLib popup system
PhobosLib.registerGuidePopup("PCP", {
    title        = "Phobos' Chemistry Pathways  \226\128\148  Quick Guide",
    buildContent = buildGuideContent,
    width        = 560,
    height       = 620,
})

print("[PCP] GuidePopup: registered [client]")
