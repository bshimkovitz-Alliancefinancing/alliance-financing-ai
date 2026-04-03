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
3. Upload dashboard.html if fixing dashboard bugs (file is 2.2MB — too large for GitHub to render)
4. Alex will be fully up to speed in under a minute

---

## KNOWN BUGS — PRIORITY ORDER

| # | File | Description | Status | Notes |
|---|------|-------------|--------|-------|
| B-001 | dashboard.html | ISO partner: Vendor Programs page stuck on "Loading..." — vendors table never loads | Open | Confirmed live on Lee Harrison account. Supabase RLS likely blocking agent role from vendors table |
| B-002 | dashboard.html | 84 failed Supabase API calls on ISO partner login — causes 100 console errors | Open | Failing: users, prospect_outreach, deals tables. Silent failures. Root cause: RLS policies for agent role |
| B-003 | dashboard.html | ISO partner dashboard shows referralPipelineSection — should be hidden for super_agent | Open | Referral pipeline widget is for referring_agent only. ISO uses Deal Pipeline page |
| B-004 | dashboard.html | favicon.ico returns 404 — no favicon tag in HTML head | Open | Minor. Add link rel icon tag pointing to alliance logo |

Status key: Open / In Progress / Fixed / Deferred

---

## COMPLETED FIXES

| # | File | Description | Fixed On | Notes |
|---|------|-------------|----------|-------|
| — | — | No fixes logged yet | — | — |

---

## CRITICAL CONTEXT FOR NEXT SESSION

### Dashboard Roles — READ THIS BEFORE TOUCHING NAV CODE
- **super_admin / admin** — Full CRM access. All nav items.
- **super_agent (ISO Partner)** — Nav: Notifications, Deal Pipeline, Clients, Vendor Programs, Referral Partners, Application Hub, Marketing, Info & Quoting Tools, Stats & Reports, Help & Resources
- **referring_agent (Referral Partner)** — Nav: Notifications, Dashboard, Vendor Programs, Application Hub, Help & Resources. Pipeline and deals are INSIDE the Dashboard page.
- **vendor_program / vendor_salesperson** — Nav: Dashboard, Info & Quoting Tools, Help & Resources
- **mortgage_broker** — Nav: Notifications, Dashboard, Deal Pipeline, Application Hub, Team, Help & Resources
- **mortgage_agent** — Nav: Notifications, Dashboard, Deal Pipeline, Application Hub, Help & Resources

### Key File Facts
- dashboard.html is 2.22MB — GitHub cannot render it. Bernie must upload it directly to Claude each session.
- Role-filtering function: applyRoleAccess() around line 5070
- referralAllowed array at line 5106 — Vendor Programs IS correct for referring_agent. Do not remove it.
- Guide PDFs for each role are in the repo root — read them before changing any role logic

---

## BUILD PRIORITY (after bugs are cleared)

### Phase 1 — BaaS Tier 1: Client Portal
- [ ] My Financings (active deals, payment schedules, balances)
- [ ] Document Vault (upload docs, access contracts)
- [ ] Apply for More (pre-populated applications)
- [ ] Messages and Alerts (deal-specific threads)
- [ ] Company Profile (business info, authorized contacts)
- [ ] Application Tracker (real-time status visibility)

### Phase 2 — Client Database and Centralized Records
### Phase 3 — Financial Intelligence
### Phase 4 — Partner Self-Serve Portal

---

## SESSION LOG

| Date | What We Worked On | Outcome |
|------|-------------------|---------|
| Apr 3, 2026 | Live-tested referral agent and ISO partner dashboards. Confirmed referral nav is correct. Found 4 real ISO bugs | B-001 to B-004 logged |
| Apr 3, 2026 | Set up Bug Tracker framework | Complete |

---

## STANDING RULES (Alex + Bernie)

- Bugs before features — no new builds until known bugs are cleared
- Confirm every bug on the LIVE site before logging — no bugs from memory
- One task per session
- GitHub is the source of truth — every fix pushed immediately
- Alex always returns complete files, never partial code
- Upload dashboard.html directly to chat — do not try to fetch it
- Read PLATFORM_CONTEXT.md + BUG_TRACKER.md + relevant guide PDF at session start

---
File location in repo: BUG_TRACKER.md (root)
