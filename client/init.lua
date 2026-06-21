lib.locale(Config.Locale)

local stateRestored = false

AddEventHandler('playerSpawned', function()
    if stateRestored then return end
    stateRestored = true

    lib.callback.await('sam_gangactions:server:restoreState', false)
end)
