# Conventional Commits

Every git commit message for this repo must follow [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/).

The Cursor Source Control **Generate Commit Message** button does **not** read `.cursor/rules`. It reads the repo-root [`.cursorrules`](../../.cursorrules) file. Keep that file short and commit-focused. Copilot’s generator (if enabled) uses `github.copilot.chat.commitMessageGeneration.instructions` in `.vscode/settings.json`.

```
<type>(<optional-scope>): <description>
```

- Imperative, present tense: `add`, `fix`, `update` — not `added` or `adds`.
- Description: lowercase start, no trailing period, about **why** if it is not obvious.
- Header **72 characters or fewer**.
- Body is optional; use it when the why needs more than one line.
- Do not use GitHub `Co-authored-by` unless the user asks.

## Types

| Type | When |
| --- | --- |
| `feat` | New user-facing behavior (new game, new toggle, new tab) |
| `fix` | Bug fix, wrong coordinate, failed load, bad PlaceId |
| `refactor` | Same behavior, clearer structure |
| `docs` | `docs/`, `AGENTS.md`, `CLAUDE.md`, README, Cursor rules |
| `style` | Formatting only |
| `chore` | Route JSON dumps, housekeeping, dependency-like library drops |
| `perf` | Faster loops, fewer instances, cheaper UI updates |
| `revert` | Revert a previous commit |

## Scopes (optional, prefer these)

`loader`, `sempat-ui`, `rayfield`, `windui`, `tabs`, `<slug>` (example: `mount-daun`, `capybara-onsen`)

## Examples

```
feat(mount-daun): add auto carry and auto accept carry
fix(mount-noxera): wait for GameplayPaused before summit teleports
feat(loader): register mount velora and mount noxera place ids
docs: add agent knowledge base and conventional commit rules
chore(mount-yahayuk): refresh recorded cp3-cp4 routes
refactor(tabs): reuse rayfield config tab through windui compat
```

## Not allowed

```
Add Auto Carry to Mount Daun.
update stuff
WIP
Fixed bug
```

If several unrelated changes are staged, split them into separate commits with their own types. Only create a commit when the user asks.
