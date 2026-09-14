# ProfitTrace | Build and Validation Runbook

## Purpose

This runbook takes the project from raw Excel workbooks to a finished Power BI dashboard. The workflow is intentionally split across Excel, SQL Server and Power BI so that each tool has a clear purpose.

## 1. Prepare the source files

Keep the five Excel workbooks in one local project folder:

```text
ProfitTrace/
└── data/
    ├── Customers.xlsx
    ├── Products.xlsx
    ├── Orders.xlsx
    ├── Returns.xlsx
    └── Shipping.xlsx
```

Do not perform the main cleaning work in Excel. Treat these workbooks as the raw operational source.

## 2. SQL Server setup

Open **SQL Server Management Studio (SSMS)** and run:

1. `sql/01_Database_Setup.sql`
2. `sql/02_Table_Creation.sql`

This creates the `ProfitTrace` database, schemas and staging tables.

## 3. Load Excel data into SSMS

Use the SQL Server **Import and Export Wizard** to load each workbook into its matching staging table.

| Excel workbook | SQL staging table |
|---|---|
| `Customers.xlsx` | `stg.Customers` |
| `Products.xlsx` | `stg.Products` |
| `Orders.xlsx` | `stg.Orders` |
| `Returns.xlsx` | `stg.Returns` |
| `Shipping.xlsx` | `stg.Shipping` |

Run `sql/03_Load_Raw_Data.sql` after the import to confirm row counts.

If the local SQL Server installation does not provide an Excel data provider, save the same workbook as CSV and use the flat-file import option. The downstream SQL workflow does not change.

## 4. Validate the raw data

Run:

`sql/04_Data_Validation.sql`

Review the output for:

- Missing required values
- Duplicate keys
- Invalid quantities or prices
- Invalid discounts
- Invalid product economics
- Invalid refunds or shipping costs
- Invalid status values
- Orphan customer, product, return or shipping references
- Multiple shipping rows for one order
- Invalid date relationships

Some source values are intentionally inconsistent in formatting. These are expected to be addressed by the cleaning layer.

If structural or referential checks fail, stop and fix the source/import issue before moving on.

## 5. Clean and transform the data

Run:

`sql/05_Data_Cleaning.sql`

The cleaning layer keeps the raw staging data unchanged and creates analytical views that standardize text and apply business rules. This includes:

- Trimming whitespace
- Standardizing category and segment labels
- Standardizing acquisition channels and carriers
- Normalizing order and return statuses
- Applying a controlled discount ceiling
- Aggregating approved refunds at order level
- Combining product, customer, shipping and return information
- Calculating revenue, discount, refund, cost and profit fields

The main analytical view is:

`analytics.vw_OrderProfitability`

Supporting views:

- `analytics.vw_ReturnsOperations`
- `analytics.vw_CustomerProfitability`

## 6. Run post-load QA

Run:

`sql/07_Post_Load_QA.sql`

Confirm that:

- Source relationships reconcile.
- Each completed order appears once in `vw_OrderProfitability`.
- Revenue, discount and net revenue identities reconcile.
- Refunds do not exceed customer-paid sales.
- No cleaned economic fields contain invalid values.
- Delivery dates are logically ordered.
- Final KPI totals are non-null and sensible.

Do not move to Power BI if these checks expose unexplained errors.

## 7. Run business analysis queries

Run:

`sql/06_Business_Analysis.sql`

This produces analysis for:

- Executive profitability
- Monthly trends
- Category profitability
- Product profitability
- Discount leakage
- Return reasons
- Late delivery versus return behavior
- Regional performance
- One-time versus repeat customer economics
- Customer profitability ranking

These outputs are useful for validating the business story before building the dashboard.

## 8. Build the Power BI model

Connect Power BI to SQL Server and import:

`analytics.vw_OrderProfitability`

Use it as the main fact table, named `FactProfitability`.

Recommended dimensions:

- `DimDate`
- `DimCustomer`
- `DimProduct`

Use one-to-many, single-direction relationships from dimensions to the fact table.

Use `analytics.vw_ReturnsOperations` only where return-level detail is required. Avoid unnecessary many-to-many relationships.

## 9. Build the dashboard

Create the four pages in this order:

1. Executive Profit Command Center
2. Profitability Deep Dive
3. Returns and Operational Leakage
4. Customer and Commercial Intelligence

Create the DAX measures in `powerbi/DAX_MEASURES.md` before building the final visuals.

Follow `powerbi/DASHBOARD_BLUEPRINT.md` for visual placement, interactions, slicers and page-level objectives.

## 10. Final portfolio QA

Before publishing the project:

- All KPI values are measure-driven.
- Currency and percentages are consistently formatted.
- Page titles use business language.
- Slicers and cross-filtering behave correctly.
- No temporary or unexplained visuals remain.
- SQL findings agree with the Power BI numbers.
- README claims match the actual final dashboard.
- Screenshots match the PBIX that is delivered.
- Synthetic-data disclosure remains visible where appropriate.

## 11. Final evidence

Capture clean screenshots of all four dashboard pages. The final GitHub project should make the workflow easy to understand:

```text
Excel source data
      ↓
SQL Server validation and cleaning
      ↓
SQL business analysis
      ↓
Power BI model and DAX
      ↓
Decision-ready dashboard
```
