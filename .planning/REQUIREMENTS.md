# Requirements: CoCo v2

**Defined:** 2026-03-20
**Core Value:** Every Claude Code session routes natural language to the right skill without memorizing commands

## v1 Requirements

### Personality

- [ ] **PERS-01**: CoCo personality active in every Claude Code session without activation command
- [ ] **PERS-02**: Context-aware greeting shows project name, branch, domain, GSD status
- [ ] **PERS-03**: Autonomy rules enforced (read-only = just do it, destructive = ask first)
- [ ] **PERS-04**: Disable mechanism via ~/.coco/disabled file

### Routing

- [ ] **ROUT-01**: Explicit slash commands execute as-is (highest priority)
- [ ] **ROUT-02**: GSD 2 commands route correctly when .planning/ exists
- [ ] **ROUT-03**: /team commands route via natural language trigger words (13 skills)
- [ ] **ROUT-04**: /pmstudio commands route via document-related triggers (11 skills)
- [ ] **ROUT-05**: /email commands route via email-related triggers (9 skills)
- [ ] **ROUT-06**: Superpowers skills invoke as part of workflow chains (12 skills)
- [ ] **ROUT-07**: /gsd commands route via project lifecycle triggers (32 commands)
- [ ] **ROUT-08**: Screenshot commands route via "show screenshot" triggers (9 commands)
- [ ] **ROUT-09**: UI/UX Pro Max routes via design-related triggers
- [ ] **ROUT-10**: Standalone commands route correctly (5 commands)
- [ ] **ROUT-11**: No-match inputs respond directly as Claude (fallback)

### Orchestration

- [ ] **ORCH-01**: Build requests trigger brainstorm → plan → execute → verify chain (Superpowers)
- [ ] **ORCH-02**: GSD context detected → use GSD 2 lifecycle (plan-phase → execute → verify)
- [ ] **ORCH-03**: Compound requests decompose into sequential steps
- [ ] **ORCH-04**: CoCo executes full chains without asking at each step (high autonomy)
- [ ] **ORCH-05**: Git push, delete, send email always require explicit confirmation

### Event Logging

- [x] **EVNT-01**: Claude Code hook appends events to ~/.coco/events.jsonl
- [x] **EVNT-02**: Events include: session_start, user_input, skill_invoked, skill_complete
- [x] **EVNT-03**: Session ID tracked via PPID-based mechanism
- [x] **EVNT-04**: Hook registered in settings.json matching existing format

### Dashboard Server

- [x] **DASH-01**: Express server runs at localhost:3000
- [x] **DASH-02**: SSE endpoint streams events from events.jsonl
- [x] **DASH-03**: Chat API accepts messages, routes through `claude -p` spawn (OAuth auth, no API key needed)
- [x] **DASH-04**: Chat responses stream back to browser via SSE as claude -p produces output
- [x] **DASH-05**: Server startable via `node ~/.coco/server.js`

### Dashboard Chat

- [x] **CHAT-01**: Chat input at bottom of page, messages stream above
- [x] **CHAT-02**: CoCo responses render as markdown
- [x] **CHAT-03**: Routing info displayed ("Routing to /team research...")
- [x] **CHAT-04**: Auto-scrolls to latest message

### Dashboard Sessions

- [x] **SESS-01**: Active sessions shown with status, skill, duration
- [x] **SESS-02**: Recent completed sessions visible (last 24h)
- [x] **SESS-03**: Live-updating via SSE

### Dashboard Skills

- [x] **SKIL-01**: All skills listed grouped by family
- [x] **SKIL-02**: Each skill shows name, description, and family badge
- [x] **SKIL-03**: Click a skill opens chat with that skill pre-filled

### Dashboard History

- [x] **HIST-01**: Timeline of past interactions from events.jsonl
- [x] **HIST-02**: Searchable by keyword

### Dashboard Design

