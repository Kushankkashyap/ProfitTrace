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

/* Duplicate / uniqueness checks */
SELECT 'Duplicate Customers' AS check_name, COUNT(*) AS duplicate_keys
FROM (SELECT customer_id FROM stg.Customers GROUP BY customer_id HAVING COUNT(*) > 1) d
UNION ALL
SELECT 'Duplicate Products', COUNT(*)
FROM (SELECT product_id FROM stg.Products GROUP BY product_id HAVING COUNT(*) > 1) d
UNION ALL
SELECT 'Duplicate Returns', COUNT(*)
FROM (SELECT return_id FROM stg.Returns GROUP BY return_id HAVING COUNT(*) > 1) d
UNION ALL
SELECT 'Duplicate Shipping', COUNT(*)
FROM (SELECT shipment_id FROM stg.Shipping GROUP BY shipment_id HAVING COUNT(*) > 1) d;

/* Domain checks */
SELECT COUNT(*) AS invalid_order_quantity
FROM stg.Orders
WHERE quantity <= 0;

SELECT COUNT(*) AS invalid_unit_prices
FROM stg.Orders
WHERE unit_price <= 0;

SELECT COUNT(*) AS invalid_discount_pct
FROM stg.Orders
WHERE discount_pct < 0 OR discount_pct > 1;

SELECT COUNT(*) AS invalid_product_prices
FROM stg.Products
WHERE unit_cost <= 0 OR list_price <= 0 OR unit_cost > list_price;

SELECT COUNT(*) AS invalid_refunds
FROM stg.Returns
WHERE refund_value < 0;

SELECT COUNT(*) AS invalid_shipping_cost
FROM stg.Shipping
WHERE shipping_cost < 0;

SELECT 'Invalid Order Status' AS check_name, COUNT(*) AS invalid_rows
FROM stg.Orders
WHERE order_status NOT IN ('Completed','Cancelled')
UNION ALL
SELECT 'Invalid Return Status', COUNT(*)
FROM stg.Returns
WHERE return_status NOT IN ('Approved','Rejected','Pending');

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

/* One shipment per order — expected by the current generator/model */
SELECT order_id, COUNT(*) AS shipment_rows
FROM stg.Shipping
GROUP BY order_id
HAVING COUNT(*) <> 1;

/* Date consistency */
SELECT COUNT(*) AS invalid_shipping_dates
FROM stg.Shipping
WHERE ship_date < (SELECT MIN(order_date) FROM stg.Orders)
   OR promised_date < ship_date
   OR (delivery_date IS NOT NULL AND delivery_date < ship_date);

SELECT COUNT(*) AS invalid_return_dates
FROM stg.Returns r
JOIN stg.Orders o ON o.order_id = r.order_id
WHERE r.return_date < o.order_date;
GO
