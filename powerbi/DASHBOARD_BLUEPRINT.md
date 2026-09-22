# ProfitTrace | Final Power BI Dashboard Blueprint

This document reflects the final implemented report.

## Semantic model

FactProfitability = analytics.vw_OrderProfitability, one order-product analytical row.
FactReturns = analytics.vw_ReturnsOperations, one return event.
Dimensions = DimDate, DimCustomer, DimProduct.

Relationships:
- DimDate to FactProfitability on order_date.
- DimDate to FactReturns on return_date.
- DimCustomer to both facts on customer_id.
- DimProduct to FactProfitability on product_id.

All relationships are 1:* and single-direction. No direct fact-to-fact relationship exists.

## Page 1 | Executive Profit Command Center

KPIs: Net Revenue, Gross Profit, Profit Margin %, Return Rate %, Delivered Orders, Return Leakage %.
Filters: Year Month, Region, Category, Customer Segment, Acquisition Channel.
Visuals: Revenue vs Gross Profit Trend; Profit Contribution by Category; Where Revenue Turns Into Profit; Revenue vs Margin.

## Page 2 | Profitability Deep Dive

KPIs: Net Revenue, Gross Profit, Profit Margin %, AOV.
Visuals: Margin by Category; Revenue Mix; High Revenue, Low Margin Opportunities; Discounting vs Profitability; Product Profitability Matrix.

## Page 3 | Returns & Operational Leakage

KPIs: Returned Orders, Return Rate %, Refund Value, Return Leakage %, Late Delivery %.
Visuals: Why Customers Return; Monthly Refund Leakage by Return Month; Return Rate by Category; Return Rate by Delivery Status; Return Event Detail.

The final report intentionally avoids Category × Return Reason because the source return extract has no reliable product/category identifier.
Late-delivery comparisons are presented as observed relationships, not proof of causation.

## Page 4 | Customer & Commercial Intelligence

KPIs: Customers, Orders Per Customer, Profit per Order, Profit per Customer.
Visuals: Profit by Customer Segment; Commercial Performance by Acquisition Channel; Regional Profitability; Top Profit-Contributing Customers; Channel Scorecard.

The Top Profit-Contributing Customers visual is filtered to exactly 10 customers.

## Design system

Design system: manually configured page backgrounds, white visual cards and consistent business-oriented formatting. The JSON theme file is not part of the final implementation.