-- ============================================================================
-- ALLIANCE FINANCING AI — Data Migration from Google Sheets
-- ============================================================================
-- Run this AFTER supabase-schema.sql
-- Test records have been removed. Only real data is included.
-- ============================================================================

-- Get the Alliance org ID (created by schema seed)
-- We'll reference it where needed

-- ============================================================================
-- LENDERS (from Lenders sheet — 14 real records)
-- ============================================================================

INSERT INTO lenders (lender_id, name, lender_type, country, currency, status) VALUES
  ('EL-001', 'CSI Leasing', 'Lender', 'Canada', 'CAD', 'Agreement Signed'),
  ('EL-002', 'NFS Leasing', 'Lender', 'Canada', 'CAD', 'Active'),
  ('MCA-001', 'Journey Capital', 'Lender', 'Canada', 'CAD', 'Active'),
  ('MCA-002', 'ROK', 'Broker', 'United States', 'USD', 'Active'),
  ('EL-003', 'Dext Capital', 'Lender', 'United States', 'USD', 'Active'),
  ('Bank-001', 'BMO', 'Lender', 'Canada', 'CAD', 'Active'),
  ('MCA-003', 'Newco Capital Group', 'Lender', 'Canada', 'CAD', 'Active'),
  ('Bank-002', 'RBC', 'Lender', 'Canada', 'CAD', 'Active'),
  ('SRED-001', 'Bonsai Growth', 'Lender', 'Canada', 'CAD', 'Active'),
  ('EL-004', 'CWB', 'Lender', 'Canada', 'CAD', 'Agreement Signed'),
  ('PD-001', 'FM Private Credit', 'Lender', 'Canada', 'CAD', 'Active'),
  ('EL-005', 'BSB Leasing', 'Broker', 'United States', 'USD', 'Agreement Signed'),
  ('MCA-004', 'Merchant Growth', 'Lender', 'Canada', 'CAD', 'Agreement Signed'),
  ('MCA-005', 'Biz Fund Canada', 'Lender', 'Canada', 'CAD', 'Agreement Signed');

-- Lender product mappings
INSERT INTO lender_products (lender_id, product)
SELECT l.id, p.product FROM lenders l, (VALUES
  ('EL-001', 'Equipment Leasing'::product_type),
  ('EL-002', 'Equipment Leasing'::product_type),
  ('MCA-001', 'MCA'::product_type),
  ('MCA-002', 'MCA'::product_type),
  ('EL-003', 'Equipment Leasing'::product_type),
  ('Bank-001', 'CSBFL'::product_type),
  ('MCA-003', 'MCA'::product_type),
  ('Bank-002', 'CSBFL'::product_type),
  ('SRED-001', 'SRED'::product_type),
  ('EL-004', 'Equipment Leasing'::product_type),
  ('PD-001', 'Private Debt'::product_type),
  ('EL-005', 'Equipment Leasing'::product_type),
  ('MCA-004', 'MCA'::product_type),
  ('MCA-005', 'MCA'::product_type)
) AS p(lender_code, product)
WHERE l.lender_id = p.lender_code;

-- ============================================================================
-- LENDER CONTACTS (from Lender Contacts sheet — 13 records)
-- ============================================================================

