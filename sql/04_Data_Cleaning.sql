/* ProfitTrace | Data Cleaning and Analytical Views */
USE ProfitTrace;
GO

/*
The raw Excel imports remain unchanged in stg.
These views standardize business logic for Power BI and analysis.
The profitability view stays at order-product-line grain. Order-level
refunds and shipping costs are allocated across lines so multi-line orders
cannot double-count those costs.
*/

CREATE OR ALTER VIEW analytics.vw_OrderProfitability AS
WITH ReturnAgg AS
(
    SELECT order_id,
           SUM(CASE WHEN LOWER(LTRIM(RTRIM(return_status)))='approved' THEN refund_value ELSE 0 END) AS refund_value,
           COUNT(CASE WHEN LOWER(LTRIM(RTRIM(return_status)))='approved' THEN 1 END) AS return_count
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
),
LineBase AS
(
    SELECT
        o.order_id,
        o.order_date,
        o.customer_id,
        o.product_id,
        o.quantity,
        o.unit_price,
        o.discount_pct AS discount_pct_raw,
        CAST(CASE WHEN o.discount_pct < 0 THEN 0
                  WHEN o.discount_pct > 0.30 THEN 0.30
                  ELSE o.discount_pct END AS DECIMAL(6,4)) AS discount_pct,
        CASE WHEN LOWER(LTRIM(RTRIM(o.order_status)))='completed' THEN 'Completed' ELSE 'Cancelled' END AS order_status,
        p.product_name,
        CASE WHEN LOWER(LTRIM(RTRIM(p.category)))='electronics' THEN 'Electronics'
             WHEN LOWER(LTRIM(RTRIM(p.category)))='home' THEN 'Home'
             WHEN LOWER(LTRIM(RTRIM(p.category)))='fashion' THEN 'Fashion'
             WHEN LOWER(LTRIM(RTRIM(p.category)))='beauty' THEN 'Beauty'
             WHEN LOWER(LTRIM(RTRIM(p.category)))='sports' THEN 'Sports'
             ELSE LTRIM(RTRIM(p.category)) END AS category,
        LTRIM(RTRIM(p.subcategory)) AS subcategory,
        p.unit_cost,
        CASE WHEN LOWER(LTRIM(RTRIM(c.segment)))='consumer' THEN 'Consumer'
             WHEN LOWER(LTRIM(RTRIM(c.segment)))='small business' THEN 'Small Business'
             WHEN LOWER(LTRIM(RTRIM(c.segment)))='enterprise' THEN 'Enterprise'
             ELSE LTRIM(RTRIM(c.segment)) END AS customer_segment,
        LTRIM(RTRIM(c.region)) AS region,
        CASE WHEN LOWER(LTRIM(RTRIM(c.acquisition_channel)))='paid social' THEN 'Paid Social'
             WHEN LOWER(LTRIM(RTRIM(c.acquisition_channel)))='paid search' THEN 'Paid Search'
             WHEN LOWER(LTRIM(RTRIM(c.acquisition_channel)))='organic' THEN 'Organic'
             WHEN LOWER(LTRIM(RTRIM(c.acquisition_channel)))='referral' THEN 'Referral'
             WHEN LOWER(LTRIM(RTRIM(c.acquisition_channel)))='email' THEN 'Email'
             ELSE LTRIM(RTRIM(c.acquisition_channel)) END AS acquisition_channel,
        s.ship_date,
        s.promised_date,
        s.delivery_date,
        CAST(o.quantity*o.unit_price AS DECIMAL(14,2)) AS gross_revenue,
        CAST(o.quantity*o.unit_price*CASE WHEN o.discount_pct < 0 THEN 0 WHEN o.discount_pct > 0.30 THEN 0.30 ELSE o.discount_pct END AS DECIMAL(14,2)) AS discount_value,
        CAST(o.quantity*o.unit_price*(1-CASE WHEN o.discount_pct < 0 THEN 0 WHEN o.discount_pct > 0.30 THEN 0.30 ELSE o.discount_pct END) AS DECIMAL(14,2)) AS sales_after_discount,
        COALESCE(r.refund_value,0) AS order_refund_value,
        COALESCE(r.return_count,0) AS return_count,
        COALESCE(s.shipping_cost,0) AS order_shipping_cost
    FROM stg.Orders o
    JOIN stg.Products p ON p.product_id=o.product_id
    JOIN stg.Customers c ON c.customer_id=o.customer_id
    LEFT JOIN ReturnAgg r ON r.order_id=o.order_id
    LEFT JOIN ShippingOne s ON s.order_id=o.order_id
    WHERE LOWER(LTRIM(RTRIM(o.order_status)))<>'cancelled'
),
LineAllocated AS
(
    SELECT *,
           CASE WHEN discount_pct_raw <> discount_pct THEN 1 ELSE 0 END AS discount_corrected_flag,
           SUM(sales_after_discount) OVER (PARTITION BY order_id) AS order_sales_after_discount,
           COUNT(*) OVER (PARTITION BY order_id) AS order_line_count
    FROM LineBase
)
SELECT
    order_id, order_date, customer_id, product_id, quantity,
    unit_price, discount_pct_raw, discount_pct, discount_corrected_flag, order_status,
    product_name, category, subcategory, unit_cost,
    customer_segment, region, acquisition_channel,
    ship_date, promised_date, delivery_date,
    gross_revenue,
    discount_value,
    sales_after_discount,
    CAST(sales_after_discount -
         CASE WHEN order_sales_after_discount > 0
              THEN order_refund_value * sales_after_discount / order_sales_after_discount
              ELSE order_refund_value / NULLIF(order_line_count,0) END AS DECIMAL(14,2)) AS net_revenue,
    CAST(CASE WHEN order_sales_after_discount > 0
              THEN order_refund_value * sales_after_discount / order_sales_after_discount
              ELSE order_refund_value / NULLIF(order_line_count,0) END AS DECIMAL(14,2)) AS refund_value,
    CAST(quantity*unit_cost AS DECIMAL(14,2)) AS product_cost,
    CAST(CASE WHEN order_sales_after_discount > 0
              THEN order_shipping_cost * sales_after_discount / order_sales_after_discount
              ELSE order_shipping_cost / NULLIF(order_line_count,0) END AS DECIMAL(14,2)) AS shipping_cost,
    CAST(sales_after_discount -
         CASE WHEN order_sales_after_discount > 0
              THEN order_refund_value * sales_after_discount / order_sales_after_discount
              ELSE order_refund_value / NULLIF(order_line_count,0) END -
         quantity*unit_cost -
         CASE WHEN order_sales_after_discount > 0
              THEN order_shipping_cost * sales_after_discount / order_sales_after_discount
              ELSE order_shipping_cost / NULLIF(order_line_count,0) END AS DECIMAL(14,2)) AS gross_profit,
    CASE WHEN delivery_date IS NOT NULL AND delivery_date>promised_date THEN 1 ELSE 0 END AS is_late_delivery,
    CASE WHEN return_count>0 THEN 1 ELSE 0 END AS is_returned,
    CASE WHEN delivery_date IS NOT NULL THEN 1 ELSE 0 END AS is_delivered,
    CASE WHEN delivery_date IS NULL THEN 'Not Delivered' WHEN delivery_date>promised_date THEN 'Late' ELSE 'On Time' END AS delivery_status
