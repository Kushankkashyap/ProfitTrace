# ProfitTrace | Hands-On Build Guide

This is the practical local execution guide. Treat the Excel files as the primary source layer, use SQL Server for staging/validation/cleaning/analysis, and build the final four-page Power BI report only after the SQL QA gates pass.

## 1. Prepare the source files

Keep these files in the local `ProfitTrace/data/` folder:

```text
Customers.xlsx
Customers.csv
Products.xlsx
Products.csv
Orders.xlsx
Orders.csv
Shipping.xlsx
Shipping.csv
Returns.xlsx
Returns.csv
README.md
```

Expected source counts:

| Source | Rows |
|---|---:|
| Customers | 1,000 |
| Products | 300 |
| Orders | 15,000 |
| Shipping | 15,000 |
| Returns | 1,155 |

`DATASET_SUMMARY.xlsx` is optional reference material and is not required for the SQL workflow.

Do not repair the intentional source-quality issues in Excel or CSV. The purpose of the project is to show those issues being identified and handled in SQL.

## 2. Prepare SQL Server

Open SQL Server Management Studio and connect to the local SQL Server instance.

If a previous `ProfitTrace` database exists and a clean rebuild is required, reset it first. Then run these scripts in order:

```text
01_Database_Setup.sql
02_Import_Raw_Data.sql
```

The scripts create the `ProfitTrace` database, `stg` schema, `analytics` schema and the five typed staging tables.

## 3. Load the five source files

Preferred source representation is Excel. If the SQL Server Import and Export Wizard cannot read `.xlsx` because the Microsoft ACE/OLE DB provider is missing or has a bitness mismatch, use the CSV copies with **Flat File Source**.

For each normal CSV import, map to the existing typed staging table and choose **Append rows to the destination table**:

```text
Customers.csv → stg.Customers
Products.csv  → stg.Products
Orders.csv    → stg.Orders
Shipping.csv  → stg.Shipping
Returns.csv   → stg.Returns
```

Do not create parallel `dbo` tables for these five final staging objects.

### Customers / Products / Orders / Returns

For each file:

1. Data Source = `Flat File Source`.
2. Format = `Delimited`.
3. Column delimiter = comma.
4. Header row contains column names = checked.
5. Destination = `Microsoft OLE DB Driver for SQL Server`.
6. Server = your local SQL Server instance.
7. Authentication = the same Windows Authentication used by SSMS.
8. Database = `ProfitTrace`.
9. Destination = the corresponding `stg` table.
10. Use **Append rows to the destination table**.
11. Verify the target data types before executing.

### Shipping fallback for blank dates

The Shipping source contains 15,000 rows and 281 records with blank `ship_date`, `promised_delivery_date` and `delivery_date` values. A direct CSV → `stg.Shipping` import can fail when the wizard tries to convert those blank text values directly to `DATE`.

Only when direct Shipping import fails:

1. Use **Import Flat File** for `Shipping.csv`.
2. Create temporary table `dbo.Shipping_Raw`.
3. In `Modify Columns`, keep all eight fields as text (`nvarchar(50)` is acceptable).
4. Allow nulls on the raw columns and do not define a primary key.
5. Finish the import and verify exactly 15,000 rows were loaded.
6. Run a validation query using `TRY_CONVERT(date, NULLIF(LTRIM(RTRIM(...)), ''))` to confirm there are no nonblank invalid dates.
7. Insert from `dbo.Shipping_Raw` into the existing `stg.Shipping` table, converting dates to `DATE` and `shipping_cost` to `DECIMAL(12,2)`.
8. Verify 15,000 rows and 15,000 unique `order_id` values in `stg.Shipping`.
9. Drop `dbo.Shipping_Raw` after verification.

The temporary raw table is only an import safety layer. The final project model still uses `stg.Shipping`.

## 4. Validate the raw layer

Run:

```text
03_Data_Validation.sql
```

Review:

- row counts
- required fields
- invalid quantity and price
- discount outside 0% to 30%
- invalid product economics
- negative refund/cost
- text/status variants
- orphan records
- duplicate order-product rows
- shipment uniqueness
- date validity
- delivered-order and delivery-date consistency

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

`vw_OrderProfitability` is kept at order-product-line grain. Approved return amounts, shipping costs and return costs are pre-aggregated at order level and allocated across lines so line-level aggregation does not double-count order-level amounts.

The cleaning layer also standardizes the known casing/whitespace variants in customer, product, shipping and return fields.

## 6. Run business analysis

Run:

```text
05_Business_Analysis.sql
```

Use the actual query results to understand profitability, discount leakage, return behavior, delivery performance, geography and customer economics. Core commercial economics are scoped to delivered orders (`is_delivered = 1`). Do not write final portfolio findings before observing the real SQL results.

## 7. Run QA gates

Run:

```text
06_Post_Load_QA.sql
07_Final_Portfolio_QA.sql
```

Check financial reconciliation, analytical grain, row-count expectations, delivery-status consistency and business-rule checks. Stop here if an unexpected failure appears.

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

Use a star schema with single-direction dimension-to-fact relationships. Do not create a direct `FactProfitability` ↔ `FactReturns` relationship.

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

Core revenue, profit and customer-economic measures are scoped to delivered orders so Power BI matches the SQL analysis.

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

Use the approved visuals from the dashboard blueprint: monthly Net Revenue vs Gross Profit trend, profit contribution by category, profitability leakage waterfall, regional profitability and management-focused high-revenue/low-margin opportunity views.

## 11. Build Page 2 | Profitability Deep Dive

Business question:

> Which products and categories convert sales into healthy profit?

KPIs:

- Net Revenue
- Gross Profit
- Profit Margin %
- AOV

Use category/subcategory/product drilldown, Net Revenue vs Gross Profit analysis, Discount Rate % vs Profit Margin % analysis and high-revenue/low-margin opportunity views.

## 12. Build Page 3 | Returns & Operational Leakage

Business question:

> Where do returns and operational friction destroy economics?

KPIs:

- Delivered Orders
- Returned Orders
- Return Rate %
- Refund Value
- Late Delivery %

Use `FactReturns` for return-event counts, reasons, refund values and event-level return detail. Use `FactProfitability` for order-level returned orders, return rate and late-delivery comparisons.

Recommended visuals:

- Refund Value by Return Reason
- Return Event Count by Return Reason
- Acquisition Channel × Return Reason matrix
- Return Rate: Late vs On-time
- Monthly Refund Value trend
- Region × Late Delivery % table

Use wording such as **"Late deliveries show a higher return rate"** rather than claiming that late delivery caused the returns.

Do not create a Category × Return Reason visual. The returns source does not contain a reliable product/category key.

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
- SQL and Power BI core KPIs reconcile to the same delivered-order scope

## 15. SQL vs Power BI reconciliation

Spot-check at least these KPIs before finalizing the report:

```text
Delivered Orders
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
