--[[
    PCP_RecipeCallbacks.lua — OnCreate callbacks for PhobosChemistryPathways

    These functions are called by craftRecipe OnCreate to handle post-craft logic
    that cannot be expressed in the recipe definition alone (e.g., returning a
    partially consumed drainable item).

    Requires: PhobosLib
]]

require "PhobosLib"

PCP_RecipeCallbacks = {}


--- pcpReturnPartialPropane
--- Called by OnCreate on propane-fueled MetalDrum/surface craft recipes.
--- The recipe consumes the PropaneTank (mode:destroy), and this callback
--- recreates it with reduced fuel level (~4% consumed per use = ~25 uses
--- per full tank).
---
--- @param items   ArrayList  The input items consumed by the recipe
--- @param result  InventoryItem  The output item created by the recipe
--- @param player  IsoGameCharacter  The player performing the recipe
---
function PCP_RecipeCallbacks.pcpReturnPartialPropane(items, result, player)
    local FUEL_PER_USE = 0.04  -- 4% of tank per craft = ~25 crafts per full tank
    local originalDelta = 1.0  -- default: full tank (delta 1.0 = 100%)

    -- Search consumed inputs for the PropaneTank to read its original fuel level
    if items then
        for i = 0, items:size() - 1 do
            local item = items:get(i)
            if item and item:getFullType() == "Base.PropaneTank" then
                -- Use PhobosLib.pcallMethod for B42 API resilience
                -- DrainableComboItem uses getDelta/setDelta in B42
                local delta = PhobosLib.pcallMethod(item, "getDelta")
                if delta then
                    originalDelta = delta
                end
                break
            end
        end
    end

    -- Calculate remaining fuel
    local remaining = math.max(0, originalDelta - FUEL_PER_USE)

    -- Create a new PropaneTank with reduced fuel
    local newTank = instanceItem("Base.PropaneTank")
    if newTank then
        PhobosLib.pcallMethod(newTank, "setDelta", remaining)
        player:getInventory():AddItem(newTank)
    end
end
