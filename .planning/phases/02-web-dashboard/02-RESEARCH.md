# Phase 2: Web Dashboard - Research

**Researched:** 2026-03-20
**Domain:** Express SSE, Claude Agent SDK, gray-matter frontmatter, marked.js markdown, vanilla HTML dashboard
**Confidence:** HIGH

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions

**Server (DASH-01 to DASH-05)**
- Express server at localhost:3000 (~300 lines)
- SSE endpoint `/api/events` reads ~/.coco/events.jsonl, streams new events to browser
- Chat API: POST `/api/chat` → Claude Code SDK `query()` → SSE response stream
- SDK fallback: if query() doesn't inherit config, spawn `claude -p` via child_process with stdin:'ignore' and cancelSignal
- Startable via `node ~/.coco/server.js`
- Auto-opens browser on start
- Package: express + @anthropic-ai/claude-code in ~/.coco/package.json

**Chat Page (CHAT-01 to CHAT-04)**
- Chat input fixed at bottom
- Messages stream above with markdown rendering
- Show "Routing to /team research..." when skill detected
- Auto-scroll to latest message
- This is the PRIMARY interface

**Sessions Page (SESS-01 to SESS-03)**
- Read events.jsonl for session_start and tool_use events
- Group by session ID
- Show: status (active/complete), skill used, duration, last activity
- Live-updating via SSE — no page refresh needed
- Show last 24h of sessions

**Skills Page (SKIL-01 to SKIL-03)**
- Read ~/.claude/commands/ and ~/.claude/skills/ at server startup
- Parse frontmatter for name, description
- Group by family (/team, /gsd, /pmstudio, /email, superpowers, standalone)
- Click a skill → navigate to chat page with skill pre-filled in input

**History Page (HIST-01 to HIST-02)**
- Timeline view of events from events.jsonl
- Searchable by keyword (client-side filter)
- Show: timestamp, event type, skill/tool, session ID

**Design (DSGN-01 to DSGN-03)**
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

### Deferred Ideas (OUT OF SCOPE)
- Voice I/O in browser (Web Speech API)
- Proactive suggestions in dashboard
- Multi-user support / auth
- Persistent chat history (DB)
- WebSocket instead of SSE (SSE is simpler for v1)
</user_constraints>

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|-----------------|
| DASH-01 | Express server at localhost:3000 | Express 5.2.1, standard middleware patterns |
| DASH-02 | SSE endpoint streams events from events.jsonl | fs.watchFile + position tracking pattern |
| DASH-03 | Chat API routes through Claude Code SDK query() | SDK renamed to @anthropic-ai/claude-agent-sdk; settingSources:['user'] loads OAuth config |
| DASH-04 | SDK fallback to claude -p spawn | `claude -p --output-format stream-json` via spawn() |
| DASH-05 | Server startable via node ~/.coco/server.js | package.json in ~/.coco with "type":"module" or CJS |
| CHAT-01 | Chat input fixed at bottom, messages above | CSS flexbox fixed-bottom pattern |
| CHAT-02 | Markdown rendering for responses | marked.js 17.0.5 via CDN UMD script |
| CHAT-03 | Routing info displayed | Parse assistant text for skill keywords |
| CHAT-04 | Auto-scroll to latest message | scrollIntoView() on message append |
| SESS-01 | Active sessions with status/skill/duration | Group events.jsonl by session ID |
| SESS-02 | Recent completed sessions (last 24h) | ts field filter: Date.now() - 86400000 |
| SESS-03 | Live-updating via SSE | SSE event listener on /api/events |
| SKIL-01 | All skills listed grouped by family | gray-matter 4.0.3 for frontmatter parsing |
| SKIL-02 | Each skill shows name, description, trigger words | Parse frontmatter.name, .description, .triggers |
| SKIL-03 | Click skill opens chat pre-filled | URL params or localStorage handoff |
| HIST-01 | Timeline of past interactions | Reverse-sorted events.jsonl read |
| HIST-02 | Searchable by keyword | Client-side filter on event JSON strings |
| DSGN-01 | Apple-style light theme | CSS variables from ~/Downloads/coco/README.html |
| DSGN-02 | Self-contained HTML with inline CSS/JS | No bundler, CDN for marked.js only |
| DSGN-03 | Responsive | CSS grid + media queries |
</phase_requirements>

