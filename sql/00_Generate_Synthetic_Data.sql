/*
 ProfitTrace — Synthetic Data Generator
 Generates deterministic portfolio data directly in SQL Server.
 Run after 01_Database_Setup.sql. This avoids dependency on external data files.
*/
USE ProfitTrace;
GO

DROP TABLE IF EXISTS stg.Shipping;
DROP TABLE IF EXISTS stg.Returns;
DROP TABLE IF EXISTS stg.Orders;
DROP TABLE IF EXISTS stg.Products;
DROP TABLE IF EXISTS stg.Customers;
GO

CREATE TABLE stg.Customers(
 customer_id INT NOT NULL PRIMARY KEY,
 customer_name VARCHAR(100) NOT NULL,
 segment VARCHAR(30) NOT NULL,
 region VARCHAR(50) NOT NULL,
 signup_date DATE NOT NULL,
 acquisition_channel VARCHAR(30) NOT NULL
);
CREATE TABLE stg.Products(
 product_id INT NOT NULL PRIMARY KEY,
 product_name VARCHAR(150) NOT NULL,
 category VARCHAR(50) NOT NULL,
 subcategory VARCHAR(60) NOT NULL,
 unit_cost DECIMAL(12,2) NOT NULL,
 list_price DECIMAL(12,2) NOT NULL
);
CREATE TABLE stg.Orders(
 order_id INT NOT NULL,
 order_date DATE NOT NULL,
 customer_id INT NOT NULL,
 product_id INT NOT NULL,
 quantity INT NOT NULL,
 unit_price DECIMAL(12,2) NOT NULL,
 discount_pct DECIMAL(6,4) NOT NULL,
 order_status VARCHAR(20) NOT NULL,
 CONSTRAINT PK_Orders PRIMARY KEY(order_id,product_id)
);
CREATE TABLE stg.Returns(
 return_id INT NOT NULL PRIMARY KEY,
 order_id INT NOT NULL,
 return_date DATE NOT NULL,
 return_reason VARCHAR(80) NOT NULL,
 refund_value DECIMAL(12,2) NOT NULL,
 return_status VARCHAR(20) NOT NULL
);
CREATE TABLE stg.Shipping(
 shipment_id INT NOT NULL PRIMARY KEY,
 order_id INT NOT NULL,
 ship_date DATE NOT NULL,
 promised_date DATE NOT NULL,
 delivery_date DATE NULL,
 shipping_cost DECIMAL(12,2) NOT NULL,
 carrier VARCHAR(40) NOT NULL
);
GO

;WITH n AS (
 SELECT TOP (800) ROW_NUMBER() OVER(ORDER BY (SELECT NULL)) n
 FROM sys.all_objects a CROSS JOIN sys.all_objects b
)
INSERT stg.Customers
SELECT 10000+n,
       CONCAT('Customer ',n),
       CASE WHEN n%10 IN(0,1,2,3,4,5) THEN 'Consumer'
            WHEN n%10 IN(6,7,8) THEN 'Small Business' ELSE 'Enterprise' END,
       CHOOSE((n%5)+1,'North','South','East','West','Central'),
       DATEADD(DAY,(n*17)%715,'2024-01-01'),
       CHOOSE((n%6)+1,'Organic','Paid Search','Paid Social','Referral','Email','Marketplace')
FROM n;
GO

;WITH n AS (
 SELECT TOP (240) ROW_NUMBER() OVER(ORDER BY (SELECT NULL)) n
 FROM sys.all_objects a CROSS JOIN sys.all_objects b
), cats AS (
 SELECT n,
        CHOOSE(((n-1)/48)+1,'Electronics','Home','Fashion','Beauty','Sports') category,
        CHOOSE(((n-1)%3)+1,'Core','Premium','Specialty') tier
 FROM n
)
INSERT stg.Products
SELECT 20000+n,
       CONCAT(category,' ',tier,' Item ',n),
       category,
       CONCAT(category,' ',tier),
       CAST(12 + ((n*37)%168) AS DECIMAL(12,2)),
       CAST((12 + ((n*37)%168)) * (1.35 + ((n*13)%100)/100.0) AS DECIMAL(12,2))