INSERT INTO lender_contacts (lender_id, contact_name, role_title, email, phone, territory, is_primary)
SELECT l.id, c.name, c.title, c.email, c.phone, c.territory, TRUE
FROM lenders l, (VALUES
  ('EL-001', 'Jason MacDonald', 'Vice President of Sales', 'jason.macdonald@csileasing.com', '613-532-4026', 'Canada and United States'),
  ('EL-002', 'David Dennis', 'Country Manager - Canada', 'david.denniss@nfscapital.com', '416-728-0224', 'Canada and United States'),
  ('EL-003', 'Jacque Garscin', 'VP Relationship Manager', 'jacque.garscin@dextcapital.com', '303-319-2431', 'United States'),
  ('Bank-001', 'Akash Khullar', 'Relationship Manager', 'Akash.Khullar@bmo.com', '519-808-6358', 'Ontario'),
  ('MCA-003', 'Shervin Ebrahim', 'Business Development', 'shervin@newcocapitalgroup.com', '437-886-5005', 'Canada'),
  ('Bank-002', 'Mohamad Fakih', 'Director, Commercial Banking', 'mohamad.fakih@rbcroyalbank.com', '905-897-2402', 'GTA'),
  ('SRED-001', 'Patrick Anderson', 'Founder and Managing Partner', 'pat@bonsaigrowth.ca', '226-979-5556', 'Canada'),
  ('EL-004', 'Jim Mackereth', 'Account Executive', 'jim.mackereth@cwb.com', '604-313-6117', 'Canada'),
  ('PD-001', 'Sandy Armoogan', 'CEO', 'sandy@FMprivate.ca', '647-920-7500', 'Canada'),
  ('EL-005', 'Matt Miller', 'CEO', 'matt@bsbleasing.com', '412-737-4441', 'United States'),
  ('MCA-004', 'Natasha McMillan', 'Sales', 'Natasha.McMillan@merchantgrowth.com', '647-243-8855', 'Canada'),
  ('MCA-005', 'Ryan Van Duzen', 'Sales Manager', 'rvanduzen@bizfundcanada.com', '416-318-0444', 'Canada'),
  ('MCA-001', 'Jason Fiorotto', 'VP, Business Development', 'jfiorotto@journeycapital.ca', '519-831-6113', 'Canada')
) AS c(lender_code, name, title, email, phone, territory)
WHERE l.lender_id = c.lender_code;

-- ============================================================================
-- AGENTS & REFERRAL PARTNERS (from AgentsReferrals sheet)
-- Cleaned: removed entries without contact info
-- ============================================================================

INSERT INTO users (full_name, email, phone, title, role, referral_slug, notes) VALUES
  ('Robert Duncan', 'rduncan@pinngrp.com', '404-538-6080', 'President and CEO', 'agent', 'robert-duncan', 'Company: Pinnacle Group Consulting. Referred by Ted Ellis.'),
  ('Paul Morrison', 'pjmorrison@alliancefinancing.com', '204-952-6460', 'Senior Technology & Commercial Finance Consultant', 'agent', 'paul-morrison', 'Alliance Financing Group. AIA status.'),
  ('Ania Piekarska', 'Ania.piekarska@nacora.com', '416-894-6860', 'Insurance Agent', 'agent', 'ania-piekarska', 'Company: Nacora. Insurance.'),
  ('Rod Heard', 'rod@andcapitalventures.com', '403-669-9057', 'Co-Founder and CEO', 'agent', 'rod-heard', 'Company: And Capital Ventures. Referred by Bernie Shimkovitz.'),
  ('Teruel Carrasco', 'teruel@andcapitalventures.com', '780-934-3622', 'Founder and Managing Director', 'agent', 'teruel-carrasco', 'Company: And Capital Ventures.'),
  ('Jan Thava', 'janthava@dwminc.ca', '416-806-3193', 'Managing Partner', 'agent', 'jan-thava', 'Company: Verico Dynasty Wealth Management. Mortgage Broker.'),
  ('Rob Seines', 'rselnes@bflcanada.ca', '778-594-5673', 'Vice-President, Client Executive', 'agent', 'rob-seines', 'Company: BFL Canada. Referred by Cortney Hayhurst.'),
  ('Cortney Hayhurst', 'cortney.hayhurst@ebury.com', '647-952-0529', 'Senior Partnership Manager', 'agent', 'cortney-hayhurst', 'Company: Ebury.'),
  ('Rawn Lakhan', 'rlakhan@meadowbankasset.com', NULL, NULL, 'agent', 'rawn-lakhan', 'Company: Meadowbank. MOU status.'),
  ('Tim Chisholm', 'timothy@chisintl.com', '416-807-3638', 'Managing Partner', 'agent', 'tim-chisholm', 'Company: Chisholm & Partners International Inc.');

-- Also add Bernie as super_admin
INSERT INTO users (full_name, email, phone, role, referral_slug) VALUES
  ('Bernie Shimkovitz', 'bernie@alliancefinancing.com', '416-569-2899', 'super_admin', NULL);