---

## Summary

Phase 2 builds a 4-page vanilla HTML dashboard served by Express at localhost:3000. The critical discovery is that the Claude Code SDK has been renamed: the correct package is now `@anthropic-ai/claude-agent-sdk` (not `@anthropic-ai/claude-code`). However, the SDK requires an Anthropic API key (`ANTHROPIC_API_KEY`), which this user does not have set. The `claude -p` spawn approach is therefore not a fallback — it is the **primary** chat implementation since the CLI uses the existing OAuth session. The SDK path should be attempted first with `settingSources: ['user']` to inherit the OAuth credentials, but `claude -p` spawn is the reliable default.

SSE for file watching is straightforward in Express: track byte offset, use `fs.watchFile()` to detect appends, push new lines via `res.write()`. Markdown rendering is handled by marked.js 17.0.5 loaded from CDN — no build step. Skill frontmatter is parsed server-side with gray-matter 4.0.3. The design tokens are already defined in `~/Downloads/coco/README.html` and should be copied verbatim.

**Primary recommendation:** Use `claude -p --output-format stream-json` as the primary chat backend (it inherits OAuth auth), implement SSE with `fs.watchFile()` and byte offset tracking, use gray-matter for skill catalog, and marked.js CDN for markdown in chat.

---

## Standard Stack

### Core

| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| express | 5.2.1 | HTTP server, routing, SSE | Industry standard, minimal deps |
| @anthropic-ai/claude-agent-sdk | 2.x (latest) | Claude chat (SDK path) | Official SDK, replaces @anthropic-ai/claude-code |
| gray-matter | 4.0.3 | Parse YAML frontmatter from skill .md files | Battle-tested, used by Gatsby/Vitepress/Astro |
| marked (CDN) | 17.0.5 | Markdown → HTML in chat messages | Lightweight, browser-native, no build step |

### Supporting

| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| open (npm) | latest | Auto-open browser on server start | Node.js cross-platform browser open |
| fs (built-in) | Node.js | watchFile(), readFileSync(), statSync() | SSE file tailing |
| child_process (built-in) | Node.js | spawn() for claude -p fallback | When SDK auth fails |
| path, os (built-in) | Node.js | Resolve ~/.coco/events.jsonl paths | Cross-platform home dir |

### Alternatives Considered

| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| fs.watchFile() | chokidar | chokidar is better for cross-platform; watchFile() is sufficient for single-file macOS case |
| marked.js CDN | highlight.js + custom regex | marked handles all edge cases; regex breaks on nested markdown |
| gray-matter | manual regex | gray-matter handles edge cases (multi-line values, quoted strings) |
| SSE | WebSockets | SSE is simpler for one-way push; WebSockets deferred by user decision |

### Installation

```bash
cd ~/.coco
npm init -y
npm install express @anthropic-ai/claude-agent-sdk gray-matter open
```

---

## Architecture Patterns

### Recommended Project Structure

```
~/.coco/
├── server.js              # Express server (~300 lines)
├── package.json           # express + claude-agent-sdk + gray-matter + open
├── events.jsonl           # Append-only event log (from Phase 1 hook)
├── hooks/
│   └── log-event.js       # Phase 1 artifact
└── public/
    ├── index.html         # Chat page (PRIMARY)
    ├── sessions.html      # Sessions monitor
    ├── skills.html        # Skill catalog
    └── history.html       # Event timeline
```

### Pattern 1: Express SSE with File Tailing

**What:** SSE endpoint reads `~/.coco/events.jsonl`, tracks byte offset, streams only new lines.
**When to use:** Any append-only log that needs live browser updates.

