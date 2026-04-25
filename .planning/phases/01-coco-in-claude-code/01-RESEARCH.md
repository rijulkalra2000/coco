# Phase 1: CoCo in Claude Code - Research

**Researched:** 2026-03-20
**Domain:** Claude Code hooks, CLAUDE.md behavior instructions, settings.json configuration
**Confidence:** HIGH

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions

**Personality (PERS-01 to PERS-04)**
- Always-on via CLAUDE.md section — no activation command needed
- Greeting format: project name, branch, domain, GSD status, then "Ready."
- Autonomy: read-only = just do it, creates files = execute autonomously, git push/delete/send email = always ask
- Disable mechanism: if ~/.coco/disabled file exists, skip CoCo behavior
- CoCo section must stay under 150 lines / 8 KB

**Routing (ROUT-01 to ROUT-11)**
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

**Orchestration (ORCH-01 to ORCH-05)**
- GSD 2 chains when .planning/ exists: progress → plan-phase → execute-phase → verify-work
- Superpowers chains when no GSD: brainstorming → writing-plans → executing-plans → verification
- Build requests: always brainstorm → plan → execute → verify
- Fix requests: systematic-debugging → fix → verify
- Compound requests: decompose into sequential steps, execute autonomously, report at end
- Never auto-execute: git push, delete, force push, send email, post message

**Event Logging (EVNT-01 to EVNT-04)**
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

### Deferred Ideas (OUT OF SCOPE)
- Web dashboard (Phase 2)
- Voice I/O (v2)
- Proactive mode — file watcher, email, calendar (v2)
- Learning loop — corrections override routing (v2)
- Skill sequence recommendations (v2)
</user_constraints>

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|-----------------|
| PERS-01 | CoCo personality active in every Claude Code session without activation command | CLAUDE.md global instructions are loaded every session — confirmed HIGH confidence |
| PERS-02 | Context-aware greeting shows project name, branch, domain, GSD status | CLAUDE.md can instruct Claude to run Bash(git branch, ls .planning/) on session start |
| PERS-03 | Autonomy rules enforced (read-only = just do it, destructive = ask first) | Risk table in CLAUDE.md section, directly instructs behavior — HIGH confidence |
| PERS-04 | Disable mechanism via ~/.coco/disabled file | Bash check in greeting logic: `if [ -f ~/.coco/disabled ]` — HIGH confidence |
| ROUT-01 | Explicit slash commands execute as-is (highest priority) | Slash commands bypass routing — user intent is unambiguous — HIGH confidence |
| ROUT-02 | GSD 2 commands route correctly when .planning/ exists | `.planning/` detection via Bash tool; GSD commands are in ~/.claude/commands/gsd/ |
| ROUT-03 | /team commands route via natural language trigger words (13 skills) | Trigger word tables in CLAUDE.md; verified against v1 coco-system.md which already has these |
| ROUT-04 | /pmstudio commands route via document-related triggers (11 skills) | Trigger patterns confirmed from v1 system prompt — MEDIUM (pmstudio triggers need expansion) |
| ROUT-05 | /email commands route via email-related triggers (9 skills) | 9 email commands confirmed in ~/.claude/commands/ — triggers map directly |
| ROUT-06 | Superpowers skills invoke as part of workflow chains (12 skills) | Orchestration chains in CLAUDE.md; Superpowers triggered by chain position, not directly |
| ROUT-07 | /gsd commands route via project lifecycle triggers (32 commands) | 32 GSD commands confirmed in ~/.claude/commands/gsd/ — triggers map to natural language |
| ROUT-08 | Screenshot commands route via "show screenshot" triggers (9 commands) | ss.md, ss2.md...ss9.md confirmed in ~/.claude/commands/ |
| ROUT-09 | UI/UX Pro Max routes via design-related triggers | Single skill, trigger words: design, wireframe, mockup, UI |
| ROUT-10 | Standalone commands route correctly (5 commands) | anti-pattern-czar, brainstorm, write-plan, execute-plan, project-sync confirmed |
| ROUT-11 | No-match inputs respond directly as Claude (fallback) | Explicit fallback rule in routing priority table |
| ORCH-01 | Build requests trigger brainstorm → plan → execute → verify chain (Superpowers) | Chain definition in CLAUDE.md; Superpowers commands confirmed at ~/.claude/commands/ |
| ORCH-02 | GSD context detected → use GSD 2 lifecycle (plan-phase → execute → verify) | .planning/ detection gate controls which chain to use |
| ORCH-03 | Compound requests decompose into sequential steps | CoCo personality instruction: "decompose and execute sequentially, report at end" |
| ORCH-04 | CoCo executes full chains without asking at each step (high autonomy) | Autonomy table in CLAUDE.md: read-only and file-creating operations proceed without confirmation |
| ORCH-05 | Git push, delete, send email always require explicit confirmation | Destructive operations listed explicitly in autonomy table |
| EVNT-01 | Claude Code hook appends events to ~/.coco/events.jsonl | PostToolUse hook confirmed working — existing gsd-context-monitor.js is exact pattern |
| EVNT-02 | Events include: session_start, user_input, skill_invoked, skill_complete | JSONL schema designed; SessionStart + PostToolUse hooks cover all types |
| EVNT-03 | Session ID tracked via PPID-based mechanism | PPID approach: SessionStart writes UUID to /tmp/coco-session-$PPID.id; PostToolUse reads it |
| EVNT-04 | Hook registered in settings.json matching existing format | settings.json format fully understood — confirmed nested hooks array structure |
</phase_requirements>