-- ============================================================================
-- VENDORS (from Vendors sheet — 7 records)
-- ============================================================================

INSERT INTO vendors (name, website, product_description, country, territory, status) VALUES
  ('Solum Group', 'solumsp.com', 'Electronic Shelf Labels', 'Canada', 'Canada and United States', 'Active'),
  ('Natural Management Inc', 'naturalmgmt.com', 'Robots', 'Canada', 'Canada and United States', 'Active'),
  ('Smartfit', 'smartfitinc.com', 'Brain Stimulation Solutions', 'Canada', 'Canada and United States', 'Active'),
  ('Cerio', 'cerio.io', 'Data Centre Solutions', 'Canada', 'Canada and United States', 'Active'),
  ('Ebury', 'ebury.com', 'FX & Trade Finance', 'Canada', 'Canada and United States', 'Active'),
  ('SourcePay', 'sourcepay.com', 'Payments', 'Canada', 'Canada and United States', 'Active'),
  ('Livegistics', 'livegistics.com', 'Construction Logistics', 'Canada', 'Canada and United States', 'Active');

-- ============================================================================
-- VENDOR CONTACTS (from Vendor Contacts sheet)
-- ============================================================================

INSERT INTO vendor_contacts (vendor_id, contact_name, role_title, email, phone, territory, is_primary)
SELECT v.id, c.name, c.title, c.email, c.phone, c.territory, c.is_primary
FROM vendors v, (VALUES
  ('Solum Group', 'Alex Walderman', 'Strategic Accounts Lead', 'awalderman@solum-group.com', '647-302-8064', 'Canada and United States', TRUE),
  ('Natural Management Inc', 'Greg Staley', 'President', 'greg@naturalmgmt.com', '705-791-7525', 'Canada and United States', TRUE),
  ('Smartfit', 'Tom West', 'VP', 'tom@smartfitinc.com', '714-271-7266', 'Canada and United States', TRUE),
  ('Cerio', 'Greg Fielding', 'Chief Operating Officer', 'gfielding@cerio.io', NULL, 'Canada and United States', TRUE),
  ('Cerio', 'Andres Sosa', 'VP Products', 'asosa@cerio.io', NULL, 'Canada and United States', FALSE),
  ('Ebury', 'Charlie Marshall', 'Sales Director', 'charlie.marshall@ebury.com', NULL, 'Canada and United States', TRUE),
  ('Ebury', 'Sabrina Nobile', 'Senior Sales Manager', 'sabrina.nobile@ebury.com', '437-988-6459', 'Canada and United States', FALSE),
  ('SourcePay', 'Jordan Dys', 'CEO', 'jordan@sourcepay.com', '343-344-8006', 'Canada and United States', TRUE),
  ('Livegistics', 'Mark Cosentino', 'VP Business Development', 'mark@livegistics.com', '833-548-3556', 'Canada and United States', TRUE)
) AS c(vendor_name, name, title, email, phone, territory, is_primary)
WHERE v.name = c.vendor_name;

-- ============================================================================
-- REAL APPLICATIONS (from New Applications — test data removed)
-- Only keeping records with real business info
-- ============================================================================

-- Note: The sheet had mostly test submissions from Bernie and Paul testing the system.
-- The few real-looking ones are preserved below. You may want to review these.

INSERT INTO applications (application_id, full_name, email, phone, business_name, time_in_business, annual_revenue, funding_amount_text, description, status, submitted_at) VALUES
  ('AF-0015', 'Paul Morrison', 'paul@approvedfinancing.ca', '204-952-6460', 'Approved Financing Centre', '2 - 5 years', '$5M - $10M', '1000000', 'Mortgage', 'Application Received', '2026-02-06 15:34:42'),
  ('AF-0017', 'Paul Morrison', 'pjmorrison@alliancefinancing.com', '204-952-6460', 'Big Time', '2 - 5 years', '$1m - $5M', '1000000', 'Growth', 'Application Received', '2026-02-18 11:33:20'),
  ('AF-0018', 'Paul Morrison', 'paul@approvedfinancing.ca', '204-952-6460', 'Big Time', '2 - 5 years', '$1m - $5M', 'Refinancing Commercial Property - 1.3 million', '1.3 million', 'Application Received', '2026-02-18 11:56:20');