FROM LineAllocated;
GO

CREATE OR ALTER VIEW analytics.vw_ReturnsOperations AS
WITH ShippingOne AS
(
    SELECT order_id,
           MAX(promised_date) AS promised_date,
           MAX(delivery_date) AS delivery_date
    FROM stg.Shipping
    GROUP BY order_id
)
SELECT r.return_id, r.order_id, r.return_date, LTRIM(RTRIM(r.return_reason)) AS return_reason,
       r.refund_value,
       CASE WHEN LOWER(LTRIM(RTRIM(r.return_status)))='approved' THEN 'Approved'
            WHEN LOWER(LTRIM(RTRIM(r.return_status)))='rejected' THEN 'Rejected'
            ELSE LTRIM(RTRIM(r.return_status)) END AS return_status,
       o.order_date, o.customer_id, o.product_id,
       p.product_name,
       CASE WHEN LOWER(LTRIM(RTRIM(p.category)))='electronics' THEN 'Electronics'
            ELSE LTRIM(RTRIM(p.category)) END AS category,
       LTRIM(RTRIM(p.subcategory)) AS subcategory,
       LTRIM(RTRIM(c.region)) AS region,
       CASE WHEN LOWER(LTRIM(RTRIM(c.segment)))='consumer' THEN 'Consumer'
            ELSE LTRIM(RTRIM(c.segment)) END AS customer_segment,
       s.promised_date, s.delivery_date,
       CASE WHEN s.delivery_date>s.promised_date THEN 1 ELSE 0 END AS is_late_delivery
FROM stg.Returns r
JOIN stg.Orders o ON o.order_id=r.order_id
JOIN stg.Products p ON p.product_id=o.product_id
JOIN stg.Customers c ON c.customer_id=o.customer_id
LEFT JOIN ShippingOne s ON s.order_id=r.order_id
WHERE LOWER(LTRIM(RTRIM(r.return_status)))='approved';
GO

CREATE OR ALTER VIEW analytics.vw_CustomerProfitability AS
SELECT customer_id, customer_segment, region, acquisition_channel,
       COUNT(DISTINCT order_id) AS orders,
       SUM(gross_revenue) AS gross_revenue,
       SUM(discount_value) AS discount_value,
       SUM(refund_value) AS refund_value,
       SUM(net_revenue) AS net_revenue,
       SUM(gross_profit) AS gross_profit,
       CAST(SUM(gross_profit)/NULLIF(SUM(net_revenue),0) AS DECIMAL(10,4)) AS profit_margin
FROM analytics.vw_OrderProfitability
GROUP BY customer_id, customer_segment, region, acquisition_channel;
GO