---

## Summary

Phase 1 delivers CoCo as a zero-infrastructure Claude Code enhancement: three files (CLAUDE.md section, Node.js hook script, settings.json entry) that make every Claude Code session CoCo-aware. The technical foundation is well-understood because the existing hooks (`gsd-context-monitor.js`, `gsd-check-update.js`) are exact implementation templates.

**The key insight:** Claude Code already does the heavy lifting. CLAUDE.md behaves like a persistent system prompt — Claude reads it at the start of every session and applies all instructions. Routing tables in CLAUDE.md tell Claude which slash command to invoke for each natural language pattern. The routing logic lives entirely in Claude's language understanding, not in code. The hook captures events via PostToolUse stdin which contains `session_id`, `tool_name`, `tool_input`, `cwd`, and `tool_response`.

**The constraints are tight but achievable:** The CoCo section must stay under 150 lines / 8 KB. The global `~/.claude/CLAUDE.md` is currently 48 lines / 4.8 KB. A 150-line CoCo section added to the project-level CLAUDE.md is feasible. The routing tables will be the space-constrained component — they must cover 104 skills in compact trigger maps.

**Primary recommendation:** Write a single `## CoCo` section in the project `CLAUDE.md` (or global `~/.claude/CLAUDE.md`), a Node.js hook at `~/.coco/hooks/log-event.js`, and register two hooks in `settings.json` (SessionStart for session ID generation, PostToolUse for event logging). No new processes, no new infrastructure.

---

## Standard Stack

### Core
| Component | Version/Path | Purpose | Why Standard |
|-----------|-------------|---------|--------------|
| CLAUDE.md | Global: `~/.claude/CLAUDE.md`, Project: `./CLAUDE.md` | Persistent instruction layer | Loaded every Claude Code session automatically |
| settings.json | `~/.claude/settings.json` | Hook registration and permissions | Single configuration file for all Claude Code behavior |
| Node.js hooks | `~/.claude/hooks/*.js` pattern | Event capture scripts | Existing pattern (3 hooks already use this) |
| JSONL | `~/.coco/events.jsonl` | Event persistence | Append-only, no lock contention, human-readable |

### Supporting
| Component | Version | Purpose | When to Use |
|-----------|---------|---------|-------------|
| `process.stdin` JSON read | Node.js built-in | Parse hook input | Every hook — gsd-context-monitor.js is exact template |
| `fs.appendFileSync` | Node.js built-in | Append JSONL events | Atomic for small writes on macOS |
| `os.tmpdir()` | Node.js built-in | Session ID file location | /tmp/coco-session-$PPID.id pattern |
| `/tmp/coco-session-{ppid}.id` | tmpfs | Cross-hook session ID | Written by SessionStart, read by PostToolUse |

