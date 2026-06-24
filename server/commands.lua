local commandConfig = Config.Commands or {}

local function addPlayerStateCommand(commandName, help, stateKey, stateValue, setter)
    if not commandName or commandName == '' then return end

    lib.addCommand(commandName, {
        help = help,
        restricted = commandConfig.restricted or 'group.admin',
        params = {
            {
                name = 'id',
                type = 'playerId',
                help = 'Target player server id',
            },
        },
    }, function(source, args)
        local targetId = args.id
        local player = Player(targetId)

        if not player or not GetPlayerName(targetId) then return end
        if player.state[stateKey] == stateValue then return end

        setter(targetId, stateValue)
    end)
end

addPlayerStateCommand(commandConfig.ziptie or 'ziptie', 'Zip tie a player', 'hasCuffs', true, SamGangActions.SetCuffs)
addPlayerStateCommand(commandConfig.unziptie or 'unziptie', 'Remove zip tie from a player', 'hasCuffs', false, SamGangActions.SetCuffs)
addPlayerStateCommand(commandConfig.headbag or 'headbag', 'Put a headbag on a player', 'hasHeadbag', true, SamGangActions.SetHeadbag)
addPlayerStateCommand(commandConfig.unheadbag or 'unheadbag', 'Remove a headbag from a player', 'hasHeadbag', false, SamGangActions.SetHeadbag)
