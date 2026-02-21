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
-- PCP_HazardSystem.lua
-- PCP-specific health hazard system for chemical recipe safety.
-- Thin wrapper around PhobosLib_Hazard with PCP constants,
-- sandbox integration, and convenience methods.
--
-- When EnableHealthHazards is ON:
--   SAFE recipes degrade the player's mask filter per craft.
--   UNSAFE recipes trigger disease (EHR) or stat penalties (vanilla).
--
-- When EnableHealthHazards is OFF:
--   This module does nothing. All methods early-return.
--
-- Requires: PhobosLib (with Hazard module)
---------------------------------------------------------------

require "PhobosLib"

PCP_HazardSystem = {}


---------------------------------------------------------------
-- Constants
---------------------------------------------------------------

--- Filter degradation per craft. ~40 crafts to exhaust a standard
--- GasmaskFilter (UseDelta=0.01, delta starts at 1.0).
PCP_HazardSystem.FILTER_DEGRADE = 0.025

--- Mask types accepted by safe recipe inputs.
--- Must match the item list in PCP_Recipes_Hazard.txt safe variants.
--- Excludes Base.Hat_DustMask (insufficient for chemical fumes).
PCP_HazardSystem.MASK_TYPES = {
    "Base.Hat_GasMask",
    "Base.Hat_NBCmask",
    "Base.Hat_BuildersRespirator",
    "Base.Hat_ImprovisedGasMask",
}

--- Hazard profiles keyed by hazard ID.
--- Each profile defines EHR disease mapping and vanilla stat fallbacks.
PCP_HazardSystem.HAZARDS = {
    methanol_vapor = {
        ehrDisease     = "corpse_sickness",
        ehrChance      = 0.50,
        ehrSevere      = "pneumonia",
        ehrSevereChance = 0.05,
        vanillaSickness = 0.15,
        vanillaPain     = 0.05,
        vanillaStress   = 0.12,
        warningMsg      = "*cough* Methanol fumes!",
    },
    acid_fumes = {
        ehrDisease     = "corpse_sickness",
        ehrChance      = 0.45,
        ehrSevere      = "pneumonia",
        ehrSevereChance = 0.10,
        vanillaSickness = 0.12,
        vanillaPain     = 0.08,
        vanillaStress   = 0.10,
        warningMsg      = "*cough* Acid fumes!",
    },
    caustic_vapor = {
        ehrDisease     = "corpse_sickness",
        ehrChance      = 0.35,
        ehrSevere      = "pneumonia",
        ehrSevereChance = 0.04,
        vanillaSickness = 0.08,
        vanillaPain     = 0.02,
        vanillaStress   = 0.15,
        warningMsg      = "*cough* Caustic fumes!",
    },
    acid_mist = {
        ehrDisease     = "wound_infection",
        ehrChance      = 0.40,
        ehrSevere      = "corpse_sickness",
        ehrSevereChance = 0.15,
        vanillaSickness = 0.10,
        vanillaPain     = 0.10,
        vanillaStress   = 0.10,
        warningMsg      = "*wince* Acid mist!",
    },
    plastic_fumes = {
        ehrDisease     = "corpse_sickness",
        ehrChance      = 0.40,
        ehrSevere      = "pneumonia",
        ehrSevereChance = 0.08,
        vanillaSickness = 0.10,
        vanillaPain     = 0.05,
        vanillaStress   = 0.12,
        warningMsg      = "*cough* Toxic plastic fumes!",
    },
    resin_fumes = {
        ehrDisease     = "corpse_sickness",
        ehrChance      = 0.30,
        ehrSevere      = "pneumonia",
        ehrSevereChance = 0.04,
        vanillaSickness = 0.08,
        vanillaPain     = 0.03,
        vanillaStress   = 0.10,
        warningMsg      = "*cough* Resin fumes!",
    },
}


---------------------------------------------------------------
-- Sandbox Integration
---------------------------------------------------------------

--- Check if the health hazard system is enabled (master toggle).
---@return boolean
function PCP_HazardSystem.isEnabled()
    return PhobosLib.getSandboxVar("PCP", "EnableHealthHazards", false) == true
end


---------------------------------------------------------------
-- Convenience Methods
---------------------------------------------------------------

--- Degrade filter on the mask found in recipe inputs.
--- Uses PCP-specific mask types and degradation amount.
---@param items any  Java ArrayList from OnCreate
---@return boolean   true if degradation was applied
function PCP_HazardSystem.degradeFilterFromInputs(items)
    return PhobosLib.degradeFilterFromInputs(
        items,
        PCP_HazardSystem.MASK_TYPES,
        PCP_HazardSystem.FILTER_DEGRADE
    )
end

--- Apply hazard effects for an unsafe recipe.
--- Checks runtime respiratory protection (player may wear partial PPE)
--- and scales disease/stat chance accordingly.
---
--- Protection multipliers:
---   NBC mask (no filter):     15% of base chance
---   Gas mask / respirator:    40% of base chance
---   No mask at all:          100% of base chance
---
---@param player any
---@param hazardId string  Key into PCP_HazardSystem.HAZARDS
function PCP_HazardSystem.applyUnsafeEffect(player, hazardId)
    if not PCP_HazardSystem.isEnabled() then return end
    local hazard = PCP_HazardSystem.HAZARDS[hazardId]
    if not hazard then return end

    -- Assess runtime respiratory protection
    local protection = PhobosLib.getRespiratoryProtection(player)
    local protMult = 1.0  -- no protection = full exposure

    if protection.protectionLevel == "nbc" then
        protMult = 0.15  -- NBC even without filter is excellent
    elseif protection.hasMask then
        protMult = 0.40  -- mask without filter gives some protection
    end

    -- Warning speech bubble always shows
    PhobosLib.warnHazard(player, hazard.warningMsg)

    -- Dispatch hazard effect with protection scaling
    PhobosLib.applyHazardEffect(player, {
        ehrDisease           = hazard.ehrDisease,
        ehrChance            = hazard.ehrChance,
        ehrSevereDisease     = hazard.ehrSevere,
        ehrSevereChance      = hazard.ehrSevereChance or 0,
        vanillaSickness      = hazard.vanillaSickness,
        vanillaPain          = hazard.vanillaPain,
        vanillaStress        = hazard.vanillaStress,
        protectionMultiplier = protMult,
    })
end