-- ============================================================================
-- DEALS (from Deal Pipeline — 5 real deals)
-- ============================================================================

-- We need to reference agent IDs, so we use subqueries
INSERT INTO deals (company_name, deal_amount, currency, product_type, is_syndicated, status, date_submitted, expected_close_month, gross_fee_pct, alliance_fee, agent_fee_pct, agent_fee_amount, alliance_net_fee, source_agent_id, assigned_lender_id) VALUES
  ('Canadian Canning', 2900000, 'CAD', 'Equipment Leasing', FALSE, 'In funding', '2025-11-01', 'April', 0.015, 43500, 0.005, 14500, 29000,
    (SELECT id FROM users WHERE email = 'Ania.piekarska@nacora.com'),
    (SELECT id FROM lenders WHERE lender_id = 'EL-001')),
  ('Mada', 6000000, 'CAD', 'Commercial Mortgage', FALSE, 'Info received', '2026-01-22', 'February', NULL, NULL, NULL, NULL, NULL,
    NULL, -- Kyle Wilson not yet in users table as agent
    NULL),
  ('Touchbistro', 2600000, 'USD', 'Equipment Leasing', FALSE, 'Prospect', '2026-01-28', 'March', NULL, NULL, NULL, NULL, NULL,
    NULL,
    (SELECT id FROM lenders WHERE lender_id = 'EL-001')),
  ('Vermillion Growers', NULL, 'CAD', NULL, FALSE, 'Prospect', NULL, NULL, NULL, NULL, NULL, NULL, NULL,
    (SELECT id FROM users WHERE email = 'pjmorrison@alliancefinancing.com'),
    NULL),
  ('Ash Bassili', NULL, 'CAD', NULL, FALSE, 'Prospect', NULL, NULL, NULL, NULL, NULL, NULL, NULL,
    (SELECT id FROM users WHERE email = 'rlakhan@meadowbankasset.com'),
    NULL);

-- ============================================================================
-- DEAL SYNDICATION (from Deal_Syndication sheet)
-- ============================================================================

INSERT INTO deal_syndication (deal_id, lender_id, amount_contributed)
SELECT d.id, l.id, 2900000
FROM deals d, lenders l
WHERE d.company_name = 'Canadian Canning' AND l.lender_id = 'EL-001';

-- ============================================================================
-- CLIENT CONTACTS (from Client Contact sheet)
-- ============================================================================

INSERT INTO client_contacts (deal_id, company_name, contact_name, title, email, phone)
SELECT d.id, c.company, c.name, c.title, c.email, c.phone
FROM deals d, (VALUES
  ('Mada', 'Mada', 'Jayne Nagy', 'Owner', 'jaynenagy@gmail.com', '647-668-8264'),
  ('Vermillion Growers', 'Vermillion Growers', 'Maria Deschauer', 'Managing Director', 'maria@vermilliongrowers.com', '204-392-4081'),
  ('Touchbistro', 'Touchbistro', 'Will Santos', 'Sr. Manager Supply Chain Operations', 'WSantos@touchbistro.com', '855-363-5252')
) AS c(deal_name, company, name, title, email, phone)
WHERE d.company_name = c.deal_name;

-- ============================================================================
-- CONTACT FORM SUBMISSIONS (from Contact US sheet — removing test entries)
-- Only keeping entries that look like real inquiries
-- Note: All current entries appear to be test submissions from Bernie.
-- These are included for reference but can be deleted.
-- ============================================================================

-- No real contact submissions to migrate (all were test data from Bernie).

-- ============================================================================
-- MIGRATION COMPLETE
-- ============================================================================
-- Summary:
--   Lenders:          14 records
--   Lender Contacts:  13 records
--   Agents/Users:     11 records (10 agents + 1 super_admin)
--   Vendors:           7 records
--   Vendor Contacts:   9 records
--   Applications:      3 records (test data removed)
--   Deals:             5 records
--   Deal Syndication:  1 record
--   Client Contacts:   3 records
-- ============================================================================
