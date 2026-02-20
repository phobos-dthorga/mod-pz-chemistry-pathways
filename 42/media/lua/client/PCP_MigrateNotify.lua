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
-- PCP_MigrateNotify.lua
-- Client-side listener for migration result notifications.
-- Buffers results and shows a single ISModalRichText summary
-- that persists until OK is clicked (cannot be missed).
--
-- Listens for: module="PCP", command="migrateResult"
-- Sent by: PhobosLib.notifyMigrationResult() via PCP_MigrationSystem.lua
---------------------------------------------------------------

local PCP_MigrateNotify = {}

-- Buffer to collect multiple migration results before showing one modal
PCP_MigrateNotify._buffer    = {}
PCP_MigrateNotify._tickDelay = 0
PCP_MigrateNotify._waiting   = false

-- How many ticks to wait after the last result before showing the modal.
-- Batches multiple migration results (e.g. v0.18.0 + v0.19.0) into one dialog.
local BATCH_DELAY_TICKS = 10

---------------------------------------------------------------
-- Modal Display
---------------------------------------------------------------

--- Build rich text body and show ISModalRichText.
local function showModal()
    local results = PCP_MigrateNotify._buffer
    if #results == 0 then return end

    -- Classify results
    local anyFail = false
    for _, r in ipairs(results) do
        if r.status ~= "ok" then anyFail = true; break end
    end

    -- Build rich text
    local lines = {}

    if anyFail then
        table.insert(lines, " <SIZE:medium> <RGB:1,0.3,0.3> PCP Migration Warning <RGB:1,1,1> <LINE> ")
    else
        table.insert(lines, " <SIZE:medium> <RGB:0.3,1,0.3> PCP Migration Complete <RGB:1,1,1> <LINE> ")
    end

    table.insert(lines, " <LINE> ")

    for _, r in ipairs(results) do
        local icon = (r.status == "ok") and "<RGB:0.3,1,0.3> [OK] " or "<RGB:1,0.3,0.3> [FAIL] "
        table.insert(lines, " " .. icon .. "<RGB:1,1,1> " .. (r.msg or "Migration completed.") .. " <LINE> ")
    end

    table.insert(lines, " <LINE> <SIZE:small> ")
    if anyFail then
        table.insert(lines, "One or more migrations did not complete as expected. ")
        table.insert(lines, "Your save is not corrupted. Check the console log for details.")
    else
        table.insert(lines, "All migrations completed successfully. Enjoy your game!")
    end

    local text = table.concat(lines)

    pcall(function()
        local modal = ISModalRichText:new(
            getCore():getScreenWidth() / 2 - 250,
            getCore():getScreenHeight() / 2 - 120,
            500,
            240,
            text,
            false  -- OK button only
        )
        modal:initialise()
        modal:addToUIManager()
    end)

    -- Clear the buffer
    PCP_MigrateNotify._buffer = {}
end

---------------------------------------------------------------
-- Tick Handler (batching delay)
---------------------------------------------------------------

local function onTick()
    if not PCP_MigrateNotify._waiting then return end

    PCP_MigrateNotify._tickDelay = PCP_MigrateNotify._tickDelay - 1
    if PCP_MigrateNotify._tickDelay <= 0 then
        PCP_MigrateNotify._waiting = false
        Events.OnTick.Remove(onTick)
        showModal()
    end
end

---------------------------------------------------------------
-- Server Command Listener
---------------------------------------------------------------

local function onServerCommand(module, command, args)
    if module ~= "PCP" or command ~= "migrateResult" then return end
    if not args then return end

    local msg    = args.msg    or "Migration completed."
    local label  = args.label  or "migration"
    local status = args.status or "fail"

    -- Log to console regardless
    print("[PCP] MigrateNotify: " .. string.upper(status) .. " — " .. label .. " — " .. msg)

    -- Buffer the result
    table.insert(PCP_MigrateNotify._buffer, {
        label  = label,
        status = status,
        msg    = msg,
    })

    -- (Re)start the batching delay
    PCP_MigrateNotify._tickDelay = BATCH_DELAY_TICKS
    if not PCP_MigrateNotify._waiting then
        PCP_MigrateNotify._waiting = true
        Events.OnTick.Add(onTick)
    end
end

Events.OnServerCommand.Add(onServerCommand)

print("[PCP] MigrateNotify: loaded [client]")
