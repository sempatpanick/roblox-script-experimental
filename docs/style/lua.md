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

## 200 local limit (always check)

Lua 5.1 / Luau allows **200 locals per function**, including the **file chunk**. Game scripts grow past this quickly (`mount_daun.lua` already has). **Before adding locals, UI handles, or helpers to a game file, check the enclosing function’s local count.** Compile after edits. The executor error looks like `too many local variables (limit is 200)`.

What counts:

- Every `local x` / `local function foo` in the **same function** (the file is one function until you nest).
- A `do … end` block does **not** give a fresh 200. Outer chunk locals stay live **during** the block; they only free after `end`.
- Nested `function` / `local function` **does** reset the counter (that function has its own 200). Upvalues into it are limited separately (about 60).

Always wrap each large tab like [games/sempat/capybara_onsen.lua](../../games/sempat/capybara_onsen.lua):

```lua
-- */  Main Tab  /* --
local function createMainTab()
    local MainTab = Window:CreateTab("Main", "mountain")
    -- tab locals live here, not on the chunk
end
createMainTab()

-- */  Fishing Tab  /* --
local function createFishingTab()
    local FishingTab = Window:CreateTab("Fishing", "fish")
end
createFishingTab()
```

Do **not** keep dumping new `local` into the file root or a file-level `do` when the script is already large. If a tab is approaching 200 internals, split that tab into another `local function` or a module under `functions/`.

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
