local isCuffed = false

local DisablePlayerFiring = DisablePlayerFiring
local DisableControlAction = DisableControlAction

local function runCuffLoop()
    local dict = 'mp_arresting'

    while isCuffed do
        if not IsEntityPlayingAnim(cache.ped, dict, 'idle', 3) then
            lib.requestAnimDict(dict)
            TaskPlayAnim(cache.ped, dict, 'idle', 8.0, -8, -1, 49, 0.0, false, false, false)
        end

        DisablePlayerFiring(cache.playerId, true)
        DisableControlAction(0, 140, true)
        Wait(0)
    end

    ClearPedTasks(cache.ped)
    RemoveAnimDict(dict)
end

---@param ped number
---@return boolean
local function canInteract(ped)
    return GetVehiclePedIsIn(ped, false) == 0
end

---@param ped number
local function cuffPlayer(ped)
    if not canInteract(ped) then return end

    local targetId = GetPlayerServerId(NetworkGetPlayerIndexFromPed(ped))
    local canUse, wasCuffed = lib.callback.await('sam_gangactions:server:toggleCuffs', false, targetId)

    if not canUse then return end

    LocalPlayer.state.invBusy = true
    FreezeEntityPosition(cache.ped, true)
    SetCurrentPedWeapon(cache.ped, `WEAPON_UNARMED`, true)
    AttachEntityToEntity(cache.ped, ped, 11816, -0.07, -0.58, 0.0, 0.0, 0.0, 0.0, false, false, false, true, 2, true)

    local dict = wasCuffed and 'mp_arresting' or 'mp_arrest_paired'
    lib.requestAnimDict(dict)

    if wasCuffed then
        TaskPlayAnim(cache.ped, dict, 'a_uncuff', 8.0, -8, 5500, 0, 0, false, false, false)
        Wait(5000)
    else
        TaskPlayAnim(cache.ped, dict, 'cop_p2_back_right', 8.0, -8.0, 3750, 2, 0.0, false, false, false)
        Wait(4000)
    end

    DetachEntity(cache.ped, true, false)
    FreezeEntityPosition(cache.ped, false)
    RemoveAnimDict(dict)
    LocalPlayer.state.invBusy = false
end

-- Vehicle escort

---@param targetPed number
local function putInVehicle(targetPed)
    local vehicle = lib.getClosestVehicle(GetEntityCoords(cache.ped), 5.0, false)

    if not vehicle then
        lib.notify({ description = locale('no_vehicle_nearby'), type = 'error' })
        return
    end

    local maxSeats = GetVehicleMaxNumberOfPassengers(vehicle)
    local freeSeat = nil

    for i = 0, maxSeats - 1 do
        if IsVehicleSeatFree(vehicle, i) then
            freeSeat = i
            break
        end
    end

    if not freeSeat then
        lib.notify({ description = locale('no_free_seat'), type = 'error' })
        return
    end

    local targetId = GetPlayerServerId(NetworkGetPlayerIndexFromPed(targetPed))
    local vehNetId = NetworkGetNetworkIdFromEntity(vehicle)

    lib.callback.await('sam_gangactions:server:putInVehicle', false, targetId, vehNetId, freeSeat)
end

---@param targetPed number
local function takeOutOfVehicle(targetPed)
    local targetId = GetPlayerServerId(NetworkGetPlayerIndexFromPed(targetPed))
    lib.callback.await('sam_gangactions:server:takeOutOfVehicle', false, targetId)
end

---@param vehicle number
---@return number?
local function getCuffedOccupant(vehicle)
    local maxPassengers = GetVehicleMaxNumberOfPassengers(vehicle)

    for seat = -1, maxPassengers - 1 do
        local ped = GetPedInVehicleSeat(vehicle, seat)

        if ped ~= 0 and IsPedAPlayer(ped) then
            local playerIndex = NetworkGetPlayerIndexFromPed(ped)

            if playerIndex ~= -1 then
                local serverId = GetPlayerServerId(playerIndex)

                if serverId > 0 and Player(serverId).state.hasCuffs then
                    return ped
                end
            end
        end
    end
end

