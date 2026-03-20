-- ============================================================
-- PROJECT: ESG SUSTAINABILITY REPORTING DATA VALIDATOR
-- Author: [Your Name]
-- Tool: PostgreSQL
-- Context: Simulates an EY-style ESG data audit for three
--          Nigerian companies before regulatory filing.
--          Covers Environmental, Social and Governance pillars.
-- ============================================================


-- ============================================================
-- SECTION 1: SCHEMA — CREATE TABLES
-- ============================================================
-- These tables store ESG data across all three pillars.
-- Every table links back to companies via company_id (FOREIGN KEY).
-- NULL is allowed on measurement columns deliberately —
-- missing values are data quality findings, not errors to reject.
-- ============================================================


-- Table: companies
-- Purpose: The anchor table. Every other table references this one.
-- Stores the Nigerian companies whose ESG data is being audited.
CREATE TABLE companies (
    company_id     SERIAL PRIMARY KEY,
    company_name   TEXT    NOT NULL,
    sector         TEXT    NOT NULL,
    country        TEXT    NOT NULL,
    listing_status TEXT    NOT NULL,
    reporting_year INTEGER NOT NULL
);


-- Table: emissions
-- Purpose: Tracks greenhouse gas emissions across Scope 1, 2, and 3.
-- reported_value = what the company submitted.
-- verified_value = what the independent auditor measured.
-- NULL on reported_value means the company never submitted the figure.
CREATE TABLE emissions (
    emission_id    SERIAL PRIMARY KEY,
    company_id     INTEGER NOT NULL REFERENCES companies(company_id),
    scope          TEXT    NOT NULL,
    category       TEXT    NOT NULL,
    reported_value NUMERIC(10,2),
    verified_value NUMERIC(10,2),
    unit           TEXT    NOT NULL DEFAULT 'tCO2e',
    quarter        TEXT    NOT NULL,
    reporting_year INTEGER NOT NULL
);


-- Table: energy_consumption
-- Purpose: Tracks energy use from renewable and non-renewable sources.
-- consumed_mwh allows NULL — missing submissions are audit findings.
-- Negative values are physically impossible and flagged as Critical.
CREATE TABLE energy_consumption (
    energy_consumption_id SERIAL PRIMARY KEY,
    company_id            INTEGER NOT NULL REFERENCES companies(company_id),
    source_type           TEXT    NOT NULL,
    source_name           TEXT    NOT NULL,
    consumed_mwh          NUMERIC(10,2),
    quarter               TEXT    NOT NULL,
    reporting_year        INTEGER NOT NULL
);


-- Table: water_usage
-- Purpose: Tracks water withdrawal, recycling, and discharge volumes.
-- All three volume columns allow NULL — missing data is a finding.
-- recycled_m3 must never exceed withdrawn_m3 — physically impossible.
CREATE TABLE water_usage (
    water_id       SERIAL PRIMARY KEY,
    company_id     INTEGER NOT NULL REFERENCES companies(company_id),
    source         TEXT    NOT NULL,
    withdrawn_m3   NUMERIC(10,2),
    recycled_m3    NUMERIC(10,2),
    discharged_m3  NUMERIC(10,2),
    quarter        TEXT    NOT NULL,
    reporting_year INTEGER NOT NULL
);


-- Table: workforce_diversity
-- Purpose: Tracks gender and disability representation at each org level.
-- org_headcount is NOT NULL — a record with no headcount is meaningless.
-- female_count and male_count allow NULL — missing gender data is a finding.
CREATE TABLE workforce_diversity (
    workforce_diversity_id SERIAL PRIMARY KEY,
    company_id             INTEGER NOT NULL REFERENCES companies(company_id),
    organisation_level     TEXT    NOT NULL,
    org_headcount          INTEGER NOT NULL,
    female_count           INTEGER,
    male_count             INTEGER,
    disability_count       INTEGER,
    reporting_year         INTEGER NOT NULL
);


