# ProfitTrace | Power BI Build Checklist

## Objective
Build a four-page executive analytics dashboard that answers **where revenue is made, where profit leaks, and what management should investigate next**.

Core commercial economics use delivered orders (`is_delivered = 1`) so SQL and Power BI reconcile to the same business scope.

## Model

Import `analytics.vw_OrderProfitability` as `FactProfitability`.

Import `analytics.vw_ReturnsOperations` as `FactReturns`.

Create dimensions from the corresponding fields:

- `DimDate` — Date, Year, Quarter, Month, Year Month
- `DimCustomer` — Customer ID, Segment, Region, Acquisition Channel
- `DimProduct` — Product ID, Product Name, Category, Subcategory

Relationships:

- `DimDate[Date]` → `FactProfitability[order_date]`
- `DimDate[Date]` → `FactReturns[return_date]`
- `DimCustomer[customer_id]` → `FactProfitability[customer_id]`
- `DimCustomer[customer_id]` → `FactReturns[customer_id]`
- `DimProduct[product_id]` → `FactProfitability[product_id]`

Use one-to-many, single-direction relationships from dimensions to facts. Do not create a direct fact-to-fact relationship.

The return source has no reliable product identifier. Do not build product/category return attribution from `FactReturns`.

## Page 1 — Executive Profit Command Center

**Purpose:** answer the executive question in 15–20 seconds.

Top KPI row:
1. Gross Revenue
2. Net Revenue
3. Gross Profit
4. Profit Margin %
5. Delivered Orders
6. Return Rate %

Visual layout:

- Monthly Net Revenue vs Gross Profit trend
- Gross Profit by Category
- Profit Margin by Region
- Profit leakage waterfall: Gross Revenue → Discount Value → Refund Value → Product Cost → Shipping Cost → Return Cost → Gross Profit
- Management watchlist: high-revenue / low-margin products or categories

## Page 2 — Profitability Deep Dive

**Purpose:** find profitable and unprofitable commercial pockets.

Visuals:

- Category → Subcategory → Product matrix
- Revenue vs Gross Profit scatter
- Discount Rate % vs Profit Margin % scatter; bubble size = Net Revenue
- Top 10 products by Gross Profit
- Bottom 10 products by Profit Margin

Tooltip fields:

- Gross Revenue
- Discount Value
- Discount Rate %
- Refund Value
- Net Revenue
- Gross Profit
- Profit Margin %
- Return Rate %

## Page 3 — Returns & Operational Leakage

**Purpose:** quantify return/refund leakage and investigate delivery experience without overstating causality.

KPI row:
1. Delivered Orders
2. Returned Orders
3. Return Rate %
4. Refund Value
5. Late Delivery %

Visuals:

- Refund Value by Return Reason
- Return Event Count by Return Reason
- Acquisition Channel × Return Reason matrix
- Return Rate: Late vs On-time
- Monthly Refund Value trend
- Region × Late Delivery % table

Use wording such as **“associated with”** rather than **“caused by”** when discussing late delivery and returns.

## Page 4 — Customer & Commercial Intelligence

**Purpose:** identify customer economics and commercial opportunities.

KPI row:
1. Customers
2. Orders per Customer
3. Repeat Customer %
4. Profit per Customer

Visuals:

- One-time vs Repeat: Customers / Net Revenue / Gross Profit
- Customer profitability segmentation
- Region × Customer Segment matrix
- Top 15 customers by Gross Profit
- Acquisition Channel: Revenue vs Profit Margin

## Slicers

Use consistent slicers where useful:

- Date
- Region
- Category
- Customer Segment
- Acquisition Channel

Avoid slicer overload. Keep the executive page especially clean.

## Interaction rules

- Category selections should cross-filter product visuals.
- Date selections should update all measures.
- Tooltips should explain the metric, not repeat the visual title.
- Avoid unnecessary many-to-many relationships.
- Do not use FactReturns fields as if they were product-level fields.

## Visual quality gate

Before screenshots:

- No overlapping objects.
- No clipped titles or labels.
- No technical field names visible to the viewer.
- Currency and percentages formatted consistently.
- Titles communicate the business question.
- Charts have meaningful sorting.
- No chart is included merely because the page has empty space.
- KPI cards have enough whitespace and consistent alignment.
- Final pages look intentional at 100% report view.

## Evidence checklist

Capture four clean screenshots after the PBIX is complete:

1. Executive Profit Command Center
2. Profitability Deep Dive
3. Returns & Operational Leakage
4. Customer & Commercial Intelligence

Screenshots should show the completed report canvas, not the Power BI editing experience.
