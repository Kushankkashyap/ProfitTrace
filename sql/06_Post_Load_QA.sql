/* ProfitTrace | Post-Load QA */
USE ProfitTrace;
GO

SELECT 'Customers' AS table_name,COUNT(*) AS row_count FROM stg.Customers
UNION ALL SELECT 'Products',COUNT(*) FROM stg.Products
UNION ALL SELECT 'Orders',COUNT(*) FROM stg.Orders
UNION ALL SELECT 'Shipping',COUNT(*) FROM stg.Shipping
UNION ALL SELECT 'Returns',COUNT(*) FROM stg.Returns;
GO

SELECT order_id,product_id,COUNT(*) AS analytical_rows
FROM analytics.vw_OrderProfitability
GROUP BY order_id,product_id HAVING COUNT(*)<>1;
GO

SELECT TOP (20) order_id,product_id,gross_revenue,discount_value,sales_after_discount,refund_amount,net_revenue,product_cost,shipping_cost,return_cost,gross_profit
FROM analytics.vw_OrderProfitability
WHERE ABS(sales_after_discount-(gross_revenue-discount_value))>0.01
   OR ABS(net_revenue-(sales_after_discount-refund_amount))>0.01
   OR ABS(gross_profit-(net_revenue-product_cost-shipping_cost-return_cost))>0.01;
GO

SELECT COUNT(*) AS negative_net_revenue_rows FROM analytics.vw_OrderProfitability WHERE order_status='Delivered' AND net_revenue<0;
SELECT COUNT(*) AS invalid_cleaned_discounts FROM analytics.vw_OrderProfitability WHERE discount_pct<0 OR discount_pct>0.30;
SELECT COUNT(*) AS negative_cost_rows FROM analytics.vw_OrderProfitability WHERE product_cost<0 OR shipping_cost<0 OR return_cost<0 OR refund_amount<0;
GO

SELECT COUNT(*) AS delivery_before_ship
FROM analytics.vw_OrderProfitability
WHERE delivery_date IS NOT NULL AND ship_date IS NOT NULL AND delivery_date<ship_date;
GO

SELECT SUM(gross_revenue-discount_value-sales_after_discount) AS sales_identity_difference,
       SUM(sales_after_discount-refund_amount-net_revenue) AS net_revenue_identity_difference,
       SUM(net_revenue-product_cost-shipping_cost-return_cost-gross_profit) AS profit_identity_difference
FROM analytics.vw_OrderProfitability;
GO

SELECT COUNT(DISTINCT CASE WHEN order_status='Delivered' THEN order_id END) AS delivered_orders,
       SUM(CASE WHEN order_status='Delivered' THEN net_revenue ELSE 0 END) AS net_revenue,
       SUM(CASE WHEN order_status='Delivered' THEN gross_profit ELSE 0 END) AS gross_profit,
       CAST(100.0*SUM(CASE WHEN order_status='Delivered' THEN gross_profit ELSE 0 END)/NULLIF(SUM(CASE WHEN order_status='Delivered' THEN net_revenue ELSE 0 END),0) AS DECIMAL(10,2)) AS margin_pct
FROM analytics.vw_OrderProfitability;
GO
