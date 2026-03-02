-- =============================================
-- Alliance Financing Group — Database Migrations
-- Run in Supabase SQL Editor
-- =============================================

-- Agent onboarding columns on users table
ALTER TABLE users ADD COLUMN IF NOT EXISTS agent_type TEXT DEFAULT 'referring_agent';
ALTER TABLE users ADD COLUMN IF NOT EXISTS invite_token UUID;
ALTER TABLE users ADD COLUMN IF NOT EXISTS invite_sent_at TIMESTAMPTZ;
ALTER TABLE users ADD COLUMN IF NOT EXISTS invite_accepted_at TIMESTAMPTZ;
ALTER TABLE users ADD COLUMN IF NOT EXISTS onboarding_status TEXT DEFAULT 'active';
ALTER TABLE users ADD COLUMN IF NOT EXISTS commission_type TEXT DEFAULT 'referral_fee';
ALTER TABLE users ADD COLUMN IF NOT EXISTS company_name TEXT;
ALTER TABLE users ADD COLUMN IF NOT EXISTS company_logo_url TEXT;
ALTER TABLE users ADD COLUMN IF NOT EXISTS program_details JSONB DEFAULT '{}';

-- Quote request details stored on deals table
ALTER TABLE deals ADD COLUMN IF NOT EXISTS program_details JSONB DEFAULT '{}';

-- =============================================
-- AI Lender Matching — Lender Criteria Columns
-- =============================================
ALTER TABLE lenders ADD COLUMN IF NOT EXISTS preferred_products TEXT[] DEFAULT '{}';
ALTER TABLE lenders ADD COLUMN IF NOT EXISTS consider_products TEXT[] DEFAULT '{}';
ALTER TABLE lenders ADD COLUMN IF NOT EXISTS min_deal_size NUMERIC;
ALTER TABLE lenders ADD COLUMN IF NOT EXISTS max_deal_size NUMERIC;
ALTER TABLE lenders ADD COLUMN IF NOT EXISTS min_credit_score INTEGER;
ALTER TABLE lenders ADD COLUMN IF NOT EXISTS min_time_in_business NUMERIC;
ALTER TABLE lenders ADD COLUMN IF NOT EXISTS min_annual_revenue NUMERIC;
ALTER TABLE lenders ADD COLUMN IF NOT EXISTS approval_speed TEXT;
ALTER TABLE lenders ADD COLUMN IF NOT EXISTS restricted_industries TEXT;
ALTER TABLE lenders ADD COLUMN IF NOT EXISTS covered_regions TEXT;
ALTER TABLE lenders ADD COLUMN IF NOT EXISTS rate_range TEXT;
ALTER TABLE lenders ADD COLUMN IF NOT EXISTS special_notes TEXT;
ALTER TABLE lenders ADD COLUMN IF NOT EXISTS terms_offered INT[] DEFAULT '{}';
ALTER TABLE lenders ADD COLUMN IF NOT EXISTS purchase_options TEXT[] DEFAULT '{}';

-- =============================================
-- AI Lender Matching — Deal Profile Columns
-- =============================================
ALTER TABLE deals ADD COLUMN IF NOT EXISTS client_credit_score INTEGER;
ALTER TABLE deals ADD COLUMN IF NOT EXISTS client_time_in_business NUMERIC;
ALTER TABLE deals ADD COLUMN IF NOT EXISTS client_annual_revenue NUMERIC;
ALTER TABLE deals ADD COLUMN IF NOT EXISTS client_industry TEXT;
ALTER TABLE deals ADD COLUMN IF NOT EXISTS client_province TEXT;
ALTER TABLE deals ADD COLUMN IF NOT EXISTS requested_term INTEGER;
ALTER TABLE deals ADD COLUMN IF NOT EXISTS requested_purchase_option TEXT;

-- =============================================
-- Document Management — Documents Table
-- =============================================
CREATE TABLE IF NOT EXISTS documents (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    deal_id UUID REFERENCES deals(id) ON DELETE CASCADE,
    application_id UUID REFERENCES applications(id) ON DELETE CASCADE,
    file_name TEXT NOT NULL,
    file_path TEXT NOT NULL,
    file_type TEXT,
    file_size_bytes BIGINT,
    document_type TEXT DEFAULT 'other',
    notes TEXT,
    uploaded_by UUID,
    uploaded_by_name TEXT,
    visible_to_agent BOOLEAN DEFAULT false,
    uploaded_at TIMESTAMPTZ DEFAULT now(),
    created_at TIMESTAMPTZ DEFAULT now()
);

