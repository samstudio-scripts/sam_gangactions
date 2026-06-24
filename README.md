# sam_gangactions

Gang action resource for FiveM: zip tie players, put headbags on them, and escort tied players into vehicles. Built with state bags, framework-aware persistence, and server authority.

## Features

- **Zip ties**: Tie up nearby players using ox_target. Item consumed on use; returning it on removal is configurable. Anyone can untie.
- **Headbag**: Put a bag over a player's head with configurable NUI transparency. Item consumed on use; returning it on removal is configurable.
- **Vehicle escort**: Put tied players into the nearest vehicle or take them out. Automatically finds a free seat.
- **Admin commands**: Admin-only commands can apply/remove zip ties and headbags without requiring items.
- **Persistence**: Cuff/headbag states are saved with KVP and restored on reconnect, including after server restarts.
- **Locale system**: Full i18n support through `lib.locale()`. English and French are included.

## Framework Support

The resource auto-detects the active framework for persistence.

| Framework | Detection | Persistence key |
|-----------|-----------|-----------------|
| QBCore / Qbox bridge | `qb-core` | `PlayerData.citizenid` |
| ESX Legacy | `es_extended` | `xPlayer.identifier` |
| Standalone | no supported framework detected | Rockstar license/license2 |

No framework configuration is required. Qbox support is handled through its qb-core bridge; there is no separate `qbx_core` persistence path.

## Dependencies

- [ox_lib](https://github.com/overextended/ox_lib)
- [ox_target](https://github.com/overextended/ox_target)
- [ox_inventory](https://github.com/overextended/ox_inventory)

## Installation

1. Download or clone this repository into your `resources` folder.
2. Add `ensure sam_gangactions` to your `server.cfg`.
3. Add the following items to your `ox_inventory/data/items.lua`:

```lua
['ziptie'] = {
    label = 'Zip Tie',
    weight = 100,
    stack = true,
},

['headbag'] = {
    label = 'Headbag',
    weight = 200,
    stack = true,
},
```

4. Set your preferred language in `shared/config.lua`:

```lua
Config.Locale = 'en' -- or 'fr'
```

## Configuration

All configuration is in `shared/config.lua`.

```lua
Config = {}

Config.Locale = 'fr'
Config.Persistence = true
Config.HeadbagTransparency = 5

Config.Items = {
    cuffs = 'ziptie',
    headbag = 'headbag',
}

Config.ReturnOnRemoval = {
    cuffs = false,
    headbag = false,
}

Config.Commands = {
    restricted = 'group.admin',
    ziptie = 'ziptie',
    unziptie = 'unziptie',
    headbag = 'headbag',
    unheadbag = 'unheadbag',
}
```

| Option | Description |
|--------|-------------|
| `Config.Locale` | Language code (`en`, `fr`, or any custom locale file you add). |
| `Config.Persistence` | Save and restore cuff/headbag states across reconnects and server restarts. |
| `Config.HeadbagTransparency` | Bag overlay transparency from `0` opaque to `100` invisible. |
| `Config.Items.cuffs` | ox_inventory item name for zip ties. |
| `Config.Items.headbag` | ox_inventory item name for headbags. |
| `Config.ReturnOnRemoval.cuffs` | Return the zip tie to the remover when set to `true`. |
| `Config.ReturnOnRemoval.headbag` | Return the headbag to the remover when set to `true`. |
| `Config.Commands.restricted` | ACE/group permission required for admin commands. |
| `Config.Commands.ziptie` | Command name used to zip tie a player. |
| `Config.Commands.unziptie` | Command name used to remove zip ties. |
| `Config.Commands.headbag` | Command name used to put a headbag on a player. |
| `Config.Commands.unheadbag` | Command name used to remove a headbag. |

## Admin Commands

Commands are registered server-side with `lib.addCommand` and default to `group.admin`.

| Command | Description |
|---------|-------------|
| `/ziptie id` | Zip tie a player without consuming an item. |
| `/unziptie id` | Remove zip ties without returning an item. |
| `/headbag id` | Put a headbag on a player without consuming an item. |
| `/unheadbag id` | Remove a headbag without returning an item. |

Command names and permissions can be changed in `Config.Commands`.

## ox_target Interactions

| Action | Icon | Distance | Condition |
|--------|------|----------|-----------|
| Tie up | `fa-handcuffs` | 1.5 | Target not cuffed, requires zip tie item. |
| Untie | `fa-handcuffs` | 1.5 | Target is cuffed, no item required. |
| Put in vehicle | `fa-car-side` | 2.5 | Target is cuffed and on foot. |
| Take out of vehicle | `fa-car-side` | 5.0 | Target is cuffed and in vehicle. |
| Put on headbag | `fa-mask` | 2.0 | Target on foot, requires headbag item. |
| Remove headbag | `fa-mask` | 2.0 | Target is headbagged, no item required. |

## Adding a Language

Create a new file in `locales/` with your language code, for example `locales/es.json`, then set `Config.Locale = 'es'`.

Command descriptions also use locales, so include the `command_*` keys from `locales/en.json` or `locales/fr.json`.

## Exports

```lua
-- Cuff a player ped (client)
exports.sam_gangactions:cuffPlayer(ped)

-- Toggle headbag on a player ped (client)
exports.sam_gangactions:toggleHeadbag(ped)
```

## Security

- All item interactions are validated server-side through `lib.callback`.
- Server-side distance checks are used on every interaction.
- Server-side item verification is handled through ox_inventory.
- Admin commands are restricted through `lib.addCommand` permissions.
- Rate limiting is applied to cuffs/headbag actions and vehicle actions.
- Client net events use `GetInvokingResource()` checks.
- Failed distance checks are logged with player name and ID through `warn()`.
- State is managed through replicated state bags with server authority.

## Structure

```text
sam_gangactions/
|-- fxmanifest.lua
|-- shared/
|   `-- config.lua
|-- client/
|   |-- init.lua          -- locale init + state restore
|   |-- cuffs.lua         -- zip tie + vehicle escort
|   `-- headbag.lua       -- headbag + NUI blindfold
|-- server/
|   |-- init.lua          -- locale init + rate limiting utility
|   |-- persistence.lua   -- framework-aware KVP state persistence
|   |-- cuffs.lua         -- cuff validation callbacks
|   |-- headbag.lua       -- headbag validation callback
|   `-- commands.lua      -- admin commands
|-- locales/
|   |-- en.json
|   `-- fr.json
`-- html/
    |-- index.html
    |-- bag.png
    |-- css/headbag.css
    `-- js/headbagHandler.js
```

## License

This project is licensed under the [GNU General Public License v3.0](LICENSE).
