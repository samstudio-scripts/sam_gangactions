local function getPlayerLicense(source)
    for _, id in ipairs(GetPlayerIdentifiers(source)) do
        if id:find('^license:') then
            return id
        end
    end
end

---@param source number
---@param key string
---@param value boolean
function SavePlayerState(source, key, value)
    local license = getPlayerLicense(source)
    if not license then return end

    local kvpKey = ('sam_gangactions:%s:%s'):format(key, license)

    if value then
        SetResourceKvp(kvpKey, '1')
    else
        DeleteResourceKvp(kvpKey)
    end
end

lib.callback.register('sam_gangactions:server:restoreState', function(source)
    local license = getPlayerLicense(source)
    if not license then return end

    local hasCuffs = GetResourceKvpString(('sam_gangactions:cuffs:%s'):format(license)) == '1'
    local hasHeadbag = GetResourceKvpString(('sam_gangactions:headbag:%s'):format(license)) == '1'

    if hasCuffs then
        Player(source).state.hasCuffs = true
    end

    if hasHeadbag then
        Player(source).state.hasHeadbag = true
    end
end)
