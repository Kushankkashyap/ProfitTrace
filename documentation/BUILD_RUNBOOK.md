# ProfitTrace | Build Runbook

## Phase 1: Source

1. Keep the Excel workbooks in `data/` locally as the primary source layer.
2. Keep the CSV copies available as the SQL import fallback.
3. Confirm the expected row counts before loading.

## Phase 2: SQL Server

Run in order:

```text
01_Database_Setup.sql
02_Import_Raw_Data.sql
```

Load these five files into the matching staging tables:

```text
Customers → stg.Customers
Products  → stg.Products
Orders    → stg.Orders
Shipping  → stg.Shipping
Returns   → stg.Returns
```

Then run:

```text
03_Data_Validation.sql
04_Data_Cleaning.sql
05_Business_Analysis.sql
06_Post_Load_QA.sql
07_Final_Portfolio_QA.sql
```

Do not start Power BI until the final QA checks reconcile.

### Excel import fallback

If the SQL Server Import and Export Wizard cannot read `.xlsx` because the Excel OLE DB provider is unavailable or has a bitness mismatch, use the CSV copies instead. The analytical workflow and staging schema remain unchanged.

## Phase 3: Power BI

Load `analytics.vw_OrderProfitability` as `FactProfitability`.

Load `analytics.vw_ReturnsOperations` as `FactReturns` for return-event and operational leakage analysis.

Create:

```text
DimDate
DimCustomer
DimProduct
```

Use the relationships documented in `powerbi/DASHBOARD_BLUEPRINT.md` and add the measures in `powerbi/DAX_MEASURES.md`.

Build the four pages in this order:

1. Executive Profit Command Center
2. Profitability Deep Dive
3. Returns & Operational Leakage
4. Customer & Commercial Intelligence

## Phase 4: Final Evidence

Capture clean screenshots showing:

- executive KPI page
- product/category profitability
- return and delivery analysis
- customer/channel economics

Document the strongest business findings and recommendations only after SQL and Power BI results exist. Do not invent findings in advance.
