---
phase: 1
slug: coco-in-claude-code
status: draft
nyquist_compliant: false
wave_0_complete: false
created: 2026-03-20
---

# Phase 1 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | None installed — validation is behavioral (smoke tests + manual inspection) |
| **Config file** | None — no test framework needed for Phase 1 |
| **Quick run command** | `echo '{"session_id":"test","tool_name":"Bash","tool_input":{"command":"ls"},"cwd":"/tmp","tool_response":{"stdout":"","success":true}}' \| node ~/.coco/hooks/log-event.js && tail -1 ~/.coco/events.jsonl` |
| **Full suite command** | Quick run + manual routing accuracy checklist (10 prompts) |
| **Estimated runtime** | ~5 seconds (automated) + ~5 minutes (manual routing tests) |

---

## Sampling Rate

- **After every task commit:** Run quick run command (pipe test JSON, check events.jsonl)
- **After every plan wave:** Run full suite — smoke tests + manual routing accuracy checklist
- **Before `/gsd:verify-work`:** Full suite must be green; routing accuracy > 90%
- **Max feedback latency:** 5 seconds (automated smoke tests)

---

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|-----------|-------------------|-------------|--------|
| 01-01-01 | 01 | 1 | PERS-01, PERS-02, PERS-03, PERS-04, ROUT-01 to ROUT-11, ORCH-01 to ORCH-05 | inspection + manual | `grep "## CoCo" ~/.claude/CLAUDE.md && awk '/^## CoCo/,0' ~/.claude/CLAUDE.md \| wc -l` | N/A (CLAUDE.md section) | pending |
| 01-01-02 | 01 | 1 | ROUT-01 to ROUT-11 | manual | `grep "## CoCo" ~/.claude/CLAUDE.md` | N/A (checkpoint) | pending |
| 01-02-01 | 02 | 1 | EVNT-01, EVNT-02, EVNT-03 | smoke | `echo '{"session_id":"smoke-test","tool_name":"Read","tool_input":{"file_path":"/tmp/test.txt"},"cwd":"/tmp","tool_response":{"success":true}}' \| node ~/.coco/hooks/log-event.js && tail -1 ~/.coco/events.jsonl \| node -e "const l=require('readline').createInterface({input:process.stdin});l.on('line',d=>{const e=JSON.parse(d);const ok=e.session==='smoke-test'&&e.type==='tool_use'&&e.tool==='Read'&&e.ts>0;console.log(ok?'PASS':'FAIL');process.exit(ok?0:1)})"` | Wave 0 | pending |
| 01-02-02 | 02 | 1 | EVNT-04 | inspection | `node -e "const s=JSON.parse(require('fs').readFileSync(require('os').homedir()+'/.claude/settings.json','utf8'));const ss=s.hooks.SessionStart.some(h=>h.hooks.some(x=>x.command.includes('log-event')));const pt=s.hooks.PostToolUse.some(h=>h.hooks.some(x=>x.command.includes('log-event')));console.log(ss&&pt?'PASS':'FAIL');process.exit(ss&&pt?0:1)"` | N/A (settings.json) | pending |

*Status: pending / green / red / flaky*

---

## Wave 0 Requirements

- [ ] `~/.coco/hooks/log-event.js` — covers EVNT-01, EVNT-02, EVNT-03 (created by Plan 02 Task 1)
- [ ] `~/.coco/` directory creation — prerequisite for hook and events.jsonl
- [ ] Test fixture: pipe-based smoke test JSON payloads (inline in verify commands, no separate file needed)

*Note: No test framework installation needed. Phase 1 produces configuration files (CLAUDE.md section, hook script, settings.json entry). Validation uses smoke tests (pipe JSON to hook, inspect output) and manual routing accuracy checks.*

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| CoCo greeting appears on session start | PERS-01, PERS-02 | Requires human to open a new Claude Code session and observe greeting | 1. Open new Claude Code session in this project. 2. Verify greeting shows: Project name, branch, domain, GSD status, "Ready." |
| Autonomy rules respected | PERS-03 | Requires human to issue commands and verify confirmation behavior | 1. Type "git push" — verify CoCo asks for confirmation. 2. Type "research X" — verify CoCo executes without asking. |
| Disable mechanism works | PERS-04 | Requires human to toggle disabled state and observe | 1. `touch ~/.coco/disabled`. 2. Open new session. 3. Verify no CoCo greeting. 4. `rm ~/.coco/disabled`. |
| Routing accuracy > 90% | ROUT-01 to ROUT-11 | Natural language routing can only be verified by testing prompts in a live session | Run 10 test prompts (see Plan 01-01 Task 2 checklist). At least 9/10 must route correctly. |
| Orchestration chains fire | ORCH-01 to ORCH-05 | Chain execution requires multi-turn interaction in live session | 1. Type "build a new feature" — verify brainstorm chain starts. 2. Type "fix the auth bug" — verify systematic-debugging chain. |
| Skill invocation approximation | EVNT-02 | skill_invoked detection requires a real skill call in a live session | 1. Invoke a /team command. 2. Check events.jsonl for skill_invoked type entry. |

---

## Validation Sign-Off

- [ ] All tasks have `<automated>` verify or Wave 0 dependencies
- [ ] Sampling continuity: no 3 consecutive tasks without automated verify
- [ ] Wave 0 covers all MISSING references
- [ ] No watch-mode flags
- [ ] Feedback latency < 5s
- [ ] `nyquist_compliant: true` set in frontmatter

**Approval:** pending
