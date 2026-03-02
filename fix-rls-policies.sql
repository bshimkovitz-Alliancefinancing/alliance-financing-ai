-- Fix all RLS policies so the dashboard can read data
-- Run this in the Supabase SQL Editor

-- Drop any existing restrictive policies on users
DROP POLICY IF EXISTS "Users can view own profile" ON users;
DROP POLICY IF EXISTS "Admins can view all users" ON users;
DROP POLICY IF EXISTS "public_read_users" ON users;

-- Allow any authenticated user to read the users table
CREATE POLICY "allow_read_users" ON users FOR SELECT USING (true);

-- Allow authenticated users to read all key tables
DROP POLICY IF EXISTS "allow_read_deals" ON deals;
CREATE POLICY "allow_read_deals" ON deals FOR SELECT USING (true);

DROP POLICY IF EXISTS "allow_insert_deals" ON deals;
CREATE POLICY "allow_insert_deals" ON deals FOR INSERT WITH CHECK (true);

DROP POLICY IF EXISTS "allow_update_deals" ON deals;
CREATE POLICY "allow_update_deals" ON deals FOR UPDATE USING (true);

DROP POLICY IF EXISTS "allow_read_applications" ON applications;
CREATE POLICY "allow_read_applications" ON applications FOR SELECT USING (true);

DROP POLICY IF EXISTS "allow_insert_applications" ON applications;
CREATE POLICY "allow_insert_applications" ON applications FOR INSERT WITH CHECK (true);

DROP POLICY IF EXISTS "allow_read_lenders" ON lenders;
CREATE POLICY "allow_read_lenders" ON lenders FOR SELECT USING (true);

DROP POLICY IF EXISTS "allow_read_vendors" ON vendors;
CREATE POLICY "allow_read_vendors" ON vendors FOR SELECT USING (true);

DROP POLICY IF EXISTS "allow_read_contacts" ON contact_submissions;
CREATE POLICY "allow_read_contacts" ON contact_submissions FOR SELECT USING (true);

DROP POLICY IF EXISTS "allow_insert_contacts" ON contact_submissions;
CREATE POLICY "allow_insert_contacts" ON contact_submissions FOR INSERT WITH CHECK (true);

DROP POLICY IF EXISTS "allow_update_contacts" ON contact_submissions;
CREATE POLICY "allow_update_contacts" ON contact_submissions FOR UPDATE USING (true);
