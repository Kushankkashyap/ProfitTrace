/*
 ProfitTrace — Analytical Cleaning / Standardization
 Raw staging tables are preserved. Views expose cleaned analytical fields.
*/
USE ProfitTrace;
GO

CREATE OR ALTER VIEW analytics.vw_OrderProfitability AS
WITH ReturnAgg AS
(
    SELECT order_id,
           SUM(CASE WHEN return_status = 'Approved' THEN refund_value ELSE 0 END) AS refund_value,
           COUNT(CASE WHEN return_status = 'Approved' THEN 1 END) AS return_count
    FROM stg.Returns
    GROUP BY order_id
),
ShippingOne AS
(
    SELECT order_id,
           MAX(ship_date) AS ship_date,
           MAX(promised_date) AS promised_date,
           MAX(delivery_date) AS delivery_date,
           MAX(shipping_cost) AS shipping_cost
    FROM stg.Shipping
    GROUP BY order_id
)
SELECT o.order_id, o.order_date, o.customer_id, o.product_id, o.quantity,
       o.unit_price, o.discount_pct, o.order_status,
       p.product_name, p.category, p.subcategory, p.unit_cost,
       c.segment AS customer_segment, c.region, c.acquisition_channel,
       s.ship_date, s.promised_date, s.delivery_date,
       CAST(o.quantity * o.unit_price AS DECIMAL(14,2)) AS gross_revenue,
       CAST(o.quantity * o.unit_price * o.discount_pct AS DECIMAL(14,2)) AS discount_value,
       CAST(o.quantity * o.unit_price * (1 - o.discount_pct) AS DECIMAL(14,2)) AS sales_after_discount,
       CAST(o.quantity * o.unit_price * (1 - o.discount_pct) - COALESCE(r.refund_value,0) AS DECIMAL(14,2)) AS net_revenue,
       CAST(COALESCE(r.refund_value,0) AS DECIMAL(14,2)) AS refund_value,
       CAST(o.quantity * p.unit_cost AS DECIMAL(14,2)) AS product_cost,
       CAST(COALESCE(s.shipping_cost,0) AS DECIMAL(14,2)) AS shipping_cost,
       CAST(o.quantity * o.unit_price * (1 - o.discount_pct)
            - COALESCE(r.refund_value,0)
            - o.quantity * p.unit_cost
            - COALESCE(s.shipping_cost,0) AS DECIMAL(14,2)) AS gross_profit,
       CASE WHEN s.delivery_date IS NOT NULL AND s.delivery_date > s.promised_date THEN 1 ELSE 0 END AS is_late_delivery,
       CASE WHEN COALESCE(r.return_count,0) > 0 THEN 1 ELSE 0 END AS is_returned,
       CASE WHEN s.delivery_date IS NOT NULL THEN 1 ELSE 0 END AS is_delivered,
       CASE WHEN s.delivery_date IS NULL THEN 'Not Delivered'
            WHEN s.delivery_date > s.promised_date THEN 'Late'
            ELSE 'On Time' END AS delivery_status
FROM stg.Orders o
JOIN stg.Products p ON p.product_id=o.product_id
JOIN stg.Customers c ON c.customer_id=o.customer_id
LEFT JOIN ReturnAgg r ON r.order_id=o.order_id
LEFT JOIN ShippingOne s ON s.order_id=o.order_id
WHERE o.order_status <> 'Cancelled';
GO

CREATE OR ALTER VIEW analytics.vw_ReturnsOperations AS
SELECT r.return_id, r.order_id, r.return_date, r.return_reason, r.refund_value, r.return_status,
       o.order_date, o.customer_id, o.product_id, p.product_name, p.category, c.region,
       s.promised_date, s.delivery_date,
       CASE WHEN s.delivery_date > s.promised_date THEN 1 ELSE 0 END AS is_late_delivery
FROM stg.Returns r
JOIN stg.Orders o ON o.order_id=r.order_id
JOIN stg.Products p ON p.product_id=o.product_id
JOIN stg.Customers c ON c.customer_id=o.customer_id
LEFT JOIN stg.Shipping s ON s.order_id=r.order_id;
GO

CREATE OR ALTER VIEW analytics.vw_CustomerProfitability AS
SELECT customer_id, customer_segment, region, acquisition_channel,
       COUNT(DISTINCT order_id) AS orders,
       SUM(gross_revenue) AS gross_revenue,
       SUM(discount_value) AS discount_value,
       SUM(refund_value) AS refund_value,
       SUM(net_revenue) AS net_revenue,
       SUM(gross_profit) AS gross_profit,
       CAST(SUM(gross_profit) / NULLIF(SUM(net_revenue),0) AS DECIMAL(10,4)) AS profit_margin
FROM analytics.vw_OrderProfitability
GROUP BY customer_id, customer_segment, region, acquisition_channel;
GO
