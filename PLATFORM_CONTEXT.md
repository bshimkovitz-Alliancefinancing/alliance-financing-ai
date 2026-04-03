# Alliance Financing AI — Platform Context
> Read this file at the start of every Claude session for instant full context.
> Last updated: April 3, 2026 | Repo: github.com/bshimkovitz-Alliancefinancing/alliance-financing-ai

---

## Who We Are
Alliance Financing Group Ltd. (alliancefinancing.ai) — Canadian commercial financing arranger, est. 1989. We are a **syndication desk**, not a direct lender. We arrange financing through 70+ institutional lenders across Canada, US, and internationally. 9 product lines. $1B+ funded.

**Key team:** Bernie Shimkovitz (Director), Carrie Rotman (Program Director), Paul J. Morrison (Sr. Technology & Commercial Finance Consultant), Lee Harrison (Sr. Advisor, Alliance Global Advisors).

---

## Tech Stack
| Layer | Technology |
|-------|------------|
| Frontend | Plain HTML, CSS, JavaScript (no framework) |
| Backend / Database | Supabase (PostgreSQL) |
| Auth | Supabase Auth (role-based) |
| Hosting | Vercel (auto-deploys from GitHub main branch) |
| Repo | github.com/bshimkovitz-Alliancefinancing/alliance-financing-ai |
| Domain | alliancefinancing.ai |

**Important conventions:**
- All files are in the root directory (flat structure — no src/, no components/)
- Supabase JS client is loaded via CDN and initialized on each page
- No build step — what's in GitHub is what's live
- Pages use consistent nav/footer patterns across the site

---

## Dashboard Roles — READ THIS BEFORE TOUCHING dashboard.html

dashboard.html is a single file serving ALL roles. Role-filtering happens in `applyRoleAccess()` around line 5070. Each role sees a different nav and different dashboard content.

**CRITICAL: Read the relevant guide PDF before changing any role's nav or features.**
All guide PDFs are in the repo root (e.g. Referral-Partner-Guide-v2.pdf, Guide-ISO-Partner.pdf).

---

### Role 1: Admin / Super Admin
**DB role:** `super_admin` or `admin`
**Nav:** Everything — full CRM access
**Dashboard shows:** Attention Alerts, full deal pipeline, all agents, all lenders, all vendors, all clients, inbox, notifications, recruitment hub, team management, stats & reports
**Key powers:** Approve agents, manage lenders, manage vendors, assign deals, view all data across all agents
**Guide:** Admin-specific guides in repo

---

### Role 2: ISO Partner (super_agent)
**DB role:** `agent` with `agent_type = super_agent`
**Nav:** Notifications | Deal Pipeline | Clients | Vendor Programs | Referral Partners | Application Hub | Marketing | Info & Quoting Tools | Stats & Reports | Help & Resources
**Dashboard shows:** Notifications hub as home page. Deal pipeline filtered to their deals. Their referral partners (sub-agents) they manage. Their vendor programs.
**Key features per guide:**
- **Deal Pipeline** — Submit deals via +Add Application, track through all stages (Prospect → Funded), view stats bar
- **Vendor Programs** — View active vendor partnerships, access vendor notes and materials, submit vendor-tied deals
- **Referral Partners** — Invite and onboard sub-agents, monitor their deal submissions, track commissions per partner
- **Application Hub** — Send applications to clients, share referral landing page
- **Marketing** — Download branded collateral with their contact info
- **Stats & Reports** — Commission tracker, deal volume, performance metrics
**Guide:** Guide-ISO-Partner.pdf in repo root

---

### Role 3: Referral Partner (referring_agent)
**DB role:** `agent` with `agent_type = referring_agent`
**Nav:** Notifications | Dashboard | Vendor Programs | Application Hub | Help & Resources
**Dashboard shows:** Personalized greeting, pipeline stats cards (Active Pipeline, Projected Fees, Funded), My Dashboard pipeline table (their referrals only)
**Key features per guide:**
- **Dashboard** — Central hub. Shows pipeline stats + full referral pipeline table with columns: Client, Source, Type, Amount, Stage, Progress, Date, Actions. Filter tabs: All, Sent Out, Client Applied, In Progress, Needs Action, Funded, Archived. Send Application button.
- **Vendor Programs** — Manage vendor outreach leads from leasing one-pager. Two tabs: Your Vendors (submitted directly) and Partner Vendors (Alliance network). Track vendor status: Requires Approval → Application Sent → Pending Review → Approved.
- **Application Hub** — Send credit applications to clients (all financing types), share personalized landing page, send MCA one-pager, send vendor leasing one-pager, submit new vendor programs directly
- **Notifications** — Client application returns, vendor inquiry responses, vendor application completions, deal status changes
**IMPORTANT:** Vendor Programs IS correct in this nav. Referral partners actively manage vendor relationships and submit vendors to Alliance. Do NOT remove it.
**Guide:** Referral-Partner-Guide-v2.pdf in repo root

