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
    };

    for itemName, itemDef in pairs(minerals) do
        forageSystem.addForageDef(itemName, itemDef);
    end;
end

generatePCPForageDefs();
