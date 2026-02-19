---------------------------------------------------------------
-- PCP_MigrateNotify.lua
-- Client-side listener for migration result notifications.
-- Displays green HaloText on success, console log on error.
--
-- Listens for: module="PCP", command="migrateResult"
-- Sent by: PhobosLib.notifyMigrationResult() via PCP_MigrationSystem.lua
---------------------------------------------------------------

local function onServerCommand(module, command, args)
    if module ~= "PCP" or command ~= "migrateResult" then return end
    if not args then return end

    local player = nil
    pcall(function()
        player = getSpecificPlayer(0)
    end)

    local msg = args.msg or "Migration completed."
    local label = args.label or "migration"

    if args.status == "ok" then
        if player then
            pcall(function()
                if HaloTextHelper and HaloTextHelper.addTextWithArrow then
                    HaloTextHelper.addTextWithArrow(player, true, "[PCP] " .. msg)
                elseif HaloTextHelper and HaloTextHelper.addText then
                    HaloTextHelper.addText(player, "[PCP] " .. msg, HaloTextHelper.getColorGreen())
                end
            end)
        end
        print("[PCP] MigrateNotify: OK — " .. label .. " — " .. msg)
    else
        print("[PCP] MigrateNotify: FAIL — " .. label .. " — " .. msg)
    end
end

Events.OnServerCommand.Add(onServerCommand)

print("[PCP] MigrateNotify: loaded [client]")
