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
-- PCP_ZReVaccinMigration.lua
-- Comprehensive save migration from zReVaccin 3.0 to Zombie
-- Virus Vaccine (ZVV).  Converts all zReLabItems inventory
-- items (player + world containers), transfers learned recipes,
-- and removes the orphaned antibodies trait.
--
-- Triggered by sandbox toggle: PCP.MigrateZReVaccinToZVV
-- Runs server-side only on Events.OnGameStart (via
-- PCP_MigrationSystem.lua hook).
--
-- Requires: PhobosLib >= 1.28.0
---------------------------------------------------------------

require "PhobosLib"

PCP_ZReVaccinMigration = {}

local _TAG = "[PCP:ZReVaccinMigration]"

---------------------------------------------------------------
-- Item Mapping Tables
---------------------------------------------------------------

--- Direct conversions: zReLabItems.X → LabItems.X
--- Items with identical names across both mods.
local ZRE_TO_ZVV_DIRECT = {
    -- Lab equipment (workstation items in inventory)
    ["zReLabItems.LabCentrifuge"]                        = "LabItems.LabCentrifuge",
    ["zReLabItems.LabChemistrySet"]                      = "LabItems.LabChemistrySet",
    ["zReLabItems.LabChromatograph"]                     = "LabItems.LabChromatograph",
    ["zReLabItems.LabMicroscope"]                        = "LabItems.LabMicroscope",
    ["zReLabItems.LabSpectrometer"]                      = "LabItems.LabSpectrometer",
    -- Lab glassware
    ["zReLabItems.LabFlask"]                             = "LabItems.LabFlask",
    ["zReLabItems.LabFlaskDirty"]                        = "LabItems.LabFlaskDirty",
    ["zReLabItems.LabTestTube"]                          = "LabItems.LabTestTube",
    ["zReLabItems.LabTestTubeDirty"]                     = "LabItems.LabTestTubeDirty",
    ["zReLabItems.LabTestTubePack"]                      = "LabItems.LabTestTubePack",
    -- Syringes
    ["zReLabItems.LabSyringe"]                           = "LabItems.LabSyringe",
    ["zReLabItems.LabSyringeUsed"]                       = "LabItems.LabSyringeUsed",
    ["zReLabItems.LabSyringeReusable"]                   = "LabItems.LabSyringeReusable",
    ["zReLabItems.LabSyringeReusableUsed"]               = "LabItems.LabSyringeReusableUsed",
    ["zReLabItems.LabSyringePack"]                       = "LabItems.LabSyringePack",
    -- Chemicals
    ["zReLabItems.ChAmmonia"]                            = "LabItems.ChAmmonia",
    ["zReLabItems.ChHydrochloricAcidCan"]                = "LabItems.ChHydrochloricAcidCan",
    ["zReLabItems.ChSodiumHydroxideBag"]                 = "LabItems.ChSodiumHydroxideBag",
    ["zReLabItems.ChSulfuricAcidCan"]                    = "LabItems.ChSulfuricAcidCan",
    -- Blood compounds
    ["zReLabItems.CmpSyringeWithBlood"]                  = "LabItems.CmpSyringeWithBlood",
    ["zReLabItems.CmpSyringeWithTaintedBlood"]           = "LabItems.CmpSyringeWithTaintedBlood",
    ["zReLabItems.CmpSyringeReusableWithBlood"]          = "LabItems.CmpSyringeReusableWithBlood",
    ["zReLabItems.CmpSyringeReusableWithTaintedBlood"]   = "LabItems.CmpSyringeReusableWithTaintedBlood",
    ["zReLabItems.CmpTestTubeWithInfectedBlood"]         = "LabItems.CmpTestTubeWithInfectedBlood",
    -- Vaccines
    ["zReLabItems.CmpSyringeWithPlainVaccine"]           = "LabItems.CmpSyringeWithPlainVaccine",
    ["zReLabItems.CmpSyringeReusableWithPlainVaccine"]   = "LabItems.CmpSyringeReusableWithPlainVaccine",
    ["zReLabItems.CmpSyringeWithQualityVaccine"]         = "LabItems.CmpSyringeWithQualityVaccine",
    ["zReLabItems.CmpSyringeReusableWithQualityVaccine"] = "LabItems.CmpSyringeReusableWithQualityVaccine",
    ["zReLabItems.CmpSyringeWithCure"]                   = "LabItems.CmpSyringeWithCure",
    ["zReLabItems.CmpSyringeReusableWithCure"]           = "LabItems.CmpSyringeReusableWithCure",
    -- Medical
    ["zReLabItems.CmpAlbuminPills"]                      = "LabItems.CmpAlbuminPills",
    -- Test results
    ["zReLabItems.LabTestResultNegative"]                = "LabItems.LabTestResultNegative",
    ["zReLabItems.LabTestResultPositive"]                = "LabItems.LabTestResultPositive",
    -- Decorations
    ["zReLabItems.LabPosterBiohazard"]                   = "LabItems.LabPosterBiohazard",
    ["zReLabItems.LabPosterHumanBrain"]                  = "LabItems.LabPosterHumanBrain",
    ["zReLabItems.LabPosterPeriodicTable"]               = "LabItems.LabPosterPeriodicTable",
    ["zReLabItems.LabPosterWashHands"]                   = "LabItems.LabPosterWashHands",
    ["zReLabItems.LabDecorWhiteboard"]                   = "LabItems.LabDecorWhiteboard",
    -- Books
    ["zReLabItems.BkLaboratoryEquipment1"]               = "LabItems.BkLaboratoryEquipment1",
    ["zReLabItems.BkLaboratoryEquipment2"]               = "LabItems.BkLaboratoryEquipment2",
    ["zReLabItems.BkLaboratoryEquipment3"]               = "LabItems.BkLaboratoryEquipment3",
    ["zReLabItems.BkVirologyCourses1"]                   = "LabItems.BkVirologyCourses1",
    ["zReLabItems.BkVirologyCourses2"]                   = "LabItems.BkVirologyCourses2",
    ["zReLabItems.BkChemistryCourse"]                    = "LabItems.BkChemistryCourse",
}