### Alternatives Considered
| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| PPID for session ID | `data.session_id` from hook stdin | `session_id` from stdin is the authoritative Claude Code session ID — use THAT, not PPID. PPID is only needed if stdin session_id is unavailable in SessionStart hook. |
| Node.js hook | Shell script hook | Node.js is the established pattern in this project; shell has no JSON parsing without jq |
| Global CLAUDE.md | Project CLAUDE.md | Global affects ALL projects. CoCo routing tables are general enough for global placement; project CLAUDE.md for project-specific overrides |

---

## Architecture Patterns

### Recommended File Structure
```
~/.claude/
├── CLAUDE.md                        # Global: add ## CoCo section here (~150 lines)
├── settings.json                    # Add SessionStart + PostToolUse hook entries
└── hooks/
    └── (existing hooks unchanged)

~/.coco/
├── hooks/
│   └── log-event.js                 # New PostToolUse hook script
└── events.jsonl                     # Append-only event log (created at runtime)
```

### Pattern 1: Claude Code Hook — Read stdin, write JSON to stdout

Every Node.js hook follows this exact pattern (from `gsd-context-monitor.js`):

```javascript
// Source: ~/.claude/hooks/gsd-context-monitor.js (verified existing)
let input = '';
const stdinTimeout = setTimeout(() => process.exit(0), 3000);
process.stdin.setEncoding('utf8');
process.stdin.on('data', chunk => input += chunk);
process.stdin.on('end', () => {
  clearTimeout(stdinTimeout);
  try {
    const data = JSON.parse(input);
    // data.session_id  — authoritative Claude Code session ID
    // data.cwd         — current working directory
    // data.tool_name   — which tool fired (PostToolUse only)
    // data.tool_input  — tool parameters (PostToolUse only)
    // data.tool_response — tool result (PostToolUse only)

    // To inject context into Claude's next turn:
    const output = {
      hookSpecificOutput: {
        hookEventName: "PostToolUse",
        additionalContext: "message to inject"
      }
    };
    process.stdout.write(JSON.stringify(output));
  } catch (e) {
    process.exit(0); // silent fail — never block tool execution
  }
});
```

### Pattern 2: settings.json Hook Registration Format

```json
// Source: ~/.claude/settings.json (verified — current production format)
{
  "hooks": {
    "SessionStart": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "node \"/absolute/path/to/hook.js\""
          }
        ]
      }
    ],
    "PostToolUse": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "node \"/absolute/path/to/hook.js\""
          }
        ]
      }
    ]
  }
}
```

Key: the structure is `{ hooks: { EventName: [ { hooks: [ { type, command } ] } ] } }` — not a flat array. The outer array is a list of matcher groups; the inner `hooks` array holds actual handlers.

### Pattern 3: CLAUDE.md Routing Table Format

From the v1 `coco-system.md` (verified working):

```markdown
## CoCo

### Routing

| Trigger Words | Route To | Notes |
|--------------|----------|-------|
| build, develop, implement | /team develop | confirm before executing |
| fix, debug, broken, error | /team fix | confirm before executing |
| research, investigate | /team research | read-only, just do it |
```

The compact trigger map format fits more skills per line than prose paragraphs. Target: all 104 skills covered in ~80 lines of tables.

### Pattern 4: Session ID Generation (PPID approach)

Because `SessionStart` stdin also includes `session_id` (confirmed from docs — all hooks receive `session_id`), the PPID fallback is only needed if `session_id` is empty:

