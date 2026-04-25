---
phase: 02
slug: web-dashboard
status: draft
nyquist_compliant: true
wave_0_complete: false
created: 2026-03-20
---

# Phase 02 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | None — curl smoke tests + manual browser verification |
| **Config file** | None — no test framework needed for vanilla HTML dashboard |
| **Quick run command** | `cd ~/.coco && node -e "const app = require('./server.js'); const s = app.listen(3099, () => { require('http').get('http://localhost:3099/', r => { console.log('Status:', r.statusCode); s.close(); process.exit(r.statusCode === 200 ? 0 : 1); }); })"` |
| **Full suite command** | `cd ~/.coco && node server.js & sleep 2 && for p in / /sessions.html /skills.html /history.html /api/skills /api/sessions; do echo "$p: $(curl -s -o /dev/null -w '%{http_code}' http://localhost:3000$p)"; done; kill %1 2>/dev/null` |
| **Estimated runtime** | ~5 seconds |

---

## Sampling Rate

- **After every task commit:** Run quick run command (server loads + responds 200)
- **After every plan wave:** Run full suite command (all pages + APIs respond)
- **Before `/gsd:verify-work`:** Full suite must be green + manual browser walkthrough
- **Max feedback latency:** 5 seconds

---

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|-----------|-------------------|-------------|--------|
| 02-01-01 | 01 | 1 | DASH-01, DASH-02, DASH-05 | smoke | `cd ~/.coco && node --check server.js && node -e "const app = require('./server.js'); console.log('OK'); process.exit(0)"` | W0 | ⬜ pending |
| 02-01-02 | 01 | 1 | DASH-03, DASH-04 | smoke | `cd ~/.coco && node -e "const http=require('http');const app=require('./server.js');const s=app.listen(3099,()=>{const r=http.request({hostname:'localhost',port:3099,path:'/api/skills',method:'GET'},res=>{let d='';res.on('data',c=>d+=c);res.on('end',()=>{console.log('Skills:',r.statusCode,d.substring(0,60));s.close();process.exit(0)})});r.end()})"` | W0 | ⬜ pending |
| 02-01-03 | 01 | 1 | CHAT-01, CHAT-02, CHAT-03, CHAT-04, DSGN-01, DSGN-02, DSGN-03 | smoke | `cd ~/.coco && node -e "const http=require('http');const app=require('./server.js');const s=app.listen(3099,()=>{http.get('http://localhost:3099/',r=>{let d='';r.on('data',c=>d+=c);r.on('end',()=>{console.log('Status:',r.statusCode,'Has marked:',d.includes('marked'),'Has nav:',d.includes('Sessions'));s.close();process.exit(0)})})})"` | W0 | ⬜ pending |
| 02-02-01 | 02 | 2 | SESS-01, SESS-02, SESS-03 | smoke | `ls -la ~/.coco/public/sessions.html && grep -c "EventSource\|api/sessions" ~/.coco/public/sessions.html` | W0 | ⬜ pending |
| 02-02-02 | 02 | 2 | SKIL-01, SKIL-02, SKIL-03 | smoke | `ls -la ~/.coco/public/skills.html && grep -c "api/skills\|family\|badge\|skill=" ~/.coco/public/skills.html` | W0 | ⬜ pending |
| 02-02-03 | 02 | 2 | HIST-01, HIST-02 | smoke | `ls -la ~/.coco/public/history.html && grep -c "EventSource\|api/events\|search\|filter" ~/.coco/public/history.html` | W0 | ⬜ pending |
| 02-02-04 | 02 | 2 | ALL | manual | Human visual inspection of all 4 pages | N/A | ⬜ pending |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

- [ ] `~/.coco/package.json` — must exist before any server.js can run (created in 02-01-01)
- [ ] `~/.coco/public/` directory — must exist for static file serving (created in 02-01-01)
- [ ] `~/.coco/server.js` — must export app for programmatic testing (created in 02-01-01)

*No separate test framework needed. All verification is curl/node smoke tests or manual browser inspection.*

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| Apple-style visual design | DSGN-01 | Visual appearance cannot be automated | Open localhost:3000, check #f5f5f7 background, white tiles, 20px radius, SF Pro font |
| Responsive mobile layout | DSGN-03 | Requires visual resize check | Resize browser to 375px width, verify layout adapts |
| Chat streaming UX | CHAT-01, CHAT-04 | Requires observing real-time streaming behavior | Type message, watch text stream in, verify auto-scroll |
| Skills family badges visible | SKIL-02 | Visual pill/badge appearance | Click Skills nav, verify each card has colored family pill |
| Click-to-chat from skills | SKIL-03 | Requires multi-page navigation flow | Click any skill card, verify chat page opens with skill name in input |

---

## Validation Sign-Off

- [x] All tasks have `<automated>` verify or Wave 0 dependencies
- [x] Sampling continuity: no 3 consecutive tasks without automated verify
- [x] Wave 0 covers all MISSING references
- [x] No watch-mode flags
- [x] Feedback latency < 5s
- [x] `nyquist_compliant: true` set in frontmatter

**Approval:** pending

---
*Validation strategy created: 2026-03-20*
