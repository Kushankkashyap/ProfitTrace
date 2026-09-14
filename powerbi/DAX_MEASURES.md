# ProfitTrace | DAX Measure Pack

Recommended model:

- `FactProfitability` from `analytics.vw_OrderProfitability`
- `FactReturns` from `analytics.vw_ReturnsOperations`
- `DimDate`, `DimCustomer`, `DimProduct`

## Core KPIs

```DAX
m_Orders = DISTINCTCOUNT(FactProfitability[order_id])
m_Delivered Orders = CALCULATE([m_Orders], FactProfitability[is_delivered] = 1)
m_Gross Revenue = SUM(FactProfitability[gross_revenue])
m_Discount Value = SUM(FactProfitability[discount_value])
m_Net Revenue = SUM(FactProfitability[net_revenue])
m_Refund Value = SUM(FactProfitability[refund_amount])
m_Product Cost = SUM(FactProfitability[product_cost])
m_Shipping Cost = SUM(FactProfitability[shipping_cost])
m_Return Cost = SUM(FactProfitability[return_cost])
m_Gross Profit = SUM(FactProfitability[gross_profit])
m_Profit Margin % = DIVIDE([m_Gross Profit], [m_Net Revenue])
m_AOV = DIVIDE([m_Net Revenue], [m_Delivered Orders])
m_Discount Rate % = DIVIDE([m_Discount Value], [m_Gross Revenue])
m_Profit per Order = DIVIDE([m_Gross Profit], [m_Delivered Orders])
```

## Returns & Operations

Use the profitability fact for order-level return rate and delivery metrics because it has one analytical row per order-product line with order-level return costs allocated across lines. Use the return fact for event-level return reasons and return financial detail.

```DAX
m_Return Events = COUNTROWS(FactReturns)
m_Approved Return Events = CALCULATE([m_Return Events], FactReturns[return_status] = "Approved")
m_Returned Orders = CALCULATE([m_Orders], FactProfitability[is_returned] = 1, FactProfitability[is_delivered] = 1)
m_Return Rate % = DIVIDE([m_Returned Orders], [m_Delivered Orders])
m_Late Orders = CALCULATE([m_Orders], FactProfitability[is_late_delivery] = 1, FactProfitability[is_delivered] = 1)
m_Late Delivery % = DIVIDE([m_Late Orders], [m_Delivered Orders])
m_Return Refund Value = CALCULATE(SUM(FactReturns[refund_amount]), FactReturns[return_status] = "Approved")
m_Return Event Cost = CALCULATE(SUM(FactReturns[total_return_cost]), FactReturns[return_status] = "Approved")
m_Return Leakage % = DIVIDE([m_Refund Value] + [m_Return Cost], [m_Gross Revenue])
```

`m_Returned Orders` and `m_Return Rate %` are deliberately based on `FactProfitability`, preventing a multi-event return order from being counted multiple times. `m_Return Events` is an event count and can legitimately exceed returned orders.

## Customer Metrics

```DAX
m_Customers = DISTINCTCOUNT(FactProfitability[customer_id])
m_Orders per Customer = DIVIDE([m_Delivered Orders], [m_Customers])
m_Repeat Customers =
COUNTROWS(
    FILTER(
        VALUES(FactProfitability[customer_id]),
        CALCULATE(DISTINCTCOUNT(FactProfitability[order_id]), FactProfitability[is_delivered] = 1) > 1
    )
)
m_Repeat Customer % = DIVIDE([m_Repeat Customers], [m_Customers])
m_Profit per Customer = DIVIDE([m_Gross Profit], [m_Customers])
```

## Opportunity Measures

```DAX
m_Low Margin Revenue =
CALCULATE(
    [m_Net Revenue],
    FILTER(FactProfitability, DIVIDE(FactProfitability[gross_profit], FactProfitability[net_revenue]) < 0.15)
)

m_Return Refund per Returned Order = DIVIDE([m_Refund Value], [m_Returned Orders])
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
                      /       \
                     /         \
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
- Use `m_` prefix consistently so measures are easy to identify in the Fields pane.