```javascript
// In SessionStart hook:
const data = JSON.parse(input);
const sessionId = data.session_id || require('crypto').randomUUID();
const ppid = process.ppid;
const idFile = `/tmp/coco-session-${ppid}.id`;
fs.writeFileSync(idFile, sessionId);

// In PostToolUse hook:
const data = JSON.parse(input);
const sessionId = data.session_id || (() => {
  try { return fs.readFileSync(`/tmp/coco-session-${process.ppid}.id`, 'utf8').trim(); }
  catch { return 'unknown'; }
})();
```

**Recommendation:** Use `data.session_id` directly from stdin — it is present in all hook events. PPID file is a backup. This simplifies the implementation and avoids /tmp file dependency.

### Anti-Patterns to Avoid

- **Putting CoCo in global CLAUDE.md only:** The project-level `CLAUDE.md` (if it exists) is also read. For this project, the project `CLAUDE.md` currently does not exist at the project root. Create it at the project root, OR add to global `~/.claude/CLAUDE.md`. Global is appropriate since CoCo should work in ALL projects. Confirmed: global `~/.claude/CLAUDE.md` is 48 lines / 4.8 KB — adding 150 lines brings it to ~198 lines, still well within context budget.
- **Using shell scripts for hooks:** All existing hooks are Node.js. Shell is brittle for JSON parsing on macOS without jq. Follow the Node.js pattern.
- **Appending raw objects to JSONL:** Must be `JSON.stringify(event) + '\n'` — one JSON object per line, no trailing commas.
- **Blocking stdin forever:** The 3-second `stdinTimeout` guard in every hook is critical — prevents hangs when Claude Code kills stuck hooks.
- **Injecting routing logic into hooks:** The PostToolUse hook should ONLY log events. Routing logic lives in CLAUDE.md. Do not try to intercept and re-route from hooks.

---

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Session tracking | Custom session registry | `data.session_id` from hook stdin | Claude Code provides the authoritative ID |
| Skill invocation | Custom command executor | Slash command in Claude conversation | Claude Code handles Skill tool dispatch |
| JSONL write safety | Lock files, write queues | `fs.appendFileSync` | File appends are atomic for small payloads on macOS (< 4KB, O_APPEND) |
| Intent routing | Node.js pattern matcher | CLAUDE.md routing tables | Claude's natural language understanding is the classifier — no regex needed |
| Disable mechanism | Config file, env var | `~/.coco/disabled` file existence check | Already decided; simple `fs.existsSync` in CLAUDE.md greeting instructions |

**Key insight:** For a CLAUDE.md-based implementation, Claude IS the routing engine. The routing tables are instructions TO Claude, not code that runs independently. This is fundamentally different from the v1 Ink TUI approach.

---

## Common Pitfalls

### Pitfall 1: CLAUDE.md CoCo Section Bloating Context
**What goes wrong:** Adding verbose routing tables, examples, and explanations pushes CLAUDE.md over 150 lines, increasing context cost for every session.
**Why it happens:** Each skill family wants detailed trigger examples. Writing prose instead of compact tables.
**How to avoid:** Use compressed trigger maps — one row per skill, triggers as comma-separated values. Target: 3 lines per skill family intro + one table row per skill = ~120 lines for all routing.
**Warning signs:** Any skill getting more than one table row; prose explanations instead of table cells.

### Pitfall 2: PostToolUse Hook Fires on EVERY Tool Use
**What goes wrong:** The hook runs after every Read, Write, Bash, Grep, Glob call — potentially hundreds of times per session.
**Why it happens:** PostToolUse has no default matcher filter; it fires for all tools.
**How to avoid:** Either (a) add a `matcher` field to filter to specific tools, or (b) keep the hook fast (< 50ms) with minimal I/O. For event logging, option (b) is sufficient — `fs.appendFileSync` with a small JSON object is ~5ms.
**Warning signs:** Hook execution time > 100ms; logging more events than needed (filter in hook, not in analysis).

### Pitfall 3: Session ID Not Available in SessionStart
**What goes wrong:** If the SessionStart hook relies on stdin `session_id` but it's not populated yet (early hook fire), session tracking breaks.
**Why it happens:** Hook fires before full session initialization in some edge cases.
**How to avoid:** Use `data.session_id || require('crypto').randomUUID()` as fallback. Write to `/tmp/coco-session-${process.ppid}.id` regardless of source.
**Warning signs:** `session` field in events.jsonl showing 'unknown' frequently.

