/* ProfitTrace | Post-Load QA and Reconciliation */
USE ProfitTrace;
GO

/* 1. Source row-count profile */
SELECT 'Customers' AS table_name, COUNT(*) AS row_count FROM stg.Customers
UNION ALL SELECT 'Products', COUNT(*) FROM stg.Products
UNION ALL SELECT 'Orders', COUNT(*) FROM stg.Orders
UNION ALL SELECT 'Shipping', COUNT(*) FROM stg.Shipping
UNION ALL SELECT 'Returns', COUNT(*) FROM stg.Returns;

/* 2. Referential integrity */
SELECT 'Orders -> Customers' AS check_name, COUNT(*) AS orphan_rows
FROM stg.Orders o LEFT JOIN stg.Customers c ON c.customer_id = o.customer_id
WHERE c.customer_id IS NULL
UNION ALL
SELECT 'Orders -> Products', COUNT(*)
FROM stg.Orders o LEFT JOIN stg.Products p ON p.product_id = o.product_id
WHERE p.product_id IS NULL
UNION ALL
SELECT 'Shipping -> Orders', COUNT(*)
FROM stg.Shipping s LEFT JOIN stg.Orders o ON o.order_id = s.order_id
WHERE o.order_id IS NULL
UNION ALL
SELECT 'Returns -> Orders', COUNT(*)
FROM stg.Returns r LEFT JOIN stg.Orders o ON o.order_id = r.order_id
WHERE o.order_id IS NULL;

/* 3. One shipment per order */
SELECT order_id, COUNT(*) AS shipment_rows
FROM stg.Shipping
GROUP BY order_id
HAVING COUNT(*) <> 1;

/* 4. One analytical row per completed order */
SELECT order_id, COUNT(*) AS analytical_rows
FROM analytics.vw_OrderProfitability
GROUP BY order_id
HAVING COUNT(*) <> 1;

/* 5. Financial identity checks */
SELECT TOP (20)
    order_id,
    gross_revenue,
    discount_value,
    sales_after_discount,
    refund_value,
    net_revenue,
    gross_profit
FROM analytics.vw_OrderProfitability
WHERE ABS(sales_after_discount - (gross_revenue - discount_value)) > 0.01
   OR ABS(net_revenue - (sales_after_discount - refund_value)) > 0.01
   OR refund_value > sales_after_discount
ORDER BY order_id;

/* 6. Economic anomaly checks */
SELECT
    SUM(CASE WHEN quantity <= 0 THEN 1 ELSE 0 END) AS invalid_quantity,
    SUM(CASE WHEN unit_price <= 0 THEN 1 ELSE 0 END) AS invalid_unit_price,
    SUM(CASE WHEN discount_pct < 0 OR discount_pct > 0.30 THEN 1 ELSE 0 END) AS invalid_discount_after_cleaning,
    SUM(CASE WHEN product_cost < 0 OR shipping_cost < 0 OR refund_value < 0 THEN 1 ELSE 0 END) AS invalid_costs
FROM analytics.vw_OrderProfitability;

/* 7. Delivery-date sanity */
SELECT COUNT(*) AS invalid_shipping_dates
FROM stg.Shipping
WHERE promised_date < ship_date
   OR (delivery_date IS NOT NULL AND delivery_date < ship_date);

/* 8. Final KPI reconciliation */
SELECT
    COUNT(DISTINCT order_id) AS completed_orders,
    SUM(gross_revenue) AS gross_revenue,
    SUM(discount_value) AS discount_value,
    SUM(refund_value) AS refunds,
    SUM(net_revenue) AS net_revenue,
    SUM(gross_profit) AS gross_profit,
    CAST(SUM(gross_profit) / NULLIF(SUM(net_revenue),0) AS DECIMAL(10,4)) AS profit_margin,
    CAST(COUNT(DISTINCT CASE WHEN is_returned = 1 AND is_delivered = 1 THEN order_id END) * 1.0
         / NULLIF(COUNT(DISTINCT CASE WHEN is_delivered = 1 THEN order_id END),0) AS DECIMAL(10,4)) AS return_rate
FROM analytics.vw_OrderProfitability;
GO
