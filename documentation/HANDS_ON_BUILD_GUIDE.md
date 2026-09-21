# ProfitTrace | Hands-On Build Guide

This guide documents the complete local build path used for ProfitTrace. The build is now complete, so these steps serve as a reproducible reference.

## 1. Prepare the source

Expected files:

Customers.xlsx / Customers.csv
Products.xlsx / Products.csv
Orders.xlsx / Orders.csv
Shipping.xlsx / Shipping.csv
Returns.xlsx / Returns.csv

Expected counts: Customers 1,000; Products 300; Orders 15,000; Shipping 15,000; Returns 1,155.

Keep intentional quality issues in the source layer so SQL validation can demonstrate how they are detected and handled.

## 2. Prepare SQL Server

Run 01_Database_Setup.sql and 02_Import_Raw_Data.sql.

This creates the ProfitTrace database, stg schema, analytics schema and typed staging tables.

## 3. Load the source data

Load the five datasets into the corresponding staging tables.

For Shipping, 281 rows contain blank ship_date, promised_delivery_date and delivery_date values. When direct import cannot convert blank text to DATE, use the temporary dbo.Shipping_Raw landing table and then convert into typed stg.Shipping.

The final typed Shipping layer contains 15,000 rows and preserves blank dates as NULL.

## 4. Validate and clean

Run 03_Data_Validation.sql, then 04_Data_Cleaning.sql.

The cleaning layer creates analytics.vw_OrderProfitability, analytics.vw_ReturnsOperations and analytics.vw_CustomerProfitability.

## 5. Business analysis and QA

Run 05_Business_Analysis.sql, 06_Post_Load_QA.sql and 07_Final_Portfolio_QA.sql.

Core realized-order economics use is_delivered = 1.

## 6. Power BI model

Load analytics.vw_OrderProfitability as FactProfitability and analytics.vw_ReturnsOperations as FactReturns. Create DimDate, DimCustomer and DimProduct.

Use 1:* single-direction relationships from dimensions to facts. Do not create a direct fact-to-fact relationship. Do not connect FactReturns to DimProduct because the source does not provide a reliable product identifier.

## 7. DAX

The final PBIX contains 32 business-facing measures. See powerbi/DAX_MEASURES.md for definitions.

## 8. Dashboard pages

Page 1: Executive Profit Command Center
Page 2: Profitability Deep Dive
Page 3: Returns & Operational Leakage
Page 4: Customer & Commercial Intelligence

## 9. Final evidence

ProfitTrace_Dashboard.pdf
powerbi/ProfitTrace_Dashboard.pbix
Four final screenshots in screenshots/

## 10. Final QA

- Verify PDF pages match the PBIX.
- Verify screenshots match the final dashboard.
- Verify number formats and chronological month sorting.
- Verify slicers and cross-filtering.
- Verify delivered-order scope.
- Verify return analysis does not imply unsupported product attribution.