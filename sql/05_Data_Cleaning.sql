/*
 ProfitTrace | Data Cleaning and Transformation

 The staging tables preserve the source data. This layer standardizes text,
 normalizes source values and applies the business rules used by the dashboard.
*/
USE ProfitTrace;
GO

CREATE OR ALTER VIEW analytics.vw_OrderProfitability AS
WITH CleanOrders AS
(
    SELECT
        o.order_id,
        o.order_date,
        o.customer_id,
        o.product_id,
        o.quantity,
        o.unit_price,
        CASE WHEN o.discount_pct < 0 THEN 0
             WHEN o.discount_pct > 0.30 THEN 0.30
             ELSE o.discount_pct END AS discount_pct,
        CASE WHEN LOWER(LTRIM(RTRIM(o.order_status))) = 'completed' THEN 'Completed'
             WHEN LOWER(LTRIM(RTRIM(o.order_status))) = 'cancelled' THEN 'Cancelled'
             ELSE 'Unknown' END AS order_status
    FROM stg.Orders o
),
CleanCustomers AS
(
    SELECT customer_id,
           customer_name,
           CASE WHEN LOWER(LTRIM(RTRIM(segment))) = 'consumer' THEN 'Consumer'
                WHEN LOWER(LTRIM(RTRIM(segment))) = 'small business' THEN 'Small Business'
                WHEN LOWER(LTRIM(RTRIM(segment))) = 'enterprise' THEN 'Enterprise'
                ELSE 'Unknown' END AS customer_segment,
           CASE WHEN LOWER(LTRIM(RTRIM(region))) = 'north' THEN 'North'
                WHEN LOWER(LTRIM(RTRIM(region))) = 'south' THEN 'South'
                WHEN LOWER(LTRIM(RTRIM(region))) = 'east' THEN 'East'
                WHEN LOWER(LTRIM(RTRIM(region))) = 'west' THEN 'West'
                WHEN LOWER(LTRIM(RTRIM(region))) = 'central' THEN 'Central'
                ELSE 'Unknown' END AS region,
           signup_date,
           CASE WHEN LOWER(LTRIM(RTRIM(acquisition_channel))) = 'paid search' THEN 'Paid Search'
                WHEN LOWER(LTRIM(RTRIM(acquisition_channel))) = 'paid social' THEN 'Paid Social'
                WHEN LOWER(LTRIM(RTRIM(acquisition_channel))) = 'organic' THEN 'Organic'
                WHEN LOWER(LTRIM(RTRIM(acquisition_channel))) = 'referral' THEN 'Referral'
                WHEN LOWER(LTRIM(RTRIM(acquisition_channel))) = 'email' THEN 'Email'
                WHEN LOWER(LTRIM(RTRIM(acquisition_channel))) = 'marketplace' THEN 'Marketplace'
                ELSE 'Unknown' END AS acquisition_channel
    FROM stg.Customers
),
CleanProducts AS
(
    SELECT product_id,
           product_name,
           CASE WHEN LOWER(LTRIM(RTRIM(category))) = 'electronics' THEN 'Electronics'
                WHEN LOWER(LTRIM(RTRIM(category))) = 'home' THEN 'Home'
                WHEN LOWER(LTRIM(RTRIM(category))) = 'fashion' THEN 'Fashion'
                WHEN LOWER(LTRIM(RTRIM(category))) = 'beauty' THEN 'Beauty'
                WHEN LOWER(LTRIM(RTRIM(category))) = 'sports' THEN 'Sports'
                ELSE 'Unknown' END AS category,
           LTRIM(RTRIM(subcategory)) AS subcategory,
           unit_cost,
           list_price
    FROM stg.Products
),
CleanShipping AS
(
    SELECT order_id,
           ship_date,
           promised_date,
           delivery_date,
           shipping_cost,
           CASE WHEN LOWER(LTRIM(RTRIM(carrier))) = 'swiftship' THEN 'SwiftShip'
                WHEN LOWER(LTRIM(RTRIM(carrier))) = 'parcelpro' THEN 'ParcelPro'
                WHEN LOWER(LTRIM(RTRIM(carrier))) = 'northstar' THEN 'NorthStar'
                WHEN LOWER(LTRIM(RTRIM(carrier))) = 'bluedart' THEN 'BlueDart'
                ELSE 'Other' END AS carrier
    FROM stg.Shipping
),
ReturnAgg AS
(
    SELECT order_id,
           SUM(CASE WHEN LOWER(LTRIM(RTRIM(return_status))) = 'approved' THEN COALESCE(refund_value,0) ELSE 0 END) AS refund_value,
           COUNT(CASE WHEN LOWER(LTRIM(RTRIM(return_status))) = 'approved' THEN 1 END) AS return_count
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
    FROM CleanShipping
    GROUP BY order_id
)
SELECT
    o.order_id,
    o.order_date,
    o.customer_id,
    o.product_id,
    o.quantity,
    o.unit_price,
    o.discount_pct,
    o.order_status,
    p.product_name,
    p.category,
    p.subcategory,
    p.unit_cost,
    c.customer_segment,
    c.region,
    c.acquisition_channel,
    s.ship_date,
    s.promised_date,
    s.delivery_date,
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
FROM CleanOrders o
JOIN CleanProducts p ON p.product_id = o.product_id
JOIN CleanCustomers c ON c.customer_id = o.customer_id
LEFT JOIN ReturnAgg r ON r.order_id = o.order_id
LEFT JOIN ShippingOne s ON s.order_id = o.order_id
WHERE o.order_status = 'Completed';
GO

CREATE OR ALTER VIEW analytics.vw_ReturnsOperations AS
SELECT
    r.return_id,
    r.order_id,
    r.return_date,
    CASE WHEN LOWER(LTRIM(RTRIM(r.return_reason))) = 'changed mind' THEN 'Changed Mind'
         WHEN LOWER(LTRIM(RTRIM(r.return_reason))) = 'damaged' THEN 'Damaged'
         WHEN LOWER(LTRIM(RTRIM(r.return_reason))) = 'wrong item' THEN 'Wrong Item'
         WHEN LOWER(LTRIM(RTRIM(r.return_reason))) = 'late delivery' THEN 'Late Delivery'
         WHEN LOWER(LTRIM(RTRIM(r.return_reason))) = 'size/fit' THEN 'Size/Fit'
         WHEN LOWER(LTRIM(RTRIM(r.return_reason))) = 'not as expected' THEN 'Not as Expected'
         ELSE 'Other' END AS return_reason,
    r.refund_value,
    CASE WHEN LOWER(LTRIM(RTRIM(r.return_status))) = 'approved' THEN 'Approved'
         WHEN LOWER(LTRIM(RTRIM(r.return_status))) = 'rejected' THEN 'Rejected'
         WHEN LOWER(LTRIM(RTRIM(r.return_status))) = 'pending' THEN 'Pending'
         ELSE 'Unknown' END AS return_status,
    o.order_date,
    o.customer_id,
    o.product_id,
    p.product_name,
    p.category,
    c.region,
    s.promised_date,
    s.delivery_date,
    CASE WHEN s.delivery_date > s.promised_date THEN 1 ELSE 0 END AS is_late_delivery
FROM stg.Returns r
JOIN stg.Orders o ON o.order_id = r.order_id
JOIN stg.Products p ON p.product_id = o.product_id
JOIN stg.Customers c ON c.customer_id = o.customer_id
LEFT JOIN stg.Shipping s ON s.order_id = r.order_id;
GO

CREATE OR ALTER VIEW analytics.vw_CustomerProfitability AS
SELECT
    customer_id,
    customer_segment,
    region,
    acquisition_channel,
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
