# ProfitTrace | Power BI Build Checklist

## Objective
Build a four-page executive analytics dashboard that answers **where revenue is made, where profit leaks, and what management should investigate next**.

## Model

Import:

- `analytics.vw_OrderProfitability` as `FactProfitability`
- `analytics.vw_ReturnsOperations` as `FactReturns`

Create:

- `DimDate` — Date, Year, Quarter, Month Number, Month, Year Month
- `DimCustomer` — Customer ID, Name, Segment, Region, State, City, Acquisition Channel
- `DimProduct` — Product ID, Name, Category, Subcategory, Brand, Tier, Rating

Relationships:

- DimDate[Date] → FactProfitability[order_date]
- DimDate[Date] → FactReturns[return_date]
- DimCustomer[customer_id] → FactProfitability[customer_id]
- DimCustomer[customer_id] → FactReturns[customer_id]
- DimProduct[product_id] → FactProfitability[product_id]

Use one-to-many, single-direction relationships from dimensions to facts. Do not create a direct fact-to-fact relationship.

Because the returns source has no reliable product identifier, do not create product/category return attribution from `FactReturns`.

## Measures

Create the DAX measures from `powerbi/DAX_MEASURES.md`.

Use clean business-facing names such as `Net Revenue`, `Gross Profit`, `Profit Margin %`, `Return Rate %` and `Return Leakage %`. Do not use a technical `m_` prefix. Organize measures in a dedicated Measures table or display folder.

## Page 1 — Executive Profit Command Center

**Purpose:** answer the executive question in 15–20 seconds.

Top KPI row:
1. Net Revenue
2. Gross Profit
3. Profit Margin %
4. Delivered Orders
5. Return Rate %
6. Return Leakage %

Visual layout:

- Monthly Revenue vs Gross Profit trend
- Profit Contribution by Category
- Profitability Leakage waterfall
- Revenue vs Margin scatter
- Management opportunity table

## Page 2 — Profitability Deep Dive

**Purpose:** find profitable and unprofitable commercial pockets.

KPI row:
1. Net Revenue
2. Gross Profit
3. Profit Margin %
4. AOV

Visuals:

- Category → Subcategory → Product matrix
- Revenue vs Gross Profit scatter
- Discount Rate % vs Profit Margin % scatter; bubble size = Net Revenue
- High Revenue / Low Margin opportunities
- Top products by Gross Profit
- Bottom products by Profit Margin

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

**Purpose:** quantify return/refund leakage and investigate delivery experience.

KPI row:
1. Returned Orders
2. Return Rate %
3. Refund Value
4. Return Leakage %
5. Late Delivery %

Visuals:

- Return Reason by Refund Value
- Return Reason by Return Event Count
- Monthly Refund Leakage trend
- Delivery Performance vs Returns
- Return Event Detail table

Use `FactReturns` for return-event reasons, counts, refund values and detail. Use `FactProfitability` for returned orders, return rate and late-delivery comparisons.

Use wording such as **“Late deliveries show a higher return rate”** rather than **“Late delivery causes returns.”**

## Page 4 — Customer & Commercial Intelligence

**Purpose:** identify customer economics and commercial opportunities.

KPI row:
1. Customers
2. Orders per Customer
3. Repeat Customer %
4. Profit per Customer

Visuals:

- One-Time vs Repeat customer economics
- Profit by Customer Segment
- Region × Customer Segment matrix
- Acquisition Channel performance
- Top customers by Gross Profit

## Slicers

Use consistent slicers where useful:

- Year / Month
- Region
- Category
- Customer Segment
- Acquisition Channel

Avoid slicer overload. Keep the executive page especially clean.

## Interaction rules

- Category selections should cross-filter product profitability visuals.
- Region selections should update profitability and customer visuals.
- Date selections should update all date-aware measures.
- Tooltips should explain the metric, not repeat the visual title.
- Avoid unnecessary many-to-many relationships.

## Visual quality gate

Before screenshots:

- No overlapping objects.
- No clipped titles or labels.
- No technical field names visible to the viewer.
- Currency and percentages formatted consistently.
- Titles communicate the business question.
- Charts have meaningful sorting.
- Monthly trends are chronological.
- KPI cards use measures, not raw columns.
- No chart exists merely to fill empty space.
- No placeholder or blank visuals remain.
- Page 3 does not imply unsupported product/category return attribution.
- Return events are not confused with returned orders.
- The final pages look intentional at 100% report view.

## Evidence checklist

Capture four clean screenshots after the PBIX is complete:

1. Executive Profit Command Center
2. Profitability Deep Dive
3. Returns & Operational Leakage
4. Customer & Commercial Intelligence

Use these exact filenames:

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

Screenshots should show the completed report canvas, not the Power BI editing experience.