FROM cats;
GO

;WITH n AS (
 SELECT TOP (11000) ROW_NUMBER() OVER(ORDER BY (SELECT NULL)) n
 FROM sys.all_objects a CROSS JOIN sys.all_objects b CROSS JOIN sys.all_objects c
)
INSERT stg.Orders
SELECT 500000+n,
       DATEADD(DAY,(n*7)%365,'2025-01-01'),
       10001+((n*17)%800),
       20001+((n*29)%240),
       CASE WHEN n%11<9 THEN 1 ELSE 2+(n%3) END,
       /* unit_price is intentionally the pre-discount list/selling price.
          Discount is stored separately so the analytical layer applies it once. */
       CAST(p.list_price AS DECIMAL(12,2)),
       CAST(CASE WHEN (n%10) IN(6,7) THEN .18
                 WHEN (n%10) IN(8,9) THEN .12 ELSE .07 END
            + CASE WHEN p.category IN('Fashion','Electronics') THEN .04 ELSE 0 END AS DECIMAL(6,4)),
       CASE WHEN n%200=0 THEN 'Cancelled' ELSE 'Completed' END
FROM n
JOIN stg.Products p ON p.product_id=20001+((n*29)%240);
GO

INSERT stg.Shipping
SELECT 900000+o.order_id-500000,
       o.order_id,
       DATEADD(DAY,2,o.order_date),
       DATEADD(DAY,5+(o.order_id%3),o.order_date),
       DATEADD(DAY,5+(o.order_id%3)+
           CASE WHEN o.order_id%9 IN(0,1) THEN 2
                WHEN o.order_id%17=0 THEN 4 ELSE 0 END,o.order_date),
       CAST(6+(o.quantity*2)+(o.order_id%13) AS DECIMAL(12,2)),
       CHOOSE((o.order_id%4)+1,'SwiftShip','ParcelPro','NorthStar','BlueDart')
FROM stg.Orders o;
GO

;WITH candidates AS (
 SELECT o.*, p.category, s.delivery_date, s.promised_date,
        ROW_NUMBER() OVER(ORDER BY o.order_id) rn
 FROM stg.Orders o
 JOIN stg.Products p ON p.product_id=o.product_id
 JOIN stg.Shipping s ON s.order_id=o.order_id
 WHERE o.order_status='Completed'
   AND (o.discount_pct>=.16 OR p.category IN('Fashion','Electronics')
        OR s.delivery_date>s.promised_date)
)
INSERT stg.Returns
SELECT TOP (900)
       700000+rn,
       order_id,
       DATEADD(DAY,7+(rn%21),order_date),
       CASE
         WHEN delivery_date>promised_date THEN 'Late Delivery'
         WHEN category='Fashion' THEN CASE WHEN rn%2=0 THEN 'Size/Fit' ELSE 'Not as Expected' END
         WHEN rn%5=0 THEN 'Damaged'
         WHEN rn%3=0 THEN 'Wrong Item'
         ELSE 'Changed Mind'
       END,
       /* Refund equals the actual customer-paid amount after discount. */
       CAST(quantity*unit_price*(1-discount_pct) AS DECIMAL(12,2)),
       'Approved'
FROM candidates
ORDER BY rn;
GO

SELECT 'Customers' table_name, COUNT(*) row_count FROM stg.Customers
UNION ALL SELECT 'Products', COUNT(*) FROM stg.Products
UNION ALL SELECT 'Orders', COUNT(*) FROM stg.Orders
UNION ALL SELECT 'Returns', COUNT(*) FROM stg.Returns
UNION ALL SELECT 'Shipping', COUNT(*) FROM stg.Shipping;
GO
