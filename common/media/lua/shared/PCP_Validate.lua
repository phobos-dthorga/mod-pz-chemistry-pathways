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
-- PCP_Validate.lua
-- Registers PCP's critical dependencies with PhobosLib's
-- startup validation system.  Runs once during OnGameStart
-- (server-side) and logs any missing items, fluids, or perks.
--
-- Part of PhobosChemistryPathways.
---------------------------------------------------------------

require "PhobosLib"

local _TAG = "[PCP:Validate]"


---------------------------------------------------------------
-- Register expected dependencies
-- (runs at file-load time, before OnGameStart)
---------------------------------------------------------------

-- Core vanilla items used by PCP recipes
PhobosLib.expectItem("PCP", "Base.Amplifier")
PhobosLib.expectItem("PCP", "Base.Screwdriver")
PhobosLib.expectItem("PCP", "Base.Pliers")
PhobosLib.expectItem("PCP", "Base.BlowTorch")
PhobosLib.expectItem("PCP", "Base.WeldingMask")
PhobosLib.expectItem("PCP", "Base.WeldingRods")
PhobosLib.expectItem("PCP", "Base.PropaneTank")
PhobosLib.expectItem("PCP", "Base.Bleach")

-- Vanilla fluids used by PCP recipes
PhobosLib.expectFluid("PCP", "Water")

-- PCP custom fluids (verify our own definitions loaded correctly)
PhobosLib.expectFluid("PCP", "SulphuricAcid")
PhobosLib.expectFluid("PCP", "CrudeVegetableOil")
PhobosLib.expectFluid("PCP", "RenderedFat")
PhobosLib.expectFluid("PCP", "WoodMethanol")
PhobosLib.expectFluid("PCP", "WoodTar")
PhobosLib.expectFluid("PCP", "CrudeBiodiesel")
PhobosLib.expectFluid("PCP", "Glycerol")
PhobosLib.expectFluid("PCP", "WashedBiodiesel")

-- Custom perk
PhobosLib.expectPerk("PCP", "AppliedChemistry")


---------------------------------------------------------------
-- OnGameStart: run validation
---------------------------------------------------------------

local function onGameStart()
    if isClient() then return end   -- server-side only

    local report = PhobosLib.validateDependencies()
    local totalMissing = #report.items + #report.fluids + #report.perks

    if totalMissing > 0 then
        print(_TAG .. " WARNING: " .. totalMissing
              .. " missing dependencies — some recipes may not work.")
    end
end

Events.OnGameStart.Add(onGameStart)
