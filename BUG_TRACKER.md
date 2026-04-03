# Alliance Financing AI — Bug Tracker & Work Log
Last updated: April 3, 2026
Repo: github.com/bshimkovitz-Alliancefinancing/alliance-financing-ai

HOW TO USE: At the start of every new Claude session, say:
"Alex — read PLATFORM_CONTEXT.md and BUG_TRACKER.md from GitHub. We are working on [X]."
Alex reads both files and picks up exactly where we left off.

---

## HOW TO START A SESSION WITH ALEX

1. Open a new chat in the Alex - CTO project
2. 2. Say: "Alex — read PLATFORM_CONTEXT.md and BUG_TRACKER.md from GitHub. We are working on [X]."
   3. 3. Alex pulls files directly from GitHub — Bernie never needs to upload source files
      4. 4. Alex will be fully up to speed in under a minute
        
         5. ---
        
         6. ## KNOWN BUGS — PRIORITY ORDER
        
         7. | # | File | Description | Status | Notes |
         8. |---|------|-------------|--------|-------|
         9. | B-001 | dashboard.html | Referral agent sidebar shows wrong items — Vendor Programs appearing for referral partners | Open | Fix role filtering in nav |
         10. | B-002 | dashboard.html | Notification actions routing referral agents to vendor pages | Open | Fix after B-001 |
         11. | B-003 | dashboard.html | 100 console errors — data may be silently failing to load | Open | Investigate after B-001 |
         12. | B-004 | syndication-portal.html | Field name mismatch — uses product but schema uses product_type | Open | Quick fix |
         13. | B-005 | syndication-portal.html | Status filter uses wrong values not in deal_status ENUM | Open | Fix after B-004 |
         14. | B-006 | partner.html | Contact leads saving to partner_leads table that does not exist — leads lost | Open | Create table or fix |
        
         15. Status key: Open / In Progress / Fixed / Deferred
        
         16. ---
        
         17. ## COMPLETED FIXES
        
         18. | # | File | Description | Fixed On | Notes |
         19. |---|------|-------------|----------|-------|
         20. | — | — | No fixes logged yet | — | — |
        
         21. ---
        
         22. ## BUILD PRIORITY (after bugs are cleared)
        
         23. ### Phase 1 — Partner Dashboards (CURRENT PRIORITY)
         24. - [ ] Fix referral agent dashboard (B-001, B-002, B-003)
             - [ ] - [ ] Fix syndication portal (B-004, B-005)
             - [ ] - [ ] Fix partner lead capture (B-006)
             - [ ] - [ ] Build ISO dashboard (no dedicated file exists yet)
             - [ ] - [ ] Build Mortgage Agent dashboard (no dedicated file exists yet)
            
             - [ ] ### Phase 2 — BaaS Tier 1: Client Portal
             - [ ] - [ ] My Financings (active deals, payment schedules, balances)
             - [ ] - [ ] Document Vault (upload docs, access contracts)
             - [ ] - [ ] Apply for More (pre-populated applications)
             - [ ] - [ ] Messages and Alerts (deal-specific threads)
             - [ ] - [ ] Company Profile (business info, authorized contacts)
             - [ ] - [ ] Application Tracker (real-time status visibility)
            
             - [ ] ### Phase 3 — Client Database and Centralized Records
             - [ ] - [ ] Centralized client records
             - [ ] - [ ] Client history and relationship view
            
             - [ ] ### Phase 4 — Financial Intelligence
             - [ ] - [ ] Cash flow forecasting
             - [ ] - [ ] Credit monitoring
             - [ ] - [ ] Automated renewal engine
            
             - [ ] ### Phase 5 — Partner Self-Serve Portal
             - [ ] - [ ] Partner self-serve financing portal
            
             - [ ] ---
            
             - [ ] ## SESSION LOG
            
             - [ ] | Date | What We Worked On | Outcome |
             - [ ] |------|-------------------|---------|
             - [ ] | Apr 3, 2026 | Full platform audit. Set up Bug Tracker and Best Practices. Identified 6 bugs across 3 files. | Complete |
            
             - [ ] ---
            
             - [ ] ## STANDING RULES (Alex + Bernie)
            
             - [ ] - Bugs before features — no new builds until known bugs are cleared
             - [ ] - One task per session — keeps conversations short and prevents crashes
             - [ ] - GitHub is the source of truth — every fix gets pushed immediately
             - [ ] - Alex pulls files directly from GitHub — Bernie never needs to upload source files
             - [ ] - Alex always returns complete files, never partial code
             - [ ] - Update this file at the end of every session before closing
            
             - [ ] ---
            
             - [ ] ## KEY FACTS FOR ALEX
            
             - [ ] - dashboard.html is 2.3MB — contains all role views (admin, referral agent, ISO, vendor)
             - [ ] - Agent types: super_agent (ISO), referring_agent (Referral Partner), vendor_program, syndication_desk
             - [ ] - All partners log in via agent-login.html and redirect to dashboard.html
             - [ ] - Role detection works correctly — nav filtering has bugs
             - [ ] - Vercel auto-deploys from GitHub main branch
             - [ ] - File location in repo: BUG_TRACKER.md (root)