```javascript
// Source: https://masteringjs.io/tutorials/express/server-sent-events
app.get('/api/events', (req, res) => {
  res.setHeader('Content-Type', 'text/event-stream');
  res.setHeader('Cache-Control', 'no-cache');
  res.setHeader('Connection', 'keep-alive');
  res.flushHeaders(); // Flush headers immediately to establish SSE

  let byteOffset = 0;

  // Send all existing events on connect
  const existing = fs.readFileSync(EVENTS_FILE, 'utf8');
  const lines = existing.split('\n').filter(Boolean);
  lines.forEach(line => {
    res.write(`data: ${line}\n\n`);
  });
  byteOffset = Buffer.byteLength(existing, 'utf8');

  // Watch for new lines
  const watcher = fs.watchFile(EVENTS_FILE, { interval: 500 }, () => {
    const stat = fs.statSync(EVENTS_FILE);
    if (stat.size <= byteOffset) return; // rotation or no change
    const fd = fs.openSync(EVENTS_FILE, 'r');
    const newSize = stat.size - byteOffset;
    const buf = Buffer.alloc(newSize);
    fs.readSync(fd, buf, 0, newSize, byteOffset);
    fs.closeSync(fd);
    byteOffset = stat.size;
    const newContent = buf.toString('utf8');
    newContent.split('\n').filter(Boolean).forEach(line => {
      res.write(`data: ${line}\n\n`);
    });
  });

  req.on('close', () => {
    fs.unwatchFile(EVENTS_FILE, watcher);
  });
});
```

### Pattern 2: Chat API — claude -p Spawn (Primary Path)

**What:** POST `/api/chat` spawns `claude -p` as child process, reads stream-json output, pipes as SSE.
**When to use:** When no ANTHROPIC_API_KEY is set (uses existing OAuth session from Claude CLI).

```javascript
// Source: https://claudelog.com/faqs/what-is-output-format-in-claude-code/
app.post('/api/chat', (req, res) => {
  const { message } = req.body;

  res.setHeader('Content-Type', 'text/event-stream');
  res.setHeader('Cache-Control', 'no-cache');
  res.setHeader('Connection', 'keep-alive');
  res.flushHeaders();

  const { spawn } = require('child_process');
  const proc = spawn('claude', ['-p', message, '--output-format', 'stream-json'], {
    stdio: ['ignore', 'pipe', 'pipe'],
    env: process.env
  });

  let buffer = '';
  proc.stdout.on('data', (chunk) => {
    buffer += chunk.toString();
    const lines = buffer.split('\n');
    buffer = lines.pop(); // keep incomplete line
    lines.filter(Boolean).forEach(line => {
      try {
        const msg = JSON.parse(line);
        res.write(`data: ${JSON.stringify(msg)}\n\n`);
      } catch (e) {
        // skip malformed JSON
      }
    });
  });

  proc.on('close', (code) => {
    res.write(`data: ${JSON.stringify({ type: 'done', code })}\n\n`);
    res.end();
  });

  req.on('close', () => proc.kill());
});
```

### Pattern 3: Chat API — Agent SDK (Fallback, Requires API Key)

**What:** Uses `@anthropic-ai/claude-agent-sdk` query() with settingSources to inherit user config.
**When to use:** When ANTHROPIC_API_KEY is set in environment.

```javascript
// Source: https://platform.claude.com/docs/en/agent-sdk/typescript
import { query } from '@anthropic-ai/claude-agent-sdk';

app.post('/api/chat-sdk', async (req, res) => {
  const { message } = req.body;

  res.setHeader('Content-Type', 'text/event-stream');
  res.setHeader('Cache-Control', 'no-cache');
  res.flushHeaders();

  try {
    for await (const msg of query({
      prompt: message,
      options: {
        settingSources: ['user'],  // loads ~/.claude/settings.json + CLAUDE.md
        permissionMode: 'bypassPermissions',
        allowDangerouslySkipPermissions: true
      }
    })) {
      res.write(`data: ${JSON.stringify(msg)}\n\n`);
    }
  } catch (err) {
    res.write(`data: ${JSON.stringify({ type: 'error', error: err.message })}\n\n`);
  }
  res.end();
});
```

### Pattern 4: Skill Catalog Loading (Server Startup)

**What:** Read all `.md` files from `~/.claude/commands/` and `~/.claude/skills/*/SKILL.md`, parse frontmatter.
**When to use:** At server startup — cache result, serve via GET `/api/skills`.