---

### Role 4: Mortgage Broker (mortgage_broker)
**DB role:** `agent` with `agent_type = mortgage_broker`
**Nav:** Notifications | Dashboard | Deal Pipeline | Application Hub | Team | Help & Resources
**Guide:** Mortgage-Broker-Guide.pdf in repo root

---

### Role 5: Mortgage Agent (mortgage_agent)
**DB role:** `agent` with `agent_type = mortgage_agent`
**Nav:** Notifications | Dashboard | Deal Pipeline | Application Hub | Help & Resources
**Guide:** Mortgage-Agent-Guide.pdf in repo root

---

### Role 6: Vendor Program Admin (vendor_program)
**DB role:** `agent` with `agent_type = vendor_program`
**Nav:** Dashboard | Info & Quoting Tools | Help & Resources
**Guide:** Vendor-Admin-Guide.pdf in repo root

---

### Role 7: Vendor Salesperson (vendor_salesperson)
**DB role:** `agent` with `agent_type = vendor_salesperson`
**Nav:** Dashboard | Info & Quoting Tools | Help & Resources
**Guide:** Vendor-Sales-Guide.pdf in repo root

---

## Critical dashboard.html Technical Notes
- **File size: 2.22MB** — GitHub cannot render it. Bernie must upload it directly to Claude each session. Do NOT attempt to fetch it via URL.
- **Role filtering function:** `applyRoleAccess()` around line 5070
- **referralAllowed array:** line 5106 — controls referring_agent nav
- **Logout resets:** on logout, all nav items are set to `display:flex` then re-filtered on next login
- **Nav uses text label matching** — the `applyRoleAccess()` function identifies nav items by their visible text label (e.g. 'Vendor Programs'), not by element ID

---

## Database Schema (Supabase PostgreSQL)

### Key ENUM Types
```sql
deal_status: Prospect, Quote sent, Info received, In Credit, Approved, Approval sent, Docs requested, Docs out for signing, In funding, Funded, Declined, Dead approval
product_type: Equipment Leasing, MCA, CSBFL, SRED, Private Debt, Factoring, Merchant Advance, Commercial Mortgage, SBA, Loans, Trade Finance
agent_status: AIA, MOU, Active, Inactive, Pending
application_status: Application Received, Under Review, Additional Info Requested, Submitted to Lender, Approved, Declined, Funded, Withdrawn
currency_code: CAD, USD, GBP, EUR
```

### Core Tables
```
organizations — multi-tenancy (alliance, agent_firm, syndication_partner, vendor)
users — auth + roles: super_admin, admin, agent, institutional_user, applicant
  key fields: auth_id, organization_id, role, referral_slug, referred_by
lenders — 70+ lender network; lender_id (e.g. EL-001), ai_metadata JSONB
lender_products — junction: lender_id × product_type
lender_contacts — contacts per lender
vendors — equipment/product vendors
vendor_contacts — contacts per vendor
applications — inbound applications; auto-ID: AF-XXXX
  key fields: full_name, email, business_name, funding_amount_requested, status, source_agent_id, source_channel, referral_slug
application_products — junction: application_id × product_type
deals — pipeline; auto-ID: DEAL-XXXX
  key fields: company_name, deal_amount, currency, product_type, status (deal_status enum), source_agent_id, assigned_lender_id, application_id, gross_fee_pct, alliance_fee, agent_fee_pct, agent_fee_amount, alliance_net_fee
deal_syndication — lender participation in syndicated deals
client_contacts — contacts associated with deals
documents — file uploads (Supabase Storage); ai_extracted_data JSONB
commissions — agent fee tracking; status: Pending, Approved, Paid, Cancelled
communications — email/SMS/system log per deal or application
activity_log — immutable audit trail (PIPEDA/FINTRAC compliance)
contact_submissions — website contact form submissions
```

### Key Views
```
deal_pipeline_view — deals + agent name + lender name + app number
agent_performance_view — per-agent: total deals, funded, volume, commissions
application_summary_view — applications + agent name + products array
```

### RLS Policy Summary
- `super_admin` / `admin` — full access to everything
- `agent` — can only see their own applications, deals, commissions (filtered by source_agent_id)
- Anonymous — can submit applications and contact forms; can read own application status
- All tables have RLS enabled

---

## Repository File Map

### Website (public-facing)
```
index.html — Homepage
about.html — About Alliance
how-it-works.html — Process explanation
products.html — All products overview
faq.html — FAQ
contact.html — Contact form
blog.html — Blog index
landing.html — Campaign landing page
privacy-policy.html — Privacy policy
terms-of-service.html — Terms of service
```

