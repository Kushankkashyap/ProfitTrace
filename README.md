# 💰 ProfitTrace | E-Commerce Profitability & Returns Intelligence

> **Trace the Revenue. Find the Leakage. Protect the Profit.**

An end-to-end analytics portfolio project that investigates a practical e-commerce question:

> **Revenue looks healthy — but where is the business actually losing profit?**

ProfitTrace combines **SQL Server, data quality validation, business analysis, Power BI, DAX, and dimensional modeling** to analyze profitability, discounting, returns, refunds, shipping performance, customers, and commercial channels.

**Synthetic portfolio dataset | SQL Server + Power BI + DAX | 32K+ source records | 4-page dashboard**

---

## 🚀 What I Built

I designed the project as a complete analyst workflow rather than a dashboard-only exercise:

**Source Data → SQL Server → Data Quality → Cleaning & Business Logic → Analytical SQL → Star Schema → DAX → Power BI Dashboard**

The analysis focuses on six business questions:

1. Which categories and products generate the most profit?
2. Where are discounts compressing margins?
3. Which high-revenue areas have weaker profitability?
4. How much revenue is affected by refunds and return-related costs?
5. How does delivery performance relate to return behavior?
6. Which customer segments, regions, and acquisition channels show stronger economics?

---

## 📊 Executive Snapshot

| KPI | Result |
|---|---:|
| Net Revenue | **₹147.92M** |
| Gross Profit | **₹59.33M** |
| Profit Margin | **40%** |
| Delivered Orders | **14,719** |
| Customers | **1,000** |
| Return Rate | **8%** |
| Return Leakage | **6%** |
| Average Order Value | **₹10,049.36** |
| Profit per Order | **₹4,030.61** |
| Profit per Customer | **₹59,326.55** |

### Key findings

- **Electronics** contributes **₹33.8M** of profit, the largest category contribution.
- **Fashion** has the highest category return rate at **12%**.
- Late-delivery orders show an **11% return rate vs. 7% for on-time orders** in the synthetic dataset.
- Profit margin decreases across discount bands, from **45% at 0–5% discount to 19% at 25–30% discount**.
- Return leakage represents **6% of gross revenue** under the project's defined leakage formula.

> **Analytical note:** These are observations from a synthetic portfolio dataset. Relationships are not presented as proof of causation.

---

## 🖥️ Dashboard

The Power BI report contains four business-focused pages.

### 01 — Executive Profit Command Center
**Question:** Where is revenue becoming profit, and where is it leaking?

- Net Revenue
- Gross Profit
- Profit Margin
- Return Rate
- Delivered Orders
- Return Leakage
- Revenue vs. Profit trend
- Category profit contribution
- Revenue-to-profit waterfall
- Revenue vs. margin

### 02 — Profitability Deep Dive
**Question:** Which products and categories convert sales into healthy profit?

- Margin by category
- Revenue mix
- High-revenue / low-margin opportunities
- Discounting vs. profitability
- Product profitability matrix

### 03 — Returns & Operational Leakage
**Question:** Where do returns and operational friction affect economics?

- Returned orders
- Refund value
- Return leakage
- Return rate
- Late vs. on-time delivery
- Return reasons
- Monthly refund leakage
- Return event detail

### 04 — Customer & Commercial Intelligence
**Question:** Which customer groups and acquisition sources create stronger economics?

- Customer profitability
- Profit per order
- Profit per customer
- Customer segments
- Acquisition-channel economics
- Regional profitability
- Top profit-contributing customers
- Channel scorecard

---

## 🧠 What This Project Demonstrates

### SQL Server / SSMS

The SQL layer is separated into seven auditable stages:

`01_Database_Setup.sql`  
`02_Import_Raw_Data.sql`  
`03_Data_Validation.sql`  
`04_Data_Cleaning.sql`  
`05_Business_Analysis.sql`  
`06_Post_Load_QA.sql`  
`07_Final_Portfolio_QA.sql`

Key techniques demonstrated:

- Staging and typed tables
- Data-quality checks
- Required-field and domain validation
- Referential-integrity checks
- Grain and uniqueness validation
- Text standardization
- Date and delivery validation
- CTEs, joins and window functions
- Order-level cost allocation
- Financial reconciliation
- Analytical SQL views
- Post-load QA

### Power BI / DAX

- Star-schema semantic model
- Fact and dimension design
- 1:* relationships
- Single-direction filtering
- 32 DAX measures
- KPI development
- Profitability and return analysis
- Executive dashboard design
- Business storytelling

