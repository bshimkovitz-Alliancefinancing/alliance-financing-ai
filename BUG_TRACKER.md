# Alliance Financing AI — Bug Tracker & Work Log
Last updated: April 3, 2026
Repo: github.com/bshimkovitz-Alliancefinancing/alliance-financing-ai

HOW TO USE: At the start of every new Claude session, say:
"Alex — read PLATFORM_CONTEXT.md and BUG_TRACKER.md from GitHub. We are working on [X]."
Alex reads both files and picks up exactly where we left off.

---

## HOW TO START A SESSION WITH ALEX

1. Open a new chat in the Alex - CTO project
2. Say: "Alex — read PLATFORM_CONTEXT.md and BUG_TRACKER.md from GitHub. Upload dashboard.html. We are working on [X]."
3. Alex will be fully up to speed in under a minute

---

## KNOWN BUGS — PRIORITY ORDER

| # | File | Description | Status | Notes |
|---|------|-------------|--------|-------|
| B-003 | dashboard.html | Referral Pipeline section visible on ISO Partner dashboard. Should only show for `referring_agent` role, not `super_agent`. ISO partners use Deal Pipeline, not the referral pipeline widget. | Open | |
| B-004 | dashboard.html | Favicon 404 error (minor). | Open | |

Status key: Open / In Progress / Fixed / Deferred

---

## COMPLETED FIXES

| # | File | Description | Fixed On | Notes |
|---|------|-------------|----------|-------|
| B-001 | dashboard.html | Vendor Programs stuck on "Loading..." for ISO partner. Catch block in `loadAgentVendors()` logged error silently but never updated the table body. | Apr 3, 2026 | Catch block updated to show error state. File uploaded to GitHub. |
| B-002 | Supabase DB | Two broken database functions causing 84 failed API calls: (1) `get_my_user_id()` caused infinite recursion — queried `public.users` via email lookup inside an RLS policy on the same table. (2) `is_admin()` returned true for ANY logged-in user — never checked the role column. | Apr 3, 2026 | Both functions rewritten in Supabase SQL Editor. `get_my_user_id()` now uses `auth.uid()`. `is_admin()` now checks `role IN ('admin', 'super_admin')`. Both confirmed Success in Supabase. |

---

## BUILD PRIORITY (after bugs are cleared)

### Phase 1 — BaaS Tier 1: Client Portal (CURRENT PRIORITY)
- [ ] My Financings (active deals, payment schedules, balances)
- [ ] Document Vault (upload docs, access contracts)
- [ ] Apply for More (pre-populated applications)
- [ ] Messages and Alerts (deal-specific threads)
- [ ] Company Profile (business info, authorized contacts)
- [ ] Application Tracker (real-time status visibility)

### Phase 2 — Client Database and Centralized Records
- [ ] Centralized client records
- [ ] Client history and relationship view

### Phase 3 — Financial Intelligence
- [ ] Cash flow forecasting
- [ ] Credit monitoring
- [ ] Automated renewal engine

### Phase 4 — Partner Self-Serve Portal
- [ ] Partner self-serve financing portal

---

## SESSION LOG

| Date | What We Worked On | Outcome |
|------|-------------------|---------|
| Apr 3, 2026 | Set up Bug Tracker and established working framework with Alex | Complete |
| Apr 3, 2026 | Fixed B-001 (vendor loading spinner) and B-002 (RLS recursion + is_admin logic) | Both fully fixed and confirmed |

---

## STANDING RULES (Alex + Bernie)

- Bugs before features — no new builds until known bugs are cleared
- One task per session — keeps conversations short and prevents crashes
- GitHub is the source of truth — every fix gets pushed immediately
- Alex always returns complete files, never partial code
- Update this file at the end of every session before closing
- Upload dashboard.html directly to chat — do not try to fetch from GitHub

---
File location in repo: BUG_TRACKER.md (root)
