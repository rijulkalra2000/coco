# Phase 2: Web Dashboard - Context

**Gathered:** 2026-03-20
**Status:** Ready for planning
**Source:** PRD Express Path (docs/superpowers/specs/2026-03-20-coco-v2-design.md)

<domain>
## Phase Boundary

Phase 2 delivers the CoCo web dashboard — a command center at localhost:3000. Four pages: chat (primary), sessions (monitoring), skills (catalog), history (timeline). Express server with SSE for live updates. Claude Code SDK for chat from browser.

Depends on Phase 1: events.jsonl from the hook, skill catalog from ~/.claude/commands/.

</domain>

<decisions>
## Implementation Decisions

### Server (DASH-01 to DASH-05)
- Express server at localhost:3000 (~300 lines)
- SSE endpoint `/api/events` reads ~/.coco/events.jsonl, streams new events to browser
- Chat API: POST `/api/chat` → Claude Code SDK `query()` → SSE response stream
- SDK fallback: if query() doesn't inherit config, spawn `claude -p` via child_process with stdin:'ignore' and cancelSignal
- Startable via `node ~/.coco/server.js`
- Auto-opens browser on start
- Package: express + @anthropic-ai/claude-code in ~/.coco/package.json

### Chat Page (CHAT-01 to CHAT-04)
- Chat input fixed at bottom
- Messages stream above with markdown rendering
- Show "Routing to /team research..." when skill detected
- Auto-scroll to latest message
- This is the PRIMARY interface

### Sessions Page (SESS-01 to SESS-03)
- Read events.jsonl for session_start and tool_use events
- Group by session ID
- Show: status (active/complete), skill used, duration, last activity
- Live-updating via SSE — no page refresh needed
- Show last 24h of sessions

### Skills Page (SKIL-01 to SKIL-03)
- Read ~/.claude/commands/ and ~/.claude/skills/ at server startup
- Parse frontmatter for name, description
- Group by family (/team, /gsd, /pmstudio, /email, superpowers, standalone)
- Click a skill → navigate to chat page with skill pre-filled in input

### History Page (HIST-01 to HIST-02)
- Timeline view of events from events.jsonl
- Searchable by keyword (client-side filter)
- Show: timestamp, event type, skill/tool, session ID

### Design (DSGN-01 to DSGN-03)
- Apple-style light theme matching README.html
- Background: #f5f5f7, cards: #fff, border-radius: 20px
- Font: -apple-system, SF Pro Display
- Colors: #0071e3 (blue), #248a3d (green), #c93400 (amber), #0071a4 (teal), #7d2fa0 (purple)
- Self-contained HTML files with inline CSS/JS — NO build step, NO bundler, NO React
- Responsive for mobile quick checks
- Shared nav bar across all pages

### Claude's Discretion
- Exact Express middleware choices
- SSE implementation details (polling interval, reconnection)
- Markdown rendering approach (simple regex or a small lib)
- How to handle SDK version incompatibilities
- Chat message persistence (in-memory for v1 is fine)

</decisions>

<specifics>
## Specific Ideas

- Reuse Apple-style CSS from ~/Downloads/coco/README.html — same design tokens
- Skills page can read the same commands the skill registry in v1 read (gray-matter frontmatter parsing)
- Events.jsonl is append-only — SSE can track file position and only send new lines
- Chat history can be in-memory array (no DB needed for v1)
- Consider marked.js or similar for markdown → HTML in chat messages
- Nav: Home (chat) | Sessions | Skills | History — sticky top bar

</specifics>

<deferred>
## Deferred Ideas

- Voice I/O in browser (Web Speech API)
- Proactive suggestions in dashboard
- Multi-user support / auth
- Persistent chat history (DB)
- WebSocket instead of SSE (SSE is simpler for v1)

</deferred>

---

*Phase: 02-web-dashboard*
*Context gathered: 2026-03-20 via PRD Express Path*
