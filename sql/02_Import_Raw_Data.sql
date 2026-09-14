/*
    ProfitTrace | Raw Excel Import Setup
    SQL Server / T-SQL

    Run this after 01_Database_Setup.sql.
    The Excel workbooks are imported into these staging tables using
    the SQL Server Import Wizard. Keeping the source data in staging
    makes the cleaning steps easy to audit and reproduce.
*/

USE ProfitTrace;
GO

CREATE TABLE stg.Customers
(
    customer_id INT NOT NULL PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    segment VARCHAR(30) NOT NULL,
    region VARCHAR(50) NOT NULL,
    signup_date DATE NOT NULL,
    acquisition_channel VARCHAR(30) NOT NULL
);

CREATE TABLE stg.Products
(
    product_id INT NOT NULL PRIMARY KEY,
    product_name VARCHAR(150) NOT NULL,
    category VARCHAR(50) NOT NULL,
    subcategory VARCHAR(60) NOT NULL,
    unit_cost DECIMAL(12,2) NOT NULL,
    list_price DECIMAL(12,2) NOT NULL
);

CREATE TABLE stg.Orders
(
    order_id INT NOT NULL,
    order_date DATE NOT NULL,
    customer_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(12,2) NOT NULL,
    discount_pct DECIMAL(6,4) NOT NULL,
    order_status VARCHAR(20) NOT NULL,
    CONSTRAINT PK_Orders PRIMARY KEY (order_id, product_id)
);

CREATE TABLE stg.Returns
(
    return_id INT NOT NULL PRIMARY KEY,
    order_id INT NOT NULL,
    return_date DATE NOT NULL,
    return_reason VARCHAR(80) NOT NULL,
    refund_value DECIMAL(12,2) NOT NULL,
    return_status VARCHAR(20) NOT NULL
);

CREATE TABLE stg.Shipping
(
    shipment_id INT NOT NULL PRIMARY KEY,
    order_id INT NOT NULL,
    ship_date DATE NOT NULL,
    promised_date DATE NOT NULL,
    delivery_date DATE NULL,
    shipping_cost DECIMAL(12,2) NOT NULL,
    carrier VARCHAR(40) NOT NULL
);
GO

CREATE INDEX IX_Orders_Customer ON stg.Orders(customer_id);
CREATE INDEX IX_Orders_Product ON stg.Orders(product_id);
CREATE INDEX IX_Returns_Order ON stg.Returns(order_id);
CREATE INDEX IX_Shipping_Order ON stg.Shipping(order_id);
GO

/*
Import with SQL Server Import and Export Wizard:
1. Source: Microsoft Excel.
2. Select the five workbooks from the project's data folder.
3. Destination: SQL Server database ProfitTrace.
4. Map each worksheet to its matching stg table.
5. Confirm the column data types shown above.
6. Run 03_Data_Validation.sql after all five imports finish.
*/
