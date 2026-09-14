/* ProfitTrace | Data Validation */
USE ProfitTrace;
GO

/* Row counts */
SELECT 'Customers' AS table_name, COUNT(*) AS row_count FROM stg.Customers
UNION ALL SELECT 'Products', COUNT(*) FROM stg.Products
UNION ALL SELECT 'Orders', COUNT(*) FROM stg.Orders
UNION ALL SELECT 'Shipping', COUNT(*) FROM stg.Shipping
UNION ALL SELECT 'Returns', COUNT(*) FROM stg.Returns;

/* Required-field checks */
SELECT 'Customers' AS table_name, COUNT(*) AS invalid_rows FROM stg.Customers
WHERE customer_id IS NULL OR signup_date IS NULL
UNION ALL SELECT 'Products', COUNT(*) FROM stg.Products
WHERE product_id IS NULL OR unit_cost IS NULL OR list_price IS NULL
UNION ALL SELECT 'Orders', COUNT(*) FROM stg.Orders
WHERE order_id IS NULL OR order_date IS NULL OR customer_id IS NULL OR product_id IS NULL
UNION ALL SELECT 'Returns', COUNT(*) FROM stg.Returns
WHERE return_id IS NULL OR order_id IS NULL OR refund_value IS NULL
UNION ALL SELECT 'Shipping', COUNT(*) FROM stg.Shipping
WHERE shipment_id IS NULL OR order_id IS NULL OR shipping_cost IS NULL;

/* Domain checks */
SELECT 'Orders with invalid quantity' AS check_name, COUNT(*) AS issue_count
FROM stg.Orders WHERE quantity <= 0
UNION ALL SELECT 'Orders with invalid unit price', COUNT(*) FROM stg.Orders WHERE unit_price <= 0
UNION ALL SELECT 'Orders with discount outside approved 0%-30% range', COUNT(*) FROM stg.Orders WHERE discount_pct < 0 OR discount_pct > 0.30
UNION ALL SELECT 'Products with invalid economics', COUNT(*) FROM stg.Products WHERE unit_cost <= 0 OR list_price <= 0 OR unit_cost > list_price
UNION ALL SELECT 'Returns with negative refund', COUNT(*) FROM stg.Returns WHERE refund_value < 0
UNION ALL SELECT 'Shipping with negative cost', COUNT(*) FROM stg.Shipping WHERE shipping_cost < 0;

/* Status checks */
SELECT 'Invalid Order Status' AS check_name, COUNT(*) AS issue_count
FROM stg.Orders WHERE LOWER(LTRIM(RTRIM(order_status))) NOT IN ('completed','cancelled')
UNION ALL
SELECT 'Invalid Return Status', COUNT(*)
FROM stg.Returns WHERE LOWER(LTRIM(RTRIM(return_status))) NOT IN ('approved','rejected','pending');

/* Referential integrity */
SELECT 'Orders -> Customers' AS check_name, COUNT(*) AS orphan_rows
FROM stg.Orders o LEFT JOIN stg.Customers c ON c.customer_id=o.customer_id
WHERE c.customer_id IS NULL
UNION ALL SELECT 'Orders -> Products', COUNT(*) FROM stg.Orders o LEFT JOIN stg.Products p ON p.product_id=o.product_id WHERE p.product_id IS NULL
UNION ALL SELECT 'Shipping -> Orders', COUNT(*) FROM stg.Shipping s LEFT JOIN stg.Orders o ON o.order_id=s.order_id WHERE o.order_id IS NULL
UNION ALL SELECT 'Returns -> Orders', COUNT(*) FROM stg.Returns r LEFT JOIN stg.Orders o ON o.order_id=r.order_id WHERE o.order_id IS NULL;

/* Uniqueness checks */
SELECT 'Duplicate customer IDs' AS check_name, COUNT(*) AS issue_count FROM (SELECT customer_id FROM stg.Customers GROUP BY customer_id HAVING COUNT(*)>1) x
UNION ALL SELECT 'Duplicate product IDs', COUNT(*) FROM (SELECT product_id FROM stg.Products GROUP BY product_id HAVING COUNT(*)>1) x
UNION ALL SELECT 'Duplicate return IDs', COUNT(*) FROM (SELECT return_id FROM stg.Returns GROUP BY return_id HAVING COUNT(*)>1) x
UNION ALL SELECT 'Duplicate shipment IDs', COUNT(*) FROM (SELECT shipment_id FROM stg.Shipping GROUP BY shipment_id HAVING COUNT(*)>1) x;

/* One shipment per order */
SELECT order_id, COUNT(*) AS shipment_rows
FROM stg.Shipping GROUP BY order_id HAVING COUNT(*) <> 1;

/* Order-product-line uniqueness */
SELECT order_id, product_id, COUNT(*) AS duplicate_rows
FROM stg.Orders
GROUP BY order_id, product_id
HAVING COUNT(*) > 1;

/* Date checks */
SELECT COUNT(*) AS invalid_shipping_dates
FROM stg.Shipping
WHERE promised_date < ship_date OR (delivery_date IS NOT NULL AND delivery_date < ship_date);

SELECT COUNT(*) AS invalid_return_dates
FROM stg.Returns r JOIN stg.Orders o ON o.order_id=r.order_id
WHERE r.return_date < o.order_date;
GO
