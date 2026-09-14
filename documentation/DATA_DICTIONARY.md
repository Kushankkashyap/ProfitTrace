# ProfitTrace | Data Dictionary

The project uses five raw operational entities. The primary source is Excel, and the raw workbooks are loaded into SQL Server staging tables before cleaning.

## Customers

| Column | Type | Description |
|---|---|---|
| customer_id | INT | Unique customer identifier |
| customer_name | VARCHAR | Synthetic customer name |
| segment | VARCHAR | Consumer, Small Business, Enterprise |
| region | VARCHAR | Sales region |
| signup_date | DATE | Customer acquisition date |
| acquisition_channel | VARCHAR | Organic, Paid Search, Paid Social, Marketplace, Referral, Email |

## Products

| Column | Type | Description |
|---|---|---|
| product_id | INT | Unique product identifier |
| product_name | VARCHAR | Synthetic product name |
| category | VARCHAR | Product category |
| subcategory | VARCHAR | Product subcategory |
| unit_cost | DECIMAL | Product cost per unit |
| list_price | DECIMAL | Standard selling price |

## Orders

| Column | Type | Description |
|---|---|---|
| order_id | INT | Unique order identifier in the current source dataset |
| order_date | DATE | Date order was placed |
| customer_id | INT | Customer placing the order |
| product_id | INT | Purchased product |
| quantity | INT | Units purchased |
| unit_price | DECIMAL | Actual selling price per unit before discount |
| discount_pct | DECIMAL | Discount applied to the line; the cleaned analytical view enforces a 0%-30% business ceiling |
| order_status | VARCHAR | Completed or Cancelled in the source data |

## Returns

| Column | Type | Description |
|---|---|---|
| return_id | INT | Unique return event identifier |
| order_id | INT | Related order |
| return_date | DATE | Return/refund date |
| return_reason | VARCHAR | Customer or operational return reason |
| refund_value | DECIMAL | Amount refunded |
| return_status | VARCHAR | Approved, Rejected or Pending |

## Shipping

| Column | Type | Description |
|---|---|---|
| shipment_id | INT | Unique shipment identifier |
| order_id | INT | Related order |
| ship_date | DATE | Shipment dispatch date |
| promised_date | DATE | Promised delivery date |
| delivery_date | DATE | Actual delivery date |
| shipping_cost | DECIMAL | Cost incurred to ship the order |
| carrier | VARCHAR | Synthetic carrier name |

## Analytical View

`analytics.vw_OrderProfitability` is the main Power BI fact source. It is designed at order-product-line grain and pre-aggregates order-level returns and shipping before allocating those values across lines when necessary.

The cleaned view also standardizes text fields, normalizes order status labels, and records when a source discount was corrected by the business-rule ceiling.

## Modeling Notes

- `Orders` is the primary sales transaction source.
- `Customers` and `Products` are dimensions in the Power BI star schema.
- `Returns` and `Shipping` are operational event sources related through `order_id`.
- Raw one-to-many event tables should not be joined directly to the sales fact without pre-aggregation.
- Power BI should use explicit DAX measures rather than hard-coded KPI values.
