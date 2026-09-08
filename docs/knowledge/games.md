# Supported games

Source of truth is the `games` table in `sempatpanick.lua` / `sempatpanick_local.lua`. Keep this page aligned when you add or move a PlaceId.

| PlaceId | Script | UI folder |
| --- | --- | --- |
| 83369512629707 | `sawah_indo.lua` | rayfield |
| 128070940451265 | `speed_bike_escape.lua` | rayfield |
| 2693023319 | `expedition_antartica.lua` | rayfield |
| 103593441753340 | `find_the_button.lua` | rayfield |
| 82775216869079 | `find_the_button.lua` | rayfield |
| 111385005478215 | `fish_and_monsters.lua` | sempat |
| 14963184269 | `mount_sumbing.lua` | rayfield |
| 76964310785698 | `mount_yahayuk.lua` | sempat |
| 135285569232987 | `mount_velora.lua` | sempat |
| 84918151469196 | `mount_noxera.lua` | sempat |
| 130444125462169 | `mount_daun.lua` | sempat |
| 118098747383977 | `mancing_indo.lua` | rayfield |
| 78404864377525 | `mancing_indo_galatama.lua` | rayfield |
| 77843161404023 | `run_a_restaurant.lua` | sempat |
| 79268393072444 | `sell_lemons.lua` | sempat |
| 92416421522960 | `slime_rng.lua` | rayfield |
| 93978595733734 | `violence_district.lua` | rayfield |
| 95496064393804 | `find_the_chameleons.lua` | sempat |
| 120336108521610 | `capybara_onsen.lua` | sempat |

Unlisted PlaceIds load Others after the UI picker (`games/rayfield/others.lua`, `games/windui/others.lua`, `games/sempat/others.lua`).

## Excluded PlaceIds

Hub does not start:

- 121864768012064
- 79378095465365

## Leftover Rayfield copies

Some games still have an older file under `games/rayfield/` (for example `mount_yahayuk.lua`, `sell_lemons.lua`) while the live map points at `games/sempat/`. Do not “fix” the map to the Rayfield copy unless asked. Prefer editing the mapped path.