-- Target client handlers (server tells cuffed player to enter/exit)

RegisterNetEvent('sam_gangactions:client:putInVehicle', function(vehNetId, seat)
    if GetInvokingResource() then return end
    if not isCuffed then return end

    local vehicle = NetworkGetEntityFromNetworkId(vehNetId)
    if not DoesEntityExist(vehicle) then return end

    if not IsVehicleSeatFree(vehicle, seat) then
        local maxSeats = GetVehicleMaxNumberOfPassengers(vehicle)
        seat = nil
        for i = 0, maxSeats - 1 do
            if IsVehicleSeatFree(vehicle, i) then
                seat = i
                break
            end
        end
        if not seat then return end
    end

    TaskWarpPedIntoVehicle(cache.ped, vehicle, seat)
end)

RegisterNetEvent('sam_gangactions:client:takeOutOfVehicle', function()
    if GetInvokingResource() then return end
    if not isCuffed then return end

    local vehicle = GetVehiclePedIsIn(cache.ped, false)
    if vehicle == 0 then return end

    TaskLeaveVehicle(cache.ped, vehicle, 16)
end)

-- State bag handler

AddStateBagChangeHandler('hasCuffs', ('player:%d'):format(cache.serverId), function(_, _, state)
    SetCurrentPedWeapon(cache.ped, `WEAPON_UNARMED`, true)
    FreezeEntityPosition(cache.ped, true)

    local dict = state and 'mp_arrest_paired' or 'mp_arresting'
    lib.requestAnimDict(dict)

    if state then
        TaskPlayAnim(cache.ped, dict, 'crook_p2_back_right', 8.0, -8, 5000, 2, 0, false, false, false)
        Wait(5000)
    else
        TaskPlayAnim(cache.ped, dict, 'arrested_spin_l_0', 8.0, -8, 4000, 0, 0, false, false, false)
        Wait(4000)
    end

    SetEnableHandcuffs(cache.ped, state)
    LocalPlayer.state.invBusy = state
    RemoveAnimDict(dict)
    FreezeEntityPosition(cache.ped, false)
    isCuffed = state

    if isCuffed then
        runCuffLoop()
    end

    ClearPedTasks(cache.ped)
end)

-- ox_target

exports.ox_target:addGlobalPlayer({
    {
        name = 'sam_gangactions:cuff',
        icon = 'fas fa-handcuffs',
        label = locale('cuff_label'),
        distance = 1.5,
        items = Config.Items.cuffs,
        canInteract = function(entity)
            return canInteract(entity) and not IsPedCuffed(entity) and not LocalPlayer.state.invBusy
        end,
        onSelect = function(data)
            cuffPlayer(data.entity)
        end,
    },
    {
        name = 'sam_gangactions:uncuff',
        icon = 'fas fa-handcuffs',
        label = locale('uncuff_label'),
        distance = 1.5,
        canInteract = function(entity)
            return canInteract(entity) and IsPedCuffed(entity) and not LocalPlayer.state.invBusy
        end,
        onSelect = function(data)
            cuffPlayer(data.entity)
        end,
    },
    {
        name = 'sam_gangactions:putInVehicle',
        icon = 'fas fa-car-side',
        label = locale('put_in_vehicle'),
        distance = 2.5,
        canInteract = function(entity)
            return IsPedCuffed(entity) and GetVehiclePedIsIn(entity, false) == 0 and not LocalPlayer.state.invBusy
        end,
        onSelect = function(data)
            putInVehicle(data.entity)
        end,
    },
})

exports.ox_target:addGlobalVehicle({
    {
        name = 'sam_gangactions:takeOutOfVehicle',
        icon = 'fas fa-car-side',
        label = locale('take_out_vehicle'),
        distance = 5.0,
        canInteract = function(vehicle)
            return getCuffedOccupant(vehicle) ~= nil and not LocalPlayer.state.invBusy
        end,
        onSelect = function(data)
            local targetPed = getCuffedOccupant(data.entity)
            if not targetPed then return end

            takeOutOfVehicle(targetPed)
        end,
    },
})

exports('cuffPlayer', cuffPlayer)
