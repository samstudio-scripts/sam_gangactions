local cooldowns = {}

SamGangActions = SamGangActions or {}

---@param source number
---@param action string
---@param duration number cooldown in ms
---@return boolean
function IsOnCooldown(source, action, duration)
    local key = ('%d:%s'):format(source, action)
    local now = GetGameTimer()

    if cooldowns[key] and now - cooldowns[key] < duration then
        return true
    end

    cooldowns[key] = now
    return false
end

AddEventHandler('playerDropped', function()
    local src = source
    for key in pairs(cooldowns) do
        if key:find('^' .. src .. ':') then
            cooldowns[key] = nil
        end
    end
end)