```javascript
// Source: https://github.com/jonschlinkert/gray-matter
const matter = require('gray-matter');
const fs = require('fs');
const path = require('path');

function loadSkills() {
  const skills = [];
  const commandsDir = path.join(os.homedir(), '.claude', 'commands');
  const skillsDir = path.join(os.homedir(), '.claude', 'skills');

  // Load commands/*.md
  if (fs.existsSync(commandsDir)) {
    const files = fs.readdirSync(commandsDir, { recursive: true })
      .filter(f => f.endsWith('.md'));
    for (const file of files) {
      const content = fs.readFileSync(path.join(commandsDir, file), 'utf8');
      const { data } = matter(content);
      if (data.description || data.name) {
        skills.push({
          id: file.replace('.md', ''),
          name: data.name || path.basename(file, '.md'),
          description: data.description || '',
          family: detectFamily(file),
          source: 'commands'
        });
      }
    }
  }

  // Load skills/*/SKILL.md
  if (fs.existsSync(skillsDir)) {
    const dirs = fs.readdirSync(skillsDir);
    for (const dir of dirs) {
      const skillFile = path.join(skillsDir, dir, 'SKILL.md');
      if (fs.existsSync(skillFile)) {
        const content = fs.readFileSync(skillFile, 'utf8');
        const { data } = matter(content);
        skills.push({
          id: dir,
          name: data.name || dir,
          description: data.description || '',
          family: detectFamily(dir),
          source: 'skills'
        });
      }
    }
  }

  return skills;
}

function detectFamily(id) {
  if (id.startsWith('gsd') || id.includes('/gsd/')) return 'gsd';
  if (id.includes('pmstudio')) return 'pmstudio';
  if (id.startsWith('email')) return 'email';
  if (['brainstorming','executing-plans','writing-plans','systematic-debugging',
       'requesting-code-review','receiving-code-review','test-driven-development',
       'finishing-a-development-branch','subagent-driven-development'].includes(id)) return 'superpowers';
  if (id.includes('team')) return 'team';
  return 'standalone';
}
```

### Pattern 5: Shared CSS Variables (Inline, Self-Contained)

**What:** Paste the CSS `:root` block from `~/Downloads/coco/README.html` into every HTML file's `<style>` tag.
**When to use:** All 4 HTML pages — no external CSS file needed.

```css
/* Source: ~/Downloads/coco/README.html — verified design tokens */
:root {
  --bg: #f5f5f7; --tile: #fff;
  --primary: #1d1d1f; --secondary: #6e6e73; --tertiary: #86868b;
  --blue: #0071e3; --green: #248a3d; --amber: #c93400;
  --teal: #0071a4; --purple: #7d2fa0;
  --gap: 16px; --radius: 20px; --pad: 28px;
  --font: -apple-system, BlinkMacSystemFont, 'SF Pro Display', 'SF Pro Text',
          system-ui, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif;
  --mono: 'SF Mono', ui-monospace, 'Cascadia Code', 'Fira Code', Menlo, Consolas, monospace;
}
```

### Anti-Patterns to Avoid

- **Do NOT use res.send() or res.end() mid-SSE stream:** These close the connection. Use `res.write()` only.
- **Do NOT forget res.flushHeaders() for SSE:** Without it, the browser waits for the full response.
- **Do NOT parse events.jsonl without handling rotation:** File may be truncated (.bak) — reset byteOffset to 0 if stat.size < byteOffset.
- **Do NOT use `fs.watch()` for SSE tailing:** It fires multiple events per write on macOS; `fs.watchFile()` with interval is more reliable.
- **Do NOT load the full SDK if ANTHROPIC_API_KEY is absent:** SDK will throw immediately; gate behind env check.
- **Do NOT share HTML files via separate CSS file:** Defeats the self-contained requirement; inline all CSS.

---

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Frontmatter parsing | Custom `---` regex | gray-matter | Edge cases: multi-line values, quoted strings, special chars |
| Markdown to HTML | String replacement regexes | marked.js CDN | Full spec compliance: tables, code blocks, nested lists |
| SSE reconnection | Custom polling fallback | Browser EventSource API (built-in) | Browser auto-reconnects on disconnect; no code needed |
| Browser auto-open | Manual `exec('open ...')` | `open` npm package | Cross-platform (mac/win/linux), handles spaces in paths |
| Session grouping | Manual loop with Map | Single reduce() pass on events array | Map by session field, accumulate per-session state |

**Key insight:** The SSE protocol + EventSource browser API handles reconnection automatically. The server just needs to correctly send `id:` fields so the browser can resume with `Last-Event-ID` header.

---

## Common Pitfalls

### Pitfall 1: SDK Auth — No ANTHROPIC_API_KEY

