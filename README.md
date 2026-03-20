# esg-sustainability-audit
A PostgreSQL data validation framework simulating an EY-style ESG audit for Nigerian companies.
ESG assurance audit for Nigerian companies before regulatory filing.

## What This Project Does
Companies across Nigeria are under pressure to report Environmental, Social and Governance (ESG) data to the SEC, investors, and international frameworks like GRI and TCFD.

ESG data is collected manually across multiple departments such as HR, Finance, Legal and Operations. It is prone to errors before it reaches a regulator. This project simulates the SQL validation layer that sits between raw data collection and regulatory submission.

## Database Structure
Six tables covers all three ESG pillars:

## Table | Pillar | What It Tracks 
companies | — | Entities under audit.
emissions | Environmental | GHG emissions by scope.
energy_consumption | Environmental | Renewable vs non-renewable energy.
water_usage | Environmental | Withdrawal, recycling, discharge.
workforce_diversity | Social | Gender representation by level.
governance_policies | Governance | Policy existence and review status.

## The 11 Audit Queries
## Business Question & Severity 
1. Which companies failed to submit emissions figures? Critical 
2. Are all emissions using a valid GHG scope category? High 
3. Which companies have reported vs verified variance above 5%? High 
4. Are any active companies reporting zero direct emissions? High 
5. Are there missing or negative energy consumption values? Critical 
6. Are there duplicate energy records causing double-counting? High 
7. Does any water recycled volume exceed water withdrawn? Critical 
8. Do gender counts exceed total headcount? High 
9. Are Board or Senior Management records missing gender data? High 
10. Are mandatory governance policies missing? Critical 
11. Are there policies that have never been reviewed? Medium 

## Key Findings

Running all 11 queries against the sample dataset exposes 13 data quality issues across 3 Nigerian companies, including a missing Anti-Bribery policy, a 53% emissions variance, negative energy consumption, and gender arithmetic errors.

## How to Run
1. Open the SQL file in any PostgreSQL environment.
2. Run Section 1 to create tables,
3. Run Section 2 to insert data,
4. Run Section 3 to execute the audit queries.

## Skills Demonstrated
1. Relational database design with referential integrity.
2. Multi-table JOINs, GROUP BY, HAVING, CASE WHEN.
3. Variance calculations and aggregate functions. 
4. Data validation patterns across ESG reporting pillars.
5. Business context framing tied to GRI, TCFD, Nigerian SEC, NDPR.

## Author
Ooreoluwa Olusegun | BSc Computer Science | QA Engineer | Product Owner

## Linkedin
linkedin.com/in/ooreoluwa-olusegun  
