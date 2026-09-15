/* ProfitTrace | Final Portfolio QA */
USE ProfitTrace;
GO

-- 1. Final headline metrics used by Power BI core economics
SELECT
    COUNT(DISTINCT CASE WHEN is_delivered=1 THEN order_id END) AS delivered_orders,
    COUNT(DISTINCT CASE WHEN is_delivered=1 THEN customer_id END) AS customers,
    COUNT(DISTINCT CASE WHEN is_delivered=1 THEN product_id END) AS products,
    SUM(CASE WHEN is_delivered=1 THEN gross_revenue ELSE 0 END) AS gross_revenue,
    SUM(CASE WHEN is_delivered=1 THEN discount_value ELSE 0 END) AS discount_value,
    SUM(CASE WHEN is_delivered=1 THEN refund_amount ELSE 0 END) AS refund_value,
    SUM(CASE WHEN is_delivered=1 THEN net_revenue ELSE 0 END) AS net_revenue,
    SUM(CASE WHEN is_delivered=1 THEN gross_profit ELSE 0 END) AS gross_profit
FROM analytics.vw_OrderProfitability;
GO

-- 2. Financial reconciliation
SELECT COUNT(*) AS reconciliation_errors
FROM analytics.vw_OrderProfitability
WHERE ABS(net_revenue-(sales_after_discount-refund_amount))>0.01
   OR ABS(gross_profit-(net_revenue-product_cost-shipping_cost-return_cost))>0.01;
GO

-- 3. Business-rule checks
SELECT COUNT(*) AS invalid_cleaned_discounts
FROM analytics.vw_OrderProfitability
WHERE discount_pct<0 OR discount_pct>0.30;

SELECT COUNT(*) AS refund_exceeds_sales
FROM analytics.vw_OrderProfitability
WHERE refund_amount>sales_after_discount;

SELECT COUNT(*) AS delivered_status_without_delivery_date
FROM analytics.vw_OrderProfitability
WHERE order_status='Delivered' AND is_delivered=0;
GO

PRINT 'ProfitTrace final QA complete. Reconciliation and business-rule error counts should be zero; the intentional delivered-status/delivery-date inconsistency is reported separately.';
