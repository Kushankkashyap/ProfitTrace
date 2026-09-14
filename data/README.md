# ProfitTrace | Source Data

ProfitTrace starts with a connected set of e-commerce operational extracts. Excel is the primary source representation. CSV copies are included as a practical SQL Server import fallback when the local environment cannot read `.xlsx` files directly.

## Source Files

| File | Grain | Rows |
|---|---|---:|
| `Customers.xlsx` / `.csv` | One row per customer | 1,000 |
| `Products.xlsx` / `.csv` | One row per product | 300 |
| `Orders.xlsx` / `.csv` | One row per order-product transaction | 15,000 |
| `Shipping.xlsx` / `.csv` | One row per order shipment | 15,000 |
| `Returns.xlsx` / `.csv` | One row per return event | 1,155 |
| `DATASET_SUMMARY.xlsx` | Dataset inventory | 8 |

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
- Late delivery increases the probability of a return event.
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
- one inconsistent carrier value
- one inconsistent return-reason value

`03_Data_Validation.sql` is expected to surface these issues. `04_Data_Cleaning.sql` standardizes them for analysis.

## Import Note

Run `01_Database_Setup.sql`, then `02_Import_Raw_Data.sql`. Load the five files into the matching `stg` tables. If the Excel provider is unavailable on the local machine, use the CSV copies. Do not delete the Excel workbooks because they remain the documented primary source layer.

The data is synthetic and intended for portfolio and learning purposes only.
