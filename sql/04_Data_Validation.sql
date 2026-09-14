/* ProfitTrace | Data Validation */
USE ProfitTrace;
GO

/* 1. Row counts */
SELECT 'Customers' AS table_name, COUNT(*) AS row_count FROM stg.Customers
UNION ALL SELECT 'Products', COUNT(*) FROM stg.Products
UNION ALL SELECT 'Orders', COUNT(*) FROM stg.Orders
UNION ALL SELECT 'Returns', COUNT(*) FROM stg.Returns
UNION ALL SELECT 'Shipping', COUNT(*) FROM stg.Shipping;

/* 2. Required-field checks */
SELECT 'Customers' AS table_name, COUNT(*) AS invalid_rows
FROM stg.Customers
WHERE customer_id IS NULL OR customer_name IS NULL OR signup_date IS NULL
UNION ALL
SELECT 'Products', COUNT(*)
FROM stg.Products
WHERE product_id IS NULL OR product_name IS NULL OR unit_cost IS NULL OR list_price IS NULL
UNION ALL
SELECT 'Orders', COUNT(*)
FROM stg.Orders
WHERE order_id IS NULL OR order_date IS NULL OR customer_id IS NULL OR product_id IS NULL
   OR quantity IS NULL OR unit_price IS NULL OR discount_pct IS NULL
UNION ALL
SELECT 'Returns', COUNT(*)
FROM stg.Returns
WHERE return_id IS NULL OR order_id IS NULL OR return_date IS NULL OR refund_value IS NULL
UNION ALL
SELECT 'Shipping', COUNT(*)
FROM stg.Shipping
WHERE shipment_id IS NULL OR order_id IS NULL OR ship_date IS NULL
   OR promised_date IS NULL OR shipping_cost IS NULL;

/* 3. Duplicate and key checks */
SELECT 'Duplicate Customers' AS check_name, COUNT(*) AS duplicate_keys
FROM (SELECT customer_id FROM stg.Customers GROUP BY customer_id HAVING COUNT(*) > 1) d
UNION ALL
SELECT 'Duplicate Products', COUNT(*)
FROM (SELECT product_id FROM stg.Products GROUP BY product_id HAVING COUNT(*) > 1) d
UNION ALL
SELECT 'Duplicate Orders', COUNT(*)
FROM (SELECT order_id, product_id FROM stg.Orders GROUP BY order_id, product_id HAVING COUNT(*) > 1) d
UNION ALL
SELECT 'Duplicate Returns', COUNT(*)
FROM (SELECT return_id FROM stg.Returns GROUP BY return_id HAVING COUNT(*) > 1) d
UNION ALL
SELECT 'Duplicate Shipments', COUNT(*)
FROM (SELECT shipment_id FROM stg.Shipping GROUP BY shipment_id HAVING COUNT(*) > 1) d;

/* 4. Domain checks */
SELECT 'Invalid Order Quantity' AS check_name, COUNT(*) AS invalid_rows
FROM stg.Orders WHERE quantity <= 0
UNION ALL
SELECT 'Invalid Unit Price', COUNT(*) FROM stg.Orders WHERE unit_price <= 0
UNION ALL
SELECT 'Invalid Discount', COUNT(*) FROM stg.Orders WHERE discount_pct < 0 OR discount_pct > 1
UNION ALL
SELECT 'Invalid Product Economics', COUNT(*) FROM stg.Products WHERE unit_cost <= 0 OR list_price <= 0 OR unit_cost > list_price
UNION ALL
SELECT 'Invalid Refund', COUNT(*) FROM stg.Returns WHERE refund_value < 0
UNION ALL
SELECT 'Invalid Shipping Cost', COUNT(*) FROM stg.Shipping WHERE shipping_cost < 0;

/* 5. Status checks. Lowercase and whitespace variants are intentionally present
      in the source data and are cleaned in 05_Data_Cleaning.sql. */
SELECT DISTINCT order_status FROM stg.Orders ORDER BY order_status;
SELECT DISTINCT return_status FROM stg.Returns ORDER BY return_status;

/* 6. Referential integrity */
SELECT 'Orders without Customer' AS check_name, COUNT(*) AS orphan_rows
FROM stg.Orders o LEFT JOIN stg.Customers c ON c.customer_id = o.customer_id
WHERE c.customer_id IS NULL
UNION ALL
SELECT 'Orders without Product', COUNT(*)
FROM stg.Orders o LEFT JOIN stg.Products p ON p.product_id = o.product_id
WHERE p.product_id IS NULL
UNION ALL
SELECT 'Returns without Order', COUNT(*)
FROM stg.Returns r LEFT JOIN stg.Orders o ON o.order_id = r.order_id
WHERE o.order_id IS NULL
UNION ALL
SELECT 'Shipping without Order', COUNT(*)
FROM stg.Shipping s LEFT JOIN stg.Orders o ON o.order_id = s.order_id
WHERE o.order_id IS NULL;

/* 7. Shipment uniqueness */
SELECT order_id, COUNT(*) AS shipment_rows
FROM stg.Shipping
GROUP BY order_id
HAVING COUNT(*) <> 1;

/* 8. Date checks */
SELECT COUNT(*) AS invalid_shipping_dates
FROM stg.Shipping
WHERE promised_date < ship_date
   OR (delivery_date IS NOT NULL AND delivery_date < ship_date);

SELECT COUNT(*) AS invalid_return_dates
FROM stg.Returns r
JOIN stg.Orders o ON o.order_id = r.order_id
WHERE r.return_date < o.order_date;
GO
