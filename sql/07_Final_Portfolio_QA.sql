/* ProfitTrace | Final Portfolio QA
   Run after the Power BI model is built to confirm the SQL source layer
   remains aligned with the report definitions.
*/

USE ProfitTrace;
GO

SELECT
    COUNT(DISTINCT order_id) AS orders,
    COUNT(DISTINCT customer_id) AS customers,
    COUNT(DISTINCT product_id) AS products,
    SUM(gross_revenue) AS gross_revenue,
    SUM(discount_value) AS discount_value,
    SUM(refund_value) AS refund_value,
    SUM(net_revenue) AS net_revenue,
    SUM(gross_profit) AS gross_profit
FROM analytics.vw_OrderProfitability;

/* Profit identity should reconcile to zero rows. */
SELECT COUNT(*) AS reconciliation_errors
FROM analytics.vw_OrderProfitability
WHERE ABS(net_revenue - (gross_revenue - discount_value - refund_value)) > 0.01
   OR ABS(gross_profit - (net_revenue - product_cost - shipping_cost)) > 0.01;

/* Business-rule checks should return zero rows. */
SELECT order_id, 'Refund exceeds paid sales' AS issue
FROM analytics.vw_OrderProfitability
WHERE refund_value > sales_after_discount;

SELECT order_id, 'Invalid discount' AS issue
FROM analytics.vw_OrderProfitability
WHERE discount_pct < 0 OR discount_pct > 0.30;
GO