-- Table: governance_policies
-- Purpose: Tracks whether mandatory ESG governance policies exist and are maintained.
-- policy_last_reviewed allows NULL — a policy never reviewed is a governance weakness.
-- policy_approved_by allows NULL — missing approver means the policy is unowned.
CREATE TABLE governance_policies (
    policy_id            SERIAL PRIMARY KEY,
    company_id           INTEGER NOT NULL REFERENCES companies(company_id),
    policy_name          TEXT    NOT NULL,
    policy_status        TEXT    NOT NULL,
    policy_last_reviewed DATE,
    policy_approved_by   TEXT,
    reporting_year       INTEGER NOT NULL
);


-- ============================================================
-- SECTION 2: SAMPLE DATA — INSERT STATEMENTS
-- ============================================================
-- Realistic data for 5 Nigerian companies across EY's core sectors.
-- 13 deliberate data quality bugs are planted across the tables.
-- Each bug simulates a real error found in manual ESG submissions.
-- ============================================================


-- Companies: 5 Nigerian entities across Oil & Gas, Banking,
-- Telecom, Health, and Energy sectors.
INSERT INTO companies
    (company_name, sector, country, listing_status, reporting_year)
VALUES
    ('Okonkwo Energy PLC',    'Oil & Gas', 'Nigeria', 'Listed',   2024),
    ('FirstCapital Bank Ltd', 'Banking',   'Nigeria', 'Listed',   2024),
    ('ConnectTel Nigeria',    'Telecom',   'Nigeria', 'Unlisted', 2024),
    ('St Luke Hospital',      'Health',    'Nigeria', 'Listed',   2023),
    ('TeKn0wledge Nigeria',   'Energy',    'Nigeria', 'Unlisted', 2022);


-- Emissions data for companies 1, 2, and 3.
-- BUG 1: Okonkwo Energy Scope 3 — reported_value is NULL (never submitted)
-- BUG 2: ConnectTel Scope 4 — invalid scope, GHG Protocol only has Scope 1/2/3
-- BUG 3: ConnectTel Scope 1 Q1 — 53.66% variance between reported and verified
-- BUG 4: FirstCapital Bank Scope 1 Q2 — reported zero emissions for active operations
INSERT INTO emissions
    (company_id, scope, category, reported_value, verified_value, unit, quarter, reporting_year)
VALUES
    (1, 'Scope 1', 'Fuel combustion',      48200.00, 47900.00, 'tCO2e', 'Q1', 2024),
    (1, 'Scope 1', 'Fuel combustion',      51300.00, 51100.00, 'tCO2e', 'Q2', 2024),
    (1, 'Scope 2', 'Electricity purchase', 12400.00, 12400.00, 'tCO2e', 'Q1', 2024),
    (1, 'Scope 3', 'Business travel',          NULL,  1200.00, 'tCO2e', 'Q1', 2024),  -- BUG 1
    (2, 'Scope 1', 'Fuel combustion',        890.00,   885.00, 'tCO2e', 'Q1', 2024),
    (2, 'Scope 1', 'Fuel combustion',          0.00,   910.00, 'tCO2e', 'Q2', 2024),  -- BUG 4
    (2, 'Scope 2', 'Electricity purchase',  3200.00,  3180.00, 'tCO2e', 'Q1', 2024),
    (3, 'Scope 1', 'Fuel combustion',      18900.00, 12300.00, 'tCO2e', 'Q1', 2024),  -- BUG 3
    (3, 'Scope 2', 'Electricity purchase',  5400.00,  5390.00, 'tCO2e', 'Q2', 2024),
    (3, 'Scope 4', 'Unknown category',      1100.00,     NULL, 'tCO2e', 'Q3', 2024);  -- BUG 2