### Product Pages
```
equipment-financing.html
working-capital.html
invoice-factoring.html
lines-of-credit.html
cash-flow-loans.html
business-acquisition.html
canadian-tax-credits.html
equipment-financing-vs-leasing.html
```

### Application Forms
```
apply-leasing.html — Equipment lease application
apply-working-capital.html — Working capital application
apply-merchant-advance.html — MCA application
application.html — General application
vendor-application.html — Vendor onboarding
vendor-inquiry.html — Vendor inquiry form
personal-net-worth.html — Personal net worth statement
```

### Partner Portals
```
agent-login.html — Agent login
agent-activate.html — Agent account activation
vendor-portal.html — Vendor dashboard
syndication-portal.html — Syndication desk
partner.html / partners.html — Partner program pages
partner-referral.html — Referral partner signup
partner-lender.html — Lender partner signup
```

### Admin
```
dashboard.html — Main admin CRM dashboard (ALL roles — 2.22MB)
dashboard-with-clients.html — Dashboard variant with client records
track-application.html — Public application status tracker
upload-documents.html — Document upload
approval-notice.html — Approval notification page
prospect-response.html — Prospect follow-up page
```

### Marketing / Collateral (repo root)
```
Guide-ISO-Partner.pdf — ISO partner dashboard guide
Referral-Partner-Guide-v2.pdf — Referral partner dashboard guide (USE v2)
Referral-Partner-Quick-Reference.pdf
Referral-Partner-Presentation.pdf
Guide-Referring-Agent.docx
Mortgage-Broker-Guide.pdf / Mortgage-Agent-Guide.pdf
Vendor-Admin-Guide.pdf / Vendor-Sales-Guide.pdf
Alliance-Financing-Platform-Guide.docx
alliance-partner-handbook.pdf
```

### Claude Skills
```
.claude/skills/alliance-comms/ — Communication patterns for dashboard email/notes UI
```

---

## What's Live (as of April 2026)
- ✅ AI-powered credit applications (all 9 product lines)
- ✅ Full admin dashboard & deal pipeline CRM
- ✅ Lender credit package system
- ✅ ISO, referral partner & vendor portals
- ✅ Document collection & secure storage
- ✅ Application tracking for clients
- ✅ Notification & alert system
- ✅ Marketing & recruitment tools (guides, PDFs, presentations)
- ✅ 27 active partners across 4 channel types

---

## What's Being Built Next (Priority Order)
1. **Fix open bugs (B-001 to B-004)** ← CURRENT PRIORITY — see BUG_TRACKER.md
2. **Client Portal / BaaS Tier 1**
   - My Financings (active deals, payment schedules, balances)
   - Document Vault (upload docs, access contracts)
   - Apply for More (pre-populated applications)
   - Messages & Alerts (deal-specific threads)
   - Company Profile (business info, authorized contacts)
   - Application Tracker (real-time status visibility)
3. Client database & centralized records
4. Cash flow forecasting & credit monitoring
5. Automated renewal engine
6. Partner self-serve financing portal

---

## BaaS Vision (4 Tiers)
```
Tier 1 — Core Portal (Building now)
Tier 2 — Financial Intel (forecasting, credit monitoring, renewal engine)
Tier 3 — Embedded Banking (Bank partnership: deposits, credit cards, payments)
Tier 4 — Marketplace (Insurance, equipment, bookkeeping integrations, white-label)
```
**Key insight:** Traditional brokers lose clients after funding. Alliance retains them through a self-service portal. Every funded client = recurring revenue, not a one-time transaction.

---

## Revenue Model
- Broker fees on funded deals (core)
- Automated renewals & cross-sell (Tier 1-2)
- Deposit revenue share (Tier 3)
- Credit card interchange (Tier 3)
- Marketplace referral fees (Tier 4)
- White-label SaaS licensing (Tier 4)

---

## Compliance Notes
- FINTRAC/PCMLTFA — AFGL is a designated reporting entity (April 2025)
- KYC at lease signing: beneficial ownership, Schedule 50, Central Securities Register
- PIPEDA — activity_log table provides immutable audit trail
- All client comms must be plain-spoken, empathetic, non-legalistic (Alliance style)

---

## Alliance Communication Style
- Warm, friendly, concise, plain-spoken
- Never formal or legalistic in client-facing copy
- No fabricated statistics — all claims must be verifiable from actual company data
- Internal fees and interest rates must NEVER appear on client-facing documents

---

## How to Start a Claude Session
1. Read this file (or paste the GitHub raw URL)
2. Read BUG_TRACKER.md from GitHub
3. State what you're working on
4. If working on dashboard.html — Bernie uploads the file directly (do NOT fetch — file is 2.22MB)
5. Claude generates complete output — no partial code

---
*File location in repo: PLATFORM_CONTEXT.md (root)*