--- Special mappings to vanilla items (no ZVV equivalent).
local ZRE_TO_VANILLA = {
    ["zReLabItems.LabCorks"]          = "Base.Cork",
    ["zReLabItems.zReV2_6ECO_gloves"] = "Base.Gloves_Surgical",
}

--- Items with NO ZVV equivalent — will be removed from save.
local ZRE_REMOVE = {
    ["zReLabItems.LabFlaskPack"]                              = true,
    ["zReLabItems.ChAmmoniumChlorideBag"]                     = true,
    ["zReLabItems.MatPlagueSamplesNormal"]                    = true,
    ["zReLabItems.MatPlagueSamplesRare"]                      = true,
    ["zReLabItems.CmpFlaskWithBloodCells"]                    = true,
    ["zReLabItems.CmpFlaskWithBloodPlasma"]                   = true,
    ["zReLabItems.CmpFlaskWithBloodCellsOrBloodPlasmaDummy"]  = true,
    ["zReLabItems.CmpFlaskWithLeukocytes"]                    = true,
    ["zReLabItems.CmpFlaskWithSodiumHypochlorite"]            = true,
    ["zReLabItems.CmpFlaskWithAmmoniumSulfate"]               = true,
    ["zReLabItems.CmpFlaskWithHydrogenPeroxide"]              = true,
    ["zReLabItems.CmpTestTubeWithAntibodies"]                 = true,
    ["zReLabItems.CmpTestTubeWithTaintedBlood"]               = true,
    ["zReLabItems.CmpSyringeWithSerum"]                       = true,
    ["zReLabItems.CmpSyringeReusableWithSerum"]               = true,
    ["zReLabItems.bkNotebookVaccineStart"]                    = true,
    ["zReLabItems.bkNotebookVaccine2"]                        = true,
    ["zReLabItems.bkNotebookVaccine3"]                        = true,
    ["zReLabItems.bkNotebookVaccine4"]                        = true,
    ["zReLabItems.bkNotebookVaccineDummy"]                    = true,
}

---------------------------------------------------------------
-- Recipe Mapping Table
---------------------------------------------------------------

