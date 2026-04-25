# Roadmap: CoCo v2

## Overview

CoCo v2 delivers an always-on conversational assistant inside Claude Code in two phases. Phase 1 embeds CoCo natively in every Claude Code session via CLAUDE.md and a lightweight event logging hook — zero new processes, zero new infrastructure. Phase 2 adds a web dashboard at localhost:3000 so the user can chat, monitor sessions, browse skills, and review history from a browser. Both phases share the same personality layer and events.jsonl log.

## Phases

- [ ] **Phase 1: CoCo in Claude Code** - CLAUDE.md personality + routing tables + event logging hook
- [ ] **Phase 2: Web Dashboard** - Express server + 4 HTML pages (chat, sessions, skills, history)

## Phase Details

### Phase 1: CoCo in Claude Code
**Goal**: Every Claude Code session routes natural language to the right skill without the user memorizing commands
**Depends on**: Nothing (first phase)
**Requirements**: PERS-01, PERS-02, PERS-03, PERS-04, ROUT-01, ROUT-02, ROUT-03, ROUT-04, ROUT-05, ROUT-06, ROUT-07, ROUT-08, ROUT-09, ROUT-10, ROUT-11, ORCH-01, ORCH-02, ORCH-03, ORCH-04, ORCH-05, EVNT-01, EVNT-02, EVNT-03, EVNT-04
**Success Criteria** (what must be TRUE):
  1. Opening a new Claude Code session shows a context-aware greeting (project name, branch, GSD status) without any user command
  2. Typing "research OAuth patterns" routes to /team research; typing "fix the auth bug" routes to /systematic-debugging — correct skill selected >90% of time
  3. Typing "build a new feature" triggers brainstorm → plan → execute → verify chain without user prompting each step
  4. When .planning/ exists, GSD 2 commands are used automatically; when absent, Superpowers workflow kicks in
  5. Every skill invocation appends a structured event to ~/.coco/events.jsonl with session ID, skill name, and status
**Plans:** 2 plans

Plans:
- [ ] 01-01-PLAN.md — CoCo personality, routing tables, orchestration chains in CLAUDE.md
- [x] 01-02-PLAN.md — Event logging hook and settings.json registration

### Phase 2: Web Dashboard
**Goal**: the user can chat with CoCo, monitor active sessions, browse all skills, and review interaction history from a browser at localhost:3000
**Depends on**: Phase 1
**Requirements**: DASH-01, DASH-02, DASH-03, DASH-04, DASH-05, CHAT-01, CHAT-02, CHAT-03, CHAT-04, SESS-01, SESS-02, SESS-03, SKIL-01, SKIL-02, SKIL-03, HIST-01, HIST-02, DSGN-01, DSGN-02, DSGN-03
**Success Criteria** (what must be TRUE):
  1. Running `node ~/.coco/server.js` serves the dashboard at localhost:3000 with chat, sessions, skills, and history pages
  2. Typing a message in the browser chat input streams a CoCo response (routed through Claude Code SDK) with routing info displayed
  3. The sessions page shows active and recent sessions updating live via SSE without a page refresh
  4. The skills page lists all 104 skills grouped by family; clicking a skill pre-fills the chat input
  5. The history page shows past interactions from events.jsonl and filters results by keyword search
**Plans:** 2 plans

Plans:
- [x] 02-01-PLAN.md — Express server + Chat page (primary interface with claude -p chat backend)
- [x] 02-02-PLAN.md — Sessions, Skills, and History pages + visual verification

## Progress

| Phase | Plans Complete | Status | Completed |
|-------|----------------|--------|-----------|
| 1. CoCo in Claude Code | 1/2 | In progress | - |
| 2. Web Dashboard | 2/2 | Complete | 2026-03-20 |

---
*Roadmap created: 2026-03-20*
*Last updated: 2026-03-20 after Phase 2 planning complete*
