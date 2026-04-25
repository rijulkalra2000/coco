---
type: quick-task
task: Enhance CoCo chat page to command center
completed: 2026-03-20
key-files:
  modified:
    - ~/.coco/public/index.html
---

# Enhance Chat Page to Command Center

**One-liner:** Transformed CoCo chat into a command center with skill quick-actions, conversation history sidebar, enhanced message display, and a welcome screen.

## What Was Built

### Task 1: Skill Quick-Action Buttons
- Collapsible skills panel at top of chat area with toggle button
- Five groups of pill buttons: Team (research, develop, review, fix, test), Project (progress, plan-phase, execute), Docs (prd, arb, meeting-notes), Email (summary, unread), Other (brainstorm, anti-pattern-czar)
- Each pill pre-fills the chat input with the corresponding skill command
- Color-coded pill borders per group (green=team, blue=project, teal=docs, amber=email, purple=other)

### Task 2: Conversation History Sidebar
- 280px left sidebar showing past conversations stored in localStorage
- Auto-generates title from first user message (first 40 chars)
- "New Chat" button at top
- Click to switch between conversations; current one highlighted in blue
- Sidebar collapses on mobile with hamburger menu and overlay
- Capped at 50 conversations in localStorage

### Task 3: Enhanced Message Display
- Routing detection shown as colored badge above assistant responses (detects /team, /gsd, /pmstudio, /email, and more)
- Elapsed time per response shown as dim text (e.g., "3.2s")
- User messages: right-aligned, light blue background
- Assistant messages: left-aligned, white background with subtle shadow
- Timestamps shown on hover for all messages

### Task 4: Welcome Screen
- Shows when conversation has no messages
- Large "CoCo" heading with "Your conversational command center" tagline
- 6 clickable skill category chips (Research, Develop, Review, Progress, Brainstorm, PRD) with icons
- "Try asking..." section with 3 clickable example prompts
- Disappears when first message is sent; reappears for empty conversations

## Design Decisions
- All CSS/JS remains inline (self-contained HTML)
- Preserved all existing chat functionality: /api/chat fetch, SSE streaming, marked.js, DOMPurify
- Apple design system maintained: #f5f5f7 bg, white tiles, 20px radius, SF Pro font stack
- localStorage for conversation persistence (no server changes needed)
- Server.js unchanged -- no new endpoints required

## Deviations from Plan

None -- plan executed exactly as written.
