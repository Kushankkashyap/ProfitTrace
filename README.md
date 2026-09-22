# 💰 ProfitTrace | E-Commerce Profitability & Returns Intelligence

> **Trace the Revenue. Find the Leakage. Protect the Profit.**

ProfitTrace is an end-to-end analytics portfolio project built around one practical commercial question:

> **Revenue looks healthy, but where is the business actually losing profit?**

The project mirrors a real analyst workflow:

**Source Data → SQL Server → Data Quality → Business Logic → Power BI Model → DAX → Executive Dashboard**

It combines **SQL Server, Power BI, DAX and Excel/CSV** to analyze profitability, discounting, returns, delivery performance, customer economics and operational leakage.

---

## 📌 Project at a Glance

| Area | Implementation |
|---|---|
| Business Domain | E-Commerce Profitability & Returns |
| Source Records | 32K+ across 5 connected datasets |
| Customers | 1,000 |
| Products | 300 |
| Orders | 15,000 |
| Returns | 1,155 |
| SQL Scripts | 7 |
| Power BI Pages | 4 |
| DAX Measures | 32 |
| Data Model | Star Schema |
| Final Deliverables | PBIX + PDF + Screenshots |

---

## 🎯 Business Problem

An e-commerce business can grow revenue while silently losing margin through discounts, refunds, product costs, shipping and return-related expenses.

ProfitTrace is designed to answer questions such as:

- Which categories and products create the most profit?
- Where are discounts compressing margin?
- Which high-revenue products have weaker profitability?
- How much revenue is lost through refunds and return-related costs?
- How do late-delivery patterns relate to return activity?
- Which customer segments and acquisition channels create stronger economics?

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

---

## 🧰 Technology Stack

| Technology | Role |
|---|---|
| **Excel / CSV** | Operational source data |
| **SQL Server / SSMS** | Staging, validation, cleaning, transformation and QA |
| **Power BI** | Data modeling, visualization and dashboard delivery |
| **DAX** | Reusable KPI and analytical measures |
| **GitHub** | Portfolio versioning and project documentation |

---

## 📊 Source Data

| Dataset | Grain | Records |
|---|---|---:|
| Customers | One row per customer | 1,000 |
| Products | One row per product | 300 |
| Orders | One row per order-product transaction | 15,000 |
| Shipping | One row per order shipment | 15,000 |
| Returns | One row per return event | 1,155 |

The data is **synthetic and intentionally structured for portfolio analysis**. It contains controlled quality issues such as inconsistent text formatting, an out-of-range discount value, an inconsistent status value and incomplete shipping dates.

These issues are intentionally detected in SQL rather than manually repaired in the source layer.

---

## 🗄️ SQL Layer

The SQL workflow is separated into seven auditable scripts. The staging script creates the typed tables; source-file ingestion is performed with the documented SQL Server import workflow.

```text
01_Database_Setup.sql
02_Import_Raw_Data.sql
03_Data_Validation.sql
04_Data_Cleaning.sql
05_Business_Analysis.sql
06_Post_Load_QA.sql
07_Final_Portfolio_QA.sql
```

### What the SQL layer demonstrates

- Typed staging tables
- Data-quality validation
- Text standardization
- `TRY_CONVERT` / `NULLIF` handling
- CTEs and aggregations
- Joins and analytical transformations
- Financial reconciliation
- Order-level cost allocation
- Profitability and returns analysis
- Post-load and final QA

### Delivered-order scope

`is_delivered = 1` is the project's definition of realized delivered-order scope.

Core profitability and customer-economic measures use this same rule in SQL and Power BI so the two layers remain analytically aligned.

---

## ⭐ Power BI Model

The final semantic model uses a star-schema structure:

```text
                         DimDate
                        /       \
                       /         \
DimCustomer ---- FactProfitability ---- DimProduct
                       |
                   FactReturns
```

### Facts

- **FactProfitability** → `analytics.vw_OrderProfitability`
- **FactReturns** → `analytics.vw_ReturnsOperations`

### Dimensions

- **DimDate**
- **DimCustomer**
- **DimProduct**

Relationships are **1:* and single-direction from dimensions to facts**.

There is no direct fact-to-fact relationship.

The returns source does not contain a reliable product identifier, so the project intentionally avoids unsupported product/category return attribution.

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
- Revenue vs Gross Profit trend
- Category profit contribution
- Revenue-to-profit waterfall
- Revenue vs Margin analysis

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
- Return Rate %
- Refund Value
- Return Leakage %
- Late Delivery %
- Return reasons
- Monthly refund leakage by return month
- Return rate by category
- Return rate by delivery status
- Return-event detail

### 04 | Customer & Commercial Intelligence

**Business focus:** Which customer groups and acquisition sources create durable value?

Includes:

- Customers
- Orders Per Customer
- Profit per Order
- Profit per Customer
- Customer segment profitability
- Acquisition-channel economics
- Regional profitability
- Top profit-contributing customers
- Channel scorecard

---

## 📌 Current Dashboard Snapshot

| KPI | Value |
|---|---:|
| Net Revenue | ₹147.92M |
| Gross Profit | ₹59.33M |
| Profit Margin | 40% |
| AOV | ₹10,049.36 |
| Customers | 1,000 |
| Orders per Customer | 14.72 |
| Profit per Order | ₹4,030.61 |
| Profit per Customer | ₹59,326.55 |

These values are from the completed synthetic portfolio dataset and represent the final dashboard output.

> **Note:** The synthetic dataset produces multiple delivered orders for all customers, so repeat-customer percentage is not used as a final KPI because it does not provide useful differentiation in this dataset.

---

## 🔎 Key Findings

- **₹147.92M net revenue generated ₹59.33M gross profit**, representing a **40% profit margin** on delivered-order economics.
- **Electronics contributed ₹33.8M of profit**, the largest category contribution in the final dashboard.
- **Fashion recorded a 12% return rate**, while Sports was 7% and Electronics, Beauty and Home were each 6%.
- **Late-delivery orders had an 11% return rate versus 7% for on-time orders** in the synthetic dataset. This is an observed relationship, not proof of causation.
- **Profit margin declined as discounting increased**, from 45% in the 0-5% discount band to 19% in the 25-30% band.

## 🖼️ Dashboard Preview

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

**Power BI Report**

[Open the final PBIX](powerbi/ProfitTrace_Dashboard.pbix)

**PDF Export**

[Open the final dashboard PDF](ProfitTrace_Dashboard.pdf)

**SQL Scripts**

[Open the SQL layer](sql/)

**Power BI Documentation**

[Open the Power BI documentation](powerbi/)

**Final Screenshots**

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
│   ├── DASHBOARD_BLUEPRINT.md
│   ├── BUILD_HANDOFF.md
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

## ✅ Final Project

ProfitTrace is now maintained as a **completed portfolio project**, not an in-progress build checklist.

The repository contains the implemented SQL layer, analytical views, QA scripts, Power BI model documentation, 32-measure DAX layer, completed four-page dashboard, final PBIX, PDF export and screenshots.

---

## ⚠️ Analytical Discipline

ProfitTrace distinguishes **observed association from causation**.

For example, a higher return rate among late-delivery orders is an observed relationship in the synthetic dataset. It is not proof that late delivery caused every return.

The project also avoids product/category return attribution because the source return data does not provide a reliable product key.

---

## 👤 Author

**Kushank Kashyap**

Data Analyst • Business Analyst • BI Analyst

**SQL • Power BI • DAX • Excel • Data Modeling • Business Analysis • Data Storytelling**