**What goes wrong:** `@anthropic-ai/claude-agent-sdk` query() throws "Authentication failed" because ANTHROPIC_API_KEY is not set. The user authenticates via OAuth (Claude Max subscription), not API key.
**Why it happens:** The Agent SDK requires pay-as-you-go API billing. OAuth tokens from the Claude CLI are for the interactive tool only.
**How to avoid:** Gate SDK usage behind `if (process.env.ANTHROPIC_API_KEY)`. Default to `claude -p` spawn which inherits the CLI's OAuth session.
**Warning signs:** "Authentication failed" or "API key not found" errors at startup.

```javascript
// Recommended: detect auth mode at startup
const useSDK = !!process.env.ANTHROPIC_API_KEY;
console.log(`Chat backend: ${useSDK ? 'Agent SDK' : 'claude -p spawn (OAuth)'}`);
```

### Pitfall 2: SDK Package Name Changed

**What goes wrong:** `require('@anthropic-ai/claude-code')` resolves to the CLI binary package, not the SDK. The SDK exports are missing or wrong.
**Why it happens:** The SDK was renamed from `@anthropic-ai/claude-code` to `@anthropic-ai/claude-agent-sdk` in 2025.
**How to avoid:** Install and import `@anthropic-ai/claude-agent-sdk`. There was also a known bug (issue #10191) about missing `sdk.mjs` entry in `@anthropic-ai/claude-code` — the new package name resolves this.
**Warning signs:** `TypeError: query is not a function` or `MODULE_NOT_FOUND` for the SDK import.

### Pitfall 3: SSE Connection Closing Unexpectedly

**What goes wrong:** Browser SSE connection drops after 30-60 seconds; EventSource reconnects but floods server with connections.
**Why it happens:** Nginx/proxies add timeouts. Express itself does not time out long-lived connections.
**How to avoid:** Send a heartbeat every 15 seconds: `res.write(': heartbeat\n\n')`. The colon prefix makes it a comment event that browsers ignore.

```javascript
const heartbeat = setInterval(() => res.write(': heartbeat\n\n'), 15000);
req.on('close', () => clearInterval(heartbeat));
```

### Pitfall 4: events.jsonl File Rotation Breaking Watcher

**What goes wrong:** When log-event.js rotates events.jsonl (>50MB), the file is renamed to .bak and a new file is created. The watcher is watching the old inode.
**Why it happens:** `fs.watchFile()` watches by path, not inode — it will detect the new file.
**How to avoid:** Check if `stat.size < byteOffset` (rotation signal), reset `byteOffset = 0`, re-read from beginning.

### Pitfall 5: Chat Page SSE and Events SSE on Same Endpoint

**What goes wrong:** Using the same `/api/events` for both the events log stream and the chat response stream creates confusion in the browser.
**Why it happens:** Different consumers need different event types/formats.
**How to avoid:** Use separate endpoints: `/api/events` for events.jsonl tailing, `/api/chat` for Claude responses. Each chat message gets its own SSE stream (opened on POST, closed when result arrives).

### Pitfall 6: gray-matter with Subdirectory Commands

**What goes wrong:** `~/.claude/commands/gsd/` is a subdirectory, not a `.md` file. `fs.readdirSync` without `recursive:true` misses it.
**Why it happens:** Commands are organized in subdirectories (e.g., `gsd/new-project.md`).
**How to avoid:** Use `fs.readdirSync(dir, { recursive: true })` (Node.js 18.17+), filter for `.endsWith('.md')`.

---

## Code Examples

### Markdown Rendering in Chat (Browser, No Build Step)

```html
<!-- Source: https://cdn.jsdelivr.net/npm/marked/lib/marked.umd.js -->
<script src="https://cdn.jsdelivr.net/npm/marked@17.0.5/lib/marked.umd.js"></script>
<script>
function appendMessage(role, text) {
  const div = document.createElement('div');
  div.className = `message message-${role}`;
  div.innerHTML = role === 'assistant' ? marked.parse(text) : escapeHtml(text);
  messagesEl.appendChild(div);
  div.scrollIntoView({ behavior: 'smooth', block: 'end' });
}
</script>
```

### Browser EventSource for Live Sessions Page

```javascript
// Source: MDN https://developer.mozilla.org/en-US/docs/Web/API/EventSource
const eventsSource = new EventSource('/api/events');
eventsSource.onmessage = (e) => {
  try {
    const event = JSON.parse(e.data);
    updateSessionsUI(event);
  } catch (_) {}
};
eventsSource.onerror = () => {
  // Browser automatically reconnects — no manual handling needed
};
```

### Routing Info Display in Chat (CHAT-03)

```javascript
// Detect skill invocation from assistant text stream
function detectRouting(text) {
  const patterns = [
    { regex: /\/team\b/, label: 'Routing to /team...' },
    { regex: /\/gsd\b/, label: 'Routing to /gsd...' },
    { regex: /\/pmstudio\b/, label: 'Routing to /pmstudio...' },
    { regex: /\/email\b/, label: 'Routing to /email...' },
    { regex: /brainstorming\s+skill/i, label: 'Starting brainstorming...' },
  ];
  for (const p of patterns) {
    if (p.regex.test(text)) return p.label;
  }
  return null;
}
```

### Auto-open Browser on Server Start

```javascript
// Source: https://www.npmjs.com/package/open
const open = require('open');
const PORT = 3000;
app.listen(PORT, () => {
  console.log(`CoCo dashboard running at http://localhost:${PORT}`);
  open(`http://localhost:${PORT}`).catch(() => {
    // Silently ignore if browser can't be opened
  });
});
```

### Session Grouping from events.jsonl

```javascript
function groupEventsBySessions(eventsPath, maxAgeMs = 86400000) {
  if (!fs.existsSync(eventsPath)) return [];
  const cutoff = Date.now() - maxAgeMs;
  const lines = fs.readFileSync(eventsPath, 'utf8').split('\n').filter(Boolean);
  const sessions = new Map();

  for (const line of lines) {
    try {
      const event = JSON.parse(line);
      if (event.ts < cutoff) continue;
      const sid = event.session;
      if (!sessions.has(sid)) {
        sessions.set(sid, { id: sid, events: [], firstTs: event.ts, lastTs: event.ts, skill: null });
      }
      const s = sessions.get(sid);
      s.events.push(event);
      s.lastTs = Math.max(s.lastTs, event.ts);
      if (event.type === 'skill_invoked' && event.tool) s.skill = event.tool;
    } catch (_) {}
  }

  return Array.from(sessions.values())
    .map(s => ({
      ...s,
      status: (Date.now() - s.lastTs < 60000) ? 'active' : 'complete',
      duration: s.lastTs - s.firstTs
    }))
    .sort((a, b) => b.lastTs - a.lastTs);
}
```

---

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| `@anthropic-ai/claude-code` (SDK) | `@anthropic-ai/claude-agent-sdk` | 2025 | Must update import; old package is CLI binary only |
| WebSockets for live updates | SSE (EventSource) | Settled pattern | SSE is simpler for one-way push; WebSockets overkill |
| React/Next.js dashboard | Vanilla HTML + inline CSS/JS | Project decision | No build step, no bundler, ~100x less complexity |

**Deprecated/outdated:**
- `@anthropic-ai/claude-code` as SDK import: The npm package exists but is the CLI binary. SDK was split to `@anthropic-ai/claude-agent-sdk`.
- `query()` from `@anthropic-ai/claude-code/sdk`: This entry point had a known missing `sdk.mjs` bug (issue #10191). Use the new package name instead.

---

## Open Questions

1. **Does `settingSources: ['user']` load OAuth credentials for the SDK?**
   - What we know: `settingSources: ['user']` loads `~/.claude/settings.json` for skills/MCP/hooks. Auth credentials for the CLI are stored separately (not in settings.json).
   - What's unclear: Whether the SDK can reuse the CLI's OAuth token when run on the same machine.
   - Recommendation: Probe at server startup — try SDK query with `settingSources: ['user']`, catch auth errors, fall back to `claude -p` spawn. Log which path is used.

2. **Performance of `claude -p` spawn per chat message**
   - What we know: Each spawn starts a new Claude process (~1-2 second cold start). Acceptable for single-user localhost dashboard.
   - What's unclear: Whether session context can be maintained across spawns (the `--resume` flag in SDK handles this, but `claude -p` has `--continue`).
   - Recommendation: Use `claude -p --continue` for follow-up messages in the same conversation to maintain context.

3. **`fs.readdirSync` with `{ recursive: true }` availability**
   - What we know: `recursive` option added in Node.js 18.17.0. Current Node is v24.14.0 — fully supported.
   - What's unclear: Nothing — confirmed safe.
   - Recommendation: Use `{ recursive: true }` without version guard.

---

## Validation Architecture

### Test Framework

| Property | Value |
|----------|-------|
| Framework | None detected in project — manual smoke tests via browser |
| Config file | None — Wave 0 gap |
| Quick run command | `node ~/.coco/server.js & sleep 2 && curl -s http://localhost:3000/ | head -5` |
| Full suite command | Manual: open http://localhost:3000 and test all 4 pages |

