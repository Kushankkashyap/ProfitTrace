/* ProfitTrace | Cleaning & Analytical Views */
USE ProfitTrace;
GO

CREATE OR ALTER VIEW analytics.vw_OrderProfitability AS
WITH CleanOrders AS
(
    SELECT o.order_id,o.order_date,o.customer_id,o.product_id,o.quantity,o.unit_price,
           o.discount_pct AS discount_pct_raw,
           CASE WHEN o.discount_pct < 0 THEN 0 WHEN o.discount_pct > 0.30 THEN 0.30 ELSE o.discount_pct END AS discount_pct,
           CASE LOWER(LTRIM(RTRIM(o.order_status)))
                WHEN 'delivered' THEN 'Delivered' WHEN 'cancelled' THEN 'Cancelled'
                WHEN 'processing' THEN 'Processing' ELSE 'Other' END AS order_status,
           o.payment_method,o.order_channel,o.promo_code
    FROM stg.Orders o
),
ReturnsAgg AS
(
    SELECT order_id,
           SUM(CASE WHEN LOWER(LTRIM(RTRIM(return_status)))='approved' THEN refund_amount ELSE 0 END) AS refund_amount,
           SUM(CASE WHEN LOWER(LTRIM(RTRIM(return_status)))='approved' THEN return_shipping_cost+restocking_cost ELSE 0 END) AS return_cost,
           COUNT(CASE WHEN LOWER(LTRIM(RTRIM(return_status)))='approved' THEN 1 END) AS approved_return_events
    FROM stg.Returns GROUP BY order_id
),
Base AS
(
    SELECT o.*, c.customer_name,c.customer_segment,c.region,c.state,c.city,c.acquisition_channel,
           p.product_name,p.category,p.subcategory,p.brand,p.product_tier,p.unit_cost,p.rating,
           s.ship_date,s.promised_delivery_date,s.delivery_date,s.delivery_status,s.carrier,s.shipping_method,s.shipping_cost,
           COALESCE(r.refund_amount,0) AS order_refund_amount,
           COALESCE(r.return_cost,0) AS order_return_cost,
           COALESCE(r.approved_return_events,0) AS approved_return_events
    FROM CleanOrders o
    JOIN stg.Customers c ON c.customer_id=o.customer_id
    JOIN stg.Products p ON p.product_id=o.product_id
    LEFT JOIN stg.Shipping s ON s.order_id=o.order_id
    LEFT JOIN ReturnsAgg r ON r.order_id=o.order_id
),
LineMath AS
(
    SELECT *,
           CAST(quantity*unit_price AS DECIMAL(14,2)) AS gross_revenue,
           CAST(quantity*unit_price*discount_pct AS DECIMAL(14,2)) AS discount_value,
           CAST(quantity*unit_price*(1-discount_pct) AS DECIMAL(14,2)) AS sales_after_discount
    FROM Base
),
Allocated AS
(
    SELECT *,SUM(sales_after_discount) OVER(PARTITION BY order_id) AS order_sales,
           COUNT(*) OVER(PARTITION BY order_id) AS order_lines
    FROM LineMath
)
SELECT order_id,order_date,customer_id,customer_name,customer_segment,region,state,city,acquisition_channel,
       product_id,product_name,category,subcategory,brand,product_tier,rating,quantity,unit_price,
       discount_pct_raw,discount_pct,gross_revenue,discount_value,sales_after_discount,
       CAST(CASE WHEN order_sales>0 THEN order_refund_amount*sales_after_discount/order_sales ELSE order_refund_amount/NULLIF(order_lines,0) END AS DECIMAL(14,2)) AS refund_amount,
       CAST(sales_after_discount-CASE WHEN order_sales>0 THEN order_refund_amount*sales_after_discount/order_sales ELSE order_refund_amount/NULLIF(order_lines,0) END AS DECIMAL(14,2)) AS net_revenue,
       CAST(quantity*unit_cost AS DECIMAL(14,2)) AS product_cost,
       CAST(CASE WHEN order_sales>0 THEN shipping_cost*sales_after_discount/order_sales ELSE shipping_cost/NULLIF(order_lines,0) END AS DECIMAL(14,2)) AS shipping_cost,
       CAST(CASE WHEN order_sales>0 THEN order_return_cost*sales_after_discount/order_sales ELSE order_return_cost/NULLIF(order_lines,0) END AS DECIMAL(14,2)) AS return_cost,
       CAST(sales_after_discount
            - CASE WHEN order_sales>0 THEN order_refund_amount*sales_after_discount/order_sales ELSE order_refund_amount/NULLIF(order_lines,0) END
            - quantity*unit_cost
            - CASE WHEN order_sales>0 THEN shipping_cost*sales_after_discount/order_sales ELSE shipping_cost/NULLIF(order_lines,0) END
            - CASE WHEN order_sales>0 THEN order_return_cost*sales_after_discount/order_sales ELSE order_return_cost/NULLIF(order_lines,0) END AS DECIMAL(14,2)) AS gross_profit,
       CASE WHEN discount_pct_raw<>discount_pct THEN 1 ELSE 0 END AS discount_corrected_flag,
       ship_date,promised_delivery_date,delivery_date,carrier,shipping_method,
       CASE WHEN delivery_date IS NULL THEN 'Not Delivered' WHEN delivery_date>promised_delivery_date THEN 'Late' ELSE 'On Time' END AS delivery_status_clean,
       CASE WHEN delivery_date IS NOT NULL AND delivery_date>promised_delivery_date THEN 1 ELSE 0 END AS is_late_delivery,
       CASE WHEN approved_return_events>0 THEN 1 ELSE 0 END AS is_returned,
       CASE WHEN delivery_date IS NOT NULL THEN 1 ELSE 0 END AS is_delivered,
       order_status,payment_method,order_channel,promo_code
