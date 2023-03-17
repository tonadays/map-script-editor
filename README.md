# Map Script Editor

Tona Days' fork of the [TTT Weapon Placer](https://steamcommunity.com/sharedfiles/filedetails/?id=119928922) by [Bad King Urgrain](https://steamcommunity.com/profiles/76561197964193008)

Improvements:

- Entities will not be listed unless they are present in your game
- Updated vgui code
- Sorted entity list with groups
- Ability to select ammo ents directly
- Partial support for `auto_ammo` (used for all ttt_random_weapon spawns)

## Todo

Pull requests accepted.

- Support for `auto_ammo` when placing individual random weapons
- Support for traitor/detective equipment
- Support for miscellaneous ttt entities
- Support for our custom weapons
- Fix for physgun beam positions not updating
- Fix "Remove all existing weapons" removing sandbox weapons from players
- Dynamic ttt weapon support
- Support for [Exho](https://steamcommunity.com/id/Exho1)'s [Prop Placing Tool](https://steamcommunity.com/sharedfiles/filedetails/?id=326667871) scripts ([source code](https://github.com/Exho1/PH_PropPlacerTool))
- Support for all of [zaratusa](https://steamcommunity.com/id/zaratusa)'s custom weapons
- Proper handling of client/server/prediction logic and consquently multiplayer sandbox support
  - Likely related to physgun beam position issue

## Developer Reference

- TTT's weapon rearm script: [terrortown/gamemode/ent_replace.lua](https://github.com/Facepunch/garrysmod/blob/master/garrysmod/gamemodes/terrortown/gamemode/ent_replace.lua)
    - [ttt_random_weapon](https://github.com/Facepunch/garrysmod/blob/master/garrysmod/gamemodes/terrortown/entities/entities/ttt_random_weapon.lua), [ttt_random_ammo](https://github.com/Facepunch/garrysmod/blob/master/garrysmod/gamemodes/terrortown/entities/entities/ttt_random_ammo.lua), and [fgd definition](https://github.com/Facepunch/garrysmod/blob/be251723824643351cb88a969818425d1ddf42b3/garrysmod/gamemodes/terrortown/ttt.fgd#L20-L23)
- Exho's prop adder script: [lua/autorun/sv_propadder.lua](https://github.com/Exho1/PH_PropPlacerTool/blob/master/lua/autorun/sv_propadder.lua)
    - [weapon_propadder.lua](https://github.com/Exho1/PH_PropPlacerTool/blob/master/lua/weapons/weapon_propadder.lua)
