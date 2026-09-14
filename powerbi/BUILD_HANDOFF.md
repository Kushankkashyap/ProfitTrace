# ProfitTrace | Power BI Build Handoff

The Excel and SQL foundation is ready. The remaining execution is the Power BI build after the SQL load and QA gates pass.

## 1. Prepare the SQL layer

Run in SQL Server using this order:

1. `sql/01_Database_Setup.sql`
2. `sql/02_Import_Raw_Data.sql`
3. Import the five Excel workbooks into the matching `stg` tables
4. `sql/03_Data_Validation.sql`
5. `sql/04_Data_Cleaning.sql`
6. `sql/05_Business_Analysis.sql`
7. `sql/06_Post_Load_QA.sql`
8. `sql/07_Final_Portfolio_QA.sql`

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

`FactReturns` is intentionally an event-level return table. The source returns extract does not contain a product identifier, so do not invent product-level return attribution. Use it for return reasons, return dates, customer/channel analysis and refund leakage. Use `FactProfitability` for category/product profitability and late-delivery comparisons.

## 3. Create measures

Create the measures in `powerbi/DAX_MEASURES.md` before building visuals. Use the `m_` naming convention and apply the documented number formats.

## 4. Build four pages

### Page 1 | Executive Profit Command Center

Tell the story: **Where is the money made, and where is it leaking?**

KPI cards: Gross Revenue, Net Revenue, Gross Profit, Margin %, Orders, Return Rate %.

Main visuals: monthly Net Revenue vs Gross Profit, category profit, regional margin, profitability leakage waterfall, management alert table.

### Page 2 | Profitability Deep Dive

Tell the story: **Which products and categories convert sales into healthy profit?**

Use category → subcategory → product drilldown, Revenue vs Profit scatter, Discount % vs Margin % scatter, and top/bottom product profitability.

### Page 3 | Returns & Operational Leakage

Tell the story: **Where do returns and operational friction destroy economics?**

KPI cards: Returned Orders, Return Rate %, Refund Value, Late Delivery %.

Use return reason/refund analysis from `FactReturns`, monthly refunds, customer/channel return activity, and late versus on-time return comparison from `FactProfitability`.

State association, not causation, when interpreting late delivery versus returns.

### Page 4 | Customer & Commercial Intelligence

Tell the story: **Which customer groups create durable profit?**

KPI cards: Customers, AOV, Repeat Customer %, Profit per Customer.

Use one-time vs repeat comparison, customer profitability segmentation, region × segment, top customers, and acquisition-channel profitability.

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
- Currency and percentages are formatted consistently.
- Month axes are chronological.
- Slicers affect intended visuals.
- Drilldown works.
- Tooltips are useful.
- No blank or placeholder visuals remain.
- No unexplained many-to-many relationships exist.
- All KPI cards use measures, not raw columns.
- Return metrics do not accidentally double-count return events.

## 7. Portfolio evidence

Capture clean screenshots of all four pages at the final state. Add them under `screenshots/` and update the root README only after the dashboard is actually complete.

## Design direction

Use `PROFITTRACE_THEME.json` as the starting theme. Keep the visual hierarchy executive and restrained: strong KPI row, clear section headers, limited chart clutter, and business-oriented titles.
