# ProfitTrace | Hands-On Build Guide

This guide is the practical execution checklist for building ProfitTrace locally. Follow it in order. The repository contains the design and SQL foundation; the local SQL execution and Power BI build create the final evidence.

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

## 2. Prepare SQL Server

Open SQL Server Management Studio and connect to the local SQL Server instance.

Run these scripts in order:

```text
01_Database_Setup.sql
02_Import_Raw_Data.sql
```

The scripts create the `ProfitTrace` database, `stg` schema and staging tables.

## 3. Load the five source files

Use SQL Server Import and Export Wizard. Import each workbook into its matching staging table:

```text
Customers.xlsx → stg.Customers
Products.xlsx  → stg.Products
Orders.xlsx    → stg.Orders
Shipping.xlsx  → stg.Shipping
Returns.xlsx   → stg.Returns
```

For each import, verify the source columns and destination columns before completing the wizard.

### If Excel import fails

If the wizard reports that the Microsoft ACE/OLE DB Excel provider is missing or has a 32-bit/64-bit mismatch, do not change the SQL schema. Use the CSV copies instead:

```text
Customers.csv → stg.Customers
Products.csv  → stg.Products
Orders.csv    → stg.Orders
Shipping.csv  → stg.Shipping
Returns.csv   → stg.Returns
```

The Excel files remain the documented primary source layer.

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

The raw staging tables are preserved. Standardization happens in the analytical layer.

## 6. Run business analysis

Run:

```text
05_Business_Analysis.sql
```

Use the results to understand profitability, discount leakage, return behavior, delivery performance, geography and customer economics.

Do not write final portfolio findings until the actual query results have been observed.

## 7. Run QA gates

Run:

```text
06_Post_Load_QA.sql
07_Final_Portfolio_QA.sql
```

Check that the financial identities reconcile and that there are no unexpected analytical-grain or data-quality failures.

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

Use the relationships in `powerbi/BUILD_HANDOFF.md` and the measures in `powerbi/DAX_MEASURES.md`.

## 9. Build Page 1

**Executive Profit Command Center**

Focus on the question:

> Where is the money made, and where is it leaking?

Use the approved KPI cards and monthly/category/regional profitability visuals from the dashboard blueprint.

## 10. Build Page 2

**Profitability Deep Dive**

Focus on:

> Which products and categories convert sales into healthy profit?

Use drilldown, profitability scatter analysis and product ranking.

## 11. Build Page 3

**Returns & Operational Leakage**

Focus on:

> Where do returns and operational friction destroy economics?

Use `FactReturns` for return events, reasons and refund analysis. Use `FactProfitability` for order-level return rate and late-delivery comparisons.

Do not claim that an observed relationship proves causation.

## 12. Build Page 4

**Customer & Commercial Intelligence**

Focus on:

> Which customer groups create durable profit?

Use one-time versus repeat economics, customer profitability, segments, regions and acquisition channels.

## 13. Visual QA

Before taking screenshots:

- format currency and percentages consistently
- sort months chronologically
- test slicers
- test drilldown
- check tooltips
- remove blank visuals
- remove technical field names from titles
- confirm KPI cards use measures
- check that no many-to-many relationship was created accidentally
- check that return events and returned orders are not being confused

## 14. Capture evidence

Save four clean screenshots under `screenshots/` using a consistent naming pattern:

```text
01_executive_profit_command_center.png
02_profitability_deep_dive.png
03_returns_operational_leakage.png
04_customer_commercial_intelligence.png
```

Keep the final `.pbix` file locally. If it is too large or unsuitable for the repository, document the build and use screenshots as the public evidence.

## 15. Final portfolio pass

After the dashboard is complete:

1. Update the README with real findings and recommendations.
2. Add the final screenshots.
3. Confirm the SQL scripts still match the executed workflow.
4. Confirm the dashboard measures match the documented definitions.
5. Review the repository as if you were a recruiter seeing it for the first time.

The final project should tell one consistent story from **Excel source data → SQL validation and transformation → Power BI decision support**.
