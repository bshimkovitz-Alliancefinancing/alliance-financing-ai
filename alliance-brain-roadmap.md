# Deal Pipeline Roadmap Tracker

**Last updated:** April 16, 2026
**Source:** `deal-pipeline-roadmap-tracker.html` (GitHub: `alliance-financing-ai` repo)

The roadmap governs the evolution of the Alliance dashboard and AI platform. Every feature request, bug fix, or new build should be checked against this roadmap to ensure alignment. The roadmap has 4 phases plus a strategic gaps backlog.

---

## Phase 0 — Data Foundation (100% Complete)

All foundational data structures are in place. These are prerequisites for every subsequent phase.

| # | Item | Status | Implementation Notes |
|---|------|--------|---------------------|
| 1 | Lender outcome tracking fields | DONE | `decision_date`, `decline_reason`, `conditions`, `terms_offered` on `lender_submissions` table |
| 2 | Deal activity log function + hooks | DONE | `logDealActivity()` JS function + `deal_activity_log` Supabase table |
| 3 | Product-specific document checklists | DONE | 14 product types, `buildDocChecklistHtml()` function in dashboard |
| 4 | Document completeness % in pipeline table | DONE | Color-coded badge, batch doc fetch from Supabase storage |
| 5 | Auto-reminder for missing docs | DONE | `checkMissingDocReminders()`, admin-only, 48-hour threshold |

---

## Phase 1 — Visual CRM + Assignment (8 of 9 Complete)

The CRM layer on top of the pipeline. Only Smart Deal Assignment is deferred.

| # | Item | Status | Implementation Notes |
|---|------|--------|---------------------|
| 1 | Kanban board with drag-and-drop | DONE | 8 color-coded columns, admin drag-to-change-status |
| 2 | Board / Table toggle | DONE | Both views share filters |
| 3 | Slide-out detail panel | DONE | 5 tabs: Overview, Timeline, Docs, Notes, Lenders |
| 4 | Full activity timeline | DONE | Powered by Phase 0 `deal_activity_log` |
| 5 | Deal health scores | DONE | 0-100 scoring, green/yellow/red on cards + table |
| 6 | 8-stage refined pipeline | DONE | All 15 `deal_status` enum values mapped to 8 Kanban columns |
| 7 | Agent Deal Health Card | DONE | Simplified 5-stage Kanban for agents/ISOs with progress dots |
| 8 | Communication logging | DONE | Note/Email compose in slideout, branded emails, activity log |
| 9 | Smart deal assignment | DEFERRED | Routing rules, workload balancing, escalation — deferred until more deal volume |

---

## Phase 2 — AI Intelligence Layer (Not Started)

This is the next major build. The AI layer sits on top of the existing pipeline and is **additive** — new Supabase edge functions storing output in new JSONB fields, no changes to existing working tables. All AI outputs are advisory; admin confirms before any deal-affecting action.

| # | Item | Status | Description | Schema Readiness |
|---|------|--------|-------------|-----------------|
| 1 | AI bank statement analysis | NOT STARTED | Avg balance, deposits, MCA stacking, NSFs, anomalies | `ai_extracted_data` JSONB exists on `deals` — needs dedicated `ai_bank_analysis` table |
| 2 | AI financial statement extraction | NOT STARTED | Revenue, margins, debt load, DSCR, trends | Same — needs `ai_financial_extraction` table |
| 3 | AI credit app verification | NOT STARTED | Auto-extract fields, flag inconsistencies | Needs verification results table + edge function |
| 4 | AI PNW analysis | NOT STARTED | Net worth, liquidity, guarantor capacity | Needs PNW analysis output table |
| 5 | Cross-document verification | NOT STARTED | Revenue match, undisclosed debt, time-in-business | Needs cross-doc results table linking multiple doc analyses |
| 6 | AI underwriting report | NOT STARTED | Auto-generated per deal with exec summary | Needs report output table + PDF generation pipeline |
| 7 | Deal risk scoring (0-100) | NOT STARTED | Credit, industry, docs, financials composite score | `ai_extracted_data` JSONB could hold this, but dedicated `ai_risk_scores` table preferred |
| 8 | AI decision summary | NOT STARTED | Next best action, comparable funded deals | Needs decision output table + historical deal matching logic |

