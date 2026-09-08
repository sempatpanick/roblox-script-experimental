# Modules

Load helpers with `functions/load_module.lua`:

```lua
local loadFunctionModule = require("../../functions/load_module") -- or HttpGet fallback
local playerMod = loadFunctionModule("player/character")
```

Subpath is under `functions/` without `.lua`.

## Loader

| Module | Role |
| --- | --- |
| `loader/bootstrap` | PlaceId dispatch + Others picker |
| `loader/run_game_script` | HttpGet and execute a game URL |
| `loader/ui_library_picker` | Native ScreenGui library choice |

## Shared tabs (`tabs/rayfield/`)

| File | Typical options |
| --- | --- |
| `local_player_tab.lua` | `flagsPrefix = "lp"`, walk speed, fly, ESP, rejoin, … |
| `teleport_tab.lua` | `flagsPrefix` for `*_tp_*` flags |
| `objects_tab.lua` | `replicatedStorage` required |
| `recording_tab.lua` | `gamePath` for saved recordings |
| `config_tab.lua` | `configDir`, `rayfieldLibrary`, optional `applyLastFlags` / `onApplyFlag` |

WindUI counterparts in `tabs/windui/` only wrap these.

## `functions/` helpers

| Path | Role |
| --- | --- |
| `player/character.lua` | Local character, root, walk speed, name lists |
| `player/inspect.lua` | Player inspection helpers |
| `player/route_player.lua` | Replay recording-v2 routes |
| `teleport/flags.lua` | `flagsPrefix` → Flag names |
| `config/storage.lua` | Profile list/read/write on executor FS |
| `config/color3.lua` | Color3 (de)serialization |
| `instance/format.lua` | Instance display strings |
| `instance/tree.lua` | Instance tree walking |
| `server/info.lua` | Server / job info |
| `string/coords.lua`, `chunk.lua`, `path.lua` | String helpers |
| `rayfield/dropdown.lua` | Dropdown first-value helper |
| `windui/compat.lua` | Rayfield API on WindUI |
| `windui/load_tab.lua` | Load a rayfield tab by name |
| `windui/notify.lua` | WindUI notify factory |
| `executor/resolve.lua` | Executor capability checks |
| `games/expedition_antartica*` | Antarctica-specific helpers (not generic) |

## Standalone (not on the PlaceId map)

- `auto_harvest.lua` — SAWAH Indo harvest helper
- `Cobalt.luau` — do not modify
