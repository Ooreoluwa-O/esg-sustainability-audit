CREATE TABLE companies (
    company_id     SERIAL PRIMARY KEY,
    company_name   TEXT    NOT NULL,
    sector         TEXT    NOT NULL,
    country        TEXT    NOT NULL,
    listing_status TEXT    NOT NULL,
    reporting_year INTEGER NOT NULL
);

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

CREATE TABLE energy_consumption ( 
	energy_consumption_id SERIAL PRIMARY KEY, 
	company_id INTEGER NOT NULL REFERENCES companies(company_id), 
	source_type TEXT NOT NULL, 
	source_name  TEXT NOT NULL, 
	consumed_mwh NUMERIC(10,2), 
	quarter TEXT NOT NULL, 
	reporting_year INTEGER NOT NULL
);

SELECT * FROM energy_consumption;

CREATE TABLE water_usage ( 
	  water_id SERIAL PRIMARY KEY, 
	  company_id INTEGER NOT NULL REFERENCES companies(company_id), 
	  source TEXT NOT NULL, 
	  withdrawn_m3 NUMERIC(10,2), 
	  recycled_m3 NUMERIC(10,2), 
	  discharged_m3 NUMERIC(10,2), 
	  quarter TEXT NOT NULL, 
	  reporting_year INTEGER NOT NULL 
);

CREATE TABLE workforce_diversity ( 
	workforce_diversity_id SERIAL PRIMARY KEY, 
	company_id INTEGER NOT NULL REFERENCES companies(company_id), 
	organisation_level TEXT NOT NULL, 
	org_headcount  INTEGER NOT NULL, 
	female_count INTEGER, 
	male_count INTEGER, 
	disability_count INTEGER, 
	reporting_year INTEGER NOT NULL 
);

CREATE TABLE governance_policies ( 
	policy_id SERIAL PRIMARY KEY, 
	company_id INTEGER NOT NULL REFERENCES companies(company_id), 
	policy_name TEXT NOT NULL, 
	policy_status  TEXT NOT NULL, 
	policy_last_reviewed DATE, 
	policy_approved_by TEXT, 
	reporting_year INTEGER NOT NULL 
);

SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'
ORDER BY table_name;

INSERT INTO companies 
    (company_name, sector, country, listing_status, reporting_year)
VALUES
    ('Okonkwo Energy PLC', 'Oil & Gas', 'Nigeria', 'Listed', 2024),
    ('FirstCapital Bank Ltd', 'Banking', 'Nigeria', 'Listed', 2024),
    ('ConnectTel Nigeria', 'Telecom', 'Nigeria', 'Unlisted', 2024),
	('St Luke Hospital', 'Health', 'Nigeria', 'Listed', 2023),
    ('TeKn0wledge Nigeria', 'Energy', 'Nigeria', 'Unlisted', 2022);

SELECT * FROM companies

DELETE FROM companies;
ALTER SEQUENCE companies_company_id_seq RESTART WITH 1;

INSERT INTO companies 
    (company_name, sector, country, listing_status, reporting_year)
VALUES
    ('Okonkwo Energy PLC', 'Oil & Gas', 'Nigeria', 'Listed', 2024),
    ('FirstCapital Bank Ltd', 'Banking', 'Nigeria', 'Listed', 2024),
    ('ConnectTel Nigeria', 'Telecom', 'Nigeria', 'Unlisted', 2024),
	('St Luke Hospital', 'Health', 'Nigeria', 'Listed', 2023),
    ('TeKn0wledge Nigeria', 'Energy', 'Nigeria', 'Unlisted', 2022);

SELECT * FROM companies

INSERT INTO emissions
    (company_id, scope, category, reported_value, verified_value, unit, quarter, reporting_year)
VALUES
    (1, 'Scope 1', 'Fuel combustion', 48200.00, 47900.00, 'tCO2e', 'Q1', 2024),
    (1, 'Scope 1', 'Fuel combustion', 51300.00, 51100.00, 'tCO2e', 'Q2', 2024),
    (1, 'Scope 2', 'Electricity purchase', 12400.00, 12400.00, 'tCO2e', 'Q1', 2024),
    (1, 'Scope 3', 'Business travel', NULL, 1200.00, 'tCO2e', 'Q1', 2024),
	(1, 'Scope 4', 'Health Electricity usage', NULL, 12000.00, 'tCO2e', 'Q1', 2025);

SELECT * FROM emissions;

