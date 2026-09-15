# ProfitTrace | Build Runbook

## Phase 1: Source

1. Keep the Excel workbooks in `data/` locally as the primary source layer.
2. Keep the CSV copies available as the SQL import fallback.
3. Confirm expected row counts before loading:

```text
Customers  1,000
Products     300
Orders    15,000
Shipping  15,000
Returns    1,155
```

## Phase 2: SQL Server

Run in order:

```text
01_Database_Setup.sql
02_Import_Raw_Data.sql
```

These scripts create the database, schemas and typed staging tables. They do not load the source rows.

Load the five source files into the matching staging tables:

```text
Customers → stg.Customers
Products  → stg.Products
Orders    → stg.Orders
Shipping  → stg.Shipping
Returns   → stg.Returns
```

### Preferred import route

Use the SQL Server Import and Export Wizard with `Flat File Source` for the CSV fallback. For each file, select the existing `stg` destination table and use **Append rows to the destination table**. Do not create parallel `dbo` versions of the final staging tables.

### Shipping import fallback used for blank dates

The Shipping source contains 281 records with blank `ship_date`, `promised_delivery_date` and `delivery_date` values. When the wizard tries to convert these text fields directly to `DATE`, the conversion can fail even though the final `stg.Shipping` columns correctly allow `NULL`.

Use this controlled workaround only when direct CSV → `stg.Shipping` conversion fails:

1. Use **Import Flat File** to create temporary `dbo.Shipping_Raw` from `Shipping.csv`.
2. Keep all eight raw columns as text and allow nulls.
3. Verify `dbo.Shipping_Raw` contains 15,000 rows.
4. Validate that the three date columns have no nonblank invalid dates.
5. Insert into `stg.Shipping` using `TRY_CONVERT` and `NULLIF(LTRIM(RTRIM(...)), '')` so blanks become `NULL` and valid dates become `DATE`.
6. Verify `stg.Shipping` contains 15,000 rows and 15,000 unique `order_id` values.
7. Drop the temporary `dbo.Shipping_Raw` table after the transfer is verified.

The workaround preserves the raw source values and keeps the final staging schema strongly typed.

### After all five staging tables are loaded

Run:

```text
03_Data_Validation.sql
04_Data_Cleaning.sql
05_Business_Analysis.sql
06_Post_Load_QA.sql
07_Final_Portfolio_QA.sql
```

Do not start Power BI until the final QA checks reconcile.

## Phase 3: Power BI

Load `analytics.vw_OrderProfitability` as `FactProfitability`.

Load `analytics.vw_ReturnsOperations` as `FactReturns` for return-event and operational leakage analysis.

Create:

```text
DimDate
DimCustomer
DimProduct
```

Use the relationships documented in `powerbi/DASHBOARD_BLUEPRINT.md` and the clean business-facing measures in `powerbi/DAX_MEASURES.md`.

Core revenue, profit and customer-economic measures use delivered orders (`is_delivered = 1`) so Power BI matches the SQL analytical scope.

Build the four pages in this order:

1. Executive Profit Command Center
2. Profitability Deep Dive
3. Returns & Operational Leakage
4. Customer & Commercial Intelligence

### Power BI modeling guardrails

- Keep dimension-to-fact relationships one-to-many and single-direction.
- Do not create a direct fact-to-fact relationship.
- Do not connect `FactReturns` to `DimProduct` because the return source has no reliable product identifier.
- Use `FactProfitability` for product/category profitability and order-level return/delivery rates.
- Use `FactReturns` for return-event reasons, return dates, refund detail and customer/channel return analysis.

## Phase 4: Final Evidence

Capture clean screenshots showing:

- executive KPI page
- product/category profitability
- return and delivery analysis
- customer/channel economics

Document the strongest business findings and recommendations only after SQL and Power BI results exist. Do not invent findings in advance.
