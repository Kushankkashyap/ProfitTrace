# ProfitTrace — Data Generation & Scenario Design

## Why synthetic data?

ProfitTrace is a portfolio project, so the dataset is synthetic. The generator is deterministic: the same SQL script produces the same underlying scenario each time it is run against a fresh `ProfitTrace` database.

## Intended analytical signals

The data is deliberately designed to contain business patterns that can be investigated rather than merely random numbers:

- Discount intensity varies by customer segment and product category.
- Fashion and Electronics receive additional promotional pressure.
- Shipping performance varies across orders, with patterned late deliveries.
- Returns are concentrated around high-discount/category/late-delivery scenarios.
- Return reasons are varied enough for operational root-cause analysis.
- Customers have different segments, regions and acquisition channels.
- Product economics vary through unit cost and list-price differences.

These patterns are **scenario design choices**, not real-company findings. The final dashboard should calculate the relationships from the generated data rather than hard-code conclusions.

## Expected scale

| Table | Approx. rows |
|---|---:|
| Customers | 800 |
| Products | 240 |
| Orders | 11,000 |
| Returns | up to 900 |
| Shipping | 11,000 |

## Recommended workflow

1. Run `sql/01_Database_Setup.sql`.
2. Run `sql/00_Generate_Synthetic_Data.sql`.
3. Run `sql/04_Data_Validation.sql`.
4. Run `sql/05_Data_Cleaning.sql`.
5. Run `sql/06_Business_Analysis.sql`.
6. Build the Power BI model using the cleaned analytical layer.

The generator is the preferred reproducible route for the portfolio version. `sql/03_Load_Raw_Data.sql` remains as a conventional CSV-loading template for demonstrating a raw-file ingestion workflow.
