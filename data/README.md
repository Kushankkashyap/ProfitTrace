# ProfitTrace — Data Folder

The `/data` folder is reserved for the finalized synthetic source files:

- `customers.csv`
- `products.csv`
- `orders.csv`
- `returns.csv`
- `shipping.csv`

## Expected Grain

- Customers: one row per customer
- Products: one row per product
- Orders: one row per order-product line
- Returns: one row per return event
- Shipping: one row per shipment/order

## Data Quality Expectations

The final dataset should contain realistic variation across:

- categories and subcategories
- regions
- customer segments
- acquisition channels
- discount levels
- order values
- return reasons
- delivery performance

The dataset should also contain enough observations for meaningful monthly, product, category, regional and customer analysis without making the portfolio unnecessarily large.

**Synthetic-data disclaimer:** These files are fictional and created for analytics portfolio/learning purposes.
