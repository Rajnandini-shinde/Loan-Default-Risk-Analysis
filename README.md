# Loan Default Risk Analysis Dashboard

## Project Overview

A data analytics project built using *PostgreSQL and Microsoft Power BI* to analyze historical loan defaults, identify higher-risk customer segments, and prioritize applications for manual review.

## Business Problem

Which customer segments have the highest historical loan default rates, and which applications may require additional manual review?

## Objectives

* Analyze historical loan performance and default rates.
* Compare defaults across loan grades, credit score segments, DTI segments, and loan purposes.
* Develop a rule-based risk scoring framework.
* Identify high-risk applications for manual review.
* Build an interactive Power BI dashboard to communicate business insights.

## Tools and Technologies

* *PostgreSQL* — data storage and SQL analysis
* *Microsoft Power BI* — dashboards and visualizations
* *DAX* — measures and calculated columns
* *SQL* — aggregations, analysis, and risk classification

## Dataset

The project uses LendingClub historical loan data, containing approximately *1,048,575 records*.

Key fields include loan amount, loan grade, interest rate, annual income, loan status, FICO score, debt-to-income ratio (DTI), delinquencies, revolving utilization, loan purpose, and state.

## Historical Default Analysis

Loans with a status of Charged Off or Default were treated as defaulted. Historical default rates were calculated using loans with known final outcomes: Fully Paid, Charged Off, and Default.

The observed historical default rate for this population was approximately *21.12%*.

### Key Findings

| Loan Grade | Historical Default Rate |
| ---------- | ----------------------: |
| A          |                   6.15% |
| B          |                  14.22% |
| C          |                  23.84% |
| D          |                  33.24% |
| E          |                  41.97% |
| F          |                  50.27% |
| G          |                  53.69% |

The analysis found higher historical default rates among lower loan grades and weaker credit score segments.

## Rule-Based Risk Scoring

A project-defined scoring framework assigns points for selected indicators:

* FICO score below 600: +3
* FICO score from 600 to below 670: +2
* DTI above 40: +3
* DTI from 30 to 40: +2
* One or more delinquencies: +2
* Revolving utilization above 80%: +2
* Four or more recent credit inquiries: +1

Risk categories:

* *Low Risk:* score 0–2
* *Medium Risk:* score 3–5
* *High Risk:* score 6 or above

Applications categorized as High Risk are flagged for manual review.

## Power BI Dashboard

### Page 1 — Loan Default Risk Analysis Dashboard

* Total loans and default-related KPIs
* Default rate by loan grade
* Default rate by credit segment
* Default rate by DTI segment
* Default rate by loan purpose

### Page 2 — Credit Risk & Manual Review

* Risk category distribution
* Default rate by risk category
* Manual review applications by grade
* Risk score distribution
* Default rate trend over time
* Slicers for risk category, loan grade, DTI segment, home ownership, loan purpose, and state

### Page 3 — Manual Review Queue

* Number of applications flagged for manual review
* Average manual-review risk score
* Average manual-review loan amount
* Detailed high-risk application table sorted by risk score

## SQL Analysis

PostgreSQL was used to analyze loan status, calculate historical default rates, compare customer segments, check missing values, calculate risk scores, classify risk categories, and generate a manual-review queue.

Key views:

* loan_risk_scored
* loan_risk_category
* loan_manual_review
## Power BI Dashboard Preview
* Page 1:Loan Default Risk Overview
* Page 2: Credit Risk
* Page 3: High Risk Manual Review Queue

## Project Structure
* REDADME.md - Project Ovreview, objectives,findings,and documentation.
* loan_risk_analysis.sql - SQL queries and risk analysis logic.
* Page 1- Loan risk overview dashboard.
* Page 2- credit risk.
* Page 3- High risk application review queue.
  
## Skills Demonstrated

* SQL and PostgreSQL
* Data analysis and segmentation
* Power BI dashboard development
* DAX measures and calculated columns
* KPI design and data visualization
* Business insight communication

## Disclaimer

The risk scoring and manual-review rules are project-defined analytical assumptions for educational and demonstration purposes. They are not official LendingClub criteria, a validated predictive model, or a recommendation for real loan approval or rejection decisions.

## Author
*Rajnandini Sopan Shinde*
B.Tech — Computer Science & Engineering
