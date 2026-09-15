# ProfitTrace | Data Generation Notes

ProfitTrace uses a deterministic synthetic e-commerce dataset designed for portfolio analysis. The objective is not to imitate a real company's records, but to create a believable operating environment in which commercial trade-offs can be investigated.

## Source Layer

| Entity | Records | Grain |
|---|---:|---|
| Customers | 1,000 | Customer |
| Products | 300 | Product |
| Orders | 15,000 | Order-product transaction |
| Shipping | 15,000 | Order shipment |
| Returns | 1,155 | Return event |

The primary source representation is Excel. CSV copies are provided for SQL Server environments where the Excel OLE DB provider is unavailable.

## Behavioral Design

The dataset contains structured signals rather than independent random values:

- Customer segment influences product price mix and discount behavior.
- Fashion products have stronger Size/Fit return behavior.
- Late delivery is associated with higher return activity.
- Higher discount intensity can compress margin.
- Shipping method changes both delivery speed and cost.
- Acquisition channels can be compared using customer economics rather than volume alone.

These patterns are intentionally designed for analysis. They are not claims about a real business.

## Controlled Quality Issues

The raw layer includes a small number of deliberate issues:

- one customer segment with inconsistent casing
- one customer region with leading/trailing whitespace
- one acquisition channel with inconsistent casing
- one product category with inconsistent casing
- one product subcategory with leading/trailing whitespace
- one shipping carrier with inconsistent casing/whitespace
- one return reason with inconsistent casing
- one discount above the intended 0% to 30% business range
- one order-status value with extra whitespace/casing variation
- a small subset of shipping records with blank dispatch/promise/delivery dates

The SQL validation layer surfaces these issues. The cleaning layer standardizes them while preserving the raw staging tables.

The dataset also intentionally contains one order whose source status is marked as delivered even though its delivery date is missing. The analytical layer therefore uses the explicit `is_delivered` flag for realized-order scope rather than relying only on the raw text status.

## Reproducibility

The source package is deterministic and was generated with a fixed random seed of **42**. This keeps the source stable while the SQL and Power BI layers are being built and reviewed.
