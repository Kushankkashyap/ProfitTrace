/*
    ProfitTrace | Staging Tables
    Run after 01_Database_Setup.sql.

    Primary source: Excel workbooks.
    CSV copies are provided as a practical SQL Server import fallback when
    the Excel OLE DB provider is unavailable.
*/
USE ProfitTrace;
GO

CREATE TABLE stg.Customers
(
    customer_id VARCHAR(20) NOT NULL PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    customer_segment VARCHAR(30) NOT NULL,
    region VARCHAR(50) NOT NULL,
    state VARCHAR(60) NOT NULL,
    city VARCHAR(60) NOT NULL,
    signup_date DATE NOT NULL,
    acquisition_channel VARCHAR(40) NOT NULL
);

CREATE TABLE stg.Products
(
    product_id VARCHAR(20) NOT NULL PRIMARY KEY,
    product_name VARCHAR(180) NOT NULL,
    category VARCHAR(50) NOT NULL,
    subcategory VARCHAR(80) NOT NULL,
    brand VARCHAR(60) NOT NULL,
    product_tier VARCHAR(30) NOT NULL,
    list_price DECIMAL(12,2) NOT NULL,
    unit_cost DECIMAL(12,2) NOT NULL,
    launch_date DATE NOT NULL,
    rating DECIMAL(3,1) NOT NULL
);

CREATE TABLE stg.Orders
(
    order_id VARCHAR(20) NOT NULL PRIMARY KEY,
    order_date DATE NOT NULL,
    customer_id VARCHAR(20) NOT NULL,
    product_id VARCHAR(20) NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(12,2) NOT NULL,
    discount_pct DECIMAL(6,4) NOT NULL,
    payment_method VARCHAR(30) NOT NULL,
    order_channel VARCHAR(30) NOT NULL,
    promo_code VARCHAR(30) NOT NULL,
    order_status VARCHAR(30) NOT NULL
);

CREATE TABLE stg.Shipping
(
    order_id VARCHAR(20) NOT NULL PRIMARY KEY,
    ship_date DATE NULL,
    promised_delivery_date DATE NULL,
    delivery_date DATE NULL,
    delivery_status VARCHAR(30) NULL,
    carrier VARCHAR(40) NULL,
    shipping_method VARCHAR(30) NULL,
    shipping_cost DECIMAL(12,2) NOT NULL
);

CREATE TABLE stg.Returns
(
    return_id VARCHAR(20) NOT NULL PRIMARY KEY,
    order_id VARCHAR(20) NOT NULL,
    return_date DATE NOT NULL,
    return_reason VARCHAR(80) NOT NULL,
    return_status VARCHAR(20) NOT NULL,
    refund_amount DECIMAL(12,2) NOT NULL,
    return_shipping_cost DECIMAL(12,2) NOT NULL,
    restocking_cost DECIMAL(12,2) NOT NULL
);
GO

CREATE INDEX IX_Orders_Customer ON stg.Orders(customer_id);
CREATE INDEX IX_Orders_Product ON stg.Orders(product_id);
CREATE INDEX IX_Returns_Order ON stg.Returns(order_id);
GO
