lib.locale(Config.Locale)

local stateRestored = false

AddEventHandler('playerSpawned', function()
    if not Config.Persistence then return end
    if stateRestored then return end
    stateRestored = true

    lib.callback.await('sam_gangactions:server:restoreState', false)
end)
