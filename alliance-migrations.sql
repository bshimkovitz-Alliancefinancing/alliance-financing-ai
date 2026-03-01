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
