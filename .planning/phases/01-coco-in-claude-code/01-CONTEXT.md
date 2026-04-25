# Phase 1: CoCo in Claude Code - Context

**Gathered:** 2026-03-20
**Status:** Ready for planning
**Source:** PRD Express Path (docs/superpowers/specs/2026-03-20-coco-v2-design.md)

<domain>
## Phase Boundary

Phase 1 delivers CoCo as a native Claude Code enhancement. Three deliverables:
1. CLAUDE.md CoCo section — personality, routing tables, orchestration rules, autonomy
2. Event logging hook — appends structured events to ~/.coco/events.jsonl
3. Hook registration — settings.json entry matching existing format

Zero new processes. Zero new infrastructure. Just configuration files that make every Claude Code session CoCo-aware.

</domain>

<decisions>
## Implementation Decisions

### Personality (PERS-01 to PERS-04)
- Always-on via CLAUDE.md section — no activation command needed
- Greeting format: project name, branch, domain, GSD status, then "Ready."
- Autonomy: read-only = just do it, creates files = execute autonomously, git push/delete/send email = always ask
- Disable mechanism: if ~/.coco/disabled file exists, skip CoCo behavior
- CoCo section must stay under 150 lines / 8 KB

### Routing (ROUT-01 to ROUT-11)
- Priority order: explicit slash command > GSD context (.planning/) > /team > /pmstudio > /email > superpowers > direct
- 104 skills total: 44 commands + 32 GSD + 28 skills
- /team: 13 skills with action verb triggers (build, fix, test, review, research, think, plan, document, present, communicate, scrape, verify, reanalyse)
- /gsd: 32 commands with project lifecycle triggers (new project, plan phase, execute, progress, debug, pause, resume, verify, quick)
- /pmstudio: 11 skills with document triggers (PRD, ARB, changelog, meeting notes, DR, IRP, NFR, sync, init, recovery, comms)
- /email: 9 commands with email triggers (check, unread, search, summary, reply, thread, today, save, read)
- Superpowers: 12 skills invoked as part of chains, not directly
- Screenshots: 9 commands via "show screenshot" triggers
- UI/UX Pro Max: 1 skill via design triggers
- Standalone: 5 commands
- No-match → respond directly as Claude (fallback)

### Orchestration (ORCH-01 to ORCH-05)
- GSD 2 chains when .planning/ exists: progress → plan-phase → execute-phase → verify-work
- Superpowers chains when no GSD: brainstorming → writing-plans → executing-plans → verification
- Build requests: always brainstorm → plan → execute → verify
- Fix requests: systematic-debugging → fix → verify
- Compound requests: decompose into sequential steps, execute autonomously, report at end
- Never auto-execute: git push, delete, force push, send email, post message

### Event Logging (EVNT-01 to EVNT-04)
- Hook type: PostToolUse in settings.json, matching existing format (nested hooks array with type: "command")
- Hook script: Node.js at ~/.coco/hooks/log-event.js (not shell — matches existing hooks pattern)
- Event file: ~/.coco/events.jsonl (append-only, one JSON per line)
- Session ID: use PPID-based mechanism (write UUID to /tmp/coco-session-$PPID.id on SessionStart, read in PostToolUse)
- Event schema: { ts, type, session, skill, args, input, cwd, status }
- Event types: session_start, user_input, skill_invoked, skill_complete, orchestration_step
- Prune: events older than 7 days (handled by Phase 2 dashboard)

### Claude's Discretion
- Exact wording of routing trigger patterns (as long as >90% accuracy)
- CLAUDE.md formatting and section organization (as long as under 150 lines)
- Hook script implementation details (as long as it appends valid JSONL)
- Intent category groupings (as long as all 104 skills are covered)

</decisions>

<specifics>
## Specific Ideas

- Reuse CoCo personality from v1 system prompt: `rijuls-claude-skills/coco/src/prompts/coco-system.md`
- Routing tables from v1 system prompt already have trigger word mappings for /team, /gsd, /email, /pmstudio
- Intent categories: build, understand, fix, document, communicate, check, manage project, check email, design UI, show screenshot
- Existing hooks in settings.json use Node.js (gsd-check-update.js, doc-sync-session-hook.js, gsd-context-monitor.js) — follow same pattern
- SessionStart hook exists already — can piggyback for session ID generation
- ~/.coco/ directory already exists from v1 testing

</specifics>

<deferred>
## Deferred Ideas

- Web dashboard (Phase 2)
- Voice I/O (v2)
- Proactive mode — file watcher, email, calendar (v2)
- Learning loop — corrections override routing (v2)
- Skill sequence recommendations (v2)

</deferred>

---

*Phase: 01-coco-in-claude-code*
*Context gathered: 2026-03-20 via PRD Express Path*
