# ProfitTrace | Source Data

ProfitTrace starts with five raw Excel workbooks representing common e-commerce operational extracts. The files are intentionally kept close to a source-system format so that validation and cleaning happen in SQL Server.

| Workbook | Grain | Rows |
|---|---|---:|
| `Customers.xlsx` | One row per customer | 800 |
| `Products.xlsx` | One row per product | 240 |
| `Orders.xlsx` | One row per order-product line | 11,000 |
| `Shipping.xlsx` | One row per shipment/order | 11,000 |
| `Returns.xlsx` | One row per return event | 785 |

## Source-to-SQL Mapping

```text
Customers.xlsx  → stg.Customers
Products.xlsx   → stg.Products
Orders.xlsx     → stg.Orders
Shipping.xlsx   → stg.Shipping
Returns.xlsx    → stg.Returns
```

The source files contain a small set of controlled quality issues such as inconsistent text casing, leading/trailing spaces and a few values that need business-rule review. These are deliberate and limited so the SQL cleaning stage has a clear purpose without making the dataset unrealistic.

## Source Data Notes

- **Customers:** customer attributes, segment, region and acquisition channel
- **Products:** category, subcategory and unit economics
- **Orders:** sales transactions, quantities, prices, discounts and order status
- **Shipping:** shipment dates, promised delivery, actual delivery, carrier and shipping cost
- **Returns:** return reason, refund value and return status

The data is synthetic and is intended for portfolio and learning purposes. It does not represent a real company's customers, transactions or performance.

## SQL Server Import

Run `sql/01_Database_Setup.sql`, then `sql/02_Import_Raw_Data.sql`. Use SQL Server's Import and Export Wizard to load each Excel workbook into its matching `stg` table. After the five imports are complete, continue with the validation, cleaning, analysis and QA scripts.

CSV copies can be used as a fallback if the local SQL Server installation does not have an Excel provider available.
