/* ProfitTrace — Data Validation */
USE ProfitTrace;
GO

/* Row counts */
SELECT 'Customers' AS table_name, COUNT(*) AS row_count FROM stg.Customers
UNION ALL SELECT 'Products', COUNT(*) FROM stg.Products
UNION ALL SELECT 'Orders', COUNT(*) FROM stg.Orders
UNION ALL SELECT 'Returns', COUNT(*) FROM stg.Returns
UNION ALL SELECT 'Shipping', COUNT(*) FROM stg.Shipping;

/* Null checks on required fields */
SELECT 'Customers' AS table_name, COUNT(*) AS invalid_rows
FROM stg.Customers
WHERE customer_id IS NULL OR signup_date IS NULL
UNION ALL
SELECT 'Products', COUNT(*) FROM stg.Products
WHERE product_id IS NULL OR unit_cost IS NULL OR list_price IS NULL
UNION ALL
SELECT 'Orders', COUNT(*) FROM stg.Orders
WHERE order_id IS NULL OR order_date IS NULL OR customer_id IS NULL OR product_id IS NULL
UNION ALL
SELECT 'Returns', COUNT(*) FROM stg.Returns
WHERE return_id IS NULL OR order_id IS NULL OR refund_value IS NULL
UNION ALL
SELECT 'Shipping', COUNT(*) FROM stg.Shipping
WHERE shipment_id IS NULL OR order_id IS NULL OR shipping_cost IS NULL;

/* Domain checks */
SELECT COUNT(*) AS invalid_order_quantity
FROM stg.Orders
WHERE quantity <= 0;

SELECT COUNT(*) AS invalid_discount_pct
FROM stg.Orders
WHERE discount_pct < 0 OR discount_pct > 1;

SELECT COUNT(*) AS invalid_product_prices
FROM stg.Products
WHERE unit_cost <= 0 OR list_price <= 0 OR unit_cost > list_price;

SELECT COUNT(*) AS invalid_refunds
FROM stg.Returns
WHERE refund_value < 0;

/* Referential integrity checks */
SELECT COUNT(*) AS orders_without_customer
FROM stg.Orders o
LEFT JOIN stg.Customers c ON c.customer_id = o.customer_id
WHERE c.customer_id IS NULL;

SELECT COUNT(*) AS orders_without_product
FROM stg.Orders o
LEFT JOIN stg.Products p ON p.product_id = o.product_id
WHERE p.product_id IS NULL;

SELECT COUNT(*) AS returns_without_order
FROM stg.Returns r
LEFT JOIN stg.Orders o ON o.order_id = r.order_id
WHERE o.order_id IS NULL;

SELECT COUNT(*) AS shipments_without_order
FROM stg.Shipping s
LEFT JOIN stg.Orders o ON o.order_id = s.order_id
WHERE o.order_id IS NULL;

/* Date consistency */
SELECT COUNT(*) AS invalid_shipping_dates
FROM stg.Shipping
WHERE ship_date > promised_date
   OR (delivery_date IS NOT NULL AND delivery_date < ship_date);

SELECT COUNT(*) AS invalid_return_dates
FROM stg.Returns r
JOIN stg.Orders o ON o.order_id = r.order_id
WHERE r.return_date < o.order_date;
GO
