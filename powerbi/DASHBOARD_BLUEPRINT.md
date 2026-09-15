# ProfitTrace | Power BI Dashboard Blueprint

Build the `.pbix` only after the SQL staging, cleaning and QA steps are complete.

## 1. Semantic Model

Use a simple star schema:

```text
                 DimDate
                    |
DimCustomer ---- FactProfitability ---- DimProduct
                    |
                FactReturns
```

### Facts

`FactProfitability` = `analytics.vw_OrderProfitability`

**Grain:** one order-product analytical row. The model keeps the grain explicit so profitability metrics can be aggregated safely.

`FactReturns` = `analytics.vw_ReturnsOperations`

**Grain:** one return event. This fact is used for event-level return reasons, return dates and return financial detail.

### Dimensions

**DimDate**
- Date
- Year
- Quarter
- Month Number
- Month
- Year Month

**DimCustomer**
- customer_id
- customer_name
- customer_segment
- region
- state
- city
- acquisition_channel

**DimProduct**
- product_id
- product_name
- category
- subcategory
- brand
- product_tier
- rating

### Relationships

- `DimDate[Date]` → `FactProfitability[order_date]` 1:*, single direction
- `DimDate[Date]` → `FactReturns[return_date]` 1:*, single direction
- `DimCustomer[customer_id]` → `FactProfitability[customer_id]` 1:*, single direction
- `DimCustomer[customer_id]` → `FactReturns[customer_id]` 1:*, single direction
- `DimProduct[product_id]` → `FactProfitability[product_id]` 1:*, single direction

Do not create a direct fact-to-fact relationship.

The Returns source does not contain a reliable product identifier, so `FactReturns` must not be joined to `DimProduct`. Do not create product/category return attribution from an unsupported relationship. Product/category profitability comes from `FactProfitability`; return-event analysis comes from `FactReturns`.

## 2. Page: Executive Profit Command Center

**Purpose:** answer where revenue becomes profit and where it leaks.

### KPI cards
- Gross Revenue
- Net Revenue
- Gross Profit
- Profit Margin %
- Delivered Orders
- Return Rate %

### Visuals
1. Monthly Net Revenue and Gross Profit trend.
2. Gross Profit by Category.
3. Profit Margin by Region.
4. Profit Leakage waterfall: Gross Revenue → Discounts → Refunds → Product Cost → Shipping/Return Cost → Gross Profit.
5. High-Revenue / Low-Margin product or category table.

### Executive callout
Use a dynamic text/card to highlight the selected category or product with the largest profit opportunity.

## 3. Page: Profitability Deep Dive

**Purpose:** find products that sell well but do not create proportionate profit.

### Visuals
- Category → Subcategory → Product matrix.
- Net Revenue vs Gross Profit scatter.
- Discount % vs Profit Margin % scatter, bubble size = Net Revenue.
- Bottom products by margin.
- Top products by gross profit.

### Useful tooltip fields
Revenue, discount value, refund value, net revenue, product cost, shipping cost, return cost, gross profit, margin and return rate.

## 4. Page: Returns & Operational Leakage

**Purpose:** connect customer returns to operational and financial leakage without overstating causality.

### KPI cards
- Returned Orders
- Return Rate %
- Refund Value
- Late Delivery %

### Visuals
- Return reason by refund value.
- Return reason by return-event count.
- Late vs On-Time return rate.
- Monthly refund/return trend.
- Customer or acquisition-channel return activity table.

### Analytical guardrail
Use wording such as **"Late deliveries show a higher return rate"**, not **"Late delivery causes returns"**. Do not claim product/category return attribution because the return source has no reliable product identifier.

## 5. Page: Customer & Commercial Intelligence

**Purpose:** understand which customers and acquisition sources create sustainable value.

### KPI cards
- Customers
- AOV
- Repeat Customer %
- Profit per Customer

### Visuals
- One-Time vs Repeat economics.
- Customer profitability distribution.
- Region × Customer Segment matrix.
- Acquisition Channel revenue vs profit.
- Top customers by Gross Profit.

## 6. Global Slicers

Use consistently where useful:

- Date
- Region
- Category
- Customer Segment
- Acquisition Channel

## 7. Interaction Rules

- Category selection filters product-level profitability visuals.
- Region selection filters profitability and customer visuals.
- Cross-page slicers should remain consistent.
- Tooltips should explain the metric, not repeat the chart title.
- Avoid excessive drillthrough pages. The four main pages should tell the story without navigation friction.

## 8. Visual Design

Aim for an executive BI report rather than a dashboard full of decorative charts.

- Clear page title and one-sentence business question.
- KPI cards aligned in one row.
- One primary visual hierarchy per page.
- Consistent currency and percentage formats.
- Minimal borders and unnecessary icons.
- Conditional formatting only where it communicates risk or opportunity.
- Keep enough whitespace for the report to feel intentional.
