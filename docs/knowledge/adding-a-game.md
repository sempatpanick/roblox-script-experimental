# Adding a game

Copy a recent Sempat script (for example `games/sempat/mount_daun.lua` or `games/sempat/others.lua`) rather than inventing a new layout.

## Checklist

1. **Slug** — lowercase `snake_case` matching the file name (`mount_noxera.lua` → `mount_noxera`).
2. **Create** `games/sempat/<slug>.lua` unless the user asked to stay on Rayfield/WindUI.
3. **Register PlaceId** in both `sempatpanick.lua` and `sempatpanick_local.lua`:

   ```lua
   [PLACE_ID] = baseURL .. "/games/sempat/<slug>.lua",
   ```

4. **Window** — `Name = "sempatpanick | <Display Name>"`, `ToggleUIKeybind = "K"`, `Icon = "https://dadang.id/sempatpanick-icon.png"`, `ConfigurationSaving.FolderName = "sempatpanick"`, `FileName = "<slug>"`.
5. **Shared tabs** — load the same require-then-HttpGet helpers as sibling games. Call:

   - `createLocalPlayerTab(Window, mountNotify, { flagsPrefix = "lp", tabIcon = "user" })`
   - `createTeleportTab(..., { flagsPrefix = "<short>", tabIcon = "map-pin" })`
   - `createObjectsTab(..., { replicatedStorage = ReplicatedStorage, tabIcon = "boxes" })`
   - `createRecordingTab(..., { gamePath = "sempatpanick/<slug>", tabIcon = "video" })`
   - `createConfigTab(..., { configDir = "sempatpanick/<slug>", rayfieldLibrary = SempatLibrary, tabIcon = "settings" })`

6. **Game tab** — put automation in a `Main` (or similarly named) tab. Keep Place-specific remotes, routes, and loops in this file, not in shared tabs. Wrap each large tab in `local function createXTab() … end` then call it. File-level `do` blocks still count against the chunk’s **200 local** limit — always check before adding locals (see [style/lua.md](../style/lua.md)).
7. **Notify** — Sempat: `SempatLibrary:Notify({ Title, Content, Duration })`. Do not pass Rayfield image ids unless the library is Rayfield.
8. **Update** [games.md](games.md) PlaceId table if you add or move a game.

## Do not

- Register only one of the two entry files.
- Point a new Sempat game at `tabs/windui/*` (Sempat speaks the Rayfield tab API).
- Put PlaceId logic inside the game script; the map belongs in the entry files.
- Clone entire tab modules into the game file.

## Excluding a place

Add the PlaceId to `excludedGameIds` in **both** entry files when the hub must not run there.

## UI library picker (Others only)

`functions/loader/bootstrap.lua` `OTHERS_UI_LIBRARIES` lists Rayfield, WindUI, and Sempat paths. Change that table only when adding a new hub-wide UI, not for a single game.
