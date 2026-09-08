# Claude Code

This repository uses the same agent knowledge as Cursor. Follow it.

@AGENTS.md
@docs/README.md
@docs/knowledge/overview.md
@docs/knowledge/architecture.md
@docs/style/lua.md
@docs/style/commits.md
@docs/prd/product.md

## Must not miss

- Product name: **sempatpanick** (local folder may be `cobalt`).
- Never edit `Cobalt.luau`.
- New games go under `games/sempat/` unless the task is to maintain an existing Rayfield/WindUI script.
- Dual-load every remote module (`require` then `HttpGet`). Set `shared.sempatpanick_baseURL` from the entry script.
- Mirror PlaceId entries in both `sempatpanick.lua` and `sempatpanick_local.lua`.
- Commits: Conventional Commits only (`feat:`, `fix:`, `refactor:`, `docs:`, `chore:`, `style:`, `perf:`, `test:`). Commit only when asked.
