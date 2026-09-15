# ProfitTrace | DAX Measure Pack

Recommended model:

- `FactProfitability` from `analytics.vw_OrderProfitability`
- `FactReturns` from `analytics.vw_ReturnsOperations`
- `DimDate`, `DimCustomer`, `DimProduct`

All measures use clean business-facing names. No technical prefix is required because the measures can be organized in a dedicated Measures table/display folder in Power BI.

## Core KPIs

```DAX
Orders = DISTINCTCOUNT(FactProfitability[order_id])
Delivered Orders = CALCULATE([Orders], FactProfitability[is_delivered] = 1)
Gross Revenue = SUM(FactProfitability[gross_revenue])
Discount Value = SUM(FactProfitability[discount_value])
Net Revenue = SUM(FactProfitability[net_revenue])
Refund Value = SUM(FactProfitability[refund_amount])
Product Cost = SUM(FactProfitability[product_cost])
Shipping Cost = SUM(FactProfitability[shipping_cost])
Return Cost = SUM(FactProfitability[return_cost])
Gross Profit = SUM(FactProfitability[gross_profit])
Profit Margin % = DIVIDE([Gross Profit], [Net Revenue])
AOV = DIVIDE([Net Revenue], [Delivered Orders])
Discount Rate % = DIVIDE([Discount Value], [Gross Revenue])
Profit per Order = DIVIDE([Gross Profit], [Delivered Orders])
```

## Returns & Operations

Use the profitability fact for order-level return rate and delivery metrics because it has one analytical row per order-product line with order-level return costs allocated across lines. Use the return fact for event-level return reasons and return financial detail.

```DAX
Return Events = COUNTROWS(FactReturns)
Approved Return Events = CALCULATE([Return Events], FactReturns[return_status] = "Approved")
Returned Orders = CALCULATE([Orders], FactProfitability[is_returned] = 1, FactProfitability[is_delivered] = 1)
Return Rate % = DIVIDE([Returned Orders], [Delivered Orders])
Late Orders = CALCULATE([Orders], FactProfitability[is_late_delivery] = 1, FactProfitability[is_delivered] = 1)
Late Delivery % = DIVIDE([Late Orders], [Delivered Orders])
Return Refund Value = CALCULATE(SUM(FactReturns[refund_amount]), FactReturns[return_status] = "Approved")
Return Event Cost = CALCULATE(SUM(FactReturns[total_return_cost]), FactReturns[return_status] = "Approved")
Return Leakage % = DIVIDE([Refund Value] + [Return Cost], [Gross Revenue])
```

`Returned Orders` and `Return Rate %` are deliberately based on `FactProfitability`, preventing a multi-event return order from being counted multiple times. `Return Events` is an event count and can legitimately exceed returned orders.

## Customer Metrics

```DAX
Customers = DISTINCTCOUNT(FactProfitability[customer_id])
Orders per Customer = DIVIDE([Delivered Orders], [Customers])
Repeat Customers =
COUNTROWS(
    FILTER(
        VALUES(FactProfitability[customer_id]),
        CALCULATE(DISTINCTCOUNT(FactProfitability[order_id]), FactProfitability[is_delivered] = 1) > 1
    )
)
Repeat Customer % = DIVIDE([Repeat Customers], [Customers])
Profit per Customer = DIVIDE([Gross Profit], [Customers])
```

## Opportunity Measures

```DAX
Low Margin Revenue =
CALCULATE(
    [Net Revenue],
    FILTER(FactProfitability, DIVIDE(FactProfitability[gross_profit], FactProfitability[net_revenue]) < 0.15)
)

Return Refund per Returned Order = DIVIDE([Refund Value], [Returned Orders])
```

Use these as decision-support measures, not as replacements for the underlying profitability calculations.

## Date Table

```DAX
DimDate =
ADDCOLUMNS(
    CALENDAR(MIN(FactProfitability[order_date]), MAX(FactProfitability[order_date])),
    "Year", YEAR([Date]),
    "Month Number", MONTH([Date]),
    "Month", FORMAT([Date], "MMM"),
    "Year Month", FORMAT([Date], "YYYY-MM"),
    "Quarter", "Q" & FORMAT([Date], "Q")
)
```

Sort `DimDate[Month]` by `DimDate[Month Number]` and use `Year Month` for chronological trends.

## Model Relationships

```text
                       DimDate
                      /       \\
                     /         \\
DimCustomer ---- FactProfitability   FactReturns
                     |
                 DimProduct
```

Relationships:

- `DimDate[Date]` 1:* `FactProfitability[order_date]`
- `DimDate[Date]` 1:* `FactReturns[return_date]`
- `DimCustomer[customer_id]` 1:* both facts
- `DimProduct[product_id]` 1:* `FactProfitability[product_id]`

All relationships should use single-direction filtering from dimensions to facts. Do not create a direct fact-to-fact relationship.

The returns source does not contain a product identifier, so `FactReturns` should not be joined to `DimProduct`. Use `FactProfitability` for product/category profitability and use `FactReturns` for return-event analysis.

## Formatting

- Currency: revenue, discounts, refunds, costs, profit, AOV.
- Percentage: margin, discount rate, return rate, late delivery rate, return leakage, repeat customer %.
- Whole number: orders, customers, return events and returned orders.
- Keep measure names clean and business-facing. Organize measures in a dedicated Measures table or display folder for model hygiene.
