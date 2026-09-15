# ProfitTrace | Power BI Build Handoff

The Excel and SQL foundation is ready. The remaining execution is the Power BI build after the SQL load and QA gates pass.

## 1. Prepare the SQL layer

Run in SQL Server using this order:

1. `sql/01_Database_Setup.sql`
2. `sql/02_Import_Raw_Data.sql`
3. Import the five source files into the matching `stg` tables. Prefer Excel when the local ACE/OLE DB provider is available; otherwise use the CSV copies with `Flat File Source`.
4. `sql/03_Data_Validation.sql`
5. `sql/04_Data_Cleaning.sql`
6. `sql/05_Business_Analysis.sql`
7. `sql/06_Post_Load_QA.sql`
8. `sql/07_Final_Portfolio_QA.sql`

For the Shipping CSV, if direct conversion of blank date fields fails, follow the temporary `dbo.Shipping_Raw` workaround documented in `documentation/HANDS_ON_BUILD_GUIDE.md` and convert into the existing typed `stg.Shipping` table with `TRY_CONVERT`.

Do not proceed if validation or reconciliation gates show unexpected failures.

## 2. Load Power BI

Import:

- `analytics.vw_OrderProfitability` and rename it to `FactProfitability`
- `analytics.vw_ReturnsOperations` and rename it to `FactReturns`
- Distinct customer attributes from the SQL source into `DimCustomer`
- Distinct product attributes from the SQL source into `DimProduct`
- Create `DimDate` using the DAX definition in `DAX_MEASURES.md`

Relationships:

- `DimDate[Date]` 1:* `FactProfitability[order_date]`
- `DimDate[Date]` 1:* `FactReturns[return_date]`
- `DimCustomer[customer_id]` 1:* `FactProfitability[customer_id]`
- `DimCustomer[customer_id]` 1:* `FactReturns[customer_id]`
- `DimProduct[product_id]` 1:* `FactProfitability[product_id]`

Use single-direction filtering from dimensions to facts. Do not create a direct fact-to-fact relationship.

`FactReturns` is intentionally an event-level return table. The source returns extract does not contain a reliable product identifier, so do not invent product-level return attribution. Use it for return reasons, return dates, customer/channel analysis and refund leakage. Use `FactProfitability` for category/product profitability and order-level late-delivery comparisons.

## 3. Create clean business-facing measures

Create the measures in `powerbi/DAX_MEASURES.md` before building visuals.

Use clean names such as `Net Revenue`, `Gross Profit`, `Profit Margin %`, `Return Rate %` and `Return Leakage %`. Do not add technical prefixes such as `m_` to measure names. Organize measures in a dedicated Measures table or display folder for model hygiene.

Core revenue, profit and customer-economic measures use `is_delivered = 1` so they reconcile with the SQL business-analysis scope.

## 4. Build four pages

### Page 1 | Executive Profit Command Center

**Business question:** Where is the money made, and where is it leaking?

KPI cards:

- Net Revenue
- Gross Profit
- Profit Margin %
- Delivered Orders
- Return Rate %
- Return Leakage %

Main visuals: monthly Net Revenue vs Gross Profit trend, profit contribution by category, profitability leakage waterfall, regional profitability and management-focused high-revenue/low-margin opportunity views.

### Page 2 | Profitability Deep Dive

**Business question:** Which products and categories convert sales into healthy profit?

KPI cards:

- Net Revenue
- Gross Profit
- Profit Margin %
- AOV

Use category → subcategory → product drilldown, Revenue vs Gross Profit analysis, Discount Rate % vs Profit Margin % analysis and high-revenue/low-margin opportunity views.

### Page 3 | Returns & Operational Leakage

**Business question:** Where do returns and operational friction destroy economics?

KPI cards:

- Delivered Orders
- Returned Orders
- Return Rate %
- Refund Value
- Late Delivery %

Use return-event measures from `FactReturns` for reasons, counts and refund detail. Use `FactProfitability` for returned orders, return rate and late-delivery comparisons.

State association, not causation, when discussing late delivery versus returns.

### Page 4 | Customer & Commercial Intelligence

**Business question:** Which customer groups create durable profit?

KPI cards:

- Customers
- Orders per Customer
- Repeat Customer %
- Profit per Customer

Use one-time versus repeat economics, customer profitability, segments, regions, acquisition-channel performance and top profit-contributing customers.

## 5. Global slicers

Keep these consistent across pages where practical:

- Date
- Region
- Category
- Customer Segment
- Acquisition Channel

## 6. Visual QA

Before screenshots:

- No visual is overcrowded.
- No technical field names are exposed to the user.
- Currency and percentage formats are consistent.
- Month axes are chronological.
- Slicers affect intended visuals.
- Drilldown works.
- Tooltips are useful.
- No blank or placeholder visuals remain.
- No unexplained many-to-many relationships exist.
- All KPI cards use measures, not raw columns.
- Return-event measures and returned-order measures are not accidentally mixed.
- Page 3 does not imply unsupported product-level return attribution.
- SQL and Power BI core KPIs reconcile to the same delivered-order scope.

## 7. Portfolio evidence

Capture clean screenshots of all four pages at the final state. Use these exact filenames:

```text
executive_profit_command_center.png
profitability_deep_dive.png
returns_operational_leakage.png
customer_commercial_intelligence.png
```

Save the final report as:

```text
powerbi/ProfitTrace_Dashboard.pbix
```

Add screenshots and update the root README only after the dashboard is actually complete.

## Design direction

Use `PROFITTRACE_THEME.json` as the starting theme. Keep the visual hierarchy executive and restrained: strong KPI row, clear section headers, limited chart clutter, concise business-oriented titles and enough whitespace for the report to feel intentional.
