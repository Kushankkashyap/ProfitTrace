# 💰 ProfitTrace | E-Commerce Profitability & Returns Intelligence

> **Trace the Revenue. Find the Leakage. Protect the Profit.**

**Status: ✅ Completed Portfolio Project**

ProfitTrace is an end-to-end analytics project built around one practical commercial question:

> **Revenue looks healthy, but where is the business actually losing profit?**

The project follows a realistic analyst workflow from operational source data through SQL validation and business logic into a Power BI semantic model, DAX measures and an executive dashboard.

**Source Data → SQL Server → Data Quality → Business Logic → Power BI Star Schema → DAX → Executive Dashboard**

---

## 📌 Project at a Glance

| Area | Implementation |
|---|---|
| Business Domain | E-Commerce Profitability & Returns |
| Source Records | 32K+ across 5 connected datasets |
| Customers | 1,000 |
| Products | 300 |
| Orders | 15,000 |
| Shipping Records | 15,000 |
| Return Events | 1,155 |
| SQL Scripts | 7 |
| Power BI Pages | 4 |
| DAX Measures | 32 |
| Data Model | Star Schema |
| Primary Tools | SQL Server, SSMS, Power BI, DAX, Excel/CSV |
| Final Deliverables | PBIX + PDF + 4 Screenshots |

---

## 🎯 Business Problem

E-commerce revenue can look strong while profitability is reduced by:

- discounting
- refunds
- product costs
- shipping costs
- return-related costs
- delivery issues

ProfitTrace is designed to answer:

- Which categories and products generate the most profit?
- Where are discounts compressing margin?
- Which high-revenue areas have weaker profitability?
- How much economic leakage comes from refunds and return-related costs?
- How do late-delivery orders compare with on-time orders on return rate?
- Which customer segments, regions and acquisition channels create stronger economics?

---

## 🔎 Key Findings

The final dashboard shows:

- **₹147.92M net revenue** and **₹59.33M gross profit**, resulting in a **40% profit margin** on the delivered-order scope.
- **Electronics contributes ₹33.8M of profit**, the largest category contribution in the dashboard.
- **Fashion has the highest category return rate at 12%**; Sports is 7%, while Electronics, Beauty and Home are each 6%.
- **Late-delivery orders have an 11% return rate versus 7% for on-time orders** in the synthetic dataset. This is an observed association, not proof of causation.
- **Profit margin declines across the discount bands**, from 45% in the 0-5% band to 19% in the 25-30% band.
- **Return leakage is 6% of gross revenue** under the project's defined leakage formula.

---

## 🔄 End-to-End Analytics Workflow

```text
Raw Excel / CSV
      ↓
SQL Server Staging
      ↓
Data Quality Validation
      ↓
Cleaning & Standardization
      ↓
Analytical SQL Views
      ↓
Business Analysis + QA
      ↓
Power BI Star Schema
      ↓
32 DAX Measures
      ↓
4-Page Executive Dashboard
```

The project is completed end to end. The repository contains the implementation, analytical SQL, QA scripts, Power BI artifacts and final evidence.

---

## 📊 Source Data

| Dataset | Grain | Rows |
|---|---|---:|
| Customers | One row per customer | 1,000 |
| Products | One row per product | 300 |
| Orders | One row per order-product transaction | 15,000 |
| Shipping | One row per order shipment | 15,000 |
| Returns | One row per return event | 1,155 |

The source data is **synthetic and intentionally structured for portfolio analysis**.

> **Public repository note:** The five raw source workbooks/CSV extracts used to build the final PBIX are maintained outside this public repository and are intentionally not committed here. The repository retains the source-data documentation, row-count expectations, validation rules and SQL import workflow so the portfolio remains auditable without publishing the raw dataset.

Controlled quality issues include inconsistent casing/whitespace, one discount above the intended 0%-30% range, an inconsistent order-status value, an inconsistent carrier value, an inconsistent return-reason value and blank shipping/delivery dates on a subset of rows.

