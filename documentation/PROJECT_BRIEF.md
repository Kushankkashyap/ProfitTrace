# ProfitTrace — Project Brief

## 1. Business Scenario

ProfitTrace models a mid-sized e-commerce business that has healthy top-line sales but inconsistent profitability. Management wants to understand whether profit is being diluted by heavy discounting, product mix, returns, refunds and shipping performance.

The analysis is intentionally designed around **decision-making**, not just dashboarding.

## 2. Primary Business Question

> **An e-commerce business is generating strong revenue, but where is the profit actually being lost?**

## 3. Stakeholder Questions

### Commercial
- Which categories and products create the most gross profit?
- Which high-revenue products have weak margins?
- Is discounting generating enough incremental revenue to justify the margin sacrifice?

### Returns
- Which products/categories have the highest return rates?
- What are the dominant return reasons?
- How much revenue/refund value is associated with returned orders?

### Operations
- How frequently are orders delivered late?
- Is late delivery associated with more returns?
- Which regions have the weakest operational and profitability outcomes?

### Customers
- How do new and repeat customers differ in AOV and profitability?
- Which customer segments generate the strongest profit contribution?

## 4. Analytical Grain

The model is designed around **one row per order line** for the sales fact and separate order-level return/shipping events. This allows product-level profitability while avoiding accidental duplication of order-level metrics.

## 5. Core Measures

- Gross Revenue
- Discount Value
- Net Revenue
- Product Cost
- Shipping Cost
- Refund Value
- Gross Profit
- Profit Margin %
- Return Rate %
- Average Order Value (AOV)
- Late Delivery %
- Repeat Customer %
- Profit per Order

## 6. Business Definitions

**Gross Revenue** = quantity × unit selling price before discounts.

**Discount Value** = gross revenue × discount percentage.

**Net Revenue** = gross revenue − discount value − refund value.

**Gross Profit** = net revenue − product cost − shipping cost.

**Profit Margin %** = gross profit ÷ net revenue.

**Return Rate %** = returned orders ÷ eligible delivered orders.

Definitions will be implemented consistently in SQL and DAX. Where a metric can be interpreted multiple ways, the final dashboard will document the selected definition.

## 7. Key Leakage Framework

```text
Gross Revenue
    ↓
Discount Leakage
    ↓
Net Revenue
    ↓
Refund / Return Leakage
    ↓
Product Cost
    ↓
Shipping Cost
    ↓
Gross Profit
```

This framework is the central storytelling device for the Executive page.

## 8. Expected Decision Outputs

The final dashboard should help management answer:

1. Where is profit being lost?
2. Which products/categories need intervention?
3. Is discounting helping or hurting profitability?
4. Are operational failures contributing to returns?
5. Which customer and regional segments deserve more commercial attention?

## 9. Portfolio Positioning

The project demonstrates an end-to-end analyst workflow:

**Business framing → data modeling → SQL validation → SQL transformation → analytical SQL → Power BI star schema → DAX → executive storytelling → recommendations.**

## 10. Data Disclaimer

All business data is synthetic and created for portfolio/learning purposes. The scenario is fictional and does not represent a real company.
