/* ProfitTrace | Business Analysis */
USE ProfitTrace;
GO

-- 1. Executive KPI: core commercial economics are based on delivered orders.
SELECT
    COUNT(DISTINCT CASE WHEN is_delivered=1 THEN order_id END) AS delivered_orders,
    SUM(CASE WHEN is_delivered=1 THEN gross_revenue ELSE 0 END) AS gross_revenue,
    SUM(CASE WHEN is_delivered=1 THEN discount_value ELSE 0 END) AS discount_value,
    SUM(CASE WHEN is_delivered=1 THEN refund_amount ELSE 0 END) AS refund_value,
    SUM(CASE WHEN is_delivered=1 THEN net_revenue ELSE 0 END) AS net_revenue,
    SUM(CASE WHEN is_delivered=1 THEN product_cost ELSE 0 END) AS product_cost,
    SUM(CASE WHEN is_delivered=1 THEN shipping_cost+return_cost ELSE 0 END) AS operational_cost,
    SUM(CASE WHEN is_delivered=1 THEN gross_profit ELSE 0 END) AS gross_profit,
    CAST(100.0*SUM(CASE WHEN is_delivered=1 THEN gross_profit ELSE 0 END)
        /NULLIF(SUM(CASE WHEN is_delivered=1 THEN net_revenue ELSE 0 END),0) AS DECIMAL(10,2)) AS margin_pct
FROM analytics.vw_OrderProfitability;
GO

-- 2. Monthly trend
SELECT
    DATEFROMPARTS(YEAR(order_date),MONTH(order_date),1) AS month_start,
    COUNT(DISTINCT CASE WHEN is_delivered=1 THEN order_id END) AS delivered_orders,
    SUM(CASE WHEN is_delivered=1 THEN net_revenue ELSE 0 END) AS net_revenue,
    SUM(CASE WHEN is_delivered=1 THEN gross_profit ELSE 0 END) AS gross_profit,
    CAST(100.0*SUM(CASE WHEN is_delivered=1 THEN gross_profit ELSE 0 END)
        /NULLIF(SUM(CASE WHEN is_delivered=1 THEN net_revenue ELSE 0 END),0) AS DECIMAL(10,2)) AS margin_pct
FROM analytics.vw_OrderProfitability
GROUP BY DATEFROMPARTS(YEAR(order_date),MONTH(order_date),1)
ORDER BY month_start;
GO

-- 3. Category profitability and return economics
SELECT
    category,
    COUNT(DISTINCT CASE WHEN is_delivered=1 THEN order_id END) AS delivered_orders,
    SUM(CASE WHEN is_delivered=1 THEN net_revenue ELSE 0 END) AS net_revenue,
    SUM(CASE WHEN is_delivered=1 THEN gross_profit ELSE 0 END) AS gross_profit,
    CAST(100.0*SUM(CASE WHEN is_delivered=1 THEN gross_profit ELSE 0 END)
        /NULLIF(SUM(CASE WHEN is_delivered=1 THEN net_revenue ELSE 0 END),0) AS DECIMAL(10,2)) AS margin_pct,
    CAST(100.0*SUM(CASE WHEN is_delivered=1 THEN discount_value ELSE 0 END)
        /NULLIF(SUM(CASE WHEN is_delivered=1 THEN gross_revenue ELSE 0 END),0) AS DECIMAL(10,2)) AS discount_rate_pct,
    CAST(100.0*COUNT(DISTINCT CASE WHEN is_returned=1 AND is_delivered=1 THEN order_id END)
        /NULLIF(COUNT(DISTINCT CASE WHEN is_delivered=1 THEN order_id END),0) AS DECIMAL(10,2)) AS return_rate_pct
FROM analytics.vw_OrderProfitability
GROUP BY category
ORDER BY gross_profit DESC;
GO

-- 4. Product profitability: find high-sales / low-profit products
SELECT TOP (50)
    product_id,product_name,category,subcategory,brand,product_tier,
    COUNT(DISTINCT CASE WHEN is_delivered=1 THEN order_id END) AS delivered_orders,
    SUM(CASE WHEN is_delivered=1 THEN net_revenue ELSE 0 END) AS net_revenue,
    SUM(CASE WHEN is_delivered=1 THEN gross_profit ELSE 0 END) AS gross_profit,
    CAST(100.0*SUM(CASE WHEN is_delivered=1 THEN gross_profit ELSE 0 END)
        /NULLIF(SUM(CASE WHEN is_delivered=1 THEN net_revenue ELSE 0 END),0) AS DECIMAL(10,2)) AS margin_pct
FROM analytics.vw_OrderProfitability
GROUP BY product_id,product_name,category,subcategory,brand,product_tier
ORDER BY gross_profit ASC;
GO

