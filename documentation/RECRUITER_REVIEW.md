# ProfitTrace | Recruiter Review Lens

## Why this project is portfolio-relevant

ProfitTrace is intentionally designed to show more than dashboard-building ability. The workflow demonstrates how an analyst can move from operational source data to validated business metrics and then communicate decisions through BI.

### Signals a recruiter should see

- **Excel:** comfortable with business-facing source data.
- **SQL Server / SSMS:** understands staging, data quality, transformations, joins, analytical queries and reconciliation.
- **Power BI:** can build a dimensional model rather than simply import a spreadsheet and add charts.
- **DAX:** separates reusable measures from visual-level calculations.
- **Business analysis:** focuses on margin, leakage, returns, delivery performance and customer economics.
- **Analytical discipline:** distinguishes association from causation and validates financial identities.

## Strong interview talking points

### 1. Why not use revenue as the main KPI?
Because revenue can look healthy while discounts, refunds, product cost and operational costs weaken realized profit.

### 2. Why stage the data in SQL?
Staging preserves the raw source layer and makes validation, cleaning and business logic auditable before Power BI consumes the analytical view.

### 3. Why use a star schema in Power BI?
It separates reusable dimensions from the transactional fact, improves filter behavior and makes DAX measures easier to maintain.

### 4. Why investigate late deliveries and returns carefully?
The dashboard can reveal an association worth investigating, but observational synthetic data is not enough to claim that late delivery caused a return.

### 5. What is the most important technical QA step?
Financial identities should reconcile. Gross revenue minus discounts should equal sales after discount, and net revenue minus product, shipping and return costs should reconcile to gross profit within rounding tolerance.

## Portfolio presentation rule

Lead with the business problem and the decision. Mention the tool stack second. A recruiter should understand what the project helped a business decide before hearing a list of technologies.
