# ProfitTrace — Data Dictionary

The project uses five analytical entities. The final CSV files will follow these fields and business meanings.

## Customers

| Column | Type | Description |
|---|---|---|
| customer_id | INT | Unique customer identifier |
| customer_name | VARCHAR | Synthetic customer name |
| segment | VARCHAR | Consumer, Small Business, Enterprise |
| region | VARCHAR | Sales region |
| signup_date | DATE | Customer acquisition date |
| acquisition_channel | VARCHAR | Organic, Paid Search, Social, Referral, Email |

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
| order_id | INT | Unique order identifier |
| order_date | DATE | Date order was placed |
| customer_id | INT | Customer placing the order |
| product_id | INT | Purchased product |
| quantity | INT | Units purchased |
| unit_price | DECIMAL | Actual selling price per unit before discount |
| discount_pct | DECIMAL | Discount applied to the line |
| order_status | VARCHAR | Delivered, Cancelled, Pending |

## Returns

| Column | Type | Description |
|---|---|---|
| return_id | INT | Unique return identifier |
| order_id | INT | Related order |
| return_date | DATE | Return/refund date |
| return_reason | VARCHAR | Customer/operational return reason |
| refund_value | DECIMAL | Amount refunded |
| return_status | VARCHAR | Approved, Rejected |

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

## Modeling Notes

- `Orders` is the primary transaction fact at order-line grain.
- `Customers` and `Products` are dimensions.
- `Returns` and `Shipping` are operational event tables related through `order_id`.
- Order-level metrics must not be summed after joining multiple one-to-many event tables without pre-aggregation.
- Power BI should use a star-schema-friendly semantic model and explicit DAX measures.
