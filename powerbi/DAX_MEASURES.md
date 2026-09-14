# ProfitTrace — DAX Measure Pack

Recommended Power BI fact table name: `FactProfitability`, sourced from `analytics.vw_OrderProfitability`.

## Core KPIs

```DAX
m_Orders = DISTINCTCOUNT(FactProfitability[order_id])
m_Gross Revenue = SUM(FactProfitability[gross_revenue])
m_Discount Value = SUM(FactProfitability[discount_value])
m_Net Revenue = SUM(FactProfitability[sales_after_discount]) - SUM(FactProfitability[refund_value])
m_Refund Value = SUM(FactProfitability[refund_value])
m_Product Cost = SUM(FactProfitability[product_cost])
m_Shipping Cost = SUM(FactProfitability[shipping_cost])
m_Gross Profit = SUM(FactProfitability[gross_profit])
m_Profit Margin % = DIVIDE([m_Gross Profit], [m_Net Revenue])
m_AOV = DIVIDE([m_Net Revenue], [m_Orders])
m_Discount Rate % = DIVIDE([m_Discount Value], [m_Gross Revenue])
m_Profit per Order = DIVIDE([m_Gross Profit], [m_Orders])
```

## Returns & Operations

```DAX
m_Delivered Orders = CALCULATE([m_Orders], FactProfitability[is_delivered] = 1)
m_Returned Orders = CALCULATE([m_Orders], FactProfitability[is_returned] = 1)
m_Return Rate % = DIVIDE([m_Returned Orders], [m_Delivered Orders])
m_Late Orders = CALCULATE([m_Orders], FactProfitability[is_late_delivery] = 1)
m_Late Delivery % = DIVIDE([m_Late Orders], [m_Delivered Orders])
m_Return Leakage % = DIVIDE([m_Refund Value], [m_Net Revenue])
```

`Return Rate %` uses delivered orders as the denominator, matching the project definition. The current deterministic generator delivers every generated order, but the explicit flag keeps the metric definition robust if future data contains undelivered orders.

## Customer Metrics

```DAX
m_Customers = DISTINCTCOUNT(FactProfitability[customer_id])
m_Orders per Customer = DIVIDE([m_Orders], [m_Customers])
m_Repeat Customers =
COUNTROWS(
    FILTER(
        VALUES(FactProfitability[customer_id]),
        CALCULATE(DISTINCTCOUNT(FactProfitability[order_id])) > 1
    )
)
m_Repeat Customer % = DIVIDE([m_Repeat Customers], [m_Customers])
m_Profit per Customer = DIVIDE([m_Gross Profit], [m_Customers])
```

These customer measures evaluate in the current filter context, so region, segment, channel and date slicers can be used without hard-coded results.

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

Sort `DimDate[Month]` by `DimDate[Month Number]` and use `Year Month` for chronological trend axes.

## Star Schema Relationships

```text
                 DimDate
                    |
DimCustomer ---- FactProfitability ---- DimProduct
```

- `DimDate[Date]` → `FactProfitability[order_date]` (1:*, single direction)
- `DimCustomer[customer_id]` → `FactProfitability[customer_id]` (1:*, single direction)
- `DimProduct[product_id]` → `FactProfitability[product_id]` (1:*, single direction)

If Returns/Shipping detail is imported separately, keep it disconnected from the main fact unless a deliberate bridge/model is introduced. Executive profitability should use the pre-aggregated fields in the analytical view.

## Formatting

- Currency: revenue, discounts, refunds, costs, profit, AOV, profit/order.
- Percentage: margin, discount rate, return rate, late-delivery rate, return leakage, repeat customer %.
- Whole number: orders, customers, returned orders, delivered orders, late orders.

All measures use the `m_` prefix for a clean, inspection-friendly Fields pane.
