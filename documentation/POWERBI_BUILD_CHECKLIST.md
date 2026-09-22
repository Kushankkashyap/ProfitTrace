# ProfitTrace | Power BI Build Checklist

## Model

- [x] FactProfitability loaded from analytics.vw_OrderProfitability.
- [x] FactReturns loaded from analytics.vw_ReturnsOperations.
- [x] DimDate created.
- [x] DimCustomer created.
- [x] DimProduct created.
- [x] 1:* single-direction relationships used.
- [x] No direct fact-to-fact relationship.
- [x] FactReturns not connected to DimProduct.
- [x] Core realized-order economics use is_delivered = 1.

## DAX

- [x] Core revenue and profit measures.
- [x] Return and delivery measures.
- [x] Customer and repeat-customer measures are implemented in the model.
- [x] Repeat Customer % is not used as a final KPI because all customers in the synthetic dataset are repeat customers.
- [x] Opportunity measures.
- [x] Waterfall support.
- [x] Discount-band profitability support.
- [x] Clean business-facing names.
- [x] Final measure count: 32.

## Final pages

- [x] Page 1 Executive Profit Command Center.
- [x] Page 2 Profitability Deep Dive.
- [x] Page 3 Returns & Operational Leakage.
- [x] Page 4 Customer & Commercial Intelligence.

## Visual QA

- [x] Number formats consistent.
- [x] Chronological month labels.
- [x] Business-friendly titles.
- [x] Measure-driven KPI cards.
- [x] No blank placeholder visuals.
- [x] Return source-key limitation respected.
- [x] Late-delivery language preserves association rather than causation.
- [x] Final screenshots captured.
- [x] Page 3 return-event detail exposes Return Status.
- [x] Page 3 monthly refund leakage is presented by return month.
- [x] Final PBIX committed.
- [x] Final PDF committed.