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

---------------------------------------------------------------
-- PCP_VesselReplacement.lua
-- Registers PCP FluidContainer -> vanilla vessel mappings with
-- PhobosLib's empty vessel replacement system.
--
-- When a PCP FluidContainer is emptied (drunk, dumped, etc.),
-- it reverts to the corresponding vanilla base vessel on the
-- next inventory refresh, giving the player a reusable container
-- instead of a useless empty "Jar of Glycerol".
--
-- Requires PhobosLib >= 1.10.0
---------------------------------------------------------------

require "PhobosLib"

local _TAG = "[PCP:VesselReplace]"

---------------------------------------------------------------
-- Vessel mapping table
-- Maps PCP FluidContainer fullType -> vanilla vessel replacement.
-- Values: string (simple) or { vessel=string, bonus={string,...} }
---------------------------------------------------------------

local VESSEL_MAP = {
    -- Glass Jar (mason jar) -> Base.EmptyJar + Base.JarLid
    ["PhobosChemistryPathways.SulphuricAcidJar"]        = { vessel = "Base.EmptyJar", bonus = {"Base.JarLid"} },
    ["PhobosChemistryPathways.CrudeVegetableOil"]       = { vessel = "Base.EmptyJar", bonus = {"Base.JarLid"} },
    ["PhobosChemistryPathways.RenderedFat"]              = { vessel = "Base.EmptyJar", bonus = {"Base.JarLid"} },
    ["PhobosChemistryPathways.WoodTar"]                  = { vessel = "Base.EmptyJar", bonus = {"Base.JarLid"} },
    ["PhobosChemistryPathways.CrudeBiodiesel"]           = { vessel = "Base.EmptyJar", bonus = {"Base.JarLid"} },
    ["PhobosChemistryPathways.WashedBiodiesel"]          = { vessel = "Base.EmptyJar", bonus = {"Base.JarLid"} },

    -- Glass Bottle (crafted bottle) -> Base.BottleCrafted
    ["PhobosChemistryPathways.SulphuricAcidBottle"]      = "Base.BottleCrafted",
    ["PhobosChemistryPathways.WoodMethanol"]             = "Base.BottleCrafted",
    ["PhobosChemistryPathways.Glycerol"]                 = "Base.BottleCrafted",

    -- Ceramic Crucible (small) -> Base.CeramicCrucibleSmall
    ["PhobosChemistryPathways.SulphuricAcidCrucible"]    = "Base.CeramicCrucibleSmall",

    -- Glazed Clay Jar -> Base.ClayJarGlazed
    ["PhobosChemistryPathways.SulphuricAcidClayJar"]     = "Base.ClayJarGlazed",
    ["PhobosChemistryPathways.CrudeVegetableOilClayJar"] = "Base.ClayJarGlazed",
    ["PhobosChemistryPathways.RenderedFatClayJar"]       = "Base.ClayJarGlazed",
    ["PhobosChemistryPathways.CrudeBiodieselClayJar"]    = "Base.ClayJarGlazed",
    ["PhobosChemistryPathways.WashedBiodieselClayJar"]   = "Base.ClayJarGlazed",

    -- Metal Bucket (empty) -> Base.BucketEmpty
    ["PhobosChemistryPathways.CrudeVegetableOilBucket"]  = "Base.BucketEmpty",
    ["PhobosChemistryPathways.RenderedFatBucket"]         = "Base.BucketEmpty",
    ["PhobosChemistryPathways.CrudeBiodieselBucket"]      = "Base.BucketEmpty",
    ["PhobosChemistryPathways.WashedBiodieselBucket"]     = "Base.BucketEmpty",

    -- Gas Can -> Base.PetrolCan (spawns with petrol, drained by PhobosLib)
    ["PhobosChemistryPathways.RefinedBiodieselCan"]       = "Base.PetrolCan",
}

---------------------------------------------------------------
-- Sandbox guard
---------------------------------------------------------------

--- Guard function: vessel replacement only runs when sandbox
--- option PCP.EnableVesselReplacement is true (default: true).
--- Server admins can disable this if it causes MP sync issues.
local function isVesselReplacementEnabled()
    return PhobosLib.getSandboxVar("PCP", "EnableVesselReplacement", true) == true
end

---------------------------------------------------------------
-- Registration
---------------------------------------------------------------

if PhobosLib.registerEmptyVesselReplacement then
    PhobosLib.registerEmptyVesselReplacement(
        "PhobosChemistryPathways.",
        VESSEL_MAP,
        isVesselReplacementEnabled
    )
    print(_TAG .. " vessel replacement mappings registered")
else
    print(_TAG .. " PhobosLib.registerEmptyVesselReplacement not available (PhobosLib >= 1.10.0 required)")
end
