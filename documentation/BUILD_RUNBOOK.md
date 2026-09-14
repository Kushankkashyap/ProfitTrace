# ProfitTrace — Build & Validation Runbook

## Purpose

This is the execution checklist for building the portfolio project from the repository into the final Power BI dashboard.

## 1. SQL Server execution order

Use **SQL Server Management Studio (SSMS)**.

### Reproducible route — recommended

Run these scripts in this exact order:

1. `sql/01_Database_Setup.sql`
2. `sql/00_Generate_Synthetic_Data.sql`
3. `sql/04_Data_Validation.sql`
4. `sql/05_Data_Cleaning.sql`
5. `sql/07_Post_Load_QA.sql`
6. `sql/06_Business_Analysis.sql`

`02_Table_Creation.sql` is an alternative table-definition route for loading external CSV files. **Do not run it between `01` and `00`**, because the generator creates the staging tables itself.

## 2. Expected source profile

The deterministic generator is designed to create approximately:

| Entity | Target rows |
|---|---:|
| Customers | 800 |
| Products | 240 |
| Orders | 11,000 |
| Shipping | 11,000 |
| Returns | up to 900 |

The final counts should be taken from the SQL output rather than hard-coded into the dashboard.

## 3. Validation gates

Before opening Power BI, confirm:

- No orphan customer/product references.
- Every order has exactly one shipping row in the generated dataset.
- Every order has exactly one analytical row in `vw_OrderProfitability`.
- Quantity, unit price, discount and cost fields contain no invalid negative/domain values.
- Shipping dates are logically ordered.
- `sales_after_discount = gross_revenue - discount_value` within rounding tolerance.
- Approved refunds do not exceed the customer-paid sales amount.
- The post-load KPI query returns sensible non-null totals.

If a validation gate fails, fix the SQL layer first. Do not compensate with DAX.

## 4. Power BI import

Recommended main fact:

`analytics.vw_OrderProfitability` → `FactProfitability`

Recommended dimensions:

- `DimDate`
- `DimCustomer`
- `DimProduct`

Keep relationships one-to-many and single-direction from dimensions to fact.

For return/operational detail, use `analytics.vw_ReturnsOperations` as a separate detail table only where needed. Avoid many-to-many relationships with the main fact.

## 5. Dashboard build order

Build pages in this order:

1. Executive Profit Command Center
2. Profitability Deep Dive
3. Returns & Operational Leakage
4. Customer & Commercial Intelligence

Create all measures in `powerbi/DAX_MEASURES.md` before building visuals.

## 6. Screenshot checklist

Final portfolio screenshots should show:

- Executive page with KPI cards and trend story.
- Profitability page with category/product economics.
- Returns page with return reasons and delivery relationship.
- Customer page with commercial/profitability segmentation.

Do not screenshot Power BI while editing fields, formatting panes, errors or temporary visuals.

## 7. Portfolio QA

Before calling the project complete:

- All page titles use business language.
- Currency and percentages are consistently formatted.
- No visual contains an unexplained abbreviation.
- No KPI is hard-coded.
- Slicers work across intended pages.
- Cross-filtering behaves as expected.
- Tooltips provide useful context rather than duplicate the visual title.
- The README findings match the final dashboard numbers.
- Screenshots match the PBIX actually delivered.

## 8. Important modeling note

The generated portfolio dataset currently has one product line per order. Shipping and returns are therefore safely aggregated at order level in the main profitability view. If the generator is later expanded to multiple product lines per order, order-level shipping and refund values must be allocated or modeled separately before summing them at line level.
