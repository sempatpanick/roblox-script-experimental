# Agent instructions

This folder is named `cobalt` locally, but the product is **sempatpanick**: a Roblox executor hub that loads per-game Lua scripts and a shared UI.

Read these before changing code:

1. [docs/README.md](docs/README.md) — documentation index
2. [docs/knowledge/overview.md](docs/knowledge/overview.md) — what this repo is
3. [docs/knowledge/architecture.md](docs/knowledge/architecture.md) — load path and folders
4. [docs/style/lua.md](docs/style/lua.md) — Lua conventions
5. [docs/prd/product.md](docs/prd/product.md) — product intent

When adding or wiring a game, also read [docs/knowledge/adding-a-game.md](docs/knowledge/adding-a-game.md).

## Hard constraints

- Do **not** modify `Cobalt.luau`. It is a third-party wax bundle (network interceptor), not this hub.
- Do **not** rewrite `rayfield_library.lua`, `rayfield_original_library.lua`, or `windui_library.lua` unless the task is specifically about those vendored UIs.
- Prefer **Sempat UI** (`games/sempat/`, `sempat_library.lua`) for new games.
- Keep `sempatpanick.lua` and `sempatpanick_local.lua` **game maps in sync**. Production uses GitHub raw; local uses `http://127.0.0.1:5500`.
- Modules must keep the dual load path: local `require`, then `HttpGet` + `loadstring`/`load` via `shared.sempatpanick_baseURL`. Strip UTF-8 BOM before compile.
- Reuse `tabs/rayfield/*` for shared tabs. WindUI wrappers live in `tabs/windui/*` and must not fork tab logic.
- Match the file you are editing. Do not reformat unrelated code.
- Git commits must follow [Conventional Commits](docs/style/commits.md). Only commit when the user asks. The IDE sparkle button uses [`.cursorrules`](.cursorrules), not `.cursor/rules`.

## Runtime map

| Entry | Audience | `baseURL` |
| --- | --- | --- |
| `sempatpanick.lua` | production | GitHub raw `sempatpanick/roblox-script-experimental` |
| `sempatpanick_local.lua` | Live Server | `http://127.0.0.1:5500` |

`functions/loader/bootstrap.lua` maps `game.PlaceId` to a game script. Unknown places show a UI picker and load `games/<library>/others.lua`.

## Where to put work

| Change | Put it here |
| --- | --- |
| New supported game | `games/sempat/<slug>.lua` plus both entry maps |
| Shared player/teleport/objects/recording/config UI | `tabs/rayfield/` (WindUI wrappers already reuse these) |
| Helpers used by tabs or games | `functions/` loaded through `functions/load_module.lua` |
| Sempat UI behavior | `sempat_library.lua` |
| Recorded mount routes | `mount_yahayuk/routes/` JSON (Yahayuk-specific) |
