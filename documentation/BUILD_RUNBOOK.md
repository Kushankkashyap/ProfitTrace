# ProfitTrace | Build Runbook

## Project state

The ProfitTrace build has been executed and the final portfolio evidence is committed to GitHub.

- Seven SQL scripts executed successfully.
- Final Power BI model and four-page dashboard completed.
- 32 DAX measures implemented.
- Four final dashboard screenshots committed.
- Final PBIX committed at powerbi/ProfitTrace_Dashboard.pbix.
- Final PDF committed at ProfitTrace_Dashboard.pdf.

This runbook remains the reproducible build reference.

## Source and SQL execution

Expected source counts:

Customers 1,000 | Products 300 | Orders 15,000 | Shipping 15,000 | Returns 1,155

Run the seven SQL scripts in order:

01_Database_Setup.sql
02_Import_Raw_Data.sql
03_Data_Validation.sql
04_Data_Cleaning.sql
05_Business_Analysis.sql
06_Post_Load_QA.sql
07_Final_Portfolio_QA.sql

The five datasets load into stg.Customers, stg.Products, stg.Orders, stg.Shipping and stg.Returns.

### Shipping import handling

The Shipping source contains 281 blank values in each of ship_date, promised_delivery_date and delivery_date. The typed staging layer preserves these as SQL NULLs.

When direct CSV date conversion is not accepted by the import wizard, the controlled landing-layer approach is:

1. Import Shipping.csv into temporary dbo.Shipping_Raw as text.
2. Validate the raw rows and date text.
3. Insert into typed stg.Shipping using TRY_CONVERT and NULLIF with trimmed text.
4. Verify 15,000 rows and 15,000 unique order IDs.
5. Drop the temporary raw table after successful transfer.

## Analytical SQL

03_Data_Validation.sql checks row counts, required fields, discount range, product economics, refunds/costs, text variants, orphan records, shipment uniqueness and date consistency.

04_Data_Cleaning.sql creates:

- analytics.vw_OrderProfitability
- analytics.vw_ReturnsOperations
- analytics.vw_CustomerProfitability

The profitability view stays at order-product-line grain. Order-level refunds, shipping and return costs are allocated across lines so aggregation does not double-count order-level economics.

Core commercial scope is is_delivered = 1. The corresponding Power BI revenue, profit and customer-economic measures use the same rule.

## Power BI

Final facts:

- FactProfitability from analytics.vw_OrderProfitability
- FactReturns from analytics.vw_ReturnsOperations

Final dimensions:

- DimDate
- DimCustomer
- DimProduct

Relationships are 1:* and single-direction from dimensions to facts. There is no direct fact-to-fact relationship. FactReturns is not related to DimProduct because the return source has no reliable product identifier.

The final PBIX contains 32 DAX measures, including revenue/profit KPIs, return and delivery metrics, customer metrics, opportunity measures, waterfall support and discount-band profitability support.

## Final dashboard

### Page 1 | Executive Profit Command Center

KPI cards: Net Revenue, Gross Profit, Profit Margin %, Return Rate %, Delivered Orders, Return Leakage %.

Visuals: Revenue vs Gross Profit Trend; Profit Contribution by Category; Where Revenue Turns Into Profit; Revenue vs Margin.

### Page 2 | Profitability Deep Dive

KPI cards: Net Revenue, Gross Profit, Profit Margin %, AOV.

Visuals: Margin by Category; Revenue Mix; High Revenue, Low Margin Opportunities; Discounting vs Profitability; Product Profitability Matrix.

### Page 3 | Returns & Operational Leakage

KPI cards: Returned Orders, Return Rate %, Refund Value, Return Leakage %, Late Delivery %.

Visuals: Why Customers Return; Monthly Refund Leakage; Return Reason Mix; Delivery Performance vs Returns; Return Event Detail.

### Page 4 | Customer & Commercial Intelligence

KPI cards: Customers, Orders Per Customer, Repeat Customer %, Profit per Customer.

Visuals: Profit by Customer Segment; Commercial Performance by Acquisition Channel; Regional Profitability; Top Profit-Contributing Customers; Channel Scorecard.

## Final evidence

ProfitTrace_Dashboard.pdf
powerbi/ProfitTrace_Dashboard.pbix
screenshots/executive_profit_command_center.png
screenshots/profitability_deep_dive.png
screenshots/returns_operational_leakage.png
screenshots/customer_commercial_intelligence.png