# Alliance Financing AI — Bug Tracker & Work Log
Last updated: April 3, 2026
Repo: github.com/bshimkovitz-Alliancefinancing/alliance-financing-ai

HOW TO USE: At the start of every new Claude session, say:
"Alex — read PLATFORM_CONTEXT.md and BUG_TRACKER.md from GitHub. We are working on [X]."
Alex reads both files and picks up exactly where we left off.

---

## HOW TO START A SESSION WITH ALEX

1. Open a new chat in the Alex - CTO project
2. Say: "Alex — read PLATFORM_CONTEXT.md and BUG_TRACKER.md from GitHub. We are working on [X]."
3. Paste or link the file you are fixing or building
4. Alex will be fully up to speed in under a minute

---

## KNOWN BUGS — PRIORITY ORDER

| # | File | Description | Status | Notes |
|---|------|-------------|--------|-------|
| B-001 | dashboard.html | Vendor Programs section stuck on "Loading..." for ISO partner (super_agent). Catch block in `loadAgentVendors()` was logging the error silently but never updating the table body. | Fixed | Fixed Apr 3 — catch block now shows error state instead of infinite loading spinner. Upload new dashboard.html to GitHub. |
| B-002 | Supabase DB | `get_my_user_id()` caused infinite recursion on the `users` table. Function queried `public.users` using email lookup — but is called inside RLS policies on the `users` table itself, causing a loop. Also: `is_admin()` function does NOT actually check admin role — it checks if any user with that email exists (semantic bug). | In Progress | `get_my_user_id()` rewritten Apr 3 to use `auth.uid()` — runs in Supabase SQL editor, success confirmed. Still need to fix `is_admin()` next session. |
| B-003 | dashboard.html | Referral Pipeline section visible on ISO Partner dashboard (`display: block`). Should only show for `referring_agent` role, not `super_agent`. ISO partners use Deal Pipeline, not the referral pipeline widget. | Open | |
| B-004 | dashboard.html | Favicon 404 error (minor). | Open | |

Status key: Open / In Progress / Fixed / Deferred

---

## COMPLETED FIXES

| # | File | Description | Fixed On | Notes |
|---|------|-------------|----------|-------|
| B-001 | dashboard.html | Vendor Programs stuck on "Loading..." for ISO partner | Apr 3, 2026 | Catch block in `loadAgentVendors()` updated to show error state. File uploaded to GitHub. |

---

## B-002 CONTINUED — NEXT SESSION

Run this in Supabase SQL Editor to fix `is_admin()`:

```sql
CREATE OR REPLACE FUNCTION is_admin()
RETURNS boolean
LANGUAGE sql STABLE SECURITY DEFINER
AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.users
    WHERE id = auth.uid()
    AND role IN ('admin', 'super_admin')
  );
$$;
```

Then verify both functions work by running:
```sql
SELECT proname, prosrc FROM pg_proc WHERE proname IN ('get_my_user_id', 'is_admin');
```

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
| Apr 3, 2026 | Fixed B-001 (vendor loading spinner), diagnosed and partially fixed B-002 (RLS recursion on `get_my_user_id`) | B-001 Fixed. B-002 In Progress — `is_admin()` fix still needed. |

---

## STANDING RULES (Alex + Bernie)

- Bugs before features — no new builds until known bugs are cleared
- One task per session — keeps conversations short and prevents crashes
- GitHub is the source of truth — every fix gets pushed immediately
- Alex always returns complete files, never partial code
- Update this file at the end of every session before closing
- Upload dashboard.html directly — do not try to fetch from GitHub

---
File location in repo: BUG_TRACKER.md (root)
