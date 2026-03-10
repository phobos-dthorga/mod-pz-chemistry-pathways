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
-- PCP_MixerCompat.lua
-- Client-side registration of the Concrete Mixer entity with
-- PhobosLib's power system.
--
-- Registers PCP_ConcreteMixer as a powered CraftBench on
-- Events.OnGameStart. Gated by PCP.EnableConcreteMixer
-- sandbox option.
--
-- Part of PhobosChemistryPathways >= 0.23.0
---------------------------------------------------------------

require "PhobosLib"

local _TAG = "[PCP:MixerCompat]"

local function registerMixer()
    -- Check sandbox option
    local enabled = PhobosLib.getSandboxVar("PCP", "EnableConcreteMixer", true)
    if not enabled then
        print(_TAG .. " Concrete Mixer disabled by sandbox option")
        return
    end

    -- Verify PhobosLib has power support
    if not PhobosLib.registerPoweredCraftBench then
        print(_TAG .. " WARNING: PhobosLib.registerPoweredCraftBench not available (PhobosLib < 1.12.0?)")
        return
    end

    -- Get drain rate from sandbox
    local drainRate = PhobosLib.getSandboxVar("PCP", "MixerFuelDrainRate", 0.5)

    -- Register the concrete mixer entity as a powered CraftBench
    PhobosLib.registerPoweredCraftBench("PCP_ConcreteMixer", {
        messageKey     = "IGUI_PhobosLib_NoPower",
        drainPerMinute = drainRate,
        guardFunc      = function()
            return PhobosLib.getSandboxVar("PCP", "EnableConcreteMixer", true)
        end,
    })

    print(_TAG .. " Concrete Mixer registered as powered workstation (drain=" .. drainRate .. "%/min)")
end

Events.OnGameStart.Add(registerMixer)
