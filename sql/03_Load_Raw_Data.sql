/*
    ProfitTrace | Excel to SQL Server Load Guide

    The source files are Excel workbooks. Use the SQL Server Import and Export
    Wizard to load each workbook into the matching staging table.

    Source files:
      Customers.xlsx -> stg.Customers
      Products.xlsx  -> stg.Products
      Orders.xlsx    -> stg.Orders
      Returns.xlsx   -> stg.Returns
      Shipping.xlsx  -> stg.Shipping

    Recommended order:
      1. Run 01_Database_Setup.sql
      2. Run 02_Table_Creation.sql
      3. Import the five Excel workbooks into the staging tables
      4. Run 04_Data_Validation.sql

    Import Wizard notes:
      - Server: your local SQL Server instance
      - Destination database: ProfitTrace
      - Destination schema: stg
      - First row contains column names: Yes
      - Preserve the column names and data types defined in 02_Table_Creation.sql
      - Do not enable automatic table creation; the staging tables already exist

    If Excel is not available in the Import Wizard, save a workbook as CSV and
    use the equivalent flat-file import option. The analytical workflow remains
    the same.
*/

USE ProfitTrace;
GO

/*
After the Import Wizard finishes, use these checks before moving to validation.
*/
SELECT 'Customers' AS table_name, COUNT(*) AS row_count FROM stg.Customers
UNION ALL SELECT 'Products', COUNT(*) FROM stg.Products
UNION ALL SELECT 'Orders', COUNT(*) FROM stg.Orders
UNION ALL SELECT 'Returns', COUNT(*) FROM stg.Returns
UNION ALL SELECT 'Shipping', COUNT(*) FROM stg.Shipping;
GO
