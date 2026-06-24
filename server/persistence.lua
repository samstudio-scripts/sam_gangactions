local playerIdentifiers = {}
local QBCore
local ESX

local function getPlayerLicense(source)
    local license2

    for _, id in ipairs(GetPlayerIdentifiers(source)) do
        if id:find('^license:') then
            return id
        elseif id:find('^license2:') then
            license2 = id
        end
    end

    return license2
end

local function getESX()
    if ESX then return ESX end
    if GetResourceState('es_extended') ~= 'started' then return end

    ESX = exports['es_extended']:getSharedObject()
    return ESX
end

local function getQBCore()
    if QBCore then return QBCore end
    if GetResourceState('qb-core') ~= 'started' then return end

    QBCore = exports['qb-core']:GetCoreObject({ 'Functions' })
    return QBCore
end

local function hasCharacterFramework()
    return GetResourceState('qb-core') == 'started'
        or GetResourceState('qbx_core') == 'started'
        or GetResourceState('es_extended') == 'started'
end

---@param source number
---@return string?
local function getPlayerIdentifier(source)
    local qbCore = getQBCore()
    if qbCore then
        local success, player = pcall(function()
            return exports['qb-core']:GetPlayer(source)
        end)

        if not success or not player then
            player = qbCore.Functions.GetPlayer(source)
        end

        local citizenid = player and player.PlayerData and player.PlayerData.citizenid

        if citizenid then
            return ('citizenid:%s'):format(citizenid)
        end
    end

    if GetResourceState('qbx_core') == 'started' then
        local player = exports.qbx_core:GetPlayer(source)
        local citizenid = player and player.PlayerData and player.PlayerData.citizenid

        if citizenid then
            return ('citizenid:%s'):format(citizenid)
        end
    end

    local esx = getESX()
    if esx then
        local xPlayer = esx.GetPlayerFromId(source)
        local identifier = xPlayer and xPlayer.identifier

        if identifier then
            return ('esx:%s'):format(identifier)
        end
    end

    local license = getPlayerLicense(source)
    return license and ('license:%s'):format(license)
end

---@param identifier string
---@param key string
---@return string
local function getKvpKey(identifier, key)
    return ('sam_gangactions:%s:%s'):format(key, identifier)
end

---@param identifier string
---@param key string
---@param value boolean
local function savePlayerStateByIdentifier(identifier, key, value)
    local kvpKey = getKvpKey(identifier, key)

    if value then
        SetResourceKvp(kvpKey, '1')
    else
        DeleteResourceKvp(kvpKey)
    end
end

---@param source number
---@param identifier string
---@param key string
---@return boolean
local function getSavedPlayerState(source, identifier, key)
    if GetResourceKvpString(getKvpKey(identifier, key)) == '1' then
        return true
    end

    if identifier:find('^license:') then
        return false
    end

    local license = getPlayerLicense(source)
    if not license then return false end

    local legacyKey = ('sam_gangactions:%s:%s'):format(key, license)
    local prefixedLicenseKey = getKvpKey(('license:%s'):format(license), key)
    local hasLegacyState = GetResourceKvpString(legacyKey) == '1'
        or GetResourceKvpString(prefixedLicenseKey) == '1'

    if hasLegacyState then
        savePlayerStateByIdentifier(identifier, key, true)
    end

    return hasLegacyState
end

---@param source number
---@param key string
---@param value boolean
function SavePlayerState(source, key, value)
    if not Config.Persistence then return end

    local identifier = getPlayerIdentifier(source)
    if not identifier then return end

    playerIdentifiers[source] = identifier
    savePlayerStateByIdentifier(identifier, key, value)
end

local function restorePlayerState(source)
    if not Config.Persistence then return end

    local identifier = getPlayerIdentifier(source)
    if not identifier then return end

    playerIdentifiers[source] = identifier

    local hasCuffs = getSavedPlayerState(source, identifier, 'cuffs')
    local hasHeadbag = getSavedPlayerState(source, identifier, 'headbag')

    Player(source).state:set('hasCuffs', hasCuffs, true)
    Player(source).state:set('hasHeadbag', hasHeadbag, true)
end

lib.callback.register('sam_gangactions:server:restoreState', function(source)
    restorePlayerState(source)
end)

RegisterNetEvent('QBCore:Server:OnPlayerLoaded', function()
    local src = source

    SetTimeout(500, function()
        if GetPlayerName(src) then
            restorePlayerState(src)
        end
    end)
end)

AddEventHandler('esx:playerLoaded', function(playerId)
    SetTimeout(500, function()
        if GetPlayerName(playerId) then
            restorePlayerState(playerId)
        end
    end)
end)

local function saveCurrentPlayerState(source)
    if not Config.Persistence then return end

    local player = Player(source)
    local identifier = playerIdentifiers[source]

    if not identifier and not hasCharacterFramework() then
        identifier = getPlayerIdentifier(source)
    end

    if not player or not identifier then return end

    savePlayerStateByIdentifier(identifier, 'cuffs', player.state.hasCuffs == true)
    savePlayerStateByIdentifier(identifier, 'headbag', player.state.hasHeadbag == true)
end

AddEventHandler('QBCore:Server:OnPlayerUnload', function(source)
    saveCurrentPlayerState(source)
    playerIdentifiers[source] = nil
end)

AddEventHandler('esx:playerDropped', function(playerId)
    saveCurrentPlayerState(playerId)
    playerIdentifiers[playerId] = nil
end)

AddEventHandler('playerDropped', function()
    local src = source
    saveCurrentPlayerState(src)
    playerIdentifiers[src] = nil
end)
