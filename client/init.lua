lib.locale(Config.Locale)

local restoringState = false

local function restoreState()
    if not Config.Persistence then return end
    if restoringState then return end

    restoringState = true
    TriggerEvent('sam_gangactions:client:restoringState', true)
    lib.callback.await('sam_gangactions:server:restoreState', false)
    Wait(1000)
    TriggerEvent('sam_gangactions:client:restoringState', false)
    restoringState = false
end

AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
    Wait(500)
    restoreState()
end)

AddEventHandler('esx:playerLoaded', function()
    Wait(500)
    restoreState()
end)

AddEventHandler('playerSpawned', function()
    Wait(1000)
    restoreState()
end)

AddEventHandler('esx:onPlayerSpawn', function()
    Wait(1000)
    restoreState()
end)
