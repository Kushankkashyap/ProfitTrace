# ProfitTrace | Portfolio QA Checklist

## Data
- [x] Customers = 1,000.
- [x] Products = 300.
- [x] Orders = 15,000.
- [x] Shipping = 15,000.
- [x] Returns = 1,155.
- [x] Shipping order IDs are unique.
- [x] Shipping blank delivery dates are preserved as NULL in the typed layer.
- [x] Intentional source-quality issues are visible before cleaning.

## SQL
- [x] Seven SQL scripts are present.
- [x] Staging tables are typed.
- [x] Validation, cleaning and business-analysis layers are separated.
- [x] Profitability remains at order-product-line grain.
- [x] Order-level financial values are allocated safely.
- [x] Core profitability uses is_delivered = 1.
- [x] Post-load and final QA scripts were executed.
- [x] No credentials or secrets are committed.

## Power BI
- [x] FactProfitability and FactReturns present.
- [x] DimDate, DimCustomer and DimProduct present.
- [x] Relationships are 1:* single-direction.
- [x] No direct fact-to-fact relationship.
- [x] FactReturns not connected to DimProduct.
- [x] 32 DAX measures implemented.
- [x] Core revenue/profit/customer metrics use delivered-order scope.
- [x] Four dashboard pages complete.

## Dashboard
- [x] Executive page complete.
- [x] Profitability page complete.
- [x] Returns and operational leakage page complete.
- [x] Customer and commercial page complete.
- [x] Slicers and interactions configured.
- [x] Currency and percentage formats consistent.
- [x] No temporary placeholder visuals remain.
- [x] Top customer visual limited to exactly 10 customers.

## Evidence
- [x] Four final screenshots committed.
- [x] ProfitTrace_Dashboard.pdf committed at repository root.
- [x] powerbi/ProfitTrace_Dashboard.pbix committed.

## Documentation
- [x] Root README describes the finished state.
- [x] PBIX and PDF paths documented.
- [x] Screenshot paths documented.
- [x] Synthetic-data disclaimer present.
- [x] Association/causation guardrail present.
- [x] Return product-key limitation documented.