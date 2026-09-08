# UI libraries

Three hub UIs exist. Game scripts pick one by folder: `games/sempat`, `games/rayfield`, `games/windui`.

## Sempat UI (default for new games)

- File: `sempat_library.lua`
- Goal: Rayfield-shaped API (`CreateWindow`, `CreateTab`, Toggle/Slider/Dropdown/…) with cheaper updates (no acrylic, no per-element entrance tweens; `Set`/`Refresh` mutate in place).
- Window extras commonly used: `ToggleUIKeybind`, `WindowTransparency`, URL `Icon`, `ConfigurationSaving.AutoSave` / `AutoLoad`.
- Tab icons: Lucide-style names (`"user"`, `"mountain"`, `"map-pin"`).
- Notifications: title + content + duration (no Rayfield image asset ids).

Prefer Sempat when adding a game or when porting a Rayfield game the user wants on the newer UI.

## Rayfield

- Files: `rayfield_library.lua` (this repo's copy), `rayfield_original_library.lua` (upstream-ish snapshot)
- Older games still live under `games/rayfield/`
- Icons often numeric rbx asset ids
- `DisableRayfieldPrompts` / `DisableBuildWarnings` are typical on `CreateWindow`
- Notify may map `"check"` / `"x"` to image ids (see `games/rayfield/others.lua`)

Do not restyle Rayfield globally for a one-game tweak.

## WindUI

- File: `windui_library.lua`
- Used for `games/windui/others.lua` and the picker option
- Shared tabs are **not** duplicated: `tabs/windui/*` wrap the window with `functions/windui/compat.lua` and load `tabs/rayfield/<name>.lua` via `functions/windui/load_tab.lua`
- Notifications: `functions/windui/notify.lua`

If a Rayfield tab API is missing on WindUI, extend **compat**, not a one-off fork of the tab.

## Picker accents

`functions/loader/ui_library_picker.lua` colors: Rayfield blue, WindUI indigo, Sempat mint (`102, 224, 163`). Sempat theme accent matches that mint.
