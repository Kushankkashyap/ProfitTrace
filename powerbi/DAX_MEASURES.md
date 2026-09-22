# ProfitTrace | Final DAX Measure Pack

The final Power BI model contains 32 measures using clean business-facing names.

**Measure-count reconciliation:** 14 Core + 9 Returns & Operations + 5 Customer + 2 Opportunity + 2 Support = **32 measures**. The two support measures are `Waterfall Value` and `Discount Band Profit Margin %`.

## Core measures

Orders = DISTINCTCOUNT(FactProfitability[order_id])

Delivered Orders = CALCULATE([Orders], FactProfitability[is_delivered] = 1)

Gross Revenue = CALCULATE(SUM(FactProfitability[gross_revenue]), FactProfitability[is_delivered] = 1)

Discount Value = CALCULATE(SUM(FactProfitability[discount_value]), FactProfitability[is_delivered] = 1)

Net Revenue = CALCULATE(SUM(FactProfitability[net_revenue]), FactProfitability[is_delivered] = 1)

Refund Value = CALCULATE(SUM(FactProfitability[refund_amount]), FactProfitability[is_delivered] = 1)

Product Cost = CALCULATE(SUM(FactProfitability[product_cost]), FactProfitability[is_delivered] = 1)

Shipping Cost = CALCULATE(SUM(FactProfitability[shipping_cost]), FactProfitability[is_delivered] = 1)

Return Cost = CALCULATE(SUM(FactProfitability[return_cost]), FactProfitability[is_delivered] = 1)

Gross Profit = CALCULATE(SUM(FactProfitability[gross_profit]), FactProfitability[is_delivered] = 1)

Profit Margin % = DIVIDE([Gross Profit], [Net Revenue])
AOV = DIVIDE([Net Revenue], [Delivered Orders])
Discount Rate % = DIVIDE([Discount Value], [Gross Revenue])
Profit per Order = DIVIDE([Gross Profit], [Delivered Orders])

## Returns and operations

Return Events = COUNTROWS(FactReturns)

Approved Return Events = CALCULATE([Return Events], FactReturns[return_status] = "Approved")

Returned Orders = CALCULATE([Orders], FactProfitability[is_returned] = 1, FactProfitability[is_delivered] = 1)

Return Rate % = DIVIDE([Returned Orders], [Delivered Orders])

Late Orders = CALCULATE([Orders], FactProfitability[is_late_delivery] = 1, FactProfitability[is_delivered] = 1)

Late Delivery % = DIVIDE([Late Orders], [Delivered Orders])

Return Refund Value = CALCULATE(SUM(FactReturns[refund_amount]), FactReturns[return_status] = "Approved")

Return Event Cost = CALCULATE(SUM(FactReturns[total_return_cost]), FactReturns[return_status] = "Approved")

Return Leakage % = DIVIDE([Refund Value] + [Return Cost], [Gross Revenue])

## Customer

Customers = CALCULATE(DISTINCTCOUNT(FactProfitability[customer_id]), FactProfitability[is_delivered] = 1)

Orders per Customer = DIVIDE([Delivered Orders], [Customers])

Repeat Customers = COUNTROWS(FILTER(VALUES(FactProfitability[customer_id]), CALCULATE(DISTINCTCOUNT(FactProfitability[order_id]), FactProfitability[is_delivered] = 1) > 1))

Repeat Customer % = DIVIDE([Repeat Customers], [Customers])

Profit per Customer = DIVIDE([Gross Profit], [Customers])

## Opportunity

Low Margin Revenue = delivered Net Revenue where line-level gross profit divided by line-level net revenue is below 15%.

Return Refund per Returned Order = DIVIDE([Refund Value], [Returned Orders])

## Helper tables and support

Waterfall Steps contains Gross Revenue, Discount Value, Refund Value, Product Cost, Shipping Cost and Return Cost.

Waterfall Value returns the positive Gross Revenue and negative downstream leakage values for the native waterfall.

Discount Bands are 0-5%, 5-10%, 10-15%, 15-20%, 20-25% and 25-30%.

Discount Band Profit Margin % calculates the margin for the selected discount band.

## Date table

DimDate is built from the minimum and maximum order_date in FactProfitability and includes Year, Month Number, Month, Year Month and Quarter.

Sort Month by Month Number and use Year Month for chronological trends.

## Formatting

Currency: revenue, discounts, refunds, costs, profit and AOV.
Percentage: margin, discount rate, return rate, late delivery rate and return leakage.
Whole number: orders, customers, repeat customers, return events and returned orders.

Final KPI note: Repeat Customer % remains a model measure for analysis/documentation, but is not used as a final dashboard KPI because the synthetic dataset produces multiple delivered orders for all customers.