# Alliance Financing AI — Bug Tracker & Work Log
Last updated: April 3, 2026
Repo: github.com/bshimkovitz-Alliancefinancing/alliance-financing-ai

HOW TO USE: At the start of every new Claude session, say:
"Alex — read PLATFORM_CONTEXT.md and BUG_TRACKER.md from GitHub. We are working on [X]."
Alex reads both files and picks up exactly where we left off.

---

## HOW TO START A SESSION WITH ALEX

1. Open a new chat in the Alex - CTO project
2. Say: "Alex — read PLATFORM_CONTEXT.md and BUG_TRACKER.md from GitHub. We are working on B-001."
3. Paste or link the file you are fixing or building
4. Alex will be fully up to speed in under a minute

---

## KNOWN BUGS — PRIORITY ORDER

| # | File | Description | Status | Notes |
|---|------|-------------|--------|-------|
| B-001 | dashboard.html | Referral agent sidebar shows "Vendor Programs" — wrong nav item for this role | Open | Role-filtering bug — referral agents should never see Vendor Programs |
| B-002 | dashboard.html | Referral agent sidebar missing critical items: My Pipeline/My Deals, My Commissions, Submit a Deal, My Applications, Messages | Open | Currently shows: Notifications, Dashboard, Vendor Programs, Application Hub, Help & Resources |
| B-003 | dashboard.html | 100 console errors on load — data likely failing silently, referral agents may see empty/stale screens | Open | Check Firebase calls, undefined references, missing data handlers |
| B-004 | dashboard.html | favicon.ico returning 404 | Open | Minor cleanup — add favicon or suppress the request |

Status key: Open / In Progress / Fixed / Deferred

---

## COMPLETED FIXES

| # | File | Description | Fixed On | Notes |
|---|------|-------------|----------|-------|
| — | — | No fixes logged yet | — | — |

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
| Apr 3, 2026 | Identified 4 bugs in dashboard.html — referral agent sidebar role-filtering broken | Bugs logged, B-001 fix in progress |
| Apr 3, 2026 | Set up Bug Tracker and established working framework with Alex | Complete |

---

## STANDING RULES (Alex + Bernie)

- Bugs before features — no new builds until known bugs are cleared
- One task per session — keeps conversations short and prevents crashes
- GitHub is the source of truth — every fix gets pushed immediately
- Alex always returns complete files, never partial code
- Update this file at the end of every session before closing

---
File location in repo: BUG_TRACKER.md (root)
