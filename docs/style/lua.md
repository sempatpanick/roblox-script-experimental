# Lua style

This repo is Lua 5.1 / Luau for Roblox executors. There is no StyLua config in tree; **match the file you are editing**.

## Indent and files

- Game scripts under `games/` use **4 spaces**.
- Several `functions/` and `tabs/windui/` files use **tabs**. Do not retab a whole file to “fix” style.
- New game scripts: 4 spaces, same section banners as siblings (`-- */  Window  /* --`).
- File names: `snake_case.lua`. Sempat UI library is `sempat_library.lua`.

## Language

- `local` everything that can be local. Services at the top.
- Use `cloneref = (cloneref or clonereference or function(instance) return instance end)` at the top of game scripts; wrap sensitive services when siblings do.
- Prefer `pcall` around `require`, `HttpGet`, and remote/game APIs that can fail.
- `task.defer` / `task.wait` over deprecated `spawn`/`wait` in new code.
- Do not add types unless the surrounding file already uses Luau types (`Cobalt.luau` does; hub scripts generally do not).

## Loaders

Keep require-then-HttpGet. Strip BOM. Compile with `loadstring or load`. If a tab module fails, stub a function that notifies instead of erroring the whole hub.

```lua
local baseURL = shared.sempatpanick_baseURL
assert(type(baseURL) == "string" and #baseURL > 0, "[sempatpanick] baseURL not set - load via sempatpanick.lua or sempatpanick_local.lua")
```

Log prefixes: `[sempatpanick]`, `[sempat/<slug>]`, or the tab name (`[Local Player]`).

## UI

- Sempat/Rayfield element tables: `Name`, `Flag` when persisted, `Callback`.
- Use `flagsPrefix` on shared tabs; do not hardcode `lp_*` inside a game unless it is game-specific.
- Sempat tab icons are Lucide names; Rayfield often uses numeric image ids. Do not mix them on the wrong library.
- Window title form: `sempatpanick | <Game Name>`.

## Comments

- File-level `--[[ ... ]]` for modules that export functions.
- Do not comment what the next line obviously does.
- Keep the existing `-- ====================================================================` CORE SERVICES banner in game scripts.

## What not to do

- Mass-format or “clean up” `end` / whitespace across files unless that is the task.
- Duplicate shared tab logic into a game file.
- Edit `Cobalt.luau` or vendored UI libraries for a game feature.