FROM Allocated;
GO

CREATE OR ALTER VIEW analytics.vw_ReturnsOperations AS
SELECT r.return_id,r.order_id,r.return_date,
       CASE LOWER(LTRIM(RTRIM(r.return_reason)))
            WHEN 'changed mind' THEN 'Changed Mind' WHEN 'late delivery' THEN 'Late Delivery'
            WHEN 'size/fit' THEN 'Size/Fit' WHEN 'not as expected' THEN 'Not as Expected'
            WHEN 'wrong item' THEN 'Wrong Item' WHEN 'damaged' THEN 'Damaged'
            ELSE LTRIM(RTRIM(r.return_reason)) END AS return_reason,
       CASE WHEN LOWER(LTRIM(RTRIM(r.return_status)))='approved' THEN 'Approved' ELSE 'Rejected' END AS return_status,
       r.refund_amount,r.return_shipping_cost,r.restocking_cost,
       r.refund_amount+r.return_shipping_cost+r.restocking_cost AS total_return_cost
FROM stg.Returns r;
GO

CREATE OR ALTER VIEW analytics.vw_CustomerProfitability AS
SELECT customer_id,MAX(customer_name) AS customer_name,MAX(customer_segment) AS customer_segment,
       MAX(region) AS region,MAX(state) AS state,MAX(city) AS city,MAX(acquisition_channel) AS acquisition_channel,
       COUNT(DISTINCT CASE WHEN order_status='Delivered' THEN order_id END) AS delivered_orders,
       SUM(CASE WHEN order_status='Delivered' THEN net_revenue ELSE 0 END) AS net_revenue,
       SUM(CASE WHEN order_status='Delivered' THEN gross_profit ELSE 0 END) AS gross_profit,
       CASE WHEN COUNT(DISTINCT CASE WHEN order_status='Delivered' THEN order_id END)>1 THEN 'Repeat' ELSE 'One-Time' END AS customer_type
FROM analytics.vw_OrderProfitability GROUP BY customer_id;
GO