-- 5. Discount leakage by band
SELECT
    CASE
        WHEN discount_pct<0.05 THEN '<5%'
        WHEN discount_pct<0.10 THEN '5-10%'
        WHEN discount_pct<0.15 THEN '10-15%'
        WHEN discount_pct<0.20 THEN '15-20%'
        ELSE '20%+'
    END AS discount_band,
    COUNT(DISTINCT CASE WHEN is_delivered=1 THEN order_id END) AS delivered_orders,
    SUM(CASE WHEN is_delivered=1 THEN discount_value ELSE 0 END) AS discount_value,
    SUM(CASE WHEN is_delivered=1 THEN net_revenue ELSE 0 END) AS net_revenue,
    SUM(CASE WHEN is_delivered=1 THEN gross_profit ELSE 0 END) AS gross_profit,
    CAST(100.0*SUM(CASE WHEN is_delivered=1 THEN gross_profit ELSE 0 END)
        /NULLIF(SUM(CASE WHEN is_delivered=1 THEN net_revenue ELSE 0 END),0) AS DECIMAL(10,2)) AS margin_pct
FROM analytics.vw_OrderProfitability
GROUP BY CASE
    WHEN discount_pct<0.05 THEN '<5%'
    WHEN discount_pct<0.10 THEN '5-10%'
    WHEN discount_pct<0.15 THEN '10-15%'
    WHEN discount_pct<0.20 THEN '15-20%'
    ELSE '20%+'
END
ORDER BY MIN(discount_pct);
GO

-- 6. Return reasons and total leakage
SELECT
    return_reason,
    COUNT(*) AS approved_return_events,
    SUM(refund_amount) AS refund_value,
    SUM(total_return_cost) AS total_return_cost
FROM analytics.vw_ReturnsOperations
WHERE return_status='Approved'
GROUP BY return_reason
ORDER BY total_return_cost DESC;
GO

-- 7. Delivery performance versus returns
SELECT
    delivery_status_clean AS delivery_group,
    COUNT(DISTINCT CASE WHEN is_delivered=1 THEN order_id END) AS delivered_orders,
    COUNT(DISTINCT CASE WHEN is_returned=1 AND is_delivered=1 THEN order_id END) AS returned_orders,
    CAST(100.0*COUNT(DISTINCT CASE WHEN is_returned=1 AND is_delivered=1 THEN order_id END)
        /NULLIF(COUNT(DISTINCT CASE WHEN is_delivered=1 THEN order_id END),0) AS DECIMAL(10,2)) AS return_rate_pct
FROM analytics.vw_OrderProfitability
WHERE is_delivered=1
GROUP BY delivery_status_clean;
GO

-- 8. Regional and acquisition-channel economics
SELECT
    region,
    COUNT(DISTINCT CASE WHEN is_delivered=1 THEN order_id END) AS orders,
    SUM(CASE WHEN is_delivered=1 THEN net_revenue ELSE 0 END) AS net_revenue,
    SUM(CASE WHEN is_delivered=1 THEN gross_profit ELSE 0 END) AS gross_profit,
    CAST(100.0*SUM(CASE WHEN is_delivered=1 THEN gross_profit ELSE 0 END)
        /NULLIF(SUM(CASE WHEN is_delivered=1 THEN net_revenue ELSE 0 END),0) AS DECIMAL(10,2)) AS margin_pct
FROM analytics.vw_OrderProfitability
GROUP BY region
ORDER BY gross_profit DESC;

SELECT
    acquisition_channel,
    COUNT(DISTINCT CASE WHEN is_delivered=1 THEN customer_id END) AS customers,
    SUM(CASE WHEN is_delivered=1 THEN net_revenue ELSE 0 END) AS net_revenue,
    SUM(CASE WHEN is_delivered=1 THEN gross_profit ELSE 0 END) AS gross_profit
FROM analytics.vw_OrderProfitability
GROUP BY acquisition_channel
ORDER BY gross_profit DESC;
GO

-- 9. One-time versus repeat customer economics
SELECT
    customer_type,
    COUNT(*) AS customers,
    AVG(delivered_orders*1.0) AS avg_orders,
    AVG(net_revenue) AS avg_net_revenue,
    AVG(gross_profit) AS avg_gross_profit
FROM analytics.vw_CustomerProfitability
GROUP BY customer_type;
GO

-- 10. Customer value leaderboard
SELECT TOP (25)
    customer_id,customer_name,customer_segment,region,acquisition_channel,
    delivered_orders,net_revenue,gross_profit,customer_type
FROM analytics.vw_CustomerProfitability
ORDER BY gross_profit DESC;
GO
