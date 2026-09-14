/* ProfitTrace | Business Analysis */
USE ProfitTrace;
GO

/* Executive profitability */
SELECT COUNT(DISTINCT order_id) AS orders,
       SUM(gross_revenue) AS gross_revenue,
       SUM(discount_value) AS discount_value,
       SUM(refund_value) AS refund_value,
       SUM(net_revenue) AS net_revenue,
       SUM(product_cost) AS product_cost,
       SUM(shipping_cost) AS shipping_cost,
       SUM(gross_profit) AS gross_profit,
       CAST(SUM(gross_profit)/NULLIF(SUM(net_revenue),0) AS DECIMAL(10,4)) AS profit_margin
FROM analytics.vw_OrderProfitability;

/* Monthly trend */
SELECT DATEFROMPARTS(YEAR(order_date),MONTH(order_date),1) AS month_start,
       COUNT(DISTINCT order_id) AS orders, SUM(gross_revenue) AS gross_revenue,
       SUM(discount_value) AS discount_value, SUM(refund_value) AS refund_value,
       SUM(net_revenue) AS net_revenue, SUM(gross_profit) AS gross_profit,
       CAST(SUM(gross_profit)/NULLIF(SUM(net_revenue),0) AS DECIMAL(10,4)) AS profit_margin
FROM analytics.vw_OrderProfitability
GROUP BY DATEFROMPARTS(YEAR(order_date),MONTH(order_date),1)
ORDER BY month_start;

/* Category profitability */
SELECT category, COUNT(DISTINCT order_id) AS orders, SUM(gross_revenue) AS gross_revenue,
       SUM(discount_value) AS discount_value, SUM(refund_value) AS refund_value,
       SUM(net_revenue) AS net_revenue, SUM(gross_profit) AS gross_profit,
       CAST(SUM(gross_profit)/NULLIF(SUM(net_revenue),0) AS DECIMAL(10,4)) AS profit_margin,
       CAST(COUNT(DISTINCT CASE WHEN is_returned=1 AND is_delivered=1 THEN order_id END)*1.0/
            NULLIF(COUNT(DISTINCT CASE WHEN is_delivered=1 THEN order_id END),0) AS DECIMAL(10,4)) AS return_rate
FROM analytics.vw_OrderProfitability
GROUP BY category ORDER BY gross_profit DESC;

/* Product profitability */
SELECT product_id, product_name, category, subcategory,
       COUNT(DISTINCT order_id) AS orders, SUM(gross_revenue) AS gross_revenue,
       SUM(discount_value) AS discount_value, SUM(refund_value) AS refund_value,
       SUM(net_revenue) AS net_revenue, SUM(gross_profit) AS gross_profit,
       CAST(SUM(gross_profit)/NULLIF(SUM(net_revenue),0) AS DECIMAL(10,4)) AS profit_margin
FROM analytics.vw_OrderProfitability
GROUP BY product_id, product_name, category, subcategory
ORDER BY gross_profit ASC;

/* Discount leakage */
SELECT category, SUM(gross_revenue) AS gross_revenue, SUM(discount_value) AS discount_value,
       CAST(SUM(discount_value)/NULLIF(SUM(gross_revenue),0) AS DECIMAL(10,4)) AS discount_rate,
       SUM(gross_profit) AS gross_profit
FROM analytics.vw_OrderProfitability
GROUP BY category ORDER BY discount_rate DESC;

/* Return reasons */
SELECT return_reason, COUNT(*) AS return_count, SUM(refund_value) AS refund_value
FROM analytics.vw_ReturnsOperations
GROUP BY return_reason ORDER BY refund_value DESC;

/* Delivery performance and returns */
SELECT delivery_status, COUNT(DISTINCT order_id) AS delivered_orders,
       COUNT(DISTINCT CASE WHEN is_returned=1 THEN order_id END) AS returned_orders,
       CAST(COUNT(DISTINCT CASE WHEN is_returned=1 THEN order_id END)*1.0/
            NULLIF(COUNT(DISTINCT order_id),0) AS DECIMAL(10,4)) AS return_rate
FROM analytics.vw_OrderProfitability
WHERE is_delivered=1 GROUP BY delivery_status;

/* Regional profitability */
SELECT region, COUNT(DISTINCT order_id) AS orders, SUM(gross_revenue) AS gross_revenue,
       SUM(net_revenue) AS net_revenue, SUM(gross_profit) AS gross_profit,
       CAST(SUM(gross_profit)/NULLIF(SUM(net_revenue),0) AS DECIMAL(10,4)) AS profit_margin
FROM analytics.vw_OrderProfitability
GROUP BY region ORDER BY gross_profit DESC;

/* One-time vs repeat customer economics */
WITH CustomerOrders AS
(
    SELECT customer_id, COUNT(DISTINCT order_id) AS order_count,
           SUM(net_revenue) AS net_revenue, SUM(gross_profit) AS gross_profit
    FROM analytics.vw_OrderProfitability GROUP BY customer_id
)
SELECT CASE WHEN order_count=1 THEN 'One-time' ELSE 'Repeat' END AS customer_type,
       COUNT(*) AS customers, SUM(net_revenue) AS net_revenue, SUM(gross_profit) AS gross_profit,
       CAST(SUM(gross_profit)/NULLIF(SUM(net_revenue),0) AS DECIMAL(10,4)) AS profit_margin
FROM CustomerOrders
GROUP BY CASE WHEN order_count=1 THEN 'One-time' ELSE 'Repeat' END;

/* Top profitable customers */
SELECT TOP (25) customer_id, customer_segment, region, acquisition_channel,
       orders, gross_revenue, discount_value, refund_value, net_revenue, gross_profit, profit_margin
FROM analytics.vw_CustomerProfitability
ORDER BY gross_profit DESC;
GO
