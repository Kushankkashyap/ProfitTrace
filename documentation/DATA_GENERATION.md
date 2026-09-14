# ProfitTrace | Data Source & Scenario Design

## Why synthetic data?

ProfitTrace is a portfolio project, so the dataset is synthetic. The source workbooks were generated as a deterministic portfolio dataset and are supplied as Excel files so the project can demonstrate a realistic Excel → SQL Server → Power BI workflow.

## Source workbooks

| Workbook | Grain | Rows |
|---|---|---:|
| `Customers.xlsx` | One row per customer | 800 |
| `Products.xlsx` | One row per product | 240 |
| `Orders.xlsx` | One row per order-product line | 11,000 |
| `Shipping.xlsx` | One row per order | 11,000 |
| `Returns.xlsx` | One row per return event | 785 |

## Intended analytical signals

The data is deliberately designed to contain business patterns that can be investigated rather than merely random numbers:

- Discount intensity varies by order and product category.
- Fashion and Electronics receive additional promotional pressure.
- Shipping performance varies across orders, with patterned late deliveries.
- Returns are concentrated around higher-discount, category and late-delivery scenarios.
- Return reasons are varied enough for operational analysis.
- Customers have different segments, regions and acquisition channels.
- Product economics vary through unit cost and list-price differences.

These patterns are **scenario design choices**, not real-company findings. The final dashboard should calculate the relationships from the data rather than hard-code conclusions.

## Controlled data-quality issues

A small number of source values intentionally contain formatting or domain inconsistencies so that the SQL validation and cleaning stages have a genuine analytical purpose. Examples include inconsistent casing, leading or trailing whitespace, a carrier with inconsistent spacing, and a discount value outside the intended range.

The raw Excel files should remain unchanged. Data-quality correction belongs in SQL Server so the project demonstrates a traceable staging-to-analytics workflow.

## Recommended workflow

1. Open the five Excel source workbooks.
2. Run `sql/01_Database_Setup.sql` in SSMS.
3. Run `sql/02_Import_Raw_Data.sql` to create the staging tables.
4. Use the SQL Server Import and Export Wizard to load each Excel workbook into its matching `stg` table.
5. Run `sql/03_Data_Validation.sql` and review the intentional source issues.
6. Run `sql/04_Data_Cleaning.sql` to create the analytical views.
7. Run `sql/05_Business_Analysis.sql` for business analysis outputs.
8. Run `sql/06_Post_Load_QA.sql` and confirm the source and analytical totals reconcile.
9. Run `sql/07_Final_Portfolio_QA.sql` before finalizing the Power BI report.
10. Build the Power BI model and dashboard from the validated analytical layer.

## Grain and allocation note

`analytics.vw_OrderProfitability` is maintained at order-product-line grain. Shipping cost and approved refunds are sourced at order level. When an order contains multiple product lines, those order-level amounts are allocated across lines using each line's share of sales after discount. This prevents shipping and refund values from being multiplied when line-level data is aggregated in Power BI.

## Methodology note

The dataset is synthetic and intended for portfolio and learning purposes. Relationships observed in the final analysis should be described as associations in the data, not as causal proof.