### Phase Requirements to Test Map

| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| DASH-01 | Express server responds at :3000 | smoke | `curl -s -o /dev/null -w "%{http_code}" http://localhost:3000/` | Wave 0 |
| DASH-02 | SSE endpoint streams events | smoke | `curl -N http://localhost:3000/api/events` (observe output) | Wave 0 |
| DASH-03 | Chat API returns SSE stream | smoke | `curl -N -X POST -H "Content-Type: application/json" -d '{"message":"hello"}' http://localhost:3000/api/chat` | Wave 0 |
| DASH-04 | SDK fallback triggers when no API key | manual | Unset ANTHROPIC_API_KEY, send chat message, verify response | Wave 0 |
| DASH-05 | Server starts via node command | smoke | `node ~/.coco/server.js &` exits without error | Wave 0 |
| SKIL-01 | Skills endpoint returns grouped catalog | smoke | `curl -s http://localhost:3000/api/skills | python3 -m json.tool` | Wave 0 |
| DSGN-02 | HTML is self-contained (no external CSS) | manual | DevTools → Network → verify no 404 CSS fetches | Wave 0 |

### Sampling Rate

- **Per task commit:** `curl -s -o /dev/null -w "%{http_code}" http://localhost:3000/` (expect 200)
- **Per wave merge:** All smoke tests above manually
- **Phase gate:** All 4 pages render correctly, chat receives a response, SSE streams events

