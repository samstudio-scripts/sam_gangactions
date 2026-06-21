local headbagEntity = nil

---@param ped number
---@return boolean
local function hasHeadbag(ped)
    local playerIndex = NetworkGetPlayerIndexFromPed(ped)
    if playerIndex == -1 then return false end

    local serverId = GetPlayerServerId(playerIndex)
    return serverId > 0 and Player(serverId).state.hasHeadbag == true
end

local function removeHeadbag()
    if not headbagEntity then return end

    DeleteEntity(headbagEntity)
    SetEntityAsNoLongerNeeded(headbagEntity)
    headbagEntity = nil
    SendNUIMessage({ type = 'bagOff' })
end

local function applyHeadbag()
    local model = `prop_money_bag_01`
    local transparency = math.min(math.max(tonumber(Config.HeadbagTransparency) or 0, 0), 100)
    lib.requestModel(model)

    headbagEntity = CreateObject(model, 0.0, 0.0, 0.0, true, true, true)
    AttachEntityToEntity(headbagEntity, cache.ped, GetPedBoneIndex(cache.ped, 12844),
        0.22, 0.04, 0.0, 0.0, 270.0, 60.0, true, true, false, true, 1, true)
    SetModelAsNoLongerNeeded(model)

    SendNUIMessage({
        type = 'bagOn',
        transparency = transparency,
    })
    SetNuiFocus(false, false)
end

AddStateBagChangeHandler('hasHeadbag', ('player:%d'):format(cache.serverId), function(_, _, state)
    if state then
        applyHeadbag()
    else
        removeHeadbag()
        lib.notify({ description = locale('headbag_taken_off'), type = 'inform' })
    end
end)

---@param ped number
local function toggleHeadbag(ped)
    if GetVehiclePedIsIn(ped, false) ~= 0 then return end

    local targetId = GetPlayerServerId(NetworkGetPlayerIndexFromPed(ped))

    if not lib.progressCircle({
        duration = 3000,
        position = 'bottom',
        useWhileDead = false,
        canCancel = true,
        label = locale('headbag_progress'),
        disable = { car = true, move = true, combat = true },
        anim = { dict = 'mp_arresting', clip = 'a_uncuff' },
    }) then
        return
    end

    local success, wasHeadbagged = lib.callback.await('sam_gangactions:server:toggleHeadbag', false, targetId)

    if success then
        local message = wasHeadbagged and locale('headbag_removed') or locale('headbag_put_on')
        lib.notify({ description = message, type = 'success' })
    end
end

exports.ox_target:addGlobalPlayer({
    {
        name = 'sam_gangactions:putHeadbag',
        icon = 'fas fa-mask',
        label = locale('headbag_put_label'),
        distance = 2.0,
        items = Config.Items.headbag,
        canInteract = function(entity)
            return GetVehiclePedIsIn(entity, false) == 0
                and not hasHeadbag(entity)
                and not LocalPlayer.state.invBusy
        end,
        onSelect = function(data)
            toggleHeadbag(data.entity)
        end,
    },
    {
        name = 'sam_gangactions:removeHeadbag',
        icon = 'fas fa-mask',
        label = locale('headbag_remove_label'),
        distance = 2.0,
        canInteract = function(entity)
            return GetVehiclePedIsIn(entity, false) == 0
                and hasHeadbag(entity)
                and not LocalPlayer.state.invBusy
        end,
        onSelect = function(data)
            toggleHeadbag(data.entity)
        end,
    },
})

AddEventHandler('playerSpawned', function()
    removeHeadbag()
end)

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        removeHeadbag()
    end
end)

exports('toggleHeadbag', toggleHeadbag)
