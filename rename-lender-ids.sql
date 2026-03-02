-- =============================================
-- Rename ALL existing lender IDs to country-based format
-- CA-001, CA-002 (Canada only)
-- US-001, US-002 (United States only)
-- NA-001, NA-002 (Canada + United States)
-- UK-001 (UK only)
-- DE-001 (Germany only)
-- INT-001 (other/multiple)
-- L-001 (no country set)
-- =============================================

-- This uses a CTE to assign sequential numbers per prefix group
-- Run this ONCE to migrate existing lender IDs

WITH prefix_calc AS (
    SELECT
        id,
        lender_id AS old_lender_id,
        name,
        country,
        CASE
            WHEN country ILIKE '%Canada%' AND country NOT ILIKE '%United States%' THEN 'CA'
            WHEN country ILIKE '%United States%' AND country NOT ILIKE '%Canada%' THEN 'US'
            WHEN country ILIKE '%Canada%' AND country ILIKE '%United States%' THEN 'NA'
            WHEN country ILIKE '%UK%' AND country NOT ILIKE '%Canada%' AND country NOT ILIKE '%United States%' THEN 'UK'
            WHEN country ILIKE '%Germany%' AND country NOT ILIKE '%Canada%' AND country NOT ILIKE '%United States%' THEN 'DE'
            WHEN country IS NULL OR country = '' THEN 'L'
            ELSE 'INT'
        END AS prefix
    FROM lenders
),
numbered AS (
    SELECT
        id,
        old_lender_id,
        name,
        country,
        prefix,
        ROW_NUMBER() OVER (PARTITION BY prefix ORDER BY name ASC) AS seq
    FROM prefix_calc
),
new_ids AS (
    SELECT
        id,
        old_lender_id,
        name,
        prefix || '-' || LPAD(seq::TEXT, 3, '0') AS new_lender_id
    FROM numbered
)
UPDATE lenders
SET lender_id = new_ids.new_lender_id
FROM new_ids
WHERE lenders.id = new_ids.id;

-- Verify results
SELECT lender_id, name, country FROM lenders ORDER BY lender_id;
