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
--
-- NOTE: PZ's ISRichTextPanel eats word spacing at <RGB:...> tag
-- boundaries (paginate line 440/463). Colour changes MUST only
-- appear at <LINE> boundaries, NEVER inline within a sentence.
---------------------------------------------------------------

local function buildGuideContent()
    local t = ""

    -- ── Title ──
    t = t .. "<H1> Phobos' Chemistry Pathways <LINE> "
    t = t .. "<CENTRE> <SIZE:small> <RGB:0.6,0.6,0.6> Quick Guide <LINE> "
    t = t .. "<LINE> "

    -- ── What this mod adds ──
    t = t .. "<SIZE:medium> <LEFT> <RGB:0.5,0.85,1.0> What this mod adds <LINE> "
    t = t .. "<SIZE:small> <RGB:0.9,0.9,0.9> "
    t = t .. "PCP adds real-world chemistry to Project Zomboid through "
    t = t .. "7 interconnected pathways: blackpowder synthesis, biodiesel "
    t = t .. "production, fat rendering, soap-making, bone char processing, "
    t = t .. "material recycling, and advanced laboratory processes. <LINE> "
    t = t .. "<LINE> "
    t = t .. "<RGB:0.9,0.9,0.9> "
    t = t .. "Everything you craft has a purity rating. Higher skill "
    t = t .. "and better equipment produce purer products, which in turn "
    t = t .. "yield better results when used as inputs in downstream "
    t = t .. "recipes. <LINE> "
    t = t .. "<LINE> "

    -- ── Crafting categories ──
    t = t .. "<SIZE:medium> <RGB:0.5,0.85,1.0> Crafting workstations <LINE> "
    t = t .. "<SIZE:small> <RGB:0.9,0.9,0.9> "
    t = t .. "Recipes are organised into four workstation tiers: <LINE> "
    t = t .. "<LINE> "
    -- Field
    t = t .. "<RGB:1.0,0.85,0.3> Field Chemistry <LINE> "
    t = t .. "<RGB:0.9,0.9,0.9> "
    t = t .. "No special equipment needed. Campfires, basic tools. "
    t = t .. "Great for getting started. <LINE> "
    -- Kitchen
    t = t .. "<RGB:1.0,0.85,0.3> Kitchen Chemistry <LINE> "
    t = t .. "<RGB:0.9,0.9,0.9> "
    t = t .. "Cooking pot required. Fat rendering, soap, bone char. <LINE> "
    -- Lab
    t = t .. "<RGB:1.0,0.85,0.3> Lab Chemistry <LINE> "
    t = t .. "<RGB:0.9,0.9,0.9> "
    t = t .. "zReVaccin chemistry set. Best purity, advanced reactions. <LINE> "
    -- Industrial
    t = t .. "<RGB:1.0,0.85,0.3> Industrial Chemistry <LINE> "
    t = t .. "<RGB:0.9,0.9,0.9> "
    t = t .. "Concrete mixer (requires electricity). Bulk production "
    t = t .. "at lower purity. <LINE> "
    t = t .. "<LINE> "

    -- ── How purity works ──
    t = t .. "<SIZE:medium> <RGB:0.5,0.85,1.0> How purity works <LINE> "
    t = t .. "<SIZE:small> <RGB:0.9,0.9,0.9> "
    t = t .. "The item condition bar doubles as a purity indicator. "
    t = t .. "Sulphur powder at 75% condition means 75% purity. <LINE> "
    t = t .. "<LINE> "
    t = t .. "<RGB:0.9,0.9,0.9> "
    t = t .. "- Higher Applied Chemistry skill improves purity <LINE> "
    t = t .. "<RGB:0.9,0.9,0.9> "
    t = t .. "- Lab equipment (chemistry set) gives the best purity range <LINE> "
    t = t .. "<RGB:0.9,0.9,0.9> "
    t = t .. "- Kitchen and field methods give lower purity <LINE> "
    t = t .. "<RGB:0.9,0.9,0.9> "
    t = t .. "- Input purity affects output purity in multi-step chains <LINE> "
    t = t .. "<LINE> "

    -- ── Getting started ──
    t = t .. "<SIZE:medium> <RGB:0.5,0.85,1.0> Getting started <LINE> "
    t = t .. "<SIZE:small> <RGB:0.9,0.9,0.9> "
    t = t .. "1. Find the Chemistry Pathways Handbook (found on "
    t = t .. "bookshelves, in classrooms, and labs). Reading it "
    t = t .. "unlocks the majority of recipes. <LINE> "
    t = t .. "<RGB:0.9,0.9,0.9> "
    t = t .. "2. Start with Field Chemistry recipes. Crush charcoal, "
    t = t .. "extract potash from ash, scavenge sulphur from matches. <LINE> "
    t = t .. "<RGB:0.9,0.9,0.9> "
    t = t .. "3. Find a cooking pot for Kitchen Chemistry. Render "
    t = t .. "animal fat, make soap, process bone char. <LINE> "
    t = t .. "<RGB:0.9,0.9,0.9> "
    t = t .. "4. Locate a zReVaccin lab for Lab Chemistry. Synthesise "
    t = t .. "sulphuric acid, potassium nitrate, and blackpowder "
    t = t .. "at peak purity. <LINE> "
    t = t .. "<LINE> "

    -- ── Safety equipment ──
    t = t .. "<SIZE:medium> <RGB:0.5,0.85,1.0> Safety equipment <LINE> "
    t = t .. "<SIZE:small> <RGB:0.9,0.9,0.9> "
    t = t .. "Some recipes produce hazardous fumes. You will need: <LINE> "
    t = t .. "<RGB:0.9,0.9,0.9> "
    t = t .. "- Gas mask or respirator for toxic recipes <LINE> "
    t = t .. "<RGB:0.9,0.9,0.9> "
    t = t .. "- Safety goggles for splash-hazard reactions <LINE> "
    t = t .. "<RGB:0.9,0.9,0.9> "
    t = t .. "Without PPE, you may suffer adverse health effects "
    t = t .. "(integrates with Extensive Health Rework if installed). <LINE> "
    t = t .. "<LINE> "

    -- ── Sandbox options ──
    t = t .. "<SIZE:medium> <RGB:0.5,0.85,1.0> Customisation <LINE> "
    t = t .. "<SIZE:small> <RGB:0.9,0.9,0.9> "
    t = t .. "PCP has 16 sandbox options for fine-tuning difficulty: <LINE> "
    t = t .. "<RGB:0.9,0.9,0.9> "
    t = t .. "- Toggle the purity/impurity system on or off <LINE> "
    t = t .. "<RGB:0.9,0.9,0.9> "
    t = t .. "- Adjust yield multipliers <LINE> "
    t = t .. "<RGB:0.9,0.9,0.9> "
    t = t .. "- Enable/disable individual pathways and features <LINE> "
    t = t .. "<RGB:0.9,0.9,0.9> "
    t = t .. "- Control concrete mixer fuel drain rate <LINE> "
    t = t .. "<RGB:0.9,0.9,0.9> "
    t = t .. "Find them in Sandbox Options when creating a new game, "
    t = t .. "under the Phobos Chemistry section. <LINE> "
    t = t .. "<LINE> "

    -- ── Tips ──
    t = t .. "<SIZE:medium> <RGB:0.2,0.9,0.3> Tips <LINE> "
    t = t .. "<SIZE:small> <RGB:0.85,0.85,0.85> "
    t = t .. "- Read the Chemistry Pathways Handbook to unlock the "
    t = t .. "full recipe catalogue. <LINE> "
    t = t .. "<RGB:0.85,0.85,0.85> "
    t = t .. "- High-purity inputs make high-purity outputs. "
    t = t .. "Chain quality matters. <LINE> "
    t = t .. "<RGB:0.85,0.85,0.85> "
    t = t .. "- The concrete mixer needs a generator (or grid power) "
    t = t .. "to operate. <LINE> "
    t = t .. "<RGB:0.85,0.85,0.85> "
    t = t .. "- Biodiesel can fuel generators and vehicles for full "
    t = t .. "energy independence. <LINE> "
    t = t .. "<RGB:0.85,0.85,0.85> "
    t = t .. "- Dynamic Trading vendors stock PCP items if that mod "
    t = t .. "is installed. <LINE> "
    t = t .. "<LINE> "

    -- ── Footer ──
    t = t .. "<CENTRE> <SIZE:small> <RGB:0.40,0.40,0.40> "
    t = t .. "Workshop: search Phobos Chemistry Pathways <LINE> "
    t = t .. "<RGB:0.40,0.40,0.40> "
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
