/* ProfitTrace | Post-Load QA */
USE ProfitTrace;
GO

/* Counts */
SELECT 'Customers' AS table_name, COUNT(*) AS row_count FROM stg.Customers
UNION ALL SELECT 'Products', COUNT(*) FROM stg.Products
UNION ALL SELECT 'Orders', COUNT(*) FROM stg.Orders
UNION ALL SELECT 'Shipping', COUNT(*) FROM stg.Shipping
UNION ALL SELECT 'Returns', COUNT(*) FROM stg.Returns;

/* The profitability view is at order-product-line grain. */
SELECT order_id, product_id, COUNT(*) AS analytical_rows
FROM analytics.vw_OrderProfitability
GROUP BY order_id, product_id
HAVING COUNT(*) <> 1;

/* Multi-line orders are valid. Shipping and approved refunds are allocated
   across lines, so their line-level sums must reconcile to the order-level
   source amounts. */
WITH SourceRefund AS
(
    SELECT order_id,
           SUM(CASE WHEN LOWER(LTRIM(RTRIM(return_status)))='approved' THEN refund_value ELSE 0 END) AS source_refund
    FROM stg.Returns
    GROUP BY order_id
),
SourceShipping AS
(
    SELECT order_id, MAX(shipping_cost) AS source_shipping
    FROM stg.Shipping
    GROUP BY order_id
),
LineTotals AS
(
    SELECT order_id, SUM(shipping_cost) AS allocated_shipping, SUM(refund_value) AS allocated_refund
    FROM analytics.vw_OrderProfitability
    GROUP BY order_id
)
SELECT l.order_id, l.allocated_shipping, s.source_shipping, l.allocated_refund, r.source_refund
FROM LineTotals l
LEFT JOIN SourceShipping s ON s.order_id=l.order_id
LEFT JOIN SourceRefund r ON r.order_id=l.order_id
WHERE ABS(l.allocated_shipping-COALESCE(s.source_shipping,0)) > 0.01
   OR ABS(l.allocated_refund-COALESCE(r.source_refund,0)) > 0.01;

/* Financial identities */
SELECT TOP (20) order_id, product_id, gross_revenue, discount_value, sales_after_discount,
       refund_value, net_revenue, product_cost, shipping_cost, gross_profit
FROM analytics.vw_OrderProfitability
WHERE ABS(sales_after_discount-(gross_revenue-discount_value)) > 0.01
   OR ABS(net_revenue-(sales_after_discount-refund_value)) > 0.01
   OR ABS(gross_profit-(net_revenue-product_cost-shipping_cost)) > 0.01
   OR refund_value > sales_after_discount;

/* Economic anomalies */
SELECT SUM(CASE WHEN quantity<=0 THEN 1 ELSE 0 END) AS invalid_quantity,
       SUM(CASE WHEN unit_price<=0 THEN 1 ELSE 0 END) AS invalid_unit_price,
       SUM(CASE WHEN discount_pct<0 OR discount_pct>0.30 THEN 1 ELSE 0 END) AS invalid_discount,
       SUM(CASE WHEN product_cost<0 OR shipping_cost<0 OR refund_value<0 THEN 1 ELSE 0 END) AS invalid_costs
FROM analytics.vw_OrderProfitability;

/* Delivery sanity */
SELECT COUNT(*) AS invalid_shipping_dates
FROM stg.Shipping
WHERE promised_date<ship_date OR (delivery_date IS NOT NULL AND delivery_date<ship_date);

/* Final KPI reconciliation */
SELECT COUNT(DISTINCT order_id) AS completed_orders,
       SUM(gross_revenue) AS gross_revenue,
       SUM(discount_value) AS discount_value,
       SUM(refund_value) AS refunds,
       SUM(net_revenue) AS net_revenue,
       SUM(gross_profit) AS gross_profit,
       CAST(SUM(gross_profit)/NULLIF(SUM(net_revenue),0) AS DECIMAL(10,4)) AS profit_margin,
       CAST(COUNT(DISTINCT CASE WHEN is_returned=1 AND is_delivered=1 THEN order_id END)*1.0/
            NULLIF(COUNT(DISTINCT CASE WHEN is_delivered=1 THEN order_id END),0) AS DECIMAL(10,4)) AS return_rate
FROM analytics.vw_OrderProfitability;
GO