-- Energy consumption data for companies 1, 2, and 3.
-- BUG 5: ConnectTel Diesel Generator Q2 — consumed_mwh is NULL (never submitted)
-- BUG 6: ConnectTel Solar Q2 — negative consumption value, physically impossible
-- BUG 7: ConnectTel Diesel Generator Q2 — exact duplicate of BUG 5 row (double counting)
INSERT INTO energy_consumption
    (company_id, source_type, source_name, consumed_mwh, quarter, reporting_year)
VALUES
    (1, 'Non-Renewable', 'Diesel Generator', 84500.00, 'Q1', 2024),
    (1, 'Non-Renewable', 'Diesel Generator', 87200.00, 'Q2', 2024),
    (1, 'Renewable',     'Solar',             1200.00, 'Q1', 2024),
    (2, 'Non-Renewable', 'EKEDC Grid',       14300.00, 'Q1', 2024),
    (2, 'Renewable',     'Solar',              450.00, 'Q1', 2024),
    (3, 'Non-Renewable', 'Diesel Generator',     NULL, 'Q2', 2024),  -- BUG 5
    (3, 'Renewable',     'Solar',             -300.00, 'Q2', 2024),  -- BUG 6
    (3, 'Non-Renewable', 'Diesel Generator',     NULL, 'Q2', 2024);  -- BUG 7


-- Water usage data for companies 1, 2, and 3.
-- BUG 8: ConnectTel Rainwater Q1 — recycled (4200) exceeds withdrawn (1500), impossible
-- BUG 9: ConnectTel Borehole Q2 — all three values are NULL, empty submission
INSERT INTO water_usage
    (company_id, source, withdrawn_m3, recycled_m3, discharged_m3, quarter, reporting_year)
VALUES
    (1, 'Borehole',   45000.00, 12000.00, 28000.00, 'Q1', 2024),
    (1, 'Municipal',   8200.00,  1500.00,  6000.00, 'Q1', 2024),
    (2, 'Municipal',   3100.00,   800.00,  2100.00, 'Q1', 2024),
    (3, 'Rainwater',   1500.00,  4200.00,   800.00, 'Q1', 2024),  -- BUG 8
    (3, 'Borehole',       NULL,     NULL,     NULL, 'Q2', 2024);  -- BUG 9


-- Workforce diversity data for companies 1, 2, and 3.
-- BUG 10: Okonkwo Energy Staff — female(430) + male(450) = 880, exceeds headcount of 820
-- BUG 11: FirstCapital Bank Senior Mgmt — female_count is NULL, mandatory under Nigerian SEC
INSERT INTO workforce_diversity
    (company_id, organisation_level, org_headcount, female_count, male_count, disability_count, reporting_year)
VALUES
    (1, 'Board',       12,   3,   9,  0, 2024),
    (1, 'Senior Mgmt', 45,  14,  31,  2, 2024),
    (1, 'Staff',      820, 430, 450,  8, 2024),  -- BUG 10
    (2, 'Board',        9,   2,   7,  0, 2024),
    (2, 'Senior Mgmt', 38, NULL,  38,  1, 2024), -- BUG 11
    (3, 'Board',        7,   1,   6,  0, 2024),
    (3, 'Staff',      540, 198, 342, 12, 2024);


-- Governance policies for companies 1, 2, and 3.
-- BUG 12: FirstCapital Bank Anti-Bribery — policy_status = 'No', mandatory under Nigerian law
-- BUG 13: ConnectTel Data Privacy — policy_last_reviewed is NULL, never been reviewed
INSERT INTO governance_policies
    (company_id, policy_name, policy_status, policy_last_reviewed, policy_approved_by, reporting_year)
VALUES
    (1, 'Environmental Policy',      'Yes',         '2024-01-15', 'Board', 2024),
    (1, 'Anti-Bribery & Corruption', 'Yes',         '2023-11-01', 'Board', 2024),
    (2, 'Environmental Policy',      'In Progress', '2024-02-20', 'CEO',   2024),
    (2, 'Anti-Bribery & Corruption', 'No',           NULL,         NULL,   2024),  -- BUG 12
    (3, 'Environmental Policy',      'Yes',         '2024-03-01', 'Board', 2024),
    (3, 'Whistleblower Protection',  'Yes',         '2023-08-14', 'Board', 2024),
    (3, 'Data Privacy Policy',       'Yes',          NULL,        'CEO',   2024);  -- BUG 13


