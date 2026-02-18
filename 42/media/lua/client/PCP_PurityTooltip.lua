---------------------------------------------------------------
-- PCP_PurityTooltip.lua
-- Client-side tooltip hook for PhobosChemistryPathways.
-- Displays purity tier and percentage on crafted items when
-- the Impurity System sandbox option is enabled.
--
-- Best-effort: entirely wrapped in pcall for B42 resilience.
-- If the tooltip API changes, this fails silently and the
-- player:Say() speech bubble remains the primary feedback.
--
-- Runs client-side only (42/media/lua/client/).
---------------------------------------------------------------

local PCP_PURITY_KEY = "PCP_Purity"

--- Tier definitions — DUPLICATED from PCP_PuritySystem.lua (server).
--- Client cannot require server modules, so tiers are defined in both places.
--- ⚠ If you change tiers here, update PCP_PuritySystem.lua to match (and vice versa).
--- See GitHub Issue: "refactor: Extract shared constants (purity tiers)"
local TIERS = {
    {name = "Lab-Grade",     min = 80, r = 0.4, g = 0.6, b = 1.0},
    {name = "Pure",          min = 60, r = 0.6, g = 1.0, b = 0.6},
    {name = "Standard",      min = 40, r = 1.0, g = 1.0, b = 0.4},
    {name = "Impure",        min = 20, r = 1.0, g = 0.6, b = 0.2},
    {name = "Contaminated",  min = 0,  r = 1.0, g = 0.2, b = 0.2},
}

--- Look up tier for a purity value.
local function getTier(purity)
    for _, tier in ipairs(TIERS) do
        if purity >= tier.min then return tier end
    end
    return TIERS[#TIERS]
end


--- Hook into ISToolTipInv to append purity info.
--- Wrapped entirely in pcall — if anything fails, tooltip just
--- won't show purity (no error, no crash).
local _hookInstalled = false

local function installTooltipHook()
    if _hookInstalled then return end
    _hookInstalled = true

    -- Guard: ISToolTipInv must exist
    if not ISToolTipInv then return end

    local originalRender = ISToolTipInv.render
    if not originalRender then return end

    ISToolTipInv.render = function(self)
        -- Call original render first
        originalRender(self)

        -- Purity extension (all in pcall)
        pcall(function()
            -- Check sandbox option
            if not SandboxVars or not SandboxVars.PCP then return end
            if SandboxVars.PCP.EnableImpuritySystem ~= true then return end

            -- Get the item being hovered
            local item = self.item
            if not item or not item.getModData then return end

            local md = item:getModData()
            if not md or md[PCP_PURITY_KEY] == nil then return end

            local purity = md[PCP_PURITY_KEY]
            if type(purity) ~= "number" then return end

            local tier = getTier(purity)

            -- Build the coloured purity line
            local line = string.format(
                "<RGB:%.1f,%.1f,%.1f> Purity: %s (%d%%) <RGB:1,1,1>",
                tier.r, tier.g, tier.b,
                tier.name, math.floor(purity)
            )

            -- Append to tooltip text
            -- Try self:addLine() first (B42 common pattern)
            if self.addLine then
                self:addLine(line)
            elseif self.description then
                -- Fallback: append to description string
                self.description = (self.description or "") .. " <br> " .. line
            end
        end)
    end
end


--- Install the hook when the game UI loads.
--- Events.OnGameStart fires after UI is initialized.
local function onGameStart()
    pcall(installTooltipHook)
end

Events.OnGameStart.Add(onGameStart)
