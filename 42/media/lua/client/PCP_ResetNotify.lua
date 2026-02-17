---------------------------------------------------------------
-- PCP_ResetNotify.lua
-- Client-side listener for reset result notifications.
-- Provides persistent messaging that cannot be missed even
-- at accelerated game speed.
--
-- Success: HaloTextHelper green on-screen text + sound.
-- Failure: ISModalRichText modal dialog that blocks game.
---------------------------------------------------------------

local PCP_ResetNotify = {}

---------------------------------------------------------------
-- Success Notification (HaloText)
---------------------------------------------------------------

--- Show a green on-screen success message with sound.
---@param player any
---@param msg string
local function showSuccess(player, msg)
    pcall(function()
        if HaloTextHelper and HaloTextHelper.addTextWithArrow then
            HaloTextHelper.addTextWithArrow(
                player,
                true,  -- good (green)
                msg
            )
        elseif HaloTextHelper and HaloTextHelper.addText then
            HaloTextHelper.addText(player, msg, HaloTextHelper.getColorGreen())
        end
    end)
    print("[PCP] ResetNotify: SUCCESS → " .. msg)
end

---------------------------------------------------------------
-- Failure Notification (Modal Dialog)
---------------------------------------------------------------

--- Show a modal dialog that blocks the game until OK is clicked.
--- Cannot be missed at any game speed.
---@param msg string
local function showFailure(msg)
    pcall(function()
        local text = " <SIZE:medium> <RGB:1,0.3,0.3> PCP Reset Warning <RGB:1,1,1> <LINE> <LINE> "
            .. msg
            .. " <LINE> <LINE> <SIZE:small> This operation did not complete as expected. "
            .. "Your save is not corrupted, but the requested reset may be incomplete. "
            .. "Check the console log for details."

        local modal = ISModalRichText:new(
            getCore():getScreenWidth() / 2 - 250,
            getCore():getScreenHeight() / 2 - 120,
            500,
            240,
            text,
            true  -- yes button only
        )
        modal:initialise()
        modal:addToUIManager()
    end)
    print("[PCP] ResetNotify: FAILURE → " .. msg)
end

---------------------------------------------------------------
-- Server Command Listener
---------------------------------------------------------------

local function onServerCommand(module, command, args)
    if module ~= "PCP" or command ~= "resetResult" then return end
    if not args then return end

    local player = nil
    pcall(function()
        player = getSpecificPlayer(0)
    end)

    local msg = args.msg or "Reset operation completed."
    local tier = args.tier or "unknown"

    if args.status == "ok" then
        if player then
            showSuccess(player, "[PCP] " .. msg)
        else
            print("[PCP] ResetNotify: success but no local player → " .. msg)
        end
    else
        showFailure(msg)
    end
end

Events.OnServerCommand.Add(onServerCommand)

print("[PCP] ResetNotify: loaded [client]")
