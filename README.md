# sempatpanick

Roblox executor hub. The local folder may be named `cobalt`; the product, GitHub repo, UI title, and config folder are **sempatpanick**.

Remote: [sempatpanick/roblox-script-experimental](https://github.com/sempatpanick/roblox-script-experimental)

## Load

Production (executor):

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/sempatpanick/roblox-script-experimental/refs/heads/main/sempatpanick.lua"))()
```

Local: serve the repo root at `http://127.0.0.1:5500` and execute `sempatpanick_local.lua`.

`functions/loader/bootstrap.lua` picks a script from `game.PlaceId`. Unlisted places prompt for Rayfield, WindUI, or Sempat UI and then load the matching `games/*/others.lua`.

## Layout

```
sempatpanick.lua / sempatpanick_local.lua   entry + PlaceId map
functions/loader/                           bootstrap, HttpGet runner, UI picker
functions/                                  shared helpers (load via load_module.lua)
games/sempat|rayfield|windui/               per-game scripts
tabs/rayfield/                              shared tabs (source of truth)
tabs/windui/                                thin wrappers over rayfield tabs
sempat_library.lua                          Sempat UI (Rayfield-compatible API)
rayfield_library.lua / windui_library.lua   vendored UI libraries
mount_yahayuk/                              recorded route JSON for Mount Yahayuk
```

## Docs for agents and humans

Start at [docs/README.md](docs/README.md). Cursor reads [AGENTS.md](AGENTS.md); Claude Code reads [CLAUDE.md](CLAUDE.md).

## Note on `Cobalt.luau`

Bundled third-party tool (https://github.com/notpoiu/cobalt). Do not edit it as part of this hub.