### Pitfall 4: Routing Priority Ambiguity in CLAUDE.md
**What goes wrong:** Claude routes "review my code" to `/team review` instead of `/gsd:verify-work` when GSD is active.
**Why it happens:** Multiple matching triggers without clear priority ordering.
**How to avoid:** Make the priority rule explicit at the TOP of the routing section: "Check in order: (1) explicit slash command, (2) if .planning/ exists check GSD triggers first, (3) /team, (4) /pmstudio, (5) /email, (6) direct response."
**Warning signs:** Routing to wrong skill when both GSD and /team triggers match.

### Pitfall 5: CLAUDE.md Section Not Respected When ~/.coco/disabled Exists
**What goes wrong:** Claude has no built-in conditional logic — it can't "skip" the CoCo section.
**Why it happens:** CLAUDE.md is not executable code; it's instructions. Claude must be instructed to check the disabled flag.
**How to avoid:** The CoCo section must begin with an explicit instruction: "Before following any CoCo behavior, check if ~/.coco/disabled exists using Bash. If it does, skip all CoCo routing and respond as standard Claude." This adds one tool call to session start but is unavoidable.
**Warning signs:** CoCo behaving normally even when disabled file exists.

### Pitfall 6: events.jsonl Growing Unbounded
**What goes wrong:** Without pruning, events.jsonl grows indefinitely; file read times increase for Phase 2 dashboard.
**Why it happens:** Phase 1 only appends — pruning is deferred to Phase 2.
**How to avoid:** Add a line count guard in the hook: if file size > 50MB, rotate to events.jsonl.bak and start fresh. This is defensive; real pruning is Phase 2's job.
**Warning signs:** events.jsonl > 10MB after a week of use.

---

## Code Examples

### log-event.js — Complete PostToolUse Hook

```javascript
// Source: based on ~/.claude/hooks/gsd-context-monitor.js pattern (verified)
// Path: ~/.coco/hooks/log-event.js
#!/usr/bin/env node

const fs = require('fs');
const os = require('os');
const path = require('path');

const EVENTS_FILE = path.join(os.homedir(), '.coco', 'events.jsonl');
const MAX_SIZE_BYTES = 50 * 1024 * 1024; // 50MB rotation threshold

let input = '';
const stdinTimeout = setTimeout(() => process.exit(0), 3000);
process.stdin.setEncoding('utf8');
process.stdin.on('data', chunk => input += chunk);
process.stdin.on('end', () => {
  clearTimeout(stdinTimeout);
  try {
    const data = JSON.parse(input);
    const sessionId = data.session_id || readSessionIdFile();

    const event = {
      ts: Date.now(),
      type: 'tool_use',
      session: sessionId,
      tool: data.tool_name,
      input: sanitizeToolInput(data.tool_input),
      cwd: data.cwd,
      status: data.tool_response?.success !== false ? 'ok' : 'error'
    };

    // Ensure directory exists
    const dir = path.dirname(EVENTS_FILE);
    if (!fs.existsSync(dir)) fs.mkdirSync(dir, { recursive: true });

    // Rotate if too large
    try {
      const stat = fs.statSync(EVENTS_FILE);
      if (stat.size > MAX_SIZE_BYTES) {
        fs.renameSync(EVENTS_FILE, EVENTS_FILE + '.bak');
      }
    } catch (e) { /* file doesn't exist yet, fine */ }

    fs.appendFileSync(EVENTS_FILE, JSON.stringify(event) + '\n');
  } catch (e) {
    process.exit(0); // silent fail — never block tool execution
  }
});

function readSessionIdFile() {
  try {
    const f = path.join(os.tmpdir(), `coco-session-${process.ppid}.id`);
    return fs.readFileSync(f, 'utf8').trim();
  } catch { return 'unknown'; }
}

function sanitizeToolInput(input) {
  if (!input) return {};
  // Don't log file contents — just paths and keys
  const safe = {};
  for (const [k, v] of Object.entries(input)) {
    safe[k] = (k === 'content' || k === 'new_string' || k === 'old_string')
      ? '[redacted]'
      : v;
  }
  return safe;
}
```

