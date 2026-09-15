# ProfitTrace | Data Dictionary

The project uses five raw operational entities. Excel is the primary source representation, while CSV copies provide a practical SQL Server import fallback. The SQL staging schema preserves the source grain and applies the final target data types defined in `sql/02_Import_Raw_Data.sql`.

## Customers

**Grain:** one row per customer.

| Column | SQL Type | Description |
|---|---|---|
| `customer_id` | `VARCHAR(20)` | Unique customer identifier |
| `customer_name` | `VARCHAR(100)` | Synthetic customer name |
| `customer_segment` | `VARCHAR(30)` | Core, Value or Premium segment |
| `region` | `VARCHAR(50)` | Sales region |
| `state` | `VARCHAR(60)` | Customer state |
| `city` | `VARCHAR(60)` | Customer city |
| `signup_date` | `DATE` | Customer signup/acquisition date |
| `acquisition_channel` | `VARCHAR(40)` | Customer acquisition source |

## Products

**Grain:** one row per product.

| Column | SQL Type | Description |
|---|---|---|
| `product_id` | `VARCHAR(20)` | Unique product identifier |
| `product_name` | `VARCHAR(180)` | Synthetic product name |
| `category` | `VARCHAR(50)` | Product category |
| `subcategory` | `VARCHAR(80)` | Product subcategory |
| `brand` | `VARCHAR(60)` | Product brand |
| `product_tier` | `VARCHAR(30)` | Core, Premium or Specialty tier |
| `list_price` | `DECIMAL(12,2)` | Standard product selling price |
| `unit_cost` | `DECIMAL(12,2)` | Product cost per unit |
| `launch_date` | `DATE` | Product launch date |
| `rating` | `DECIMAL(3,1)` | Product rating |

## Orders

**Grain:** one row per order-product transaction.

| Column | SQL Type | Description |
|---|---|---|
| `order_id` | `VARCHAR(20)` | Unique order identifier |
| `order_date` | `DATE` | Date order was placed |
| `customer_id` | `VARCHAR(20)` | Customer placing the order |
| `product_id` | `VARCHAR(20)` | Purchased product |
| `quantity` | `INT` | Units purchased |
| `unit_price` | `DECIMAL(12,2)` | Selling price per unit before discount |
| `discount_pct` | `DECIMAL(6,4)` | Line discount percentage; one source value exceeds the business ceiling intentionally |
| `payment_method` | `VARCHAR(30)` | Payment method |
| `order_channel` | `VARCHAR(30)` | Purchase channel |
| `promo_code` | `VARCHAR(30)` | Promotion code or NONE |
| `order_status` | `VARCHAR(30)` | Raw order lifecycle status |

## Shipping

**Grain:** one row per order shipment.

| Column | SQL Type | Description |
|---|---|---|
| `order_id` | `VARCHAR(20)` | Related order identifier and unique shipment key |
| `ship_date` | `DATE NULL` | Shipment dispatch date; may be blank in the source |
| `promised_delivery_date` | `DATE NULL` | Promised delivery date; may be blank in the source |
| `delivery_date` | `DATE NULL` | Actual delivery date; may be blank for undelivered records |
| `delivery_status` | `VARCHAR(30) NULL` | Shipment/delivery status |
| `carrier` | `VARCHAR(40) NULL` | Shipping carrier |
| `shipping_method` | `VARCHAR(30) NULL` | Shipping service/method |
| `shipping_cost` | `DECIMAL(12,2)` | Shipping cost |

## Returns

**Grain:** one row per return event.

| Column | SQL Type | Description |
|---|---|---|
| `return_id` | `VARCHAR(20)` | Unique return-event identifier |
| `order_id` | `VARCHAR(20)` | Related order identifier |
| `return_date` | `DATE` | Return event date |
| `return_reason` | `VARCHAR(80)` | Customer or operational return reason |
| `return_status` | `VARCHAR(20)` | Approved or rejected return status |
| `refund_amount` | `DECIMAL(12,2)` | Refund amount associated with the return event |
| `return_shipping_cost` | `DECIMAL(12,2)` | Return-shipping cost |
| `restocking_cost` | `DECIMAL(12,2)` | Restocking cost |

## Analytical Views

### `analytics.vw_OrderProfitability`

**Grain:** one analytical row per order-product line.

This view joins cleaned customer, product, order and shipping data, pre-aggregates approved return amounts by `order_id`, and allocates order-level refund, shipping and return costs across lines. It also exposes business-ready fields such as `discount_pct`, `discount_corrected_flag`, `delivery_status_clean`, `is_delivered`, `is_late_delivery` and `is_returned`.

### `analytics.vw_ReturnsOperations`

**Grain:** one row per return event.

This view standardizes return reasons/statuses and enriches return events with customer, region, segment and acquisition-channel context. The returns source does not contain a reliable product identifier, so this view does not invent product-level return attribution.

### `analytics.vw_CustomerProfitability`

**Grain:** one row per customer.

This view summarizes delivered-order economics and classifies customers as `Repeat` or `One-Time` based on delivered orders.

## Key Modeling Notes

- `Orders` is the sales transaction source.
- `Shipping` is a one-row-per-order shipment source and is joined to orders by `order_id`.
- `Returns` is a one-row-per-event source and is pre-aggregated before order-level profitability calculations.
- `DimCustomer` and `DimProduct` are Power BI dimensions.
- `FactReturns` remains a separate event fact because the source does not provide a reliable `product_id`.
- Core revenue/profitability measures in Power BI use `is_delivered = 1` so SQL and Power BI apply the same commercial scope.
