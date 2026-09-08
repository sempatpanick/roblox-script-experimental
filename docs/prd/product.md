# Product (lightweight PRD)

sempatpanick is a **personal** Roblox executor hub: detect the place, load the right Lua, show a stable hub, and automate repetitive actions in games the author plays.

This is not a shipped commercial product. There is no public changelog, support SLA, or multi-user auth. Decisions optimize for **the author’s executor workflow** (GitHub raw in production, Live Server locally).

## Goals

1. One paste-load entry (`sempatpanick.lua`) that works across many PlaceIds.
2. Fast local iteration via `sempatpanick_local.lua` + `http://127.0.0.1:5500`.
3. Shared tabs (local player, teleport, objects, recording, config) so each game script stays about that game.
4. Sempat UI as the long-term hub look; Rayfield/WindUI remain for existing scripts and the Others picker.
5. Config profiles on the executor filesystem under `sempatpanick/`.

## Non-goals

- A plugin, Rojo game, or Wally package.
- Supporting every executor equally beyond what `cloneref` / `gethui` / `loadstring` already cover.
- Rewriting vendored Rayfield/WindUI or `Cobalt.luau`.
- Automatic CI, tests, or obfuscation.

## Users and success

**User:** the repo owner running an executor in Roblox.

Success looks like: correct script for the place, UI opens, shared tabs work, game automation is reliable enough to leave running (summit loops, tycoon jobs, fishing, etc.).

## Feature principles

- **Place-specific logic stays in `games/…`**. Shared UX stays in `tabs/` + `functions/`.
- **Prefer Sempat** for new places; do not mass-migrate Rayfield games without being asked.
- **Fail soft** on optional tabs (notify + stub) so a missing HttpGet does not kill the hub.
- **Keep production and local maps identical** so a PlaceId never works in only one environment.
- **Recording** is a power tool; hiking games may instead use hardcoded routes or `route_player`.

## When to add a game vs Others

Add a mapped game script when the place needs dedicated automation or a custom Main tab. Leave it on Others if Local Player / Teleport / Objects / Recording / Config is enough.

## Agent implications

If a request is ambiguous, choose the smallest change that matches an existing Sempat game (window + shared tabs + one Main tab + both entry maps). Do not introduce a fourth UI library or a new bootstrap.