-- ============================================================
-- SECTION 3: AUDIT QUERIES — DATA VALIDATION TEST CASES
-- ============================================================
-- Each query answers a specific business question an EY auditor
-- would ask when validating ESG data before regulatory filing.
-- Findings are labelled by severity: Critical, High, or Medium.
-- ============================================================


-- ------------------------------------------------------------
-- QUERY 1: Missing Emissions Data
-- Severity: CRITICAL
-- ------------------------------------------------------------
-- Business question: Which companies failed to submit their
-- emissions figures, leaving mandatory fields blank?
-- ------------------------------------------------------------
-- Why it matters: Regulators require complete emissions disclosure.
-- A NULL reported value means the company cannot substantiate
-- its emissions claim. The report cannot be filed with gaps.
-- Expected result: Zero rows = clean dataset
-- ------------------------------------------------------------
SELECT
    e.emission_id,
    c.company_name,
    e.scope,
    e.category,
    e.quarter,
    e.reported_value,
    'Missing reported emissions value — cannot file' AS issue
FROM emissions e
JOIN companies c ON e.company_id = c.company_id
WHERE e.reported_value IS NULL;


-- ------------------------------------------------------------
-- QUERY 2: Invalid GHG Scope Categories
-- Severity: HIGH
-- ------------------------------------------------------------
-- Business question: Are all emissions records using a valid
-- GHG Protocol scope (Scope 1, 2, or 3 only)?
-- ------------------------------------------------------------
-- Why it matters: The GHG Protocol defines only three scopes.
-- Any other label is either a data entry error or deliberate
-- misclassification. Both are reportable audit findings.
-- Expected result: Zero rows = all scopes are valid
-- ------------------------------------------------------------
SELECT
    e.emission_id,
    c.company_name,
    e.scope,
    e.category,
    e.quarter,
    'Invalid GHG scope — not Scope 1, 2 or 3' AS issue
FROM emissions e
JOIN companies c ON e.company_id = c.company_id
WHERE e.scope NOT IN ('Scope 1', 'Scope 2', 'Scope 3');


-- ------------------------------------------------------------
-- QUERY 3: Variance Between Reported and Verified Emissions
-- Severity: HIGH
-- ------------------------------------------------------------
-- Business question: Which companies have a gap of more than 5%
-- between what they reported and what the auditor verified?
-- ------------------------------------------------------------
-- Why it matters: EY uses a 5% materiality threshold. A gap
-- above 5% is a material discrepancy that must be investigated.
-- Large variances could indicate greenwashing — deliberately
-- understating or overstating emissions to mislead investors.
-- Expected result: Zero rows = all within acceptable tolerance
-- ------------------------------------------------------------
SELECT
    e.emission_id,
    c.company_name,
    e.scope,
    e.reported_value,
    e.verified_value,
    ROUND(ABS(e.reported_value - e.verified_value) / e.verified_value * 100, 2) AS variance_pct,
    'Variance exceeds 5% materiality threshold' AS issue
FROM emissions e
JOIN companies c ON e.company_id = c.company_id
WHERE e.reported_value IS NOT NULL
  AND e.verified_value IS NOT NULL
  AND ABS(e.reported_value - e.verified_value) / e.verified_value * 100 > 5;