### Phase 2 Prerequisites (from Architecture Audit, April 2026)

Before building Phase 2, these schema/infrastructure items need attention:

- **Dedicated AI output tables**: The current `ai_extracted_data` JSONB column on `deals` is a catch-all. Each AI module should write to its own typed table for queryability, indexing, and audit trail.
- **Edge function framework**: Extend the existing `send-email` / `resend-webhook` pattern to support AI processing edge functions. Consider a queue-based approach for long-running analyses.
- **Document access pipeline**: AI modules need to read uploaded docs from the `deal-documents` storage bucket. Build a shared utility for fetching and parsing (PDF text extraction, image OCR).
- **RLS security fixes**: The 14 "allow_all" bypass policies identified in the architecture audit must be fixed before AI writes advisory data that could be misread if accessed by wrong roles.

---

## Phase 3 — Scale + Automation (Not Started)

Operational intelligence and workflow automation. Depends on Phase 2 data.

| # | Item | Status | Description |
|---|------|--------|-------------|
| 1 | Pipeline analytics dashboard | NOT STARTED | Conversion rates, stage velocity, bottleneck detection |
| 2 | Automated stage transitions | NOT STARTED | Auto-move deals based on triggers (doc upload, approval) |
| 3 | SLA tracking and alerts | NOT STARTED | Time-in-stage limits per product type |
| 4 | Lender performance analytics | NOT STARTED | Approval rates, speed, decline patterns by lender |
| 5 | Agent performance scoring | NOT STARTED | Deal quality, doc completeness, conversion rates |
| 6 | Bulk deal actions | NOT STARTED | Multi-select for status changes, assignments, exports |

---

## Strategic Gaps (Backlog — Not Yet Scheduled)

Items identified as important but not assigned to a phase or timeline.

| # | Item | Status | Description |
|---|------|--------|-------------|
| 1 | Smart deal assignment | DEFERRED | Routing rules, workload balancing, escalation (from Phase 1) |
| 2 | Communication hub integration | DEFERRED | Centralized email/SMS tied to deal records |
| 3 | Client portal / self-serve doc upload | DEFERRED | Clients upload docs directly into deal record |
| 4 | Revenue forecasting | DEFERRED | Weighted pipeline value, expected close dates |
| 5 | Mobile-responsive pipeline | DEFERRED | Touch-friendly Kanban for phone/tablet |

---

## AI Intelligence Layer — 5 Insertion Points (Priority Order)

These are the specific insertion points identified for the AI layer. They map to Phase 2 items but are more granular about where in the codebase/infrastructure each one plugs in:

1. **Lender reply parsing** — Extract structured decisions (approve/reject/counter + terms) from inbound email replies. Insertion: extend `process-inbound-email` edge function.
2. **Partner application scoring** — Auto-score `partner_applications` on quality/risk. Insertion: new edge function on INSERT trigger.
3. **Deal red-flag detection** — Flag inconsistencies in `form_data` when deal moves to `under_review`. Insertion: new edge function on status transition.
4. **Lender matching suggestions** — Rank top-5 lender fits from the 70+ platform based on deal profile + historical data. Insertion: new "Recommend" button in deal detail modal.
5. **Follow-up email drafting** — Auto-draft tone-matched follow-ups by channel type. Insertion: new "Draft Follow-Up" button in deal/partner records.

---

## How to Use This Reference

- **Before building anything new**: Check which phase it falls under. Build in phase order unless there's a compelling reason to pull something forward.
- **When a phase item is completed**: Update the status in this file AND in `deal-pipeline-roadmap-tracker.html` in the GitHub repo.
- **When a new gap is identified**: Add it to Strategic Gaps with a description. It gets scheduled during the next planning session.
- **When auditing the schema**: Cross-reference Phase 2 prerequisites against the live Supabase schema to track readiness.