INSERT INTO emissions
    (company_id, scope, category, reported_value, verified_value, unit, quarter, reporting_year)
VALUES
    (2, 'Scope 1', 'Fuel combustion', 890.00, 885.00, 'tCO2e', 'Q1', 2024),
    (2, 'Scope 1', 'Fuel combustion', 0.00, 910.00, 'tCO2e', 'Q2', 2024),
    (2, 'Scope 2', 'Electricity purchase', 3200.00, 3180.00, 'tCO2e', 'Q1', 2024),
    (3, 'Scope 1', 'Fuel combustion', 18900.00, 12300.00, 'tCO2e', 'Q1', 2024),
    (3, 'Scope 2', 'Electricity purchase', 5400.00, 5390.00, 'tCO2e', 'Q2', 2024),
    (3, 'Scope 5', 'Unknown category', 1100.00, NULL, 'tCO2e', 'Q3', 2024);

SELECT 
    emission_id,
    company_id,
    scope,
    category,
    reported_value,
    verified_value,
    quarter
FROM emissions
ORDER BY company_id, quarter;

DELETE FROM emissions
WHERE emission_id = 5;

UPDATE emissions
SET scope = 'Scope 4',
    category = 'Unknown category'
WHERE emission_id = 11;

SELECT 
    emission_id,
    company_id,
    scope,
    category,
    reported_value,
    verified_value,
    quarter
FROM emissions
ORDER BY company_id, emission_id;

INSERT INTO energy_consumption
    (company_id, source_type, source_name, consumed_mwh, quarter, reporting_year)
VALUES
    (1, 'Non-Renewable', 'Diesel Generator', 84500.00, 'Q1', 2024),
    (1, 'Non-Renewable', 'Diesel Generator', 87200.00, 'Q2', 2024),
    (1, 'Renewable', 'Solar', 1200.00, 'Q1', 2024),
    (2,  'Non-Renewable', 'EKEDC Grid', 14300.00, 'Q1', 2024),
    (2, 'Renewable', 'Solar', 450.00, 'Q1', 2024),
    (3, 'Non-Renewable', 'Diesel Generator', NULL, 'Q2', 2024),
    (3, 'Renewable', 'Solar', -300.00, 'Q2', 2024),
    (3, 'Non-Renewable', 'Diesel Generator', NULL, 'Q2', 2024);

SELECT * FROM energy_consumption 
ORDER BY company_id, quarter;

INSERT INTO water_usage 
(company_id, source, withdrawn_m3, recycled_m3, discharged_m3, quarter, reporting_year) 
VALUES 
(1, 'Borehole', 45000.00, 12000.00, 28000.00, 'Q1', 2024), 
(1, 'Municipal', 8200.00, 1500.00, 6000.00, 'Q1', 2024), 
(2, 'Municipal', 3100.00, 800.00, 2100.00, 'Q1', 2024), 
(3, 'Rainwater', 1500.00, 4200.00, 800.00, 'Q1', 2024), 
(3, 'Borehole', NULL, NULL, NULL, 'Q2', 2024);

SELECT * FROM water_usage 
ORDER BY company_id, quarter;

INSERT INTO workforce_diversity 
(company_id, organisation_level, org_headcount, female_count, male_count, disability_count, reporting_year) 
VALUES
(1, 'Board', 12, 3, 9, 0, 2024),
(1, 'Senior Mgmt', 45, 14, 31, 2, 2024),
(1, 'Staff', 820, 430, 450, 8, 2024),
(2, 'Board', 9, 2, 7, 0, 2024),
(2, 'Senior Mgmt', 38, NULL, 38, 1, 2024),
(3, 'Board', 7, 1, 6, 0, 2024),
(3, 'Staff', 540, 198, 342, 12, 2024);

SELECT * FROM workforce_diversity
ORDER BY company_id, organisation_level;

INSERT INTO governance_policies 
(company_id, policy_name, policy_status, policy_last_reviewed, policy_approved_by, reporting_year) 
VALUES 
(1, 'Environmental Policy', 'Yes', '2024-01-15', 'Board', 2024), 
(1, 'Anti-Bribery & Corruption', 'Yes', '2023-11-01', 'Board', 2024), 
(2, 'Environmental Policy', 'In Progress', '2024-02-20', 'CEO', 2024), 
(2, 'Anti-Bribery & Corruption', 'No', NULL, NULL, 2024), 
(3, 'Environmental Policy', 'Yes', '2024-03-01', 'Board', 2024), 
(3, 'Whistleblower Protection', 'Yes', '2023-08-14', 'Board', 2024), 
(3, 'Data Privacy Policy', 'Yes', NULL, 'CEO', 2024);

