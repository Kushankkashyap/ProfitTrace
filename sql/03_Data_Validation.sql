/* ProfitTrace | Data Validation */
USE ProfitTrace;
GO

-- 1. Row-count gate
SELECT 'Customers' AS table_name, COUNT(*) AS row_count FROM stg.Customers
UNION ALL SELECT 'Products', COUNT(*) FROM stg.Products
UNION ALL SELECT 'Orders', COUNT(*) FROM stg.Orders
UNION ALL SELECT 'Shipping', COUNT(*) FROM stg.Shipping
UNION ALL SELECT 'Returns', COUNT(*) FROM stg.Returns;
GO

-- 2. Required-field checks
SELECT 'Customers' AS table_name, COUNT(*) AS bad_rows
FROM stg.Customers
WHERE customer_id IS NULL OR customer_name IS NULL OR customer_segment IS NULL
   OR region IS NULL OR state IS NULL OR city IS NULL OR signup_date IS NULL OR acquisition_channel IS NULL
UNION ALL SELECT 'Products', COUNT(*) FROM stg.Products
WHERE product_id IS NULL OR product_name IS NULL OR category IS NULL OR subcategory IS NULL
   OR brand IS NULL OR list_price IS NULL OR unit_cost IS NULL OR launch_date IS NULL OR rating IS NULL
UNION ALL SELECT 'Orders', COUNT(*) FROM stg.Orders
WHERE order_id IS NULL OR order_date IS NULL OR customer_id IS NULL OR product_id IS NULL
   OR quantity IS NULL OR unit_price IS NULL OR discount_pct IS NULL
UNION ALL SELECT 'Shipping', COUNT(*) FROM stg.Shipping
WHERE order_id IS NULL OR shipping_cost IS NULL
UNION ALL SELECT 'Returns', COUNT(*) FROM stg.Returns
WHERE return_id IS NULL OR order_id IS NULL OR return_date IS NULL OR refund_amount IS NULL;
GO

-- 3. Domain checks
SELECT 'Invalid quantity' AS check_name, COUNT(*) AS issue_count
FROM stg.Orders WHERE quantity <= 0
UNION ALL SELECT 'Invalid unit price', COUNT(*) FROM stg.Orders WHERE unit_price <= 0
UNION ALL SELECT 'Discount outside 0%-30% range', COUNT(*) FROM stg.Orders WHERE discount_pct < 0 OR discount_pct > 0.30
UNION ALL SELECT 'Invalid product economics', COUNT(*) FROM stg.Products WHERE unit_cost <= 0 OR list_price <= 0 OR unit_cost >= list_price
UNION ALL SELECT 'Negative refund/cost', COUNT(*) FROM stg.Returns WHERE refund_amount < 0 OR return_shipping_cost < 0 OR restocking_cost < 0;
GO

-- 4. Controlled text/status variants that should be corrected in the analytical layer
SELECT 'Customer segment variants' AS check_name,
       COUNT(*) AS issue_count
FROM stg.Customers
WHERE LTRIM(RTRIM(customer_segment)) <> customer_segment
   OR LOWER(LTRIM(RTRIM(customer_segment))) NOT IN ('core','value','premium')
UNION ALL SELECT 'Customer region variants', COUNT(*)
FROM stg.Customers
WHERE LTRIM(RTRIM(region)) <> region
UNION ALL SELECT 'Acquisition channel variants', COUNT(*)
FROM stg.Customers
WHERE LTRIM(RTRIM(acquisition_channel)) <> acquisition_channel
   OR LOWER(LTRIM(RTRIM(acquisition_channel))) = 'paid social'
      AND acquisition_channel <> 'Paid Social'
UNION ALL SELECT 'Product category variants', COUNT(*)
FROM stg.Products
WHERE LOWER(LTRIM(RTRIM(category))) = 'electronics'
  AND category <> 'Electronics'
