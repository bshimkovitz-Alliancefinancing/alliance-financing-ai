-- ============================================================================
-- ALLIANCE FINANCING AI — Supabase PostgreSQL Schema v1.0
-- ============================================================================
-- This schema replaces the Google Sheets database with a proper relational
-- database designed for multi-tenancy, role-based access, and scale.
-- ============================================================================

-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ============================================================================
-- ENUM TYPES (replaces the Settings sheet dropdown values)
-- ============================================================================

CREATE TYPE deal_status AS ENUM (
  'Prospect',
  'Quote sent',
  'Info received',
  'In Credit',
  'Approved',
  'Approval sent',
  'Docs requested',
  'Docs out for signing',
  'In funding',
  'Funded',
  'Declined',
  'Dead approval'
);

CREATE TYPE product_type AS ENUM (
  'Equipment Leasing',
  'MCA',
  'CSBFL',
  'SRED',
  'Private Debt',
  'Factoring',
  'Merchant Advance',
  'Commercial Mortgage',
  'SBA',
  'Loans',
  'Trade Finance'
);

CREATE TYPE currency_code AS ENUM ('CAD', 'USD', 'GBP', 'EUR');

CREATE TYPE country_name AS ENUM ('Canada', 'United States', 'UK', 'Germany');

CREATE TYPE lender_type AS ENUM ('Lender', 'Broker');

CREATE TYPE agent_status AS ENUM ('AIA', 'MOU', 'Active', 'Inactive', 'Pending');

CREATE TYPE agent_business_type AS ENUM (
  'Mortgage Agent',
  'Mortgage Broker',
  'Insurance',
  'Consulting',
  'Accounting',
  'Other'
);

CREATE TYPE application_status AS ENUM (
  'Application Received',
  'Under Review',
  'Additional Info Requested',
  'Submitted to Lender',
  'Approved',
  'Declined',
  'Funded',
  'Withdrawn'
);

CREATE TYPE time_in_business AS ENUM (
  'Less than 1 Year',
  '1 - 2 years',
  '2 - 5 years',
  '5 - 10 years',
  'Over 10 years'
);

CREATE TYPE revenue_range AS ENUM (
  'Under $500k',
  '$500k - $1m',
  '$1m - $5M',
  '$5M - $10M',
  '$10M - $25M',
  'Over $25m'
);

-- ============================================================================
-- ORGANIZATIONS (multi-tenancy foundation)
-- ============================================================================
-- Represents Alliance itself, agent firms, and syndication partners (banks/CUs)