--- zReVaccin recipe name → ZVV recipe name.
--- Only recipes with a direct ZVV equivalent are listed.
--- Recipes with no equivalent simply vanish when zReVaccin unloads.
local ZRE_TO_ZVV_RECIPES = {
    -- Equipment assembly
    ["zReLabAssembleMicroscope"]                     = "LabAssembleMicroscope",
    ["zReLabAssembleChromatograph"]                  = "LabAssembleChromatograph",
    ["zReLabAssembleChemistrySet"]                   = "LabAssembleChemistrySet",
    ["zReLabAssembleSpectrometer"]                   = "LabAssembleSpectrometer",
    ["zReLabAssembleCentrifuge"]                     = "LabAssembleCentrifuge",
    -- Decorations
    ["zReLabDecAssembleWhiteboard"]                  = "DecAssembleWhiteboard",
    ["zReLabDecPaintPeriodicTablePoster"]             = "DecPaintPeriodicTablePoster",
    ["zReLabDecPaintWashYourHandsPoster"]             = "DecPaintWashYourHandsPoster",
    ["zReLabDecPaintBiohazardPoster"]                = "DecPaintBiohazardPoster",
    ["zReLabDecPaintHumanBrainPoster"]               = "DecPaintHumanBrainPoster",
    -- Glassmaking / fabrication
    ["zReLabFrnMakeTestTube"]                        = "FrnMakeTestTube",
    ["zReLabFrnMakeFlask"]                           = "FrnMakeFlask",
    ["zReLabFrnMakeSyringeReusable"]                 = "ChmMakeSyringe",
    ["zReLabMedImprovisedCottonBalls"]               = "OthMakeCottonBalls",
    -- Blood/virology
    ["zReLabChmTakeBloodForNextWork"]                = "ChmCollectInfectedBlood",
    ["zReLabChmDivideBloodIntoComponents"]            = "ChmDivideBloodIntoComponents",
    ["zReLabChmExtractLeukocytesFromBloodCells"]      = "ChmExtractLeukocytesFromBloodCells",
    ["zReLabChmExtractAntibodiesFromLeukocytes"]      = "ChmExtractAntibodiesFromLeukocytes",
    -- Vaccine synthesis
    ["zReLabChmSynthesizePlainVaccine"]               = "ChmSynthesizePlainVaccine",
    ["zReLabChmSynthesizeQualityVaccine"]             = "ChmSynthesizeQualityVaccine",
    ["zReLabChmSynthesizeCure"]                      = "ChmSynthesizeCure",
    -- Chemical mixing
    ["zReLabChmMixFlaskOfSodiumHypochlorite"]         = "ChmMixFlaskOfSodiumHypochlorite",
    ["zReLabChmMixFlaskOfAmmoniumSulfate"]            = "ChmMixFlaskOfAmmoniumSulfate",
    ["zReLabChmMixFlaskOfHydrogenPeroxide"]           = "ChmMixFlaskOfHydrogenPeroxide",
    ["zReLabChmMakeBottleOfBleach"]                  = "ChmMakeBottleOfBleach",
    ["zReLabChmMakeBottleOfDisinfectant"]             = "ChmMakeBottleOfDisinfectant",
    ["zReLabChmGetAnAlbumin"]                        = "ChmMakeAlbumin",
    -- Packing
    ["zReLabOthPacking"]                             = "OthPackSyringes",
    ["zReLabOthUnpacking"]                           = "OthUnpackSyringes",
}

---------------------------------------------------------------
-- Internal helpers
---------------------------------------------------------------

