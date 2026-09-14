# ProfitTrace | Source Data

The project starts with five raw Excel workbooks that represent common e-commerce operational extracts.

| Workbook | Grain | Approx. rows |
|---|---|---:|
| `Customers.xlsx` | One row per customer | 800 |
| `Products.xlsx` | One row per product | 240 |
| `Orders.xlsx` | One row per order-product line | 11,000 |
| `Returns.xlsx` | One row per return event | Up to 900 |
| `Shipping.xlsx` | One row per shipment/order | 11,000 |

## Source-to-SQL Mapping

```text
Customers.xlsx  → stg.Customers
Products.xlsx   → stg.Products
Orders.xlsx     → stg.Orders
Returns.xlsx    → stg.Returns
Shipping.xlsx   → stg.Shipping
```

The Excel files are treated as raw source data. Data standardization and business transformations are performed in SQL Server rather than being hidden inside the source files.

A small number of controlled quality issues are included in the raw files, mainly text-format inconsistencies. These give the validation and cleaning stages a practical purpose and make the workflow closer to a typical analyst task.

## Source Data Notes

- Customers: customer attributes, segment, region and acquisition channel
- Products: category, subcategory and unit economics
- Orders: sales transactions, quantities, prices, discounts and order status
- Returns: return reason, refund value and return status
- Shipping: ship date, promised date, delivery date, carrier and shipping cost

The data is synthetic and is intended for portfolio and learning purposes. It is not representative of a real company's customers, transactions or performance.

## SQL Server Import

Use SQL Server Management Studio's Import and Export Wizard to load each workbook into the matching `stg` table. The detailed sequence is documented in `sql/03_Load_Raw_Data.sql` and `documentation/BUILD_RUNBOOK.md`.

CSV copies may also be used as a fallback when the local SQL Server installation does not expose an Excel provider in the Import and Export Wizard.
