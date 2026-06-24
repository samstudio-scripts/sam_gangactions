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
                help = locale('command_target_help'),
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

addPlayerStateCommand(commandConfig.ziptie or 'ziptie', locale('command_ziptie_help'), 'hasCuffs', true, SamGangActions.SetCuffs)
addPlayerStateCommand(commandConfig.unziptie or 'unziptie', locale('command_unziptie_help'), 'hasCuffs', false, SamGangActions.SetCuffs)
addPlayerStateCommand(commandConfig.headbag or 'headbag', locale('command_headbag_help'), 'hasHeadbag', true, SamGangActions.SetHeadbag)
addPlayerStateCommand(commandConfig.unheadbag or 'unheadbag', locale('command_unheadbag_help'), 'hasHeadbag', false, SamGangActions.SetHeadbag)
