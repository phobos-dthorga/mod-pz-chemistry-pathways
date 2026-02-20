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
-- PCP_ResetNotify.lua
-- Client-side listener for PCP reset result notifications.
-- Always shows a modal dialog since resets run after a world
-- restart and the user needs clear confirmation of what happened.
--
-- Success: green-header modal with reset summary.
-- Failure: red-header modal with error details.
---------------------------------------------------------------

local PCP_ResetNotify = {}

---------------------------------------------------------------
-- Modal Dialog
---------------------------------------------------------------

--- Show a modal dialog with reset results.
--- Cannot be missed at any game speed.
---@param msg string
---@param isOk boolean
local function showModal(msg, isOk)
    pcall(function()
        local header
        if isOk then
            header = " <SIZE:medium> <RGB:0.3,0.8,0.3> PCP Reset Complete <RGB:1,1,1> "
        else
            header = " <SIZE:medium> <RGB:1,0.3,0.3> PCP Reset Warning <RGB:1,1,1> "
        end

        -- Replace newlines with <LINE> tags for ISModalRichText
        local body = string.gsub(msg, "\n", " <LINE> ")

        local text = header
            .. " <LINE> <LINE> <SIZE:small> "
            .. body
            .. " <LINE> <LINE> "
            .. " <RGB:0.6,0.6,0.6> Check the console log (press ~ or F3) for full details. <RGB:1,1,1> "

        local modal = ISModalRichText:new(
            getCore():getScreenWidth() / 2 - 280,
            getCore():getScreenHeight() / 2 - 150,
            560,
            300,
            text,
            true  -- OK button only
        )
        modal:initialise()
        modal:addToUIManager()
    end)

    local prefix = isOk and "SUCCESS" or "WARNING"
    print("[PCP] ResetNotify: " .. prefix .. " -> " .. msg)
end

---------------------------------------------------------------
-- HaloText (supplemental)
---------------------------------------------------------------

--- Show a green on-screen halo text as a quick visual indicator.
---@param player any
---@param msg string
local function showHaloText(player, msg)
    pcall(function()
        if HaloTextHelper and HaloTextHelper.addTextWithArrow then
            HaloTextHelper.addTextWithArrow(player, true, msg)
        elseif HaloTextHelper and HaloTextHelper.addText then
            HaloTextHelper.addText(player, msg, HaloTextHelper.getColorGreen())
        end
    end)
end

---------------------------------------------------------------
-- Server Command Listener
---------------------------------------------------------------

local function onServerCommand(module, command, args)
    if module ~= "PCP" or command ~= "resetResult" then return end
    if not args then return end

    local msg = args.msg or "Reset operation completed."
    local isOk = (args.status == "ok")

    -- Always show modal for reset results
    showModal(msg, isOk)

    -- Also show halo text if player exists and it was successful
    if isOk then
        local player = nil
        pcall(function()
            player = getSpecificPlayer(0)
        end)
        if player then
            showHaloText(player, "[PCP] Reset complete!")
        end
    end
end

Events.OnServerCommand.Add(onServerCommand)

print("[PCP] ResetNotify: loaded [client]")