---

## ⭐ Data Model

The final Power BI model uses a star-schema approach:

```text
                         DimDate
                        /       \\
                       /         \\
DimCustomer ---- FactProfitability ---- DimProduct
                       |
                   FactReturns
```

### Fact tables

- **FactProfitability** → `analytics.vw_OrderProfitability`
- **FactReturns** → `analytics.vw_ReturnsOperations`

### Dimensions

- **DimDate**
- **DimCustomer**
- **DimProduct**

The returns fact is intentionally not connected directly to DimProduct because the source returns data does not contain a reliable product identifier. This avoids unsupported product-level return attribution.

---

## 🧮 Metric Definitions

**Return Rate**

> Returned delivered orders ÷ delivered orders

Approved return events determine returned orders. Rejected return events remain visible in the detailed return analysis but do not count toward Return Rate.

**Return Leakage**

> (Refund Value + Return Cost) ÷ Gross Revenue

**Profit per Order**

> Gross Profit ÷ Delivered Orders

**Profit per Customer**

> Gross Profit ÷ Delivered Customers

**Late Delivery**

> A delivered order is classified as Late when the delivery date is later than the promised delivery date.

Core revenue, profit, and customer-economic measures use the project's consistent **delivered-order scope**.

---

## 🧹 Data Quality & Assumptions

The dataset is synthetic and intentionally contains controlled quality issues to demonstrate an analyst's validation workflow.

Examples include:

- inconsistent casing / whitespace
- a discount outside the intended 0–30% range
- inconsistent order-status values
- inconsistent carrier values
- inconsistent return-reason values
- blank shipping / delivery dates

The raw source is preserved while validation and standardization are handled in the SQL analytical workflow.

### Source data

| Dataset | Grain | Rows |
|---|---|---:|
| Customers | One row per customer | 1,000 |
| Products | One row per product | 300 |
| Orders | One row per order-product transaction | 15,000 |
| Shipping | One row per order shipment | 15,000 |
| Returns | One row per return event | 1,155 |

The five raw CSV extracts are included in the `data/` folder so the SQL workflow can be inspected and reproduced.

---

## 📸 Dashboard Screenshots

### Executive Profit Command Center
![Executive Profit Command Center](screenshots/executive_profit_command_center.png)

### Profitability Deep Dive
![Profitability Deep Dive](screenshots/profitability_deep_dive.png)

### Returns & Operational Leakage
![Returns & Operational Leakage](screenshots/returns_operational_leakage.png)

### Customer & Commercial Intelligence
![Customer & Commercial Intelligence](screenshots/customer_commercial_intelligence.png)

---

## 📂 Repository Guide

| Folder / File | What you'll find |
|---|---|
| `data/` | Synthetic source CSVs + source documentation |
| `sql/` | Database setup, validation, cleaning, analysis and QA |
| `powerbi/` | PBIX, DAX measures and Power BI build documentation |
| `screenshots/` | Final dashboard evidence |
| `documentation/` | Data dictionary, project brief, build guides and QA documentation |
| `ProfitTrace_Dashboard.pdf` | Final dashboard PDF |
| `README.md` | Project overview and analytical summary |

### Key files

- [Power BI Report](powerbi/ProfitTrace_Dashboard.pbix)
- [SQL Scripts](sql/)
- [Source Data](data/)
- [Power BI Documentation](powerbi/)
- [Dashboard Screenshots](screenshots/)
- [Final Dashboard PDF](ProfitTrace_Dashboard.pdf)

---

## 🔍 Why This Project Matters

ProfitTrace is designed to show more than the ability to create charts.

It demonstrates how an analyst can move from:

**Business Question → Raw Data → Data Quality → SQL Analysis → Data Model → Metrics → Dashboard → Business Insight**

The goal is to connect technical implementation with decisions a commercial or operations team could actually investigate.

---

## ⚠️ Limitations

- The dataset is synthetic and intended for portfolio / learning use.
- Observed relationships are not treated as causal proof.
- The returns source has no reliable product identifier, so unsupported product/category return attribution is intentionally avoided.
- Repeat Customer % is not used as a final KPI because every customer in this synthetic population has multiple delivered orders, making the metric non-differentiating.

---

## 👤 Author

**Kushank Kashyap**

**Data Analyst • Business Analyst • BI Analyst**

SQL • Power BI • DAX • Excel • Data Modeling • Business Analysis • Data Storytelling
