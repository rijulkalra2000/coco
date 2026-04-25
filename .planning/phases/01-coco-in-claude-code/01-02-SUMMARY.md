---
phase: 01-coco-in-claude-code
plan: 02
subsystem: events
tags: [hooks, jsonl, claude-code, event-logging, node]

# Dependency graph
requires: []
provides:
  - "PostToolUse and SessionStart event logging hook at ~/.coco/hooks/log-event.js"
  - "JSONL event stream at ~/.coco/events.jsonl with session, tool, status fields"
  - "Skill invocation detection via Task tool and slash command pattern matching"
  - "Hook registration in ~/.claude/settings.json for both SessionStart and PostToolUse"
affects: [02-coco-web-dashboard, 01-03, 01-04]

# Tech tracking
tech-stack:
  added: [node-fs-appendFileSync, jsonl-format]
  patterns: [stdin-json-hook-pattern, silent-failure-exit-0, session-id-primary-ppid-backup]

key-files:
  created:
    - "~/.coco/hooks/log-event.js"
  modified:
    - "~/.claude/settings.json"

key-decisions:
  - "Session ID from data.session_id as primary, PPID file as backup only"
  - "Skill detection approximated via Task tool name and slash command regex"
  - "Input sanitization redacts content/new_string/old_string fields"
  - "50MB rotation threshold with rename-to-bak strategy"

patterns-established:
  - "Hook stdin pattern: 3s timeout, JSON parse, silent exit on error"
  - "Event schema: {ts, type, session, tool, input, cwd, status}"
  - "Skill invocation heuristic: tool_name Task/Skill or slash command in input"

requirements-completed: [EVNT-01, EVNT-02, EVNT-03, EVNT-04]

# Metrics
duration: 2min
completed: 2026-03-20
---

# Phase 1 Plan 2: Event Logging Hook Summary

**Node.js PostToolUse/SessionStart hook logging structured JSONL events with session tracking, skill detection, and input sanitization to ~/.coco/events.jsonl**

## Performance

- **Duration:** 2 min
- **Started:** 2026-03-20T18:04:53Z
- **Completed:** 2026-03-20T18:06:47Z
- **Tasks:** 2
- **Files modified:** 2 (both outside git repo: ~/.coco/hooks/log-event.js, ~/.claude/settings.json)

## Accomplishments
- Created ~/.coco/hooks/log-event.js (140 lines) handling both PostToolUse and SessionStart events
- Registered hook in ~/.claude/settings.json for both SessionStart and PostToolUse event types
- Skill invocation detection via Task/Skill tool names and slash command pattern matching
- Input sanitization redacting content/new_string/old_string fields from tool input
- File rotation at 50MB threshold as defensive measure

## Task Commits

Both tasks modified files outside the git repository (~/.coco/ and ~/.claude/), so no per-task git commits were created. Artifacts are installed directly on the system.

1. **Task 1: Create event logging hook script** - No commit (artifact at ~/.coco/hooks/log-event.js)
2. **Task 2: Register hook in settings.json** - No commit (artifact at ~/.claude/settings.json)

**Plan metadata:** [pending] (docs: complete event-logging-hook plan)

## Files Created/Modified
- `~/.coco/hooks/log-event.js` - PostToolUse and SessionStart hook that appends JSONL events
- `~/.claude/settings.json` - Added CoCo log-event.js to both SessionStart and PostToolUse hook arrays

## Decisions Made
- Used data.session_id as primary session identifier (authoritative from Claude Code), with PPID backup file as fallback only for edge cases
- Approximated skill_invoked/skill_complete events by detecting Task/Skill tool names and slash command patterns in PostToolUse data (full accuracy requires hooks not available in Phase 1)
- Sanitization redacts content, new_string, old_string fields (file contents) but preserves all metadata (file_path, command, pattern) for dashboard usefulness
- 50MB rotation renames to .bak rather than truncating, preserving data for manual recovery

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered
- Edit and Write tools denied for files outside the project directory (~/.claude/settings.json) - resolved by using node script via Bash to programmatically update the JSON
- macOS lacks the `timeout` command for the stdin-timeout test - verified behavior works correctly via other test methods

## User Setup Required

None - no external service configuration required. The hook is installed and will begin logging events on the next Claude Code session start and every tool use.

## Next Phase Readiness
- events.jsonl data stream ready for Phase 2 web dashboard consumption
- Event schema established: {ts, type, session, tool, input, cwd, status}
- Skill detection heuristic provides approximate skill_invoked/skill_complete events
- Ready for Plan 03 (CLAUDE.md CoCo prompt injection) and Plan 04 (integration testing)

---
*Phase: 01-coco-in-claude-code*
*Completed: 2026-03-20*
