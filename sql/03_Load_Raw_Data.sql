/*
    ProfitTrace — Raw CSV Load Template

    1) Download/copy the five source CSV files into a local folder.
    2) Update @DataPath below.
    3) Ensure SQL Server has permission to read the folder.
    4) Run after 01_Database_Setup.sql and 02_Table_Creation.sql.

    The exact CSV files will be added to /data as the project dataset is finalized.
*/

USE ProfitTrace;
GO

DECLARE @DataPath NVARCHAR(4000) = N'C:\ProfitTrace\data\';

-- Customers
BULK INSERT stg.Customers
FROM 'C:\ProfitTrace\data\customers.csv'
WITH
(
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDQUOTE = '"',
    TABLOCK
);

-- Products
BULK INSERT stg.Products
FROM 'C:\ProfitTrace\data\products.csv'
WITH
(
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDQUOTE = '"',
    TABLOCK
);

-- Orders
BULK INSERT stg.Orders
FROM 'C:\ProfitTrace\data\orders.csv'
WITH
(
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDQUOTE = '"',
    TABLOCK
);

-- Returns
BULK INSERT stg.Returns
FROM 'C:\ProfitTrace\data\returns.csv'
WITH
(
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDQUOTE = '"',
    TABLOCK
);

-- Shipping
BULK INSERT stg.Shipping
FROM 'C:\ProfitTrace\data\shipping.csv'
WITH
(
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDQUOTE = '"',
    TABLOCK
);
GO
