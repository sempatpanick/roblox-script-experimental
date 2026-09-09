# Documentation index

Agents (Cursor, Claude Code, and similar) must treat this folder as the project knowledge base. Humans can use the same pages.

## Read first

| Doc | Use it for |
| --- | --- |
| [knowledge/overview.md](knowledge/overview.md) | What this repo is, what it is not |
| [knowledge/architecture.md](knowledge/architecture.md) | Boot, loaders, folders |
| [knowledge/adding-a-game.md](knowledge/adding-a-game.md) | New PlaceId + game script checklist |
| [knowledge/ui-libraries.md](knowledge/ui-libraries.md) | Sempat vs Rayfield vs WindUI |
| [knowledge/modules.md](knowledge/modules.md) | `functions/` and `tabs/` map |
| [knowledge/games.md](knowledge/games.md) | PlaceId → script table |

## Style and process

| Doc | Use it for |
| --- | --- |
| [style/lua.md](style/lua.md) | Indent, loaders, UI flags, **200 local limit**, comments |
| [style/commits.md](style/commits.md) | Conventional Commits |

## Product

| Doc | Use it for |
| --- | --- |
| [prd/product.md](prd/product.md) | Goals, non-goals, how to decide scope |

## How agents pick this up

| Tool | What it reads |
| --- | --- |
| Cursor Agent | `AGENTS.md` plus `.cursor/rules/*.mdc` (always-on context + Lua/game globs) |
| Claude Code | `CLAUDE.md` plus `.claude/rules/*.md` |

Those rule files stay short and point here. Put the long explanation in `docs/`, not in the rule files.