### settings.json — Hook Registration Addition

```json
// Add to existing ~/.claude/settings.json hooks section:
// Source: verified against current settings.json structure
{
  "hooks": {
    "SessionStart": [
      // ... existing hooks ...
      {
        "hooks": [
          {
            "type": "command",
            "command": "node \"~/.coco/hooks/log-event.js\""
          }
        ]
      }
    ],
    "PostToolUse": [
      // ... existing hooks ...
      {
        "hooks": [
          {
            "type": "command",
            "command": "node \"~/.coco/hooks/log-event.js\""
          }
        ]
      }
    ]
  }
}
```

### CLAUDE.md CoCo Section — Skeleton Structure

```markdown
## CoCo — Conversational Assistant

> If `~/.coco/disabled` exists, skip all CoCo behavior and respond as standard Claude.

### Session Start
On every new session, run: `git branch --show-current 2>/dev/null`, `ls .planning/ 2>/dev/null`.
Then greet: `Project: {name} ({branch}) | Domain: {detected} | GSD: {active/inactive} | Ready.`

### Routing Priority
Check in order — use FIRST match:
1. Explicit `/slash-command` → execute as-is
2. `.planning/` exists + project lifecycle language → /gsd commands
3. Action verb trigger → /team
4. Document trigger → /pmstudio
5. Email trigger → /email
6. No match → respond as Claude directly

### /team Trigger Map
| Trigger Words | Command |
|--------------|---------|
| build, develop, implement, create (code) | /team develop |
| fix, debug, broken, error, failing | /team fix |
| test, coverage, write tests | /team test |
| review, audit, check quality | /team review |
| research, investigate, explore, find out | /team research |
| think, brainstorm, options, evaluate | /team think |
| plan, roadmap, project plan | /team plan |
| document, write docs, guide, PRD | /team document |
| present, deck, slides | /team present |
| email to stakeholders, announce, comms | /team communicate |
| scrape, fetch URLs, web research | /team scrape |
| verify, check against spec | /team verify |
| recheck, regression | /team reanalyse |

### /gsd Trigger Map
| Trigger Words | Command |
|--------------|---------|
| new project, start project | /gsd:new-project |
| plan phase, plan next phase | /gsd:plan-phase |
| execute phase, run phase | /gsd:execute-phase |
| progress, status, where are we | /gsd:progress |
| pause, stop work | /gsd:pause-work |
| resume, continue | /gsd:resume-work |
| verify work, check done | /gsd:verify-work |
| quick task, quick fix | /gsd:quick |
| research phase | /gsd:research-phase |
| discuss phase | /gsd:discuss-phase |

### /pmstudio Trigger Map
| Trigger Words | Command |
|--------------|---------|
| write a PRD, product requirements | /pmstudio-prd |
| ARB deck, architecture review board | /pmstudio-arb |
| meeting notes, transcript | /pmstudio-meeting-notes |
| change log, changelog | /pmstudio-changelog |
| decision record, DR | /pmstudio-dr |
| IRP, incident | /pmstudio-irp |
| NFR, non-functional requirements | /pmstudio-nfr |
| sync doc | /pmstudio-sync |
| init studio | /pmstudio-init |
| comms plan | /pmstudio-comms |

### /email Trigger Map
| Trigger Words | Command |
|--------------|---------|
| check email, unread emails | /email-unread |
| read email from [person] | /email-read |
| search email [topic] | /email-search |
| email summary, today's emails | /email-summary |
| reply to email | /email-reply |
| email thread | /email-thread |
| save email | /email-save |
| today's email | /email-today |

### Orchestration Chains
- **Build request** (no GSD): brainstorm → /write-plan → /execute-plan → verify
- **Build request** (GSD active): /gsd:plan-phase → /gsd:execute-phase → /gsd:verify-work
- **Fix request**: /team fix → verify result
- **Compound request**: decompose silently, execute steps sequentially, report summary at end

### Autonomy Rules
| Risk Level | Examples | Behavior |
|------------|---------|----------|
| Read-only | research, review, check, think | Execute immediately, no confirmation |
| Creates files | document, plan | Execute immediately, mention files created |
| Modifies code | develop, fix | Execute, show what changed |
| Destructive | git push, delete, send email, force push | ALWAYS ask explicit confirmation first |
```

