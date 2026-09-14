# ProfitTrace — Power BI Dashboard Blueprint

This file is the build specification for the final `.pbix`. **Do not start dashboard design until the SQL layer has been loaded and validated.**

## Semantic Model

Recommended model:

```text
                 DimDate
                    |
DimCustomers ── FactOrders ── DimProducts
                    |
             Order-level aggregates
                /           \
        FactReturns      FactShipping
```

For the first build, it is acceptable to import the cleaned `analytics.vw_OrderProfitability` view as the main analytical fact and use dedicated dimensions for Date, Customer and Product. Returns/Shipping should be pre-aggregated or modeled separately so order-level metrics are not duplicated.

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
3. Regional Profit Margin matrix/map-style visual.
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

Use a clean `m_` prefix for measures, for example:

```DAX
m_Gross Revenue
m_Net Revenue
m_Gross Profit
m_Profit Margin %
m_Return Rate %
m_AOV
m_Discount Rate %
m_Late Delivery %
m_Profit per Order
```

Avoid hard-coded KPI numbers. All dashboard KPIs should be driven by measures.

## Design Principles

- One clear executive message per page.
- Avoid overcrowding.
- Prefer business labels over technical field names.
- Use consistent number formats: currency, %, counts.
- Add dynamic titles where useful.
- Keep detailed explanations in tooltips rather than filling the canvas with text.
- Every major visual should answer a business question.
