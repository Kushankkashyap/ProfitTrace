/* ProfitTrace | Final Portfolio QA */
USE ProfitTrace;
GO

SELECT COUNT(DISTINCT CASE WHEN order_status='Delivered' THEN order_id END) AS delivered_orders,
       COUNT(DISTINCT customer_id) AS customers,
       COUNT(DISTINCT product_id) AS products,
       SUM(CASE WHEN order_status='Delivered' THEN gross_revenue ELSE 0 END) AS gross_revenue,
       SUM(CASE WHEN order_status='Delivered' THEN discount_value ELSE 0 END) AS discount_value,
       SUM(CASE WHEN order_status='Delivered' THEN refund_amount ELSE 0 END) AS refund_value,
       SUM(CASE WHEN order_status='Delivered' THEN net_revenue ELSE 0 END) AS net_revenue,
       SUM(CASE WHEN order_status='Delivered' THEN gross_profit ELSE 0 END) AS gross_profit
FROM analytics.vw_OrderProfitability;
GO

SELECT COUNT(*) AS reconciliation_errors
FROM analytics.vw_OrderProfitability
WHERE ABS(net_revenue-(sales_after_discount-refund_amount))>0.01
   OR ABS(gross_profit-(net_revenue-product_cost-shipping_cost-return_cost))>0.01;
GO

SELECT COUNT(*) AS invalid_cleaned_discounts
FROM analytics.vw_OrderProfitability
WHERE discount_pct<0 OR discount_pct>0.30;

SELECT COUNT(*) AS refund_exceeds_sales
FROM analytics.vw_OrderProfitability
WHERE refund_amount>sales_after_discount;
GO

PRINT 'ProfitTrace final QA complete. Reconciliation and business-rule error counts should be zero.';