--- Convert a single zReLabItems item in a container.
--- Preserves condition (purity %) and fluid contents.
---@param item any   InventoryItem
---@param container any  ItemContainer
---@return string|nil  "converted", "removed", or nil
local function convertItem(item, container)
    local fullType = item:getFullType()
    if not fullType then return nil end

    -- Find the replacement fullType
    local replacement = ZRE_TO_ZVV_DIRECT[fullType] or ZRE_TO_VANILLA[fullType]

    if replacement then
        local newItem = instanceItem(replacement)
        if not newItem then
            print(_TAG .. " WARN: failed to instance " .. replacement)
            return nil
        end

        -- Preserve condition (purity proxy) as percentage
        local ok1 = PhobosLib.safecall(function()
            local cond    = item:getCondition()
            local maxCond = item:getConditionMax()
            if cond and maxCond and maxCond > 0 and cond < maxCond then
                local newMax = newItem:getConditionMax()
                local pct    = cond / maxCond
                newItem:setCondition(math.floor(pct * newMax + 0.5))
            end
        end)
        if not ok1 then
            print(_TAG .. " WARN: condition copy failed for " .. fullType)
        end

        -- Preserve fluid contents for FluidContainer items
        PhobosLib.safecall(function()
            local fc    = item:getFluidContainer()
            local newFc = newItem:getFluidContainer()
            if fc and newFc then
                local amount = fc:getAmount()
                if amount and amount > 0 then
                    local pf = fc:getPrimaryFluid()
                    if pf then
                        local fluidName = pf:getName()
                        if fluidName then
                            newFc:addFluid(fluidName, amount)
                        end
                    end
                end
            end
        end)

        container:AddItem(newItem)
        PhobosLib.safecall(function() sendItemStats(newItem) end)
        PhobosLib.safecall(function() sendAddItemToContainer(container, newItem) end)
        container:Remove(item)
        PhobosLib.safecall(function() sendRemoveItemFromContainer(container, item) end)
        return "converted"
    end

    -- Explicitly marked for removal
    if ZRE_REMOVE[fullType] then
        container:Remove(item)
        PhobosLib.safecall(function() sendRemoveItemFromContainer(container, item) end)
        return "removed"
    end

    -- Catch-all: any remaining zReLabItems.* item not in the maps
    if string.find(fullType, "zReLabItems.", 1, true) then
        print(_TAG .. " removing unknown zReLabItems item: " .. fullType)
        container:Remove(item)
        PhobosLib.safecall(function() sendRemoveItemFromContainer(container, item) end)
        return "removed"
    end

    return nil
end

--- Transfer known zReVaccin recipes to ZVV equivalents.
---@param player any  IsoGameCharacter
---@return number taught  Number of new ZVV recipes taught
local function transferRecipes(player)
    local taught = 0
    local ok, known = PhobosLib.safecall(function() return player:getKnownRecipes() end)
    if not ok or not known then return 0 end

    for zreName, zvvName in pairs(ZRE_TO_ZVV_RECIPES) do
        PhobosLib.safecall(function()
            if known:contains(zreName) then
                if not known:contains(zvvName) then
                    player:learnRecipe(zvvName)
                    taught = taught + 1
                end
                known:remove(zreName)
            end
        end)
    end
    return taught
end

--- Remove the zReVaccin antibodies trait from a player.
--- Uses Build 42 CharacterTraits API: getCharacterTraits() → getKnownTraits()
--- → iterate for CharacterTrait objects by name → remove(CharacterTrait).
---@param player any  IsoGameCharacter
---@return boolean removed  Whether the trait was found and removed
local function removeAntibodiesTrait(player)
    local removed = false
    PhobosLib.safecall(function()
        local charTraits = player:getCharacterTraits()
        if not charTraits then return end

        local knownTraits = charTraits:getKnownTraits()
        if not knownTraits then return end

        -- Collect matching trait objects first (avoid mutation during iteration)
        local toRemove = {}
        for i = 0, knownTraits:size() - 1 do
            local trait = knownTraits:get(i)
            if trait then
                local name = trait:getName()
                if name == "zrevac:zreantibodies" or name == "zreantibodies" then
                    table.insert(toRemove, trait)
                end
            end
        end

        -- Remove collected traits
        for _, trait in ipairs(toRemove) do
            charTraits:remove(trait)
            removed = true
        end
    end)
    return removed
end

---------------------------------------------------------------
-- Public API
---------------------------------------------------------------

