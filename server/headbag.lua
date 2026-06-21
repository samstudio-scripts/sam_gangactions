local COOLDOWN = 5000

lib.callback.register('sam_gangactions:server:toggleHeadbag', function(source, targetId)
    if IsOnCooldown(source, 'headbag', COOLDOWN) then return false end
    if not GetPlayerName(targetId) then return false end

    local srcCoords = GetEntityCoords(GetPlayerPed(source))
    local targetCoords = GetEntityCoords(GetPlayerPed(targetId))

    if #(srcCoords - targetCoords) > 10.0 then
        warn(('[sam_gangactions] %s (id:%d) failed distance check for toggleHeadbag on %d'):format(GetPlayerName(source), source, targetId))
        return false
    end

    local hasBag = Player(targetId).state.hasHeadbag

    if hasBag then
        exports.ox_inventory:AddItem(source, Config.Items.headbag, 1)
    else
        if not exports.ox_inventory:RemoveItem(source, Config.Items.headbag, 1) then
            return false
        end
    end

    Player(targetId).state.hasHeadbag = not hasBag
    SavePlayerState(targetId, 'headbag', not hasBag)

    return true
end)