### Wave 0 Gaps

- [ ] `~/.coco/package.json` — must exist before any server.js can run
- [ ] `~/.coco/public/` directory — must exist for static file serving
- [ ] `~/.coco/server.js` — the main deliverable of this phase
- [ ] No formal test framework configured — all tests are curl smoke tests or manual browser verification

---

## Sources

### Primary (HIGH confidence)

- `https://platform.claude.com/docs/en/agent-sdk/typescript` — Full TypeScript SDK API, Options type, SDKMessage types, settingSources behavior
- `https://platform.claude.com/docs/en/agent-sdk/overview` — SDK renamed to claude-agent-sdk, query() async generator pattern, settingSources documentation
- `~/Downloads/coco/README.html` — Authoritative design tokens (CSS variables, colors, typography, tile patterns)
- `~/.coco/hooks/log-event.js` — Confirmed events.jsonl format: `{ ts, type, session, tool, input, cwd, status }`
- `~/.claude/commands/*.md` / `~/.claude/skills/*/SKILL.md` — Actual skill frontmatter format: `name`, `description`, `allowed-tools`

### Secondary (MEDIUM confidence)

- `https://npm show express version` → 5.2.1 (verified locally)
- `https://npm show gray-matter version` → 4.0.3 (verified locally)
- `https://npm show marked version` → 17.0.5 (verified locally)
- `https://github.com/anthropics/claude-code/issues/6536` — Confirms SDK requires API key, cannot use OAuth token from CLI
- `https://masteringjs.io/tutorials/express/server-sent-events` — SSE header pattern (Content-Type, Cache-Control, flushHeaders)
- `https://claudelog.com/faqs/what-is-output-format-in-claude-code/` — `claude -p --output-format stream-json` syntax

### Tertiary (LOW confidence)

- WebSearch results about claude -p spawn hanging in Node.js test environments — known issue but not reproducible in production server context; not a concern for this use case (single POST handler, not test runner)

---

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH — versions verified via npm locally, docs verified via official SDK reference
- Architecture: HIGH — SSE pattern from official Node.js docs; SDK pattern from official Anthropic docs
- SDK auth situation: HIGH — confirmed via GitHub issue and official docs that OAuth cannot be used with SDK
- Pitfalls: HIGH — most verified against official sources or real project artifacts

**Research date:** 2026-03-20
**Valid until:** 2026-04-20 (SDK docs stable; SDK rename is settled; marked.js and gray-matter are stable)