UNION ALL SELECT 'Product subcategory whitespace variants', COUNT(*)
FROM stg.Products
WHERE LTRIM(RTRIM(subcategory)) <> subcategory
UNION ALL SELECT 'Carrier variants', COUNT(*)
FROM stg.Shipping
WHERE LTRIM(RTRIM(carrier)) <> carrier
   OR LOWER(LTRIM(RTRIM(carrier))) = 'bluedart'
      AND carrier <> 'Blue Dart'
UNION ALL SELECT 'Return reason variants', COUNT(*)
FROM stg.Returns
WHERE LOWER(LTRIM(RTRIM(return_reason))) = 'changed mind'
  AND return_reason <> 'Changed Mind'
UNION ALL SELECT 'Order status variants', COUNT(*)
FROM stg.Orders
WHERE LTRIM(RTRIM(order_status)) <> order_status;
GO

SELECT order_status, COUNT(*) AS row_count
FROM stg.Orders
GROUP BY order_status
ORDER BY row_count DESC;

SELECT customer_segment, COUNT(*) AS row_count
FROM stg.Customers
GROUP BY customer_segment
ORDER BY row_count DESC;

SELECT acquisition_channel, COUNT(*) AS row_count
FROM stg.Customers
GROUP BY acquisition_channel
ORDER BY row_count DESC;
GO

-- 5. Referential-integrity checks
SELECT 'Orders -> Customers' AS check_name, COUNT(*) AS orphan_rows
FROM stg.Orders o
LEFT JOIN stg.Customers c ON c.customer_id=o.customer_id
WHERE c.customer_id IS NULL
UNION ALL SELECT 'Orders -> Products', COUNT(*)
FROM stg.Orders o
LEFT JOIN stg.Products p ON p.product_id=o.product_id
WHERE p.product_id IS NULL
UNION ALL SELECT 'Shipping -> Orders', COUNT(*)
FROM stg.Shipping s
LEFT JOIN stg.Orders o ON o.order_id=s.order_id
WHERE o.order_id IS NULL
UNION ALL SELECT 'Returns -> Orders', COUNT(*)
FROM stg.Returns r
LEFT JOIN stg.Orders o ON o.order_id=r.order_id
WHERE o.order_id IS NULL;
GO

-- 6. Grain and uniqueness checks
SELECT order_id, COUNT(*) AS shipment_count
FROM stg.Shipping
GROUP BY order_id
HAVING COUNT(*) <> 1;

SELECT order_id, product_id, COUNT(*) AS duplicate_rows
FROM stg.Orders
GROUP BY order_id, product_id
HAVING COUNT(*) > 1;
GO

-- 7. Date and delivery consistency checks
SELECT COUNT(*) AS invalid_shipping_dates
FROM stg.Shipping
WHERE (promised_delivery_date IS NOT NULL AND ship_date IS NOT NULL AND promised_delivery_date < ship_date)
   OR (delivery_date IS NOT NULL AND ship_date IS NOT NULL AND delivery_date < ship_date);

SELECT COUNT(*) AS invalid_return_dates
FROM stg.Returns r
JOIN stg.Orders o ON o.order_id=r.order_id
WHERE r.return_date < o.order_date;

SELECT COUNT(*) AS delivered_order_without_delivery_date
FROM stg.Orders o
LEFT JOIN stg.Shipping s ON s.order_id=o.order_id
WHERE LOWER(LTRIM(RTRIM(o.order_status)))='delivered'
  AND s.delivery_date IS NULL;

SELECT COUNT(*) AS non_delivered_status_with_delivery_date
FROM stg.Orders o
JOIN stg.Shipping s ON s.order_id=o.order_id
WHERE LOWER(LTRIM(RTRIM(o.order_status)))<>'delivered'
  AND s.delivery_date IS NOT NULL;
GO

/* Intentional text/case/whitespace issues are expected to be visible here.
   Standardized analytical values are created by 04_Data_Cleaning.sql. */