SELECT * FROM governance_policies 
ORDER BY company_id, policy_name;

SELECT
    e.emission_id,
    c.company_name,
    e.scope,
    e.category,
    e.quarter,
    e.reported_value,
    'Missing reported emissions value' AS issue
FROM emissions e
JOIN companies c ON e.company_id = c.company_id
WHERE e.reported_value IS NULL;

SELECT
    e.emission_id,
    c.company_name,
    e.scope,
    e.reported_value,
    e.verified_value,
    ROUND(ABS(e.reported_value - e.verified_value) / e.verified_value * 100, 2) AS variance_pct,
    'Variance exceeds 5%' AS issue
FROM emissions e
JOIN companies c ON e.company_id = c.company_id
WHERE e.reported_value IS NOT NULL
  AND e.verified_value IS NOT NULL
  AND ABS(e.reported_value - e.verified_value) / e.verified_value * 100 > 5;

SELECT 
e.emission_id, 
c.company_name, 
e.scope, 
e.reported_value, 
e.quarter
FROM emissions e 
JOIN companies c ON e.company_id = c.company_id 
WHERE e.reported_value = 0 
AND e.scope = 'Scope 1';

SELECT * FROM energy_consumption LIMIT 3;

SELECT
    en.energy_consumption_id,
    c.company_name,
    en.source_type,
    en.source_name,
    en.consumed_mwh,
    en.quarter,
CASE
        WHEN en.consumed_mwh IS NULL THEN 'Missing energy value'
        WHEN en.consumed_mwh < 0     THEN 'Negative energy — impossible'
    END AS issue
FROM energy_consumption en
JOIN companies c ON en.company_id = c.company_id
WHERE en.consumed_mwh IS NULL
   OR en.consumed_mwh < 0;

SELECT
    c.company_name,
    en.source_type,
    en.source_name,
    en.quarter,
    COUNT(*) AS duplicate_count,
    'Duplicate record detected' AS issue
FROM energy_consumption en
JOIN companies c ON en.company_id = c.company_id
GROUP BY c.company_name, en.source_type, en.source_name, en.quarter
HAVING COUNT(*) > 1;

SELECT * FROM water_usage LIMIT 3;

SELECT
    wt.water_id,
    c.company_name,
    wt.source,
    wt.withdrawn_m3,
    wt.recycled_m3,
    wt.quarter,
    'Recycled exceeds withdrawn — impossible' AS issue
FROM water_usage wt
JOIN companies c ON wt.company_id = c.company_id
WHERE wt.recycled_m3 > wt.withdrawn_m3;

SELECT 
	wd.workforce_diversity_id, 
	c.company_name, 
	wd.organisation_level, 
	wd.org_headcount, 
	wd.female_count, 
	wd.male_count, 
	(wd.female_count + wd.male_count) AS sum_of_genders,
	'Gender counts exceed headcount' AS issue 
FROM workforce_diversity wd 
JOIN companies c ON wd.company_id = c.company_id 
WHERE (wd.female_count + wd.male_count) > wd.org_headcount;

SELECT 
	wd.workforce_diversity_id, 
	c.company_name, 
	wd.organisation_level, 
	wd.org_headcount, 
	wd.female_count, 
	'Missing gender data at leadership level' AS issue
FROM workforce_diversity wd 
JOIN companies c ON wd.company_id = c.company_id 
WHERE organisation_level IN ('Board', 'Senior Mgmt') AND female_count IS NULL;

SELECT 
	gp.policy_id, 
	c.company_name, 
	gp.policy_name, 
	gp.policy_status, 
	gp.policy_last_reviewed, 
	gp.policy_approved_by, 
	'Critical policy not in place' AS issue 
FROM governance_policies gp 
JOIN companies c ON gp.company_id = c.company_id 
WHERE gp.policy_name IN ('Anti-Bribery & Corruption', 'Whistleblower Protection', 'Environmental Policy') 
AND gp.policy_status = 'No';

SELECT 
	gp.policy_id, 
	c.company_name, 
	gp.policy_name, 
	gp.policy_status, 
	gp.policy_last_reviewed, 
	'Policy never reviewed' AS issue
FROM governance_policies gp 
JOIN companies c ON gp.company_id = c.company_id 
WHERE gp.policy_last_reviewed IS NULL;