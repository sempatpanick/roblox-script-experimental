# Overview

**sempatpanick** is a personal Roblox executor hub. One entry script detects `game.PlaceId`, loads the matching game Lua file, and mounts a hub UI (Sempat UI preferred for new work; Rayfield and WindUI still exist).

This knowledge is for agents and maintainers. It is not a public SDK.

## Names

| Name | Meaning |
| --- | --- |
| sempatpanick | Product, GitHub owner/repo, window titles, executor config folder |
| cobalt | Local workspace folder only. Also a **different** third-party tool in `Cobalt.luau` — ignore that file |
| Others | Fallback script when PlaceId is not in the map (user picks a UI library) |

## What a game script does

A file under `games/<library>/<slug>.lua` typically:

1. Reads `shared.sempatpanick_baseURL` (set by the entry script).
2. Loads the UI library (local `require`, Studio `ReplicatedStorage`, or `HttpGet`).
3. Dynamically loads shared tab modules (`local_player_tab`, `teleport_tab`, `objects_tab`, `recording_tab`, `config_tab`).
4. Creates a window named `sempatpanick | <Game>`.
5. Adds game-specific tabs (Main / Automation / etc.).
6. Enables ConfigurationSaving under folder `sempatpanick` with a per-game `FileName`.

## Environments

- **Executor:** `game:HttpGet` + `loadstring`/`load`. Use `cloneref` / `gethui` / `protectgui` when present.
- **Local Live Server:** `sempatpanick_local.lua` with `baseURL = "http://127.0.0.1:5500"`.
- **Studio (rare):** some scripts `require` libraries from `ReplicatedStorage`.

## In scope vs out of scope

In scope: per-game automation, shared tabs, Sempat UI, loaders, config/recording, PlaceId wiring.

Out of scope unless the user asks: rewriting vendored Rayfield/WindUI, editing `Cobalt.luau`, adding a build system, or changing production `baseURL` without an explicit request.
