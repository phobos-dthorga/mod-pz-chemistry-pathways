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
-- PCP_FarmingCompat.lua
-- Registers PCP gardening sprays with PhobosLib's farming
-- spray API so they appear in the "Treat Problem" submenu
-- and respond to the Interact hotkey on diseased plants.
--
-- Three sprays mapped to three vanilla plant diseases:
--   SulphurFungicideSpray  -> Mildew  (antifungal)
--   InsecticidalSoapSpray  -> Aphids  (insecticidal soap)
--   PotashFoliarSpray      -> Flies   (potassium pest deterrent)
--
-- Part of PhobosChemistryPathways >= 0.22.0
-- Requires PhobosLib >= 1.11.0
---------------------------------------------------------------

require "PhobosLib"

PhobosLib.registerFarmingSpray(
    "PhobosChemistryPathways.SulphurFungicideSpray", "Mildew")
PhobosLib.registerFarmingSpray(
    "PhobosChemistryPathways.InsecticidalSoapSpray", "Aphids")
PhobosLib.registerFarmingSpray(
    "PhobosChemistryPathways.PotashFoliarSpray", "Flies")
PhobosLib.registerFarmingSpray(
    "Base.SlugRepellent", "Slugs")
