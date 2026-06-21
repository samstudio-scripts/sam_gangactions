# sam_gangactions

Standalone gang action resource for FiveM — zip tie players, put headbags on them, escort them into vehicles. Built with ox ecosystem, state bags, and server authority.

## Features

- **Zip Ties** — Tie up nearby players using ox_target. Item consumed on use, destroyed on removal. Anyone can untie.
- **Headbag** — Put a bag over a player's head, fully blinding them with a NUI overlay. Item consumed on use, returned on removal.
- **Vehicle Escort** — Put tied-up players into the nearest vehicle or take them out. Automatically finds a free seat.
- **Persistence** — Player states are saved via KVP. If a player disconnects while tied up or headbagged, the state is restored on reconnect (survives server restarts).
- **Locale System** — Full i18n support via `lib.locale()`. English and French included. Easy to add more languages.

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

All configuration is in `shared/config.lua`:

```lua
Config = {}

Config.Locale = 'fr'
Config.Persistence = true

Config.Items = {
    cuffs = 'ziptie',
    headbag = 'headbag',
}
```

| Option | Description |
|--------|-------------|
| `Config.Locale` | Language code (`en`, `fr`, or any custom locale file you add) |
| `Config.Persistence` | Save and restore cuff/headbag states across reconnects and server restarts |
| `Config.Items.cuffs` | ox_inventory item name for zip ties |
| `Config.Items.headbag` | ox_inventory item name for headbags |

## Adding a Language

Create a new file in `locales/` with your language code (e.g. `locales/es.json`):

```json
{
    "cuff_label": "Atar",
    "uncuff_label": "Desatar",
    "put_in_vehicle": "Subir al vehículo",
    "take_out_vehicle": "Bajar del vehículo",
    "no_vehicle_nearby": "No hay vehículo cerca",
    "no_free_seat": "No hay asiento disponible",
    "headbag_label": "Poner/Quitar bolsa",
    "headbag_put_on": "Le pusiste una bolsa a un jugador",
    "headbag_taken_off": "Alguien te quitó la bolsa",
    "headbag_progress": "Bolsa..."
}
```

Then set `Config.Locale = 'es'` in the config.

## ox_target Interactions

| Action | Icon | Distance | Condition |
|--------|------|----------|-----------|
| Tie up | `fa-handcuffs` | 1.5 | Target not cuffed, requires zip tie item |
| Untie | `fa-handcuffs` | 1.5 | Target is cuffed, no item required |
| Put in vehicle | `fa-car-side` | 2.5 | Target is cuffed and on foot |
| Take out of vehicle | `fa-car-side` | 5.0 | Target is cuffed and in vehicle |
| Headbag | `fa-mask` | 2.0 | Target on foot, requires headbag item |

## Exports

```lua
-- Cuff a player ped (client)
exports.sam_gangactions:cuffPlayer(ped)

-- Toggle headbag on a player ped (client)
exports.sam_gangactions:toggleHeadbag(ped)
```

## Security

- All actions validated server-side via `lib.callback`
- Server-side distance checks on every interaction
- Server-side item verification via ox_inventory
- Rate limiting (5s cooldown on cuffs/headbag, 2s on vehicle actions)
- `GetInvokingResource()` checks on client net events
- Failed distance checks logged with player name and ID via `warn()`
- State managed through state bags (server authority)

## Structure

```
sam_gangactions/
├── fxmanifest.lua
├── shared/
│   └── config.lua
├── client/
│   ├── init.lua          -- locale init + state restore
│   ├── cuffs.lua         -- zip tie + vehicle escort
│   └── headbag.lua       -- headbag + NUI blindfold
├── server/
│   ├── init.lua          -- rate limiting utility
│   ├── persistence.lua   -- KVP state persistence
│   ├── cuffs.lua         -- cuff validation callbacks
│   └── headbag.lua       -- headbag validation callback
├── locales/
│   ├── en.json
│   └── fr.json
└── html/
    ├── index.html
    ├── bag.png
    ├── css/headbag.css
    └── js/headbagHandler.js
```

## License

This project is licensed under the [GNU General Public License v3.0](LICENSE).
