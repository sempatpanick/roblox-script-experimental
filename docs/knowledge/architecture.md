# Architecture

## Boot sequence

```
sempatpanick.lua  or  sempatpanick_local.lua
        │
        ├─ sets baseURL
        ├─ games[PlaceId] = baseURL .. "/games/<library>/<slug>.lua"
        ├─ excludedGameIds skip bootstrap entirely
        └─ load functions/loader/bootstrap.lua
                    │
                    ├─ shared.sempatpanick_baseURL = baseURL
                    ├─ if PlaceId in games → run_game_script.run(url)
                    └─ else UI picker → games/rayfield|windui|sempat/others.lua
```

`functions/loader/run_game_script.lua` HttpGets the game file, strips BOM, compiles, and runs it.

## Dual load (required pattern)

Anything fetched at runtime must work both from a filesystem `require` and from raw HTTP:

1. `pcall(require, relativePath)`
2. Optional second relative path
3. `game:HttpGet(baseURL .. "/<path>.lua")`
4. Strip UTF-8 BOM (`EF BB BF`)
5. `loadstring` or `load`, then `pcall(chunk)`

`functions/load_module.lua` is the shared helper for `functions/*`. It also sets `shared.__sempatpanick_load_function_module` because HttpGet chunks cannot `require` siblings.

Game scripts still often inline a copy of this pattern for tab modules. When editing those loaders, keep require-then-HttpGet, BOM strip, and a fallback stub if the tab fails to load.

## Folder roles

```
functions/loader/     bootstrap, run_game_script, ui_library_picker
functions/            helpers; path is load_module("player/character")
tabs/rayfield/        shared hub tabs (source of truth)
tabs/windui/          wrapWindow + load_tab so WindUI reuses rayfield tabs
games/sempat/         current default for new PlaceIds
games/rayfield/       older / still-maintained Rayfield games
games/windui/         WindUI Others (and picker target)
mount_yahayuk/        recorded routes + possibilities for Mount Yahayuk
```

## Shared state

| Key | Set by | Used for |
| --- | --- | --- |
| `shared.sempatpanick_baseURL` | entry / bootstrap / run_game_script | HttpGet of modules |
| `shared.sempatpanick_ui_library` | UI picker | which Others script was chosen |
| `shared.__sempatpanick_load_function_module` | load_module.lua | sibling loads inside HttpGet chunks |

## Config and flags

Windows use `ConfigurationSaving` with `FolderName = "sempatpanick"` and a per-game `FileName`. Shared tabs take `flagsPrefix` so flags become `lp_walkSpeed`, `daun_tp_location`, etc. Config tab `configDir` is usually `sempatpanick/<slug>`.

Sempat windows typically set `AutoSave = false` and `AutoLoad = false`; the Config tab applies profiles.

## Recording and routes

`tabs/rayfield/recording_tab.lua` records character motion. `functions/player/route_player.lua` replays recording-v2 tables (frames + events). Mount Yahayuk stores many JSON takes under `mount_yahayuk/routes/`. Other hiking games (Daun, Noxera, Velora) usually keep summit/checkpoint routes as Lua tables inside the game script.
