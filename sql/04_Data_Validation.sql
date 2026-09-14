/*
 ProfitTrace — Data Validation
 Run after 00_Generate_Synthetic_Data.sql (or after CSV load).
 Every check should return zero invalid rows unless explicitly noted.
*/
USE ProfitTrace;
GO

/* 1. Row counts */
SELECT 'Customers' AS table_name, COUNT(*) AS row_count FROM stg.Customers
UNION ALL SELECT 'Products', COUNT(*) FROM stg.Products
UNION ALL SELECT 'Orders', COUNT(*) FROM stg.Orders
UNION ALL SELECT 'Returns', COUNT(*) FROM stg.Returns
UNION ALL SELECT 'Shipping', COUNT(*) FROM stg.Shipping;

/* 2. Duplicate business keys */
SELECT 'Duplicate customer_id' AS check_name, COUNT(*) AS duplicate_groups
FROM (SELECT customer_id FROM stg.Customers GROUP BY customer_id HAVING COUNT(*) > 1) x
UNION ALL
SELECT 'Duplicate product_id', COUNT(*)
FROM (SELECT product_id FROM stg.Products GROUP BY product_id HAVING COUNT(*) > 1) x
UNION ALL
SELECT 'Duplicate order_id + product_id', COUNT(*)
FROM (SELECT order_id, product_id FROM stg.Orders GROUP BY order_id, product_id HAVING COUNT(*) > 1) x
UNION ALL
SELECT 'Duplicate return_id', COUNT(*)
FROM (SELECT return_id FROM stg.Returns GROUP BY return_id HAVING COUNT(*) > 1) x
UNION ALL
SELECT 'Duplicate shipment_id', COUNT(*)
FROM (SELECT shipment_id FROM stg.Shipping GROUP BY shipment_id HAVING COUNT(*) > 1) x;

/* 3. Null checks on required fields */
SELECT 'Customers' AS table_name, COUNT(*) AS invalid_rows
FROM stg.Customers
WHERE customer_id IS NULL OR customer_name IS NULL OR segment IS NULL OR region IS NULL OR signup_date IS NULL OR acquisition_channel IS NULL
UNION ALL
SELECT 'Products', COUNT(*) FROM stg.Products
WHERE product_id IS NULL OR product_name IS NULL OR category IS NULL OR subcategory IS NULL OR unit_cost IS NULL OR list_price IS NULL
UNION ALL
SELECT 'Orders', COUNT(*) FROM stg.Orders
WHERE order_id IS NULL OR order_date IS NULL OR customer_id IS NULL OR product_id IS NULL OR quantity IS NULL OR unit_price IS NULL OR discount_pct IS NULL OR order_status IS NULL
UNION ALL
SELECT 'Returns', COUNT(*) FROM stg.Returns
WHERE return_id IS NULL OR order_id IS NULL OR return_date IS NULL OR return_reason IS NULL OR refund_value IS NULL OR return_status IS NULL
UNION ALL
SELECT 'Shipping', COUNT(*) FROM stg.Shipping
WHERE shipment_id IS NULL OR order_id IS NULL OR ship_date IS NULL OR promised_date IS NULL OR shipping_cost IS NULL OR carrier IS NULL;

/* 4. Domain checks */
SELECT COUNT(*) AS invalid_order_quantity FROM stg.Orders WHERE quantity <= 0;
SELECT COUNT(*) AS invalid_discount_pct FROM stg.Orders WHERE discount_pct < 0 OR discount_pct > 1;
SELECT COUNT(*) AS invalid_product_prices FROM stg.Products WHERE unit_cost <= 0 OR list_price <= 0 OR unit_cost > list_price;
SELECT COUNT(*) AS invalid_refunds FROM stg.Returns WHERE refund_value < 0;
SELECT COUNT(*) AS invalid_shipping_costs FROM stg.Shipping WHERE shipping_cost < 0;

SELECT order_status, COUNT(*) AS row_count
FROM stg.Orders GROUP BY order_status ORDER BY order_status;

SELECT return_status, COUNT(*) AS row_count
FROM stg.Returns GROUP BY return_status ORDER BY return_status;

/* 5. Referential integrity */
SELECT 'Orders -> Customers' AS check_name, COUNT(*) AS orphan_rows
FROM stg.Orders o LEFT JOIN stg.Customers c ON c.customer_id=o.customer_id
WHERE c.customer_id IS NULL
UNION ALL
SELECT 'Orders -> Products', COUNT(*)
FROM stg.Orders o LEFT JOIN stg.Products p ON p.product_id=o.product_id
WHERE p.product_id IS NULL
UNION ALL
SELECT 'Returns -> Orders', COUNT(*)
FROM stg.Returns r LEFT JOIN stg.Orders o ON o.order_id=r.order_id
WHERE o.order_id IS NULL
UNION ALL
SELECT 'Shipping -> Orders', COUNT(*)
FROM stg.Shipping s LEFT JOIN stg.Orders o ON o.order_id=s.order_id
WHERE o.order_id IS NULL;

/* 6. Order-level operational grain */
SELECT COUNT(*) AS orders_without_shipping
FROM stg.Orders o
LEFT JOIN stg.Shipping s ON s.order_id=o.order_id
WHERE s.order_id IS NULL;

SELECT order_id, COUNT(*) AS shipment_rows
FROM stg.Shipping
GROUP BY order_id
HAVING COUNT(*) <> 1;

/* 7. Date consistency */
SELECT COUNT(*) AS invalid_shipping_dates
FROM stg.Shipping
WHERE ship_date < (SELECT MIN(order_date) FROM stg.Orders)
   OR ship_date > promised_date
   OR (delivery_date IS NOT NULL AND delivery_date < ship_date)
   OR (delivery_date IS NOT NULL AND delivery_date < promised_date AND delivery_date < ship_date);

SELECT COUNT(*) AS invalid_return_dates
FROM stg.Returns r
JOIN stg.Orders o ON o.order_id=r.order_id
WHERE r.return_date < o.order_date;
GO
