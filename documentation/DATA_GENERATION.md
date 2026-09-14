# ProfitTrace | V2 Data Generation Notes

ProfitTrace V2 uses a deterministic synthetic e-commerce dataset designed for portfolio analysis. The objective is not to imitate a real company's records, but to create a believable operating environment in which commercial trade-offs can be investigated.

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
- Late deliveries have elevated return propensity.
- Higher discount intensity can compress margin.
- Shipping method changes both delivery speed and cost.
- Acquisition channels can be compared using customer economics rather than volume alone.

These patterns are intentionally designed for analysis. They are not claims about a real business.

## Controlled Quality Issues

The raw layer includes a small number of deliberate issues:

- inconsistent casing in customer segment and acquisition channel
- leading/trailing whitespace in selected region, product and carrier values
- one discount above the intended 0% to 30% business range
- one inconsistent order-status value
- one inconsistent return-reason value

The SQL validation layer should surface these issues. The cleaning layer standardizes them while preserving the raw staging tables.

## Reproducibility

The V2 source package is deterministic and was generated with a fixed random seed. This keeps the source stable while the SQL and Power BI layers are being built and reviewed.
