/*
    ProfitTrace | Database Setup
    SQL Server / T-SQL
*/
IF DB_ID('ProfitTrace') IS NULL
    CREATE DATABASE ProfitTrace;
GO

USE ProfitTrace;
GO

IF SCHEMA_ID('stg') IS NULL EXEC('CREATE SCHEMA stg');
IF SCHEMA_ID('analytics') IS NULL EXEC('CREATE SCHEMA analytics');
GO

DROP VIEW IF EXISTS analytics.vw_OrderProfitability;
DROP VIEW IF EXISTS analytics.vw_ReturnsOperations;
DROP VIEW IF EXISTS analytics.vw_CustomerProfitability;
GO

DROP TABLE IF EXISTS stg.Returns;
DROP TABLE IF EXISTS stg.Shipping;
DROP TABLE IF EXISTS stg.Orders;
DROP TABLE IF EXISTS stg.Products;
DROP TABLE IF EXISTS stg.Customers;
GO