CREATE TABLE organizations (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  org_type TEXT NOT NULL CHECK (org_type IN ('alliance', 'agent_firm', 'syndication_partner', 'vendor')),
  website TEXT,
  country country_name,
  territory TEXT,
  status TEXT DEFAULT 'Active',
  branding JSONB DEFAULT '{}',  -- logo_url, colors, custom_domain for white-label
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================================
-- USERS (authentication & role-based access)
-- ============================================================================

CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  auth_id UUID UNIQUE,  -- links to Supabase Auth user
  organization_id UUID REFERENCES organizations(id),
  email TEXT NOT NULL UNIQUE,
  full_name TEXT NOT NULL,
  phone TEXT,
  title TEXT,
  role TEXT NOT NULL CHECK (role IN ('super_admin', 'admin', 'agent', 'institutional_user', 'applicant')),
  is_active BOOLEAN DEFAULT TRUE,
  linkedin_profile TEXT,
  referral_slug TEXT UNIQUE,  -- e.g., 'paul-morrison' for /paul-morrison URLs
  referred_by UUID REFERENCES users(id),
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_org ON users(organization_id);
CREATE INDEX idx_users_referral_slug ON users(referral_slug);

-- ============================================================================
-- LENDERS (your 70+ lending partner network)
-- ============================================================================

CREATE TABLE lenders (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  lender_id TEXT UNIQUE NOT NULL,  -- e.g., EL-001, MCA-001 (preserves your existing IDs)
  name TEXT NOT NULL,
  lender_type lender_type NOT NULL DEFAULT 'Lender',
  country country_name,
  currency currency_code DEFAULT 'CAD',
  min_loan NUMERIC,
  max_loan NUMERIC,
  status TEXT DEFAULT 'Active',
  ai_metadata JSONB DEFAULT '{}',  -- for AI matching criteria
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Junction table: which products each lender offers
CREATE TABLE lender_products (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  lender_id UUID REFERENCES lenders(id) ON DELETE CASCADE,
  product product_type NOT NULL,
  UNIQUE(lender_id, product)
);

CREATE INDEX idx_lender_products_lender ON lender_products(lender_id);
CREATE INDEX idx_lender_products_product ON lender_products(product);

-- ============================================================================
-- LENDER CONTACTS
-- ============================================================================

CREATE TABLE lender_contacts (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  lender_id UUID REFERENCES lenders(id) ON DELETE CASCADE,
  contact_name TEXT NOT NULL,
  role_title TEXT,
  email TEXT,
  phone TEXT,
  territory TEXT,
  linkedin_profile TEXT,
  login_info TEXT,  -- encrypted credentials reference
  is_primary BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_lender_contacts_lender ON lender_contacts(lender_id);

-- ============================================================================
-- VENDORS (equipment/product vendors in your programs)
-- ============================================================================

CREATE TABLE vendors (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  organization_id UUID REFERENCES organizations(id),
  name TEXT NOT NULL,
  website TEXT,
  product_description TEXT,
  country country_name,
  territory TEXT,
  primary_agent_id UUID REFERENCES users(id),
  alliance_support_id UUID REFERENCES users(id),
  status TEXT DEFAULT 'Active',
  ai_metadata JSONB DEFAULT '{}',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================================
-- VENDOR CONTACTS
-- ============================================================================

CREATE TABLE vendor_contacts (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  vendor_id UUID REFERENCES vendors(id) ON DELETE CASCADE,
  contact_name TEXT NOT NULL,
  role_title TEXT,
  email TEXT,
  phone TEXT,
  territory TEXT,
  linkedin_profile TEXT,
  is_primary BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_vendor_contacts_vendor ON vendor_contacts(vendor_id);

-- ============================================================================
-- APPLICATIONS (funding applications from website & agent referrals)
-- ============================================================================

CREATE TABLE applications (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  application_id TEXT UNIQUE,  -- AF-XXXX format (auto-generated)

  -- Applicant info
  full_name TEXT NOT NULL,
  email TEXT NOT NULL,
  phone TEXT,
  business_name TEXT,
  time_in_business time_in_business,
  annual_revenue revenue_range,

  -- Financing details
  funding_amount_requested NUMERIC,
  funding_amount_text TEXT,  -- preserves free-text amounts like "1.3 million"
  description TEXT,

  -- Tracking
  status application_status DEFAULT 'Application Received',
  source_agent_id UUID REFERENCES users(id),  -- which agent referred this
  source_channel TEXT DEFAULT 'direct',  -- 'direct', 'agent', 'syndication'
  referral_slug TEXT,  -- which agent URL they came through

  -- Metadata
  submitted_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Junction table: which products the applicant needs
CREATE TABLE application_products (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  application_id UUID REFERENCES applications(id) ON DELETE CASCADE,
  product product_type NOT NULL,
  UNIQUE(application_id, product)
);

CREATE INDEX idx_applications_status ON applications(status);
CREATE INDEX idx_applications_agent ON applications(source_agent_id);
CREATE INDEX idx_applications_submitted ON applications(submitted_at);
CREATE INDEX idx_application_products_app ON application_products(application_id);

-- Auto-generate Application ID sequence
CREATE SEQUENCE application_id_seq START WITH 19;  -- next after AF-0018

CREATE OR REPLACE FUNCTION generate_application_id()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.application_id IS NULL THEN
    NEW.application_id := 'AF-' || LPAD(nextval('application_id_seq')::TEXT, 4, '0');
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER set_application_id
  BEFORE INSERT ON applications
  FOR EACH ROW
  EXECUTE FUNCTION generate_application_id();

-- ============================================================================
-- DEALS (the pipeline — connects applications to lenders and agents)
-- ============================================================================

CREATE TABLE deals (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  deal_number TEXT UNIQUE,  -- auto-generated deal reference

  -- Core deal info
  company_name TEXT NOT NULL,
  deal_amount NUMERIC,
  currency currency_code DEFAULT 'CAD',
  product_type product_type,
  is_syndicated BOOLEAN DEFAULT FALSE,

  -- Relationships
  application_id UUID REFERENCES applications(id),
  source_agent_id UUID REFERENCES users(id),
  assigned_lender_id UUID REFERENCES lenders(id),

  -- Status & timeline
  status deal_status DEFAULT 'Prospect',
  date_submitted DATE,
  expected_close_month TEXT,
  close_date DATE,

  -- Fee structure
  gross_fee_pct NUMERIC,        -- e.g., 0.015 = 1.5%
  alliance_fee NUMERIC,         -- calculated: deal_amount * gross_fee_pct
  agent_fee_pct NUMERIC,        -- e.g., 0.005 = 0.5%
  agent_fee_amount NUMERIC,     -- calculated: deal_amount * agent_fee_pct
  alliance_net_fee NUMERIC,     -- calculated: alliance_fee - agent_fee_amount

  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_deals_status ON deals(status);
CREATE INDEX idx_deals_agent ON deals(source_agent_id);
CREATE INDEX idx_deals_lender ON deals(assigned_lender_id);

-- Auto-generate deal numbers
CREATE SEQUENCE deal_number_seq START WITH 6;

CREATE OR REPLACE FUNCTION generate_deal_number()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.deal_number IS NULL THEN
    NEW.deal_number := 'DEAL-' || LPAD(nextval('deal_number_seq')::TEXT, 4, '0');
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER set_deal_number
  BEFORE INSERT ON deals
  FOR EACH ROW
  EXECUTE FUNCTION generate_deal_number();

-- ============================================================================
-- DEAL SYNDICATION (when a deal is split across multiple lenders)
-- ============================================================================

CREATE TABLE deal_syndication (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  deal_id UUID REFERENCES deals(id) ON DELETE CASCADE,
  lender_id UUID REFERENCES lenders(id),
  amount_contributed NUMERIC,
  participation_pct NUMERIC,
  status TEXT DEFAULT 'Pending',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_deal_syndication_deal ON deal_syndication(deal_id);

-- ============================================================================
-- CLIENT CONTACTS (contacts associated with deals)
-- ============================================================================

CREATE TABLE client_contacts (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  deal_id UUID REFERENCES deals(id) ON DELETE CASCADE,
  company_name TEXT,
  contact_name TEXT NOT NULL,
  title TEXT,
  email TEXT,
  phone TEXT,
  is_primary BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_client_contacts_deal ON client_contacts(deal_id);

-- ============================================================================
-- CONTACT SUBMISSIONS (website contact form)
-- ============================================================================

CREATE TABLE contact_submissions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  email TEXT NOT NULL,
  phone TEXT,
  subject TEXT,
  message TEXT,
  is_read BOOLEAN DEFAULT FALSE,
  submitted_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================================
-- DOCUMENTS (file uploads — Phase 2)
-- ============================================================================

CREATE TABLE documents (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  application_id UUID REFERENCES applications(id),
  deal_id UUID REFERENCES deals(id),
  uploaded_by UUID REFERENCES users(id),
  file_name TEXT NOT NULL,
  file_path TEXT NOT NULL,  -- Supabase Storage path
  file_type TEXT,
  file_size_bytes BIGINT,
  document_type TEXT,  -- 'financial_statement', 'tax_return', 'bank_statement', etc.
  ai_extracted_data JSONB DEFAULT '{}',
  uploaded_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_documents_application ON documents(application_id);
CREATE INDEX idx_documents_deal ON documents(deal_id);

-- ============================================================================
-- COMMISSIONS (agent fee tracking — Phase 2)
-- ============================================================================

CREATE TABLE commissions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  deal_id UUID REFERENCES deals(id),
  agent_id UUID REFERENCES users(id),
  deal_amount NUMERIC,
  commission_pct NUMERIC,
  commission_amount NUMERIC,
  status TEXT DEFAULT 'Pending' CHECK (status IN ('Pending', 'Approved', 'Paid', 'Cancelled')),
  paid_date DATE,
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_commissions_agent ON commissions(agent_id);
CREATE INDEX idx_commissions_deal ON commissions(deal_id);

-- ============================================================================
-- COMMUNICATIONS LOG (email/notification tracking)
-- ============================================================================

CREATE TABLE communications (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  related_to_type TEXT CHECK (related_to_type IN ('application', 'deal', 'agent', 'contact')),
  related_to_id UUID,
  channel TEXT CHECK (channel IN ('email', 'sms', 'system')),
  direction TEXT CHECK (direction IN ('inbound', 'outbound')),
  subject TEXT,
  body TEXT,
  recipient_email TEXT,
  status TEXT DEFAULT 'sent',
  sent_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================================
-- ACTIVITY LOG (audit trail for compliance)
-- ============================================================================

CREATE TABLE activity_log (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id),
  action TEXT NOT NULL,
  entity_type TEXT NOT NULL,
  entity_id UUID,
  details JSONB DEFAULT '{}',
  ip_address INET,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_activity_log_entity ON activity_log(entity_type, entity_id);
CREATE INDEX idx_activity_log_user ON activity_log(user_id);

-- ============================================================================
-- AUTO-UPDATE TIMESTAMPS
-- ============================================================================

CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_organizations_timestamp BEFORE UPDATE ON organizations FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER update_users_timestamp BEFORE UPDATE ON users FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER update_lenders_timestamp BEFORE UPDATE ON lenders FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER update_vendors_timestamp BEFORE UPDATE ON vendors FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER update_applications_timestamp BEFORE UPDATE ON applications FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER update_deals_timestamp BEFORE UPDATE ON deals FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- ============================================================================
-- ROW LEVEL SECURITY (RLS) — multi-tenant data isolation
-- ============================================================================

ALTER TABLE organizations ENABLE ROW LEVEL SECURITY;
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE lenders ENABLE ROW LEVEL SECURITY;
ALTER TABLE lender_contacts ENABLE ROW LEVEL SECURITY;
ALTER TABLE vendors ENABLE ROW LEVEL SECURITY;
ALTER TABLE vendor_contacts ENABLE ROW LEVEL SECURITY;
ALTER TABLE applications ENABLE ROW LEVEL SECURITY;
ALTER TABLE deals ENABLE ROW LEVEL SECURITY;
ALTER TABLE deal_syndication ENABLE ROW LEVEL SECURITY;
ALTER TABLE client_contacts ENABLE ROW LEVEL SECURITY;
ALTER TABLE contact_submissions ENABLE ROW LEVEL SECURITY;
ALTER TABLE documents ENABLE ROW LEVEL SECURITY;
ALTER TABLE commissions ENABLE ROW LEVEL SECURITY;
ALTER TABLE activity_log ENABLE ROW LEVEL SECURITY;

-- Super admins (Alliance team) can see everything
CREATE POLICY admin_all_organizations ON organizations FOR ALL
  USING (EXISTS (SELECT 1 FROM users WHERE users.auth_id = auth.uid() AND users.role = 'super_admin'));

CREATE POLICY admin_all_users ON users FOR ALL
  USING (EXISTS (SELECT 1 FROM users u WHERE u.auth_id = auth.uid() AND u.role = 'super_admin'));

CREATE POLICY admin_all_lenders ON lenders FOR ALL
  USING (EXISTS (SELECT 1 FROM users WHERE users.auth_id = auth.uid() AND users.role IN ('super_admin', 'admin')));

CREATE POLICY admin_all_applications ON applications FOR ALL
  USING (EXISTS (SELECT 1 FROM users WHERE users.auth_id = auth.uid() AND users.role IN ('super_admin', 'admin')));

CREATE POLICY admin_all_deals ON deals FOR ALL
  USING (EXISTS (SELECT 1 FROM users WHERE users.auth_id = auth.uid() AND users.role IN ('super_admin', 'admin')));

-- Agents can only see their own referrals and deals
CREATE POLICY agent_own_applications ON applications FOR SELECT
  USING (
    EXISTS (SELECT 1 FROM users WHERE users.auth_id = auth.uid() AND users.role = 'agent' AND users.id = applications.source_agent_id)
  );

CREATE POLICY agent_own_deals ON deals FOR SELECT
  USING (
    EXISTS (SELECT 1 FROM users WHERE users.auth_id = auth.uid() AND users.role = 'agent' AND users.id = deals.source_agent_id)
  );

CREATE POLICY agent_own_commissions ON commissions FOR SELECT
  USING (
    EXISTS (SELECT 1 FROM users WHERE users.auth_id = auth.uid() AND users.role = 'agent' AND users.id = commissions.agent_id)
  );

-- ============================================================================
-- VIEWS (convenient queries for the admin dashboard)
-- ============================================================================

-- Deal pipeline with agent and lender names
CREATE VIEW deal_pipeline_view AS
SELECT
  d.*,
  u.full_name AS agent_name,
  u.email AS agent_email,
  l.name AS lender_name,
  l.lender_id AS lender_code,
  a.application_id AS app_number
FROM deals d
LEFT JOIN users u ON d.source_agent_id = u.id
LEFT JOIN lenders l ON d.assigned_lender_id = l.id
LEFT JOIN applications a ON d.application_id = a.id
ORDER BY d.created_at DESC;

-- Agent performance summary
CREATE VIEW agent_performance_view AS
SELECT
  u.id AS agent_id,
  u.full_name AS agent_name,
  u.email,
  u.referral_slug,
  COUNT(DISTINCT d.id) AS total_deals,
  COUNT(DISTINCT d.id) FILTER (WHERE d.status = 'Funded') AS funded_deals,
  COALESCE(SUM(d.deal_amount) FILTER (WHERE d.status = 'Funded'), 0) AS total_funded_volume,
  COALESCE(SUM(d.agent_fee_amount) FILTER (WHERE d.status = 'Funded'), 0) AS total_commissions_earned,
  COUNT(DISTINCT a.id) AS total_referrals
FROM users u
LEFT JOIN deals d ON u.id = d.source_agent_id
LEFT JOIN applications a ON u.id = a.source_agent_id
WHERE u.role = 'agent'
GROUP BY u.id, u.full_name, u.email, u.referral_slug;

-- Application summary with products
CREATE VIEW application_summary_view AS
SELECT
  a.*,
  u.full_name AS agent_name,
  ARRAY_AGG(ap.product) FILTER (WHERE ap.product IS NOT NULL) AS products_needed
FROM applications a
LEFT JOIN users u ON a.source_agent_id = u.id
LEFT JOIN application_products ap ON a.id = ap.id
GROUP BY a.id, u.full_name
ORDER BY a.submitted_at DESC;

-- ============================================================================
-- SEED DATA: Alliance organization
-- ============================================================================

INSERT INTO organizations (name, org_type, website, country, status)
VALUES ('Alliance Financing Group Ltd.', 'alliance', 'alliancefinancing.ai', 'Canada', 'Active');
