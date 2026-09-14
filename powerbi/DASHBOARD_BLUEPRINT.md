# ProfitTrace — Power BI Dashboard Blueprint

This file is the build specification for the final `.pbix`. **Build the dashboard only after the SQL layer has been loaded, cleaned and passed validation/QA.**

## Semantic Model

The primary Power BI fact is the cleaned, order-level analytical view:

```text
DimDate
   |
DimCustomer ── FactProfitability ── DimProduct
```

- `FactProfitability` = `analytics.vw_OrderProfitability`
- Grain = **one analytical row per order** in the current generated dataset.
- `DimDate[Date]` → `FactProfitability[order_date]` (1:*, single direction)
- `DimCustomer[customer_id]` → `FactProfitability[customer_id]` (1:*, single direction)
- `DimProduct[product_id]` → `FactProfitability[product_id]` (1:*, single direction)

Returns and shipping are already aggregated to order level inside the analytical view. Do **not** relate raw Returns/Shipping directly to `FactProfitability` in a way that can multiply order rows. If detail is needed for a dedicated operational visual, use a separate deliberate model/bridge rather than a casual many-to-many relationship.

### Recommended build sequence

1. Load `analytics.vw_OrderProfitability` as `FactProfitability`.
2. Create `DimDate` from the fact's order-date range.
3. Create `DimCustomer` from customer attributes.
4. Create `DimProduct` from product attributes.
5. Create the three 1:* single-direction relationships above.
6. Add the DAX measures from `DAX_MEASURES.md`.
7. Validate totals against the SQL QA outputs before styling the pages.

## Page 1 — Executive Profit Command Center

### KPI cards
- Gross Revenue
- Net Revenue
- Gross Profit
- Profit Margin %
- Orders
- Return Rate %

### Visuals
1. Monthly Net Revenue vs Gross Profit line/column combination.
2. Category Gross Profit bar chart.
3. Regional Profit Margin matrix or map-style visual.
4. Profit Leakage waterfall: Gross Revenue → Discounts → Refunds → Product Cost → Shipping → Gross Profit.
5. Management alert table showing high-revenue / low-margin categories or products.

### Executive story
The page should answer **where the money is made and where it leaks** within 15–20 seconds.

## Page 2 — Profitability Deep Dive

### Visuals
- Category → Subcategory → Product drilldown matrix.
- Revenue vs Gross Profit scatter plot.
- Discount % vs Profit Margin % scatter; bubble size = Net Revenue.
- Top/bottom products by Gross Profit.
- Product detail tooltip with revenue, discount, refund, profit and margin.

### Key interaction
Selecting a category should filter all product-level visuals.

## Page 3 — Returns & Operational Leakage

### KPI cards
- Returned Orders
- Return Rate %
- Refund Value
- Late Delivery %

### Visuals
- Return reason bar chart by refund value.
- Category × Return Reason matrix.
- Late vs On-time delivery return-rate comparison.
- Monthly returns/refund trend.
- Region × late delivery performance table.

### Analytical story
Test whether operational friction (especially late delivery) is associated with return behavior. Do not claim causality from this synthetic observational dataset.

## Page 4 — Customer & Commercial Intelligence

### KPI cards
- Customers
- AOV
- Repeat Customer %
- Profit per Customer

### Visuals
- New/one-time vs Repeat comparison.
- Customer profitability segmentation.
- Region × Customer Segment matrix.
- Top customers by Gross Profit.
- Acquisition Channel profitability.

## Recommended Slicers

Keep slicers consistent across pages where practical:

- Date
- Region
- Category
- Customer Segment
- Acquisition Channel

## DAX Measure Naming

Use the clean `m_` prefix for measures, as documented in `DAX_MEASURES.md`.

Avoid hard-coded KPI numbers. All dashboard KPIs should be driven by measures.

## Design Principles

- One clear executive message per page.
- Avoid overcrowding.
- Prefer business labels over technical field names.
- Use consistent number formats: currency, %, counts.
- Add dynamic titles where useful.
- Keep detailed explanations in tooltips rather than filling the canvas with text.
- Every major visual should answer a business question.
- Use conditional formatting sparingly to surface risk/opportunity, not as decoration.
- Keep whitespace intentional and align visuals to a consistent grid.