These issues are surfaced in validation and standardized in the analytical layer rather than manually overwritten in the source.

---

## 🗄️ SQL Server Layer

The SQL workflow is separated into seven auditable scripts:

```text
01_Database_Setup.sql
02_Import_Raw_Data.sql
03_Data_Validation.sql
04_Data_Cleaning.sql
05_Business_Analysis.sql
06_Post_Load_QA.sql
07_Final_Portfolio_QA.sql
```

### What it demonstrates

- Typed staging tables
- Source-data validation
- Required-field and domain checks
- Referential-integrity checks
- Grain and uniqueness checks
- Text standardization
- Discount correction
- Date and delivery consistency checks
- CTEs, joins and window functions
- Order-level cost allocation
- Financial reconciliation
- Business-analysis queries
- Post-load and final portfolio QA

### Delivered-order scope

`is_delivered = 1` is the project's definition of realized delivered-order scope.

Core revenue, profit and customer-economic measures use this same rule in SQL and Power BI.

### Shipping import handling

The Shipping source contains blank values in shipment and delivery date fields. The documented workflow uses a temporary text landing layer when direct date conversion is not accepted by the SQL Server import wizard, then applies controlled `TRY_CONVERT` / `NULLIF` conversion into the typed staging table.

---

## ⭐ Power BI Semantic Model

The final model uses a star-schema structure:

