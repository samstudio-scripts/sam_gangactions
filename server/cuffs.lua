local COOLDOWN = 5000

lib.callback.register('sam_gangactions:server:toggleCuffs', function(source, targetId)
    if IsOnCooldown(source, 'cuffs', COOLDOWN) then return false end
    if not GetPlayerName(targetId) then return false end

    local srcCoords = GetEntityCoords(GetPlayerPed(source))
    local targetCoords = GetEntityCoords(GetPlayerPed(targetId))

    if #(srcCoords - targetCoords) > 10.0 then
        warn(('[sam_gangactions] %s (id:%d) failed distance check for toggleCuffs on %d'):format(GetPlayerName(source), source, targetId))
        return false
    end

    local wasCuffed = Player(targetId).state.hasCuffs

    if wasCuffed then
        if Config.ReturnOnRemoval.cuffs
            and not exports.ox_inventory:AddItem(source, Config.Items.cuffs, 1)
        then
            return false
        end
    else
        if not exports.ox_inventory:RemoveItem(source, Config.Items.cuffs, 1) then
            return false
        end
    end

    Player(targetId).state.hasCuffs = not wasCuffed
    SavePlayerState(targetId, 'cuffs', not wasCuffed)

    return true, wasCuffed
end)

lib.callback.register('sam_gangactions:server:putInVehicle', function(source, targetId, vehNetId, seat)
    if IsOnCooldown(source, 'vehicle', 2000) then return false end
    if not GetPlayerName(targetId) then return false end
    if not Player(targetId).state.hasCuffs then return false end

    if #(GetEntityCoords(GetPlayerPed(source)) - GetEntityCoords(GetPlayerPed(targetId))) > 10.0 then
        warn(('[sam_gangactions] %s (id:%d) failed distance check for putInVehicle on %d'):format(GetPlayerName(source), source, targetId))
        return false
    end

    TriggerClientEvent('sam_gangactions:client:putInVehicle', targetId, vehNetId, seat)

    return true
end)

lib.callback.register('sam_gangactions:server:takeOutOfVehicle', function(source, targetId)
    if IsOnCooldown(source, 'vehicle', 2000) then return false end
    if not GetPlayerName(targetId) then return false end
    if not Player(targetId).state.hasCuffs then return false end

    local targetPed = GetPlayerPed(targetId)
    if targetPed == 0 or GetVehiclePedIsIn(targetPed, false) == 0 then return false end

    if #(GetEntityCoords(GetPlayerPed(source)) - GetEntityCoords(targetPed)) > 15.0 then
        warn(('[sam_gangactions] %s (id:%d) failed distance check for takeOutOfVehicle on %d'):format(GetPlayerName(source), source, targetId))
        return false
    end

    TriggerClientEvent('sam_gangactions:client:takeOutOfVehicle', targetId)

    return true
end)
