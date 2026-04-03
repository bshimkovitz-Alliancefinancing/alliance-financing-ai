# Alliance Financing AI — Best Practices
Last updated: April 3, 2026
Repo: github.com/bshimkovitz-Alliancefinancing/alliance-financing-ai

This file governs how Bernie and Alex work together to build the platform.
It is the operating standard for every session.

---

## SESSION MANAGEMENT

**How to start every session:**
1. Open a new chat in the Alex - CTO project
2. Say: "Alex — read PLATFORM_CONTEXT.md and BUG_TRACKER.md from GitHub. We are working on [X]."
3. Paste the file you are fixing or building
4. Alex is fully up to speed in under a minute

**One task per session.**
Every conversation has one job. Finish it, push it, close it.
This prevents context crashes and keeps work clean.

**Keep sessions short.**
Long conversations hit limits and crash. Short, focused sessions are faster and safer.

**End every session by updating BUG_TRACKER.md.**
Log what was completed, what is next, and push the updated file to GitHub before closing.

---

## FILE MANAGEMENT

**GitHub is the source of truth.**
What is in GitHub main branch is what is live. Nothing exists unless it is in GitHub.

**Push every fix immediately.**
Never sit on a fixed file. Fix it, get the file from Alex, upload it to GitHub, confirm it deployed on Vercel.

**Flat file structure — always.**
All files go in the root directory. No subfolders for HTML files.
This is how the platform is built and must stay consistent.

**No build step.**
What is in GitHub is what is live on alliancefinancing.ai via Vercel auto-deploy.
Never add a build process, package.json, or framework.

**Alex always returns complete files.**
Never partial code, never snippets. Always the full file ready to upload.
If Alex gives you a partial file, ask for the complete version.

---

## CODING STANDARDS

**Tech stack is fixed. Do not change it.**
- Frontend: Plain HTML, CSS, JavaScript — no frameworks
- Backend: Supabase (PostgreSQL + Auth)
- Hosting: Vercel
- No React, no Next.js, no build tools

**Supabase client is loaded via CDN on every page.**
Initialize it the same way on every page. Never import from node_modules.

**Every page uses the same nav and footer pattern.**
Copy the nav and footer from an existing page when building a new one.
Consistency across all pages is mandatory.

**RLS is always on.**
Every Supabase table has Row Level Security enabled.
Never disable RLS. Never write queries that bypass it.

**Role-based access is enforced everywhere.**
Roles: super_admin, admin, agent, institutional_user, applicant.
Every page that is role-restricted must check the user's role before rendering content.

**No hardcoded fees, rates, or financial figures in client-facing files.**
Internal fees and interest rates never appear in public-facing HTML.

**No fabricated data.**
All statistics and claims must come from real Alliance data.

---

## DATABASE STANDARDS

**supabase-schema.sql is the source of truth for the database.**
Any schema change must be reflected in this file and committed to GitHub.

**Use the correct ENUM values.**
Always use the exact values defined in the schema ENUMs.
Example: deal_status must be one of the defined values — never a custom string.

**Auto-IDs are always used.**
Applications: AF-XXXX
Deals: DEAL-XXXX
Never manually assign IDs.

**activity_log is immutable.**
Never update or delete rows in activity_log. It is an audit trail for PIPEDA/FINTRAC compliance.

---

## COMMUNICATION & CONTENT STANDARDS

**Alliance tone: warm, friendly, plain-spoken, concise.**
Never formal, never legalistic in client-facing copy.
Write like a trusted advisor, not a bank.

**Never reproduce internal financials externally.**
Fees, rates, and internal deal economics stay internal.

**All client communications must be empathetic.**
Clients are often stressed. Every touchpoint should feel supportive and clear.

---

## BUILD DISCIPLINE

**Bugs before features.**
No new features until known bugs are cleared.
Check BUG_TRACKER.md at the start of every session.

**Build to the plan.**
Phase 1 → Phase 2 → Phase 3 → Phase 4.
Do not jump ahead. Each phase unlocks the next.

**Test before closing.**
Every fix must be verified live on alliancefinancing.ai before the session ends.
"It looks right in the file" is not good enough — confirm it works in production.

**Update BUG_TRACKER.md after every fix.**
Move the bug from Open to Fixed. Log the date. Push the updated tracker.

---

## THE GOAL

Alliance Financing is building toward $100M+ in funded volume.
The platform is the engine that gets us there.

Every decision — every file, every session, every fix — should serve that goal.
Build clean. Build fast. Build to last.

---
File location in repo: BEST_PRACTICES.md (root)