--- Run the comprehensive zReVaccin → ZVV save migration.
--- Called by PCP_MigrationSystem.lua when the sandbox toggle is ON.
---@param players table  Array of IsoGameCharacter
function PCP_ZReVaccinMigration.run(players)
    -- Auto-reset the sandbox toggle so it doesn't re-run next load
    PhobosLib.unconsumeSandboxFlag("PCP", "MigrateZReVaccinToZVV")

    -- Check if the migration was actually requested
    local requested = false
    PhobosLib.safecall(function()
        require "PCP_SandboxIntegration"
        requested = PCP_Sandbox.isZReVaccinMigrationRequested()
    end)
    if not requested then return end

    print(_TAG .. " manual trigger activated!")

    local stats = {
        playerConverted = 0,
        playerRemoved   = 0,
        worldConverted  = 0,
        worldRemoved    = 0,
        recipesTransferred = 0,
        traitsRemoved   = 0,
    }

    ---------------------------------------------------------
    -- Phase 1: Player inventories (deep scan)
    ---------------------------------------------------------
    for _, player in ipairs(players) do
        -- Two-pass: collect matching items first, then convert
        local pending = {}
        PhobosLib.iterateInventoryDeep(player, function(item, container)
            local ft = item:getFullType()
            if ft and string.find(ft, "zReLabItems.", 1, true) then
                table.insert(pending, {item = item, container = container})
            end
        end)
        for _, entry in ipairs(pending) do
            local result = convertItem(entry.item, entry.container)
            if result == "converted" then
                stats.playerConverted = stats.playerConverted + 1
            elseif result == "removed" then
                stats.playerRemoved = stats.playerRemoved + 1
            end
        end
    end

    print(_TAG .. " Phase 1 done: " .. stats.playerConverted
        .. " converted, " .. stats.playerRemoved .. " removed from player inventories")

    ---------------------------------------------------------
    -- Phase 2: World containers (loaded cells + vehicles)
    ---------------------------------------------------------
    local worldPending = {}
    PhobosLib.iterateWorldContainers(function(item, container, _source)
        local ft = item:getFullType()
        if ft and string.find(ft, "zReLabItems.", 1, true) then
            table.insert(worldPending, {item = item, container = container})
        end
    end)
    for _, entry in ipairs(worldPending) do
        local result = convertItem(entry.item, entry.container)
        if result == "converted" then
            stats.worldConverted = stats.worldConverted + 1
        elseif result == "removed" then
            stats.worldRemoved = stats.worldRemoved + 1
        end
    end

    print(_TAG .. " Phase 2 done: " .. stats.worldConverted
        .. " converted, " .. stats.worldRemoved .. " removed from world containers")

    ---------------------------------------------------------
    -- Phase 3: Recipe transfer
    ---------------------------------------------------------
    for _, player in ipairs(players) do
        local taught = transferRecipes(player)
        stats.recipesTransferred = stats.recipesTransferred + taught
    end

    print(_TAG .. " Phase 3 done: " .. stats.recipesTransferred
        .. " recipes transferred")

    ---------------------------------------------------------
    -- Phase 4: Trait removal + notification
    ---------------------------------------------------------
    for _, player in ipairs(players) do
        if removeAntibodiesTrait(player) then
            stats.traitsRemoved = stats.traitsRemoved + 1
            PhobosLib.safecall(function()
                sendServerCommand(player, "PCP", "zrevacTraitRemoved", {})
            end)
        end
    end

    print(_TAG .. " Phase 4 done: " .. stats.traitsRemoved
        .. " antibodies trait(s) removed")

    ---------------------------------------------------------
    -- Build summary and notify all players
    ---------------------------------------------------------
    local parts = {}
    if stats.playerConverted > 0 then
        table.insert(parts, "Converted " .. stats.playerConverted
            .. " item(s) in player inventories")
    end
    if stats.worldConverted > 0 then
        table.insert(parts, "Converted " .. stats.worldConverted
            .. " item(s) in world containers")
    end
    local totalRemoved = stats.playerRemoved + stats.worldRemoved
    if totalRemoved > 0 then
        table.insert(parts, "Removed " .. totalRemoved
            .. " obsolete item(s) with no ZVV equivalent")
    end
    if stats.recipesTransferred > 0 then
        table.insert(parts, "Transferred " .. stats.recipesTransferred
            .. " recipe(s) to ZVV equivalents")
    end
    if stats.traitsRemoved > 0 then
        table.insert(parts, "Removed zReVaccin antibodies trait from "
            .. stats.traitsRemoved .. " player(s)")
    end

    local msg = #parts > 0
        and table.concat(parts, ". ") .. "."
        or "No zReVaccin data found."

    print(_TAG .. " " .. msg)

    for _, player in ipairs(players) do
        PhobosLib.notifyMigrationResult(player, "PCP", {
            ok    = true,
            label = "PCP: zReVaccin to ZVV Migration",
            msg   = msg,
        })
    end
end

print(_TAG .. " loaded [" .. (isServer() and "server" or "local") .. "]")