-- ------------------------------------------------------------
-- QUERY 4: Zero Scope 1 Emissions for Active Operations
-- Severity: HIGH
-- ------------------------------------------------------------
-- Business question: Are any active companies reporting zero
-- direct emissions — which is physically impossible?
-- ------------------------------------------------------------
-- Why it matters: All physical operations produce some direct
-- emissions. A zero value for an active company almost certainly
-- means the Q2 data was never submitted — a completeness gap.
-- Expected result: Zero rows = no suspicious zero values
-- ------------------------------------------------------------
SELECT
    e.emission_id,
    c.company_name,
    e.scope,
    e.reported_value,
    e.quarter,
    'Zero Scope 1 emissions reported — not credible for active operations' AS issue
FROM emissions e
JOIN companies c ON e.company_id = c.company_id
WHERE e.reported_value = 0
  AND e.scope = 'Scope 1';


-- ------------------------------------------------------------
-- QUERY 5: NULL or Negative Energy Consumption Values
-- Severity: CRITICAL
-- ------------------------------------------------------------
-- Business question: Are there energy records with missing
-- or physically impossible consumption values?
-- ------------------------------------------------------------
-- Why it matters: NULL means data was never submitted.
-- Negative energy consumption is physically impossible —
-- a company cannot consume less than zero megawatt-hours.
-- Both indicate data collection or submission failures.
-- Expected result: Zero rows = all values present and positive
-- ------------------------------------------------------------
SELECT
    en.energy_consumption_id,
    c.company_name,
    en.source_type,
    en.source_name,
    en.consumed_mwh,
    en.quarter,
    CASE
        WHEN en.consumed_mwh IS NULL THEN 'Missing energy value — not submitted'
        WHEN en.consumed_mwh < 0     THEN 'Negative energy value — physically impossible'
    END AS issue
FROM energy_consumption en
JOIN companies c ON en.company_id = c.company_id
WHERE en.consumed_mwh IS NULL
   OR en.consumed_mwh < 0;


-- ------------------------------------------------------------
-- QUERY 6: Duplicate Energy Records
-- Severity: HIGH
-- ------------------------------------------------------------
-- Business question: Are there energy records submitted more
-- than once for the same company, source, and quarter?
-- ------------------------------------------------------------
-- Why it matters: Duplicate records inflate total energy figures.
-- If a company appears to consume more energy than it does,
-- its environmental footprint is overstated. This is a data
-- management failure — common in manual spreadsheet submissions.
-- Expected result: Zero rows = no duplicates detected
-- ------------------------------------------------------------
SELECT
    c.company_name,
    en.source_type,
    en.source_name,
    en.quarter,
    COUNT(*) AS duplicate_count,
    'Duplicate energy record — will cause double counting' AS issue
FROM energy_consumption en
JOIN companies c ON en.company_id = c.company_id
GROUP BY c.company_name, en.source_type, en.source_name, en.quarter
HAVING COUNT(*) > 1;


-- ------------------------------------------------------------
-- QUERY 7: Water Recycled Exceeds Water Withdrawn
-- Severity: CRITICAL
-- ------------------------------------------------------------
-- Business question: Are there water records where the volume
-- recycled is greater than the volume withdrawn?
-- ------------------------------------------------------------
-- Why it matters: A company cannot recycle water it never had.
-- recycled_m3 > withdrawn_m3 is a logical impossibility —
-- the figures were either entered incorrectly or fabricated.
-- Either scenario invalidates the water data for that record.
-- Expected result: Zero rows = all water figures are logical
-- ------------------------------------------------------------
SELECT
    wt.water_id,
    c.company_name,
    wt.source,
    wt.withdrawn_m3,
    wt.recycled_m3,
    wt.quarter,
    'Recycled water exceeds withdrawn — logically impossible' AS issue
FROM water_usage wt
JOIN companies c ON wt.company_id = c.company_id
WHERE wt.recycled_m3 > wt.withdrawn_m3;


