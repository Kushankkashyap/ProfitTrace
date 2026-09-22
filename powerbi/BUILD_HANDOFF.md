# ProfitTrace | Power BI Build Handoff

## Final Status

The Power BI build is complete. The final report is committed at powerbi/ProfitTrace_Dashboard.pbix.

Supporting evidence: ProfitTrace_Dashboard.pdf and the four final PNG screenshots.

## Semantic model

Facts: FactProfitability and FactReturns.
Dimensions: DimDate, DimCustomer and DimProduct.

Relationships:
- DimDate to FactProfitability on order_date, 1:*.
- DimDate to FactReturns on return_date, 1:*.
- DimCustomer to both facts on customer_id, 1:*.
- DimProduct to FactProfitability on product_id, 1:*.

All relationships are single-direction from dimensions to facts. There is no direct fact-to-fact relationship.

FactReturns is intentionally not related to DimProduct because the return source has no reliable product identifier.

## DAX

The final model contains 32 business-facing measures covering revenue, profit, margin, discounting, returns, delivery, customer economics, opportunities, waterfall logic and discount-band analysis.

Full definitions are documented in DAX_MEASURES.md.

## Final pages

Page 1 | Executive Profit Command Center: six KPI cards plus revenue/profit trend, category contribution, profit bridge waterfall and revenue-vs-margin analysis.

Page 2 | Profitability Deep Dive: four KPI cards plus category margin, revenue mix, high-revenue/low-margin opportunities, discounting-vs-profitability and product profitability matrix.

Page 3 | Returns & Operational Leakage: five KPI cards plus return reasons, monthly refund leakage by return month, return rate by category, return rate by delivery status and return-event detail.

Page 4 | Customer & Commercial Intelligence: four KPI cards plus customer-segment profit, acquisition-channel performance, regional profitability, top ten customers, profit per order and channel scorecard.

## Design

Design system: the final report uses manually configured page backgrounds, white visual cards and consistent business-oriented formatting. The JSON theme file is not part of the final implementation.

## Portfolio notes

- Source data is synthetic.
- Core realized-order economics use is_delivered = 1.
- Return-event analysis does not invent product/category attribution.
- Late delivery versus returns is presented as observed association, not causal proof.