```text
                         DimDate
                        /       \
                       /         \
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

### Modeling discipline

- 1:* relationships
- Single-direction filtering from dimensions to facts
- No direct fact-to-fact relationship
- FactReturns intentionally remains disconnected from DimProduct because the return source does not contain a reliable product identifier

---

## 🧮 Key Metric Definitions

### Return Rate

**Returned delivered orders ÷ delivered orders**

Approved return events are used to determine returned orders. Rejected return events remain visible in return-event detail but do not count toward Return Rate.

### Return Leakage %

**(Refund Value + Return Cost) ÷ Gross Revenue**

### Profit per Order

**Gross Profit ÷ Delivered Orders**

### Profit per Customer

**Gross Profit ÷ Delivered Customers**

### Late Delivery

A delivered order is classified as **Late** when its delivery date is later than its promised delivery date.

---

## 📈 Final Dashboard

### 01 | Executive Profit Command Center

**Business focus:** Where is revenue becoming profit, and where is it leaking?

Includes:

- Net Revenue
- Gross Profit
- Profit Margin %
- Return Rate %
- Delivered Orders
- Return Leakage %
- Revenue vs Gross Profit Trend
- Profit Contribution by Category
- Revenue-to-Profit Waterfall
- Revenue vs Margin

### 02 | Profitability Deep Dive

**Business focus:** Which categories and products convert sales into healthy profit?

Includes:

- Margin by Category
- Revenue Mix
- High Revenue, Low Margin Opportunities
- Discounting vs Profitability
- Product Profitability Matrix

### 03 | Returns & Operational Leakage

**Business focus:** Where do returns and operational friction affect economics?

Includes:

- Returned Orders
- Refund Value
- Late Delivery %
- Return Leakage %
- Return Rate %
- Why Customers Return
- Monthly Refund Leakage by Return Month
- Return Rate by Delivery Status
- Return Rate by Category
- Return Event Detail with Return Status

### 04 | Customer & Commercial Intelligence

**Business focus:** Which customer groups and acquisition sources create durable value?

Includes:

- Customers
- Orders Per Customer
- Profit per Order
- Profit per Customer
- Customer Segment Profitability
- Acquisition-Channel Economics
- Regional Profitability
- Top Profit-Contributing Customers
- Channel Scorecard

> **Portfolio note:** Repeat Customer % is not used as a final KPI because every customer in this synthetic dataset has multiple delivered orders, so the metric does not provide useful differentiation.

---

## 📌 Final Dashboard Snapshot

| KPI | Value |
|---|---:|
| Net Revenue | ₹147.92M |
| Gross Profit | ₹59.33M |
| Profit Margin | 40% |
| AOV | ₹10,049.36 |
| Customers | 1,000 |
| Delivered Orders | 14,719 |
| Orders per Customer | 14.72 |
| Profit per Order | ₹4,030.61 |
| Profit per Customer | ₹59,326.55 |
| Return Rate | 8% |
| Return Leakage | 6% |

---

## 🖼️ Final Dashboard Screenshots

### Executive Profit Command Center
![Executive Profit Command Center](screenshots/executive_profit_command_center.png)

### Profitability Deep Dive
![Profitability Deep Dive](screenshots/profitability_deep_dive.png)

### Returns & Operational Leakage
![Returns & Operational Leakage](screenshots/returns_operational_leakage.png)

### Customer & Commercial Intelligence
![Customer & Commercial Intelligence](screenshots/customer_commercial_intelligence.png)

---

## 📥 Final Deliverables

### Power BI Report
[Open the final PBIX](powerbi/ProfitTrace_Dashboard.pbix)

### Source Data
[Open the source-data documentation](data/README.md) — the raw Excel/CSV package is maintained separately and is not committed to this public repository.

### Dashboard PDF
[Open the final dashboard PDF](ProfitTrace_Dashboard.pdf)

### SQL Scripts
[Open the SQL layer](sql/)

### Power BI Documentation
[Open the Power BI documentation](powerbi/)

### Final Screenshots
[Open the dashboard screenshots](screenshots/)

---

## 📁 Repository Structure

```text
ProfitTrace/
├── ProfitTrace_Dashboard.pdf
├── README.md
├── data/
│   └── README.md
├── documentation/
│   ├── PROJECT_BRIEF.md
│   ├── DATA_DICTIONARY.md
│   ├── DATA_GENERATION.md
│   ├── BUILD_RUNBOOK.md
│   ├── HANDS_ON_BUILD_GUIDE.md
│   ├── PORTFOLIO_QA_CHECKLIST.md
│   ├── POWERBI_BUILD_CHECKLIST.md
│   └── RECRUITER_REVIEW.md
├── powerbi/
│   ├── ProfitTrace_Dashboard.pbix
│   ├── BUILD_HANDOFF.md
│   ├── DASHBOARD_BLUEPRINT.md
│   └── DAX_MEASURES.md
├── screenshots/
│   ├── customer_commercial_intelligence.png
│   ├── executive_profit_command_center.png
│   ├── profitability_deep_dive.png
│   └── returns_operational_leakage.png
└── sql/
    ├── 01_Database_Setup.sql
    ├── 02_Import_Raw_Data.sql
    ├── 03_Data_Validation.sql
    ├── 04_Data_Cleaning.sql
    ├── 05_Business_Analysis.sql
    ├── 06_Post_Load_QA.sql
    └── 07_Final_Portfolio_QA.sql
```

---

## ✅ Project Completion

ProfitTrace is maintained as a **completed portfolio project**.

The repository includes:

- completed SQL staging, transformation and QA workflow
- analytical SQL views
- 32 Power BI DAX measures
- star-schema semantic model
- completed 4-page dashboard
- final PBIX
- final PDF export
- four final dashboard screenshots
- build and recruiter-facing documentation

There are no in-progress checklist blocks in the project README.

---

## ⚠️ Analytical Discipline & Limitations

- The dataset is synthetic and intended for portfolio and learning use.
- Observed relationships are not presented as causal proof.
- The returns source has no reliable product identifier, so unsupported product/category return attribution is intentionally avoided.
- The final customer KPI set excludes Repeat Customer % because the synthetic population does not provide meaningful variation for that metric.

---

## 👤 Author

**Kushank Kashyap**

Data Analyst • Business Analyst • BI Analyst

**SQL • Power BI • DAX • Excel • Data Modeling • Business Analysis • Data Storytelling**