- [x] **DSGN-01**: Apple-style light theme (#f5f5f7, white tiles, SF Pro, 20px radius)
- [x] **DSGN-02**: Self-contained HTML files (inline CSS/JS, no build step)
- [x] **DSGN-03**: Responsive (works on mobile for quick checks)

## v2 Requirements

### Voice I/O
- **VOIC-01**: Push-to-talk via whisper.cpp in web dashboard
- **VOIC-02**: Text-to-speech for CoCo responses

### Proactive Mode
- **PROA-01**: File watcher suggests actions on changes
- **PROA-02**: Email monitor surfaces new emails
- **PROA-03**: Calendar bridge for meeting awareness

### Intelligence
- **INTL-01**: Learning loop from routing corrections
- **INTL-02**: Skill sequence recommendations
- **INTL-03**: Session summarization

## Out of Scope

| Feature | Reason |
|---------|--------|
| Terminal TUI (Ink) | v1 proved over-engineered — raw mode issues, WAL crashes, notification spam |
| SQLite state manager | events.jsonl is simpler, no WAL issues, dashboard reads via SSE |
| React/Next.js dashboard | Plain HTML + vanilla JS. No build step, no bundler. |
| Mobile native app | Web dashboard is responsive enough |
| Multi-user support | Single user, no auth needed on localhost |
| Notification system | Caused spam in v1, disabled |

## Traceability

| Requirement | Phase | Status |
|-------------|-------|--------|
| PERS-01 | Phase 1 | Pending |
| PERS-02 | Phase 1 | Pending |
| PERS-03 | Phase 1 | Pending |
| PERS-04 | Phase 1 | Pending |
| ROUT-01 | Phase 1 | Pending |
| ROUT-02 | Phase 1 | Pending |
| ROUT-03 | Phase 1 | Pending |
| ROUT-04 | Phase 1 | Pending |
| ROUT-05 | Phase 1 | Pending |
| ROUT-06 | Phase 1 | Pending |
| ROUT-07 | Phase 1 | Pending |
| ROUT-08 | Phase 1 | Pending |
| ROUT-09 | Phase 1 | Pending |
| ROUT-10 | Phase 1 | Pending |
| ROUT-11 | Phase 1 | Pending |
| ORCH-01 | Phase 1 | Pending |
| ORCH-02 | Phase 1 | Pending |
| ORCH-03 | Phase 1 | Pending |
| ORCH-04 | Phase 1 | Pending |
| ORCH-05 | Phase 1 | Pending |
| EVNT-01 | Phase 1 | Complete |
| EVNT-02 | Phase 1 | Complete |
| EVNT-03 | Phase 1 | Complete |
| EVNT-04 | Phase 1 | Complete |
| DASH-01 | Phase 2 | Complete |
| DASH-02 | Phase 2 | Complete |
| DASH-03 | Phase 2 | Complete |
| DASH-04 | Phase 2 | Complete |
| DASH-05 | Phase 2 | Complete |
| CHAT-01 | Phase 2 | Complete |
| CHAT-02 | Phase 2 | Complete |
| CHAT-03 | Phase 2 | Complete |
| CHAT-04 | Phase 2 | Complete |
| SESS-01 | Phase 2 | Complete |
| SESS-02 | Phase 2 | Complete |
| SESS-03 | Phase 2 | Complete |
| SKIL-01 | Phase 2 | Complete |
| SKIL-02 | Phase 2 | Complete |
| SKIL-03 | Phase 2 | Complete |
| HIST-01 | Phase 2 | Complete |
| HIST-02 | Phase 2 | Complete |
| DSGN-01 | Phase 2 | Complete |
| DSGN-02 | Phase 2 | Complete |
| DSGN-03 | Phase 2 | Complete |

**Coverage:**
- v1 requirements: 44 total
- Mapped to phases: 44
- Unmapped: 0 ✓

---
*Requirements defined: 2026-03-20*
*Last updated: 2026-03-20 after roadmap creation — traceability confirmed 44/44*
