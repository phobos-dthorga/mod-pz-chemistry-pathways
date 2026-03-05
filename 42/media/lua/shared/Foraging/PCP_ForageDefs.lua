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

-----------------------------------------------------
-- Phobos' Chemistry Pathways - Foraging Definitions
-----------------------------------------------------
-- Adds Calcite and Sulphur as forageable minerals
-- in zones appropriate for Kentucky geology.
-----------------------------------------------------

require "Foraging/forageDefinitions";
require "Foraging/forageSystem";

local function generatePCPForageDefs()
    local minerals = {

        -----------------------------------------------------------
        -- CALCITE (Calcium Carbonate / Chalk / Limestone fragment)
        -----------------------------------------------------------
        -- Kentucky sits on the Western Interior Platform — a vast
        -- karst landscape built almost entirely from Ordovician
        -- and Mississippian limestone. Calcite is everywhere:
        -- stream beds, road cuts, ploughed fields, forest floors.
        -- Found year-round; less visible under snow cover.
        -- Slightly more common after rain washes topsoil away.
        -----------------------------------------------------------
        PCP_Calcite = {
            type            = "PhobosChemistryPathways.Calcite",
            minCount        = 1,
            maxCount        = 2,
            skill           = 0,
            xp              = 1,
            snowChance      = -50,
            hasRainedChance = 10,
            categories      = { "Stones" },
            zones = {
                BirchForest     = 2,
                PHForest        = 2,
                PRForest        = 2,
                DeepForest      = 3,
                FarmLand        = 3,
                ForagingNav     = 1,
                Forest          = 3,
                OrganicForest   = 2,
                TownZone        = 1,
                TrailerPark     = 1,
                Vegitation      = 2,
            },
            months = { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12 },
        },

        -----------------------------------------------------------
        -- SULPHUR POWDER (Native sulphur / brimstone)
        -----------------------------------------------------------
        -- Kentucky has scattered sulphur-bearing mineral springs
        -- and coal seam outcrops where pyrite weathers to native
        -- sulphur. Found near stream banks, rocky outcrops, and
        -- deep forest where coal measures are exposed.
        -- Rare find — requires some foraging skill to identify.
        -- More visible after rain exposes yellow deposits.
        -- Not found in towns or cultivated farmland.
        -----------------------------------------------------------
        PCP_SulphurPowder = {
            type            = "PhobosChemistryPathways.SulphurPowder",
            minCount        = 1,
            maxCount        = 1,
            skill           = 3,
            xp              = 5,
            snowChance      = -75,
            rainChance      = 10,
            hasRainedChance = 20,
            categories      = { "Stones" },
            zones = {
                DeepForest      = 2,
                Forest          = 1,
                PHForest        = 1,
                PRForest        = 1,
                Vegitation      = 1,
            },
            months = { 3, 4, 5, 6, 7, 8, 9, 10, 11 },
        },
        -----------------------------------------------------------
        -- WILD HEMP STALK (Feral hemp / ditchweed)
        -----------------------------------------------------------
        -- Kentucky was a major hemp-producing state through the
        -- 1800s. Feral hemp (ditchweed) still grows wild along
        -- roadsides, fence lines, creek banks, and abandoned
        -- farmland. Hardy perennial that reseeds aggressively.
        -- Most common in summer and early autumn.
        -- Not found in deep forest or developed town centres.
        -----------------------------------------------------------
        PCP_WildHemp = {
            type            = "Base.HempBroken",
            minCount        = 1,
            maxCount        = 3,
            skill           = 1,
            xp              = 2,
            snowChance      = -80,
            hasRainedChance = 5,
            categories      = { "CropVegetables" },
            zones = {
                FarmLand        = 5,
                Vegitation      = 3,
                Forest          = 2,
                PHForest        = 2,
                PRForest        = 2,
                OrganicForest   = 2,
                TrailerPark     = 2,
                ForagingNav     = 1,
            },
            months = { 4, 5, 6, 7, 8, 9, 10 },
        },
    };

    for itemName, itemDef in pairs(minerals) do
        forageSystem.addForageDef(itemName, itemDef);
    end;
end

generatePCPForageDefs();
