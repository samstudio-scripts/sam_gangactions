local headbagEntity = nil

local function removeHeadbag()
    if not headbagEntity then return end

    DeleteEntity(headbagEntity)
    SetEntityAsNoLongerNeeded(headbagEntity)
    headbagEntity = nil
    SendNUIMessage({ type = 'bagOff' })
end

local function applyHeadbag()
    local model = `prop_money_bag_01`
    lib.requestModel(model)

    headbagEntity = CreateObject(model, 0.0, 0.0, 0.0, true, true, true)
    AttachEntityToEntity(headbagEntity, cache.ped, GetPedBoneIndex(cache.ped, 12844),
        0.22, 0.04, 0.0, 0.0, 270.0, 60.0, true, true, false, true, 1, true)
    SetModelAsNoLongerNeeded(model)

    SendNUIMessage({ type = 'bagOn' })
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

    local success = lib.callback.await('sam_gangactions:server:toggleHeadbag', false, targetId)

    if success then
        lib.notify({ description = locale('headbag_put_on'), type = 'success' })
    end
end

exports.ox_target:addGlobalPlayer({
    {
        name = 'sam_gangactions:headbag',
        icon = 'fas fa-mask',
        label = locale('headbag_label'),
        distance = 2.0,
        items = Config.Items.headbag,
        canInteract = function(entity)
            return GetVehiclePedIsIn(entity, false) == 0 and not LocalPlayer.state.invBusy
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