---

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| CoCo as Ink TUI terminal app (v1) | CoCo as CLAUDE.md behavior layer | 2026-03-20 (v2 design) | Zero infrastructure, works in all Claude Code sessions |
| SQLite state manager | events.jsonl append-only | 2026-03-20 | No WAL issues, simpler, file-portable |
| Separate CoCo process | Native Claude Code hooks | 2026-03-20 | No process management, no startup delay |
| v1 coco-system.md separate prompt | Merged into ~/.claude/CLAUDE.md | Phase 1 | Always-on, no activation needed |

**Deprecated/outdated:**
- `rijuls-claude-skills/coco/src/` TypeScript source: v1 Ink TUI — over-engineered, do not use
- `rijuls-claude-skills/coco/phase0/coco.sh`: v0 shell POC — superseded
- `~/.coco/coco.db`: v1 SQLite state — superseded by events.jsonl

---

## Open Questions

1. **SessionStart hook stdin: does it include `session_id`?**
   - What we know: Official docs say all hooks receive `session_id`. PostToolUse confirmed from docs.
   - What's unclear: Whether `session_id` is populated in SessionStart hook at that point in initialization.
   - Recommendation: Write SessionStart hook to use `data.session_id || crypto.randomUUID()` as fallback. Test by logging the value on first run.

2. **CLAUDE.md location: global vs. project?**
   - What we know: Global `~/.claude/CLAUDE.md` is 48 lines today. Project CLAUDE.md at project root does not exist for `how-i-pm-with-ai`. Both are read by Claude Code.
   - What's unclear: Should CoCo routing live in global (affects all projects) or project-level?
   - Recommendation: Put CoCo in global `~/.claude/CLAUDE.md` since CoCo should route skills in all projects. The CoCo section references skills (email, team, gsd) that are globally available in `~/.claude/commands/`.

3. **Hook execution order when multiple PostToolUse hooks exist**
   - What we know: The existing `gsd-context-monitor.js` is in PostToolUse. The new `log-event.js` will be added alongside it.
   - What's unclear: Do multiple PostToolUse hooks fire in order or parallel? Does one hook's output affect another?
   - Recommendation: Hooks appear to fire independently (each in its own process). `log-event.js` should not depend on or affect `gsd-context-monitor.js`. No ordering dependency in the design.

4. **How many lines does the CoCo CLAUDE.md section actually need?**
   - What we know: v1 `coco-system.md` is 99 lines. The compressed trigger map approach targets ~120 lines.
   - What's unclear: Whether 120 lines actually fits all routing within the 150-line limit.
   - Recommendation: Use the compact table format shown above. Count during implementation — if over limit, collapse /gsd trigger map (only show top-10 most common commands).

---

## Validation Architecture

> Nyquist validation applies. workflow.nyquist_validation not set to false in .planning/config.json.

### Test Framework
| Property | Value |
|----------|-------|
| Framework | None installed in this project — validation is behavioral (manual + inspection) |
| Config file | None — see Wave 0 |
| Quick run command | `node ~/.coco/hooks/log-event.js < test-event.json` |
| Full suite command | Manual checklist (see below) |

**Note:** Phase 1 produces configuration files (CLAUDE.md section, hook script, settings.json entry). Automated unit tests are not applicable to CLAUDE.md behavioral instructions. Validation is: (a) hook script syntax/function tests, (b) manual routing accuracy checks in a Claude Code session.

