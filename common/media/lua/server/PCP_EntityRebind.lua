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
-- PCP_EntityRebind.lua
-- Registers PCP entity rebinding with PhobosLib so that
-- pre-existing world objects (placed before PCP was installed)
-- get their CraftBench entity on chunk load.
--
-- Sprites must match exactly what is defined in:
--   PCP_Entities_ConcreteMixer.txt   (4 directional sprites)
--   PCP_Entities_MetalDrumStation.txt (1 sprite)
--
-- Requires PhobosLib >= 1.14.0
---------------------------------------------------------------

if isClient() then return end

require "PhobosLib"

local _TAG = "[PCP:EntityRebind]"

---------------------------------------------------------------
-- Registration
---------------------------------------------------------------

if not PhobosLib.registerEntityRebinding then
    print(_TAG .. " PhobosLib.registerEntityRebinding not available"
        .. " (PhobosLib >= 1.14.0 required)")
    return
end

-- Concrete Mixer: 4 directional sprites
-- Gated by PCP.EnableConcreteMixer sandbox option
PhobosLib.registerEntityRebinding({
    sprites   = {
        "construction_01_6",   -- face S
        "construction_01_7",   -- face E
        "construction_01_14",  -- face N
        "construction_01_15",  -- face W
    },
    label     = "PCP_ConcreteMixer",
    guardFunc = function()
        return PhobosLib.getSandboxVar("PCP", "EnableConcreteMixer", true) == true
    end,
})

-- Metal Drum Station: 1 sprite (single facing)
-- No sandbox guard: metal drum station is always active
PhobosLib.registerEntityRebinding({
    sprites   = { "crafted_01_32" },
    label     = "PCP_MetalDrumStation",
})

print(_TAG .. " entity rebinding registered for ConcreteMixer + MetalDrumStation")
