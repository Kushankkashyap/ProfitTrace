/* ProfitTrace | Final Portfolio QA
   Run after the SQL source layer is built and again before finalizing Power BI.
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
WHERE ABS(net_revenue - (sales_after_discount - refund_value)) > 0.01
   OR ABS(gross_profit - (net_revenue - product_cost - shipping_cost)) > 0.01;

/* Business-rule checks should return zero rows. */
SELECT order_id, 'Refund exceeds paid sales' AS issue
FROM analytics.vw_OrderProfitability
WHERE refund_value > sales_after_discount;

/* The raw source may contain controlled invalid discounts. The cleaning layer
   caps them at the documented business ceiling and records the correction. */
SELECT order_id, product_id, discount_pct_raw, discount_pct,
       'Discount corrected during cleaning' AS issue
FROM analytics.vw_OrderProfitability
WHERE discount_corrected_flag=1;

/* Cleaned discounts should now be within the approved range. */
SELECT COUNT(*) AS invalid_cleaned_discounts
FROM analytics.vw_OrderProfitability
WHERE discount_pct < 0 OR discount_pct > 0.30;
GO
