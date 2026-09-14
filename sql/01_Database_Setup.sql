/*
    ProfitTrace | Database Setup
    SQL Server / T-SQL

    Creates the project database and schemas.
    Raw Excel data is imported into the stg schema in the next step.
*/

IF DB_ID(N'ProfitTrace') IS NULL
BEGIN
    CREATE DATABASE ProfitTrace;
END;
GO

USE ProfitTrace;
GO

IF SCHEMA_ID(N'stg') IS NULL EXEC(N'CREATE SCHEMA stg');
IF SCHEMA_ID(N'analytics') IS NULL EXEC(N'CREATE SCHEMA analytics');
GO

DROP VIEW IF EXISTS analytics.vw_OrderProfitability;
DROP VIEW IF EXISTS analytics.vw_ReturnsOperations;
DROP VIEW IF EXISTS analytics.vw_CustomerProfitability;
GO

DROP TABLE IF EXISTS stg.Shipping;
DROP TABLE IF EXISTS stg.Returns;
DROP TABLE IF EXISTS stg.Orders;
DROP TABLE IF EXISTS stg.Products;
DROP TABLE IF EXISTS stg.Customers;
GO
