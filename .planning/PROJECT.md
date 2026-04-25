# CoCo v2

## What This Is

CoCo is an always-on conversational assistant that lives natively inside Claude Code. It turns every Claude Code session into a skill-aware routing assistant that knows all 104 skills and chains workflows autonomously. Phase 2 adds a web dashboard at localhost:3000 for chat, session monitoring, and skill browsing.

## Core Value

Every Claude Code session routes natural language to the right skill without the user memorizing commands. CoCo decides, acts, and reports — the user steers by exception.

## Requirements

### Validated

(None yet — ship to validate)

### Active

- [ ] CoCo personality active in every Claude Code session via CLAUDE.md
- [ ] Natural language routes to correct skill (104 skills across /team, /gsd, /pmstudio, /email, superpowers, screenshots, UI/UX, standalone)
- [ ] Orchestration chains work (build → brainstorm → plan → execute → verify)
- [ ] GSD 2 context detection (.planning/ exists → use GSD commands)
- [ ] Superpowers workflow when no GSD context
- [ ] High autonomy — read-only actions just execute, only destructive/external asks first
- [ ] Event logging via Claude Code hook to ~/.coco/events.jsonl
- [ ] Web dashboard at localhost:3000 with chat, sessions, skills, history
- [ ] Chat from browser via Claude Code SDK query()
- [ ] Live session monitoring via SSE from events.jsonl
- [ ] Skill catalog browsable and invocable from browser
- [ ] Apple-style light theme design (SF Pro, #f5f5f7, white tiles, 20px radius)

### Out of Scope

- Terminal TUI (Ink) — v1 proved this was over-engineered
- SQLite state manager with 15+ tables — events.jsonl is sufficient
- Voice I/O — revisit after core experience is validated
- Proactive mode (file watcher, email, calendar) — revisit after dashboard works
- Notification system (osascript) — caused spam, disabled
- Mobile app — web dashboard is responsive enough

## Context

- CoCo v1 was built with 6 phases, 227 tests, 34 modules — but never battle-tested. The Ink TUI had WAL issues, execa signal bugs, notification spam, confusing session panels. User never got a clean experience.
- Key lesson: build the simplest thing that works, test with real usage, add complexity only after basics validated.
- 104 skills exist: 44 commands + 32 GSD + 28 skills. All in ~/.claude/commands/ and ~/.claude/skills/.
- Design spec at: docs/superpowers/specs/2026-03-20-coco-v2-design.md
- v1 archived at: ~/Downloads/coco/

## Constraints

- **Zero infrastructure for Phase 1**: CoCo in Claude Code must be CLAUDE.md + hook only. No new processes, no databases.
- **CLAUDE.md size**: CoCo section must stay under 150 lines / 8 KB to avoid context bloat.
- **Hook format**: Must match existing settings.json structure (nested hooks array with type: "command").
- **Web dashboard stack**: Express + plain HTML + vanilla JS. No React, no build step, no bundler.
- **SDK fallback**: If Claude Code SDK query() doesn't inherit full config, fall back to spawning claude -p.
- **Disable mechanism**: ~/.coco/disabled file skips CoCo behavior. Must be easy to turn off.

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| CLAUDE.md native, not separate app | v1 proved separate Ink app was over-engineered | — Pending |
| Approach 2 (CLAUDE.md + lightweight server) | Right balance: zero-infra Phase 1, real dashboard Phase 2. Path to Approach 3 if needed | — Pending |
| Always-on (option B) | No activation command — every session is CoCo | — Pending |
| High autonomy (option A) | CoCo acts and reports. User steers by exception. | — Pending |
| Command center dashboard (option C) | Chat + visibility + session management. Terminal becomes optional. | — Pending |
| events.jsonl not SQLite | Simpler. File append is atomic. Dashboard reads via SSE. No WAL issues. | — Pending |
| GSD 2 for project management | User installed GSD 2 on 2026-03-20. Use for all multi-phase work. | — Pending |

---
*Last updated: 2026-03-20 after initialization*
