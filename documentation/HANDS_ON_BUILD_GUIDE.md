# ProfitTrace | Hands-On Build Guide

This is the practical local execution guide. Treat the Excel files as the primary source layer, use SQL Server for staging/validation/cleaning/analysis, and build the final four-page Power BI report only after the SQL QA gates pass.

## 1. Prepare the source files

Keep these files in the local `ProfitTrace/data/` folder:

```text
Customers.xlsx
Products.xlsx
Orders.xlsx
Shipping.xlsx
Returns.xlsx
DATASET_SUMMARY.xlsx
```

Expected source counts:

| Source | Rows |
|---|---:|
| Customers | 1,000 |
| Products | 300 |
| Orders | 15,000 |
| Shipping | 15,000 |
| Returns | 1,155 |

Do not repair the intentional source-quality issues in Excel. The purpose of the project is to show those issues being identified and handled in SQL.

## 2. Prepare SQL Server

Open SQL Server Management Studio and connect to the local SQL Server instance.

Run these scripts in order:

```text
01_Database_Setup.sql
02_Import_Raw_Data.sql
```

The scripts create the `ProfitTrace` database, `stg` schema and the five staging tables.

## 3. Load the five source files

Use SQL Server Import and Export Wizard. Import each workbook into its matching staging table:

```text
Customers.xlsx → stg.Customers
Products.xlsx  → stg.Products
Orders.xlsx    → stg.Orders
Shipping.xlsx  → stg.Shipping
Returns.xlsx   → stg.Returns
```

For each import, verify source columns, destination columns, data types and row count before completing the wizard.

### If Excel import fails

If the wizard reports a missing Microsoft ACE/OLE DB Excel provider or a 32-bit/64-bit mismatch, do not redesign the SQL layer. Use the CSV copies instead:

```text
Customers.csv → stg.Customers
Products.csv  → stg.Products
Orders.csv    → stg.Orders
Shipping.csv  → stg.Shipping
Returns.csv   → stg.Returns
```

Excel remains the documented primary source layer. CSV is only the practical local-import fallback.

## 4. Validate the raw layer

Run:

```text
03_Data_Validation.sql
```

Review row counts, required fields, invalid quantity/price, discount outside 0% to 30%, invalid product economics, negative refund/cost, text/status variants, orphan records, duplicate order-product rows, shipment uniqueness and date validity.

The intentional quality issues should be visible before cleaning.

## 5. Build the analytical views

Run:

```text
04_Data_Cleaning.sql
```

This creates:

```text
analytics.vw_OrderProfitability
analytics.vw_ReturnsOperations
analytics.vw_CustomerProfitability
```

The raw staging tables remain unchanged. Standardization and analytical logic live in the SQL analytical layer.

## 6. Run business analysis

Run:

```text
05_Business_Analysis.sql
```

Use the actual query results to understand profitability, discount leakage, return behavior, delivery performance, geography and customer economics. Do not write final portfolio findings before observing the real SQL results.

## 7. Run QA gates

Run:

```text
06_Post_Load_QA.sql
07_Final_Portfolio_QA.sql
```

Check financial reconciliation, analytical grain, row-count expectations and other data-quality gates. Stop here if an unexpected failure appears.

## 8. Build the Power BI model

Connect Power BI to the SQL Server analytical views.

Use:

```text
FactProfitability = analytics.vw_OrderProfitability
FactReturns       = analytics.vw_ReturnsOperations
```

Create:

```text
DimDate
DimCustomer
DimProduct
```

Use a star schema with single-direction dimension-to-fact relationships. Do not create a direct FactProfitability ↔ FactReturns relationship.

Important modeling guardrail: `FactReturns` is a return-event fact and the returns source does not contain a reliable product identifier. Do not invent product/category return attribution from that fact.

## 9. Create clean business-facing DAX measures

Use the definitions in `powerbi/DAX_MEASURES.md`.

Do **not** add a technical prefix such as `m_` to measure names. Use names such as:

```text
Orders
Delivered Orders
Net Revenue
Gross Profit
Profit Margin %
Return Rate %
Return Leakage %
Customers
Repeat Customer %
Profit per Customer
```

Keep measures in a dedicated Measures table or display folder for organization.

## 10. Build Page 1 | Executive Profit Command Center

Business question:

> Where is the money made, and where is it leaking?

Use these six KPI cards:

- Net Revenue
- Gross Profit
- Profit Margin %
- Delivered Orders
- Return Rate %
- Return Leakage %

Use the approved visuals from the dashboard blueprint: monthly Revenue vs Gross Profit trend, profit contribution by category, profitability leakage waterfall, revenue vs margin analysis and management-focused opportunity views.

## 11. Build Page 2 | Profitability Deep Dive

Business question:

> Which products and categories convert sales into healthy profit?

KPIs:

- Net Revenue
- Gross Profit
- Profit Margin %
- AOV

Use category/subcategory/product drilldown, Revenue vs Gross Profit analysis, Discount Rate % vs Profit Margin % analysis and high-revenue/low-margin opportunity views.

## 12. Build Page 3 | Returns & Operational Leakage

Business question:

> Where do returns and operational friction destroy economics?

KPIs:

- Returned Orders
- Return Rate %
- Refund Value
- Return Leakage %
- Late Delivery %

Use `FactReturns` for return-event counts, reasons, refund values and event-level return detail. Use `FactProfitability` for order-level returned orders, return rate and late-delivery comparisons.

Use wording such as **"Late deliveries show a higher return rate"** rather than claiming that late delivery caused the returns.

## 13. Build Page 4 | Customer & Commercial Intelligence

Business question:

> Which customer groups create durable profit?

KPIs:

- Customers
- Orders per Customer
- Repeat Customer %
- Profit per Customer

Use one-time versus repeat economics, customer profitability, customer segment, region, acquisition-channel profitability and top profit-contributing customers.

## 14. Visual QA

Before screenshots:

- no unexplained many-to-many relationships
- dimension-to-fact relationships are single direction
- `DimDate` is marked as the Date table
- month labels are sorted chronologically
- KPI cards use measures, not raw columns
- technical field names are not exposed in the report
- currency and percentage formats are consistent
- slicers and interactions work as intended
- no overlaps, placeholders or blank visuals remain
- Page 3 does not imply unsupported product-level return attribution
- return events are not accidentally substituted for returned orders

## 15. SQL vs Power BI reconciliation

Spot-check at least these KPIs before finalizing the report:

```text
Orders
Net Revenue
Gross Profit
Return Rate %
Late Delivery %
```

Record the SQL result, the Power BI result and whether they match. Resolve mismatches before screenshots.

## 16. Capture final evidence

Save four clean screenshots under `screenshots/`:

```text
executive_profit_command_center.png
profitability_deep_dive.png
returns_operational_leakage.png
customer_commercial_intelligence.png
```

Save the final Power BI file as:

```text
powerbi/ProfitTrace_Dashboard.pbix
```

Keep the report canvas clean in the screenshots. Avoid showing unnecessary Power BI editing panes.

## 17. Final portfolio pass

After the dashboard is actually complete:

1. Update the README with observed findings and recommendations.
2. Add the four final screenshots.
3. Confirm the SQL scripts still match the workflow you executed.
4. Confirm DAX measures match the documented business definitions.
5. Review the repository as a recruiter would see it for the first time.

The final project story should remain consistent end to end:

**Excel source data → SQL Server staging → validation → cleaning/analytical views → business analysis/QA → Power BI star schema → clean DAX measures → four-page decision dashboard.**
