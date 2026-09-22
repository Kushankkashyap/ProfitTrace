# ProfitTrace | Source Data

ProfitTrace starts with a connected set of e-commerce operational extracts. Excel is the primary source representation. The raw Excel/CSV source package is maintained separately and is **not committed to this public repository**. CSV copies can be used locally as a practical SQL Server import fallback when the environment cannot read `.xlsx` files directly.

## Expected Source Package

| File | Grain | Rows |
|---|---|---:|
| `Customers.xlsx` / `.csv` | One row per customer | 1,000 |
| `Products.xlsx` / `.csv` | One row per product | 300 |
| `Orders.xlsx` / `.csv` | One row per order-product transaction | 15,000 |
| `Shipping.xlsx` / `.csv` | One row per order shipment | 15,000 |
| `Returns.xlsx` / `.csv` | One row per return event | 1,155 |

## Source-to-SQL Mapping

```text
Customers → stg.Customers
Products  → stg.Products
Orders    → stg.Orders
Shipping  → stg.Shipping
Returns   → stg.Returns
```

## Why the Data Is More Than Random

The dataset is synthetic, but the records are behaviorally structured to create realistic analytical trade-offs:

- Fashion carries higher discount intensity and a stronger Size/Fit return pattern.
- Late delivery is associated with higher return activity.
- Higher discounts can compress product-level margin.
- Customer segments influence product price mix and discount behavior.
- Shipping method affects cost and delivery speed.
- Acquisition channels can be compared on customer economics, not just order volume.

These patterns are intentionally designed to support investigation. They should be treated as portfolio scenarios, not real-world causal claims.

## Controlled Data-Quality Issues

A small number of source records contain deliberate quality issues such as:

- inconsistent text casing
- leading/trailing whitespace
- one discount above the intended 0% to 30% range
- one inconsistent order-status value
- one inconsistent carrier value
- one inconsistent return-reason value
- blank shipment/delivery dates on a subset of shipping records

`03_Data_Validation.sql` is expected to surface these issues. `04_Data_Cleaning.sql` standardizes them for analysis.

## Import Note

The filenames below describe the source package expected by the SQL workflow; the files themselves are not stored in this public repository. Run `01_Database_Setup.sql`, then `02_Import_Raw_Data.sql` to create the typed staging tables.

When the SQL Server Import and Export Wizard can read Excel, the local `.xlsx` workbooks can be loaded directly. If the Excel OLE DB provider is unavailable or has a bitness mismatch, use local CSV copies with `Flat File Source` and load the matching `stg` tables.

For the Shipping CSV, some source date fields are blank. If the wizard attempts to coerce those blanks directly to `DATE` and fails, use the documented temporary `dbo.Shipping_Raw` text landing table workflow in `documentation/HANDS_ON_BUILD_GUIDE.md`. The raw text is then converted with `TRY_CONVERT` into the final typed `stg.Shipping` table.

Do not manually change the raw source values to make the import pass. Validation and business-rule cleaning belong in SQL.

The data is synthetic and intended for portfolio and learning purposes only.