### Phase Requirements → Test Map
| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| PERS-01 | CoCo greeting appears on session start | manual | Start new Claude Code session, observe greeting | N/A |
| PERS-02 | Greeting shows correct project/branch/domain | manual | Open session in this project, verify output | N/A |
| PERS-03 | Autonomy rules respected | manual | Ask "git push", verify confirmation prompt | N/A |
| PERS-04 | Disabled file stops CoCo | manual | `touch ~/.coco/disabled`, start session | N/A |
| EVNT-01 | events.jsonl receives entries | smoke | `echo '{"session_id":"test","tool_name":"Read","tool_input":{},"cwd":"/tmp","tool_response":{}}' \| node ~/.coco/hooks/log-event.js && cat ~/.coco/events.jsonl \| tail -1` | ❌ Wave 0 |
| EVNT-02 | Event schema correct | smoke | `cat ~/.coco/events.jsonl \| node -e "process.stdin.on('data',d=>JSON.parse(d.toString().trim().split('\n').pop()))" ` | ❌ Wave 0 |
| EVNT-03 | Session ID populated | smoke | Check events.jsonl `session` field is not 'unknown' | ❌ Wave 0 |
| EVNT-04 | Hook registered in settings.json | inspection | `cat ~/.claude/settings.json \| grep log-event` | ❌ Wave 0 |
| ROUT-01 to ROUT-11 | Routing accuracy | manual | Run 11 routing accuracy test prompts in a Claude Code session | N/A |
| ORCH-01 to ORCH-05 | Chain execution | manual | Trigger a build request, observe chain | N/A |

### Sampling Rate
- **Per task commit:** `echo '{"session_id":"test","tool_name":"Bash","tool_input":{"command":"ls"},"cwd":"/tmp","tool_response":{"stdout":"","success":true}}' | node ~/.coco/hooks/log-event.js`
- **Per wave merge:** Full manual checklist (all routing accuracy tests)
- **Phase gate:** Manual routing accuracy > 90% before `/gsd:verify-work`

### Wave 0 Gaps
- [ ] `~/.coco/hooks/log-event.js` — covers EVNT-01, EVNT-02, EVNT-03
- [ ] `~/.coco/` directory creation — prerequisite for hook
- [ ] Test fixture: `test-event.json` — sample PostToolUse stdin payload for hook testing

---

## Sources

### Primary (HIGH confidence)
- `~/.claude/hooks/gsd-context-monitor.js` — verified PostToolUse hook: stdin read pattern, JSON parse, `data.session_id`, `data.cwd`, `data.tool_name`, additionalContext output
- `~/.claude/settings.json` — verified: exact hooks registration format (`{ hooks: { EventName: [ { hooks: [ { type, command } ] } ] } }`)
- `~/.claude/hooks/gsd-check-update.js` — verified: SessionStart hook pattern, background spawn
- Official Claude Code docs (https://code.claude.com/docs/en/hooks) — verified: PostToolUse stdin schema, all hook event names, output format (decision, additionalContext)

### Secondary (MEDIUM confidence)
- `rijuls-claude-skills/coco/src/prompts/coco-system.md` — v1 routing tables; confirmed trigger words and skill mappings. Verified against current `~/.claude/commands/` skill list.
- `~/.claude/commands/` directory listing — confirmed 44 slash commands available globally (team, email, gsd, standalone)

### Tertiary (LOW confidence)
- Hook execution ordering (parallel vs. sequential for multiple PostToolUse handlers) — not explicitly documented; assumed independent based on architecture pattern

---

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH — verified from existing production hooks and official docs
- Architecture: HIGH — exact patterns from gsd-context-monitor.js; no speculation
- Pitfalls: HIGH for CLAUDE.md size and hook performance; MEDIUM for session ID edge cases
- Routing triggers: MEDIUM — trigger words verified from v1 system prompt, but >90% accuracy target is behavioral (not measurable pre-implementation)

**Research date:** 2026-03-20
**Valid until:** 2026-04-20 (Claude Code hook API is stable; settings.json format unlikely to change)