-- ------------------------------------------------------------
-- QUERY 8: Gender Counts Exceed Total Headcount
-- Severity: HIGH
-- ------------------------------------------------------------
-- Business question: Do the female and male headcount figures
-- add up to more than the reported total headcount?
-- ------------------------------------------------------------
-- Why it matters: female + male must never exceed total headcount.
-- If it does, at least one figure is wrong — either the total
-- or the gender breakdown. GRI 405-1 requires accurate gender
-- disaggregation. This must be reconciled with HR source records.
-- Expected result: Zero rows = all headcount arithmetic is correct
-- ------------------------------------------------------------
SELECT
    wd.workforce_diversity_id,
    c.company_name,
    wd.organisation_level,
    wd.org_headcount,
    wd.female_count,
    wd.male_count,
    (wd.female_count + wd.male_count) AS sum_of_genders,
    'Gender counts exceed total headcount — arithmetic error' AS issue
FROM workforce_diversity wd
JOIN companies c ON wd.company_id = c.company_id
WHERE (wd.female_count + wd.male_count) > wd.org_headcount;


-- ------------------------------------------------------------
-- QUERY 9: Missing Gender Data at Leadership Level
-- Severity: HIGH
-- ------------------------------------------------------------
-- Business question: Are Board or Senior Management records
-- missing female headcount data?
-- ------------------------------------------------------------
-- Why it matters: Gender representation at leadership level is
-- mandatory under the Nigerian SEC Code of Corporate Governance
-- and GRI 405-1. NULL at this level is a compliance gap that
-- must be sourced from HR records and corrected before filing.
-- Expected result: Zero rows = all leadership gender data present
-- ------------------------------------------------------------
SELECT
    wd.workforce_diversity_id,
    c.company_name,
    wd.organisation_level,
    wd.org_headcount,
    wd.female_count,
    'Missing female count at leadership level — SEC compliance gap' AS issue
FROM workforce_diversity wd
JOIN companies c ON wd.company_id = c.company_id
WHERE wd.organisation_level IN ('Board', 'Senior Mgmt')
  AND wd.female_count IS NULL;


-- ------------------------------------------------------------
-- QUERY 10: Critical Governance Policies Not In Place
-- Severity: CRITICAL
-- ------------------------------------------------------------
-- Business question: Are any mandatory governance policies
-- missing or not yet implemented?
-- ------------------------------------------------------------
-- Why it matters: Anti-Bribery, Whistleblower, and Environmental
-- policies are mandatory under Nigerian law and international ESG
-- frameworks. A 'No' status is a critical governance failure —
-- it directly impacts ESG ratings and investor confidence.
-- Expected result: Zero rows = all critical policies are active
-- ------------------------------------------------------------
SELECT
    gp.policy_id,
    c.company_name,
    gp.policy_name,
    gp.policy_status,
    gp.policy_last_reviewed,
    gp.policy_approved_by,
    'Critical governance policy not in place — regulatory violation' AS issue
FROM governance_policies gp
JOIN companies c ON gp.company_id = c.company_id
WHERE gp.policy_name IN (
    'Anti-Bribery & Corruption',
    'Whistleblower Protection',
    'Environmental Policy'
)
AND gp.policy_status = 'No';


-- ------------------------------------------------------------
-- QUERY 11: Governance Policies Never Reviewed
-- Severity: MEDIUM
-- ------------------------------------------------------------
-- Business question: Are there policies with no review date —
-- meaning they have never been formally reviewed?
-- ------------------------------------------------------------
-- Why it matters: A policy that has never been reviewed is
-- effectively unmanaged. ESG governance frameworks require
-- annual policy review. An unreviewed policy is a control
-- weakness — especially for Data Privacy under Nigeria's NDPR.
-- Expected result: Zero rows = all policies have review dates
-- ------------------------------------------------------------
SELECT
    gp.policy_id,
    c.company_name,
    gp.policy_name,
    gp.policy_status,
    gp.policy_last_reviewed,
    'Policy has no review date — governance control weakness' AS issue
FROM governance_policies gp
JOIN companies c ON gp.company_id = c.company_id
WHERE gp.policy_last_reviewed IS NULL;