-- Index for faster lookups by deal
CREATE INDEX IF NOT EXISTS idx_documents_deal_id ON documents(deal_id);
CREATE INDEX IF NOT EXISTS idx_documents_application_id ON documents(application_id);
CREATE INDEX IF NOT EXISTS idx_documents_uploaded_at ON documents(uploaded_at DESC);

-- =============================================
-- Document Management — Storage Bucket
-- =============================================
-- NOTE: You must also create a storage bucket in Supabase:
-- 1. Go to Storage in Supabase sidebar
-- 2. Click "New Bucket"
-- 3. Name: deal-documents
-- 4. Toggle "Public bucket" ON (or configure RLS policies)
-- 5. Set file size limit: 10MB
-- 6. Allowed MIME types: application/pdf, image/png, image/jpeg, image/gif,
--    application/msword, application/vnd.openxmlformats-officedocument.wordprocessingml.document,
--    application/vnd.ms-excel, application/vnd.openxmlformats-officedocument.spreadsheetml.sheet,
--    text/csv

-- Storage policy to allow uploads with anon key (if bucket is not public)
-- INSERT INTO storage.policies (name, bucket_id, operation, definition)
-- VALUES ('Allow uploads', 'deal-documents', 'INSERT', 'true');
-- INSERT INTO storage.policies (name, bucket_id, operation, definition)
-- VALUES ('Allow reads', 'deal-documents', 'SELECT', 'true');
-- INSERT INTO storage.policies (name, bucket_id, operation, definition)
-- VALUES ('Allow deletes', 'deal-documents', 'DELETE', 'true');

-- =============================================
-- Document archiving (soft-delete — no files ever removed)
-- =============================================
ALTER TABLE documents ADD COLUMN IF NOT EXISTS archived BOOLEAN DEFAULT false;
CREATE INDEX IF NOT EXISTS idx_documents_archived ON documents(archived);

-- Lender documents — reuse documents table with lender_id reference
ALTER TABLE documents ADD COLUMN IF NOT EXISTS lender_id UUID;
CREATE INDEX IF NOT EXISTS idx_documents_lender_id ON documents(lender_id);

-- =============================================
-- Admin Resources table
-- =============================================
CREATE TABLE IF NOT EXISTS admin_resources (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    title TEXT NOT NULL,
    category TEXT DEFAULT 'other',
    access_level TEXT DEFAULT 'admin_only',
    description TEXT,
    resource_type TEXT DEFAULT 'file',
    url TEXT,
    file_path TEXT,
    file_name TEXT,
    file_size_bytes BIGINT,
    uploaded_by UUID,
    uploaded_by_name TEXT,
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_admin_resources_category ON admin_resources(category);
CREATE INDEX IF NOT EXISTS idx_admin_resources_created ON admin_resources(created_at DESC);

-- =============================================
-- Multi-Lender Credit Submissions
-- =============================================
CREATE TABLE IF NOT EXISTS lender_submissions (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    deal_id UUID NOT NULL REFERENCES deals(id) ON DELETE CASCADE,
    lender_id UUID NOT NULL REFERENCES lenders(id) ON DELETE RESTRICT,
    submitted_at TIMESTAMPTZ DEFAULT now(),
    submitted_by UUID,
    submitted_by_name TEXT,
    status TEXT DEFAULT 'Pending',
    approval_amount NUMERIC,
    approval_rate NUMERIC,
    approval_term INTEGER,
    approval_buyout_type TEXT,
    approval_notes TEXT,
    is_selected BOOLEAN DEFAULT false,
    selected_at TIMESTAMPTZ,
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_lender_submissions_deal ON lender_submissions(deal_id);
CREATE INDEX IF NOT EXISTS idx_lender_submissions_lender ON lender_submissions(lender_id);
CREATE INDEX IF NOT EXISTS idx_lender_submissions_status ON lender_submissions(status);
ALTER TABLE lender_submissions DISABLE ROW LEVEL SECURITY;
GRANT ALL ON lender_submissions TO anon;
GRANT ALL ON lender_submissions TO authenticated;
