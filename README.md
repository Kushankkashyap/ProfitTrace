# 💰 ProfitTrace — E-Commerce Profitability & Returns Intelligence

> **Trace the Revenue. Find the Leakage. Protect the Profit.**

ProfitTrace is an end-to-end analytics portfolio project built around a practical e-commerce problem:

> **An e-commerce business is generating strong revenue, but where is the profit actually being lost?**

The project traces order economics from gross revenue through discounts, refunds, product cost and shipping cost to expose profitability pressure and operational leakage. It combines **SQL Server, T-SQL validation/cleaning, analytical SQL, Power BI, DAX and star-schema modeling**.

## 🎯 Business Objectives

- Measure gross revenue, net revenue, gross profit and margin.
- Identify categories, products and regions where revenue does not translate into profit.
- Quantify leakage from discounts, refunds, product cost and shipping.
- Test whether late delivery is associated with higher return activity.
- Compare one-time and repeat customer economics.
- Turn analytical findings into commercial and operational actions.

## 🧩 Architecture

```text
Synthetic Source Data
        ↓
SQL Server — Staging
        ↓
Validation + Cleaning
        ↓
Analytical Views / Business Queries
        ↓
Power BI — Star Schema + DAX
        ↓
Executive Profitability & Returns Dashboard
```

## 📁 Repository Structure

```text
ProfitTrace/
├── data/                  # Source-data documentation / future CSV exports
├── sql/
│   ├── 00_Generate_Synthetic_Data.sql
│   ├── 01_Database_Setup.sql
│   ├── 02_Table_Creation.sql
│   ├── 03_Load_Raw_Data.sql
│   ├── 04_Data_Validation.sql
│   ├── 05_Data_Cleaning.sql
│   ├── 06_Business_Analysis.sql
│   └── 07_Post_Load_QA.sql
├── documentation/         # Business requirements, definitions and methodology
├── powerbi/               # Dashboard/model blueprint
├── screenshots/            # Final dashboard screenshots
├── README.md
└── .gitignore
```

## 🛠️ Technology Stack

| Layer | Tools |
|---|---|
| Data | Deterministic synthetic e-commerce data |
| Database | Microsoft SQL Server / T-SQL |
| BI | Microsoft Power BI |
| Calculations | DAX |
| Modeling | Star schema |
| Documentation | Markdown |

## 📊 Dashboard Plan

### 1. Executive Profit Command Center
Executive KPIs, revenue-to-profit trend, category profitability, regional margin and a visual leakage bridge covering discounts, refunds and operating costs.

### 2. Profitability Deep Dive
Category → subcategory → product analysis with revenue, net revenue, profit, margin, discount and return metrics, plus a discount-intensity vs. margin analysis.

### 3. Returns & Operational Leakage
Return rate, refund value, return reasons, late-delivery performance and the relationship between delivery experience and returns.

### 4. Customer & Commercial Intelligence
One-time vs. repeat behavior, AOV, customer revenue/profit, customer profitability segmentation and commercial opportunity flags.

## 🔎 Core Analytical Questions

1. Which categories generate the most revenue but the least profit?
2. How much revenue is sacrificed through discounting?
3. Which products have high sales but weak margins?
4. Where do returns create the largest financial leakage?
5. Does late delivery coincide with higher return rates?
6. Which regions and customer segments are most profitable?
7. Are repeat customers economically more valuable than one-time customers?

## ▶️ Reproducible SQL Run Order

For the portfolio's deterministic generated dataset:

```text
1. 01_Database_Setup.sql
2. 00_Generate_Synthetic_Data.sql
3. 04_Data_Validation.sql
4. 05_Data_Cleaning.sql
5. 06_Business_Analysis.sql
6. 07_Post_Load_QA.sql
```

`02_Table_Creation.sql` and `03_Load_Raw_Data.sql` are retained as an alternative CSV-loading workflow. Do **not** run `02_Table_Creation.sql` immediately before the generator, because the generator creates the staging tables itself.

## 📌 Data & Methodology Note

The dataset is synthetic and intentionally designed to contain realistic profitability signals such as discount pressure, category-level return behavior and late-delivery patterns. Findings are portfolio analysis outputs, not claims about a real company.

The current generated model keeps one product line per order so order-level refund and shipping economics can be allocated without duplication. If the generator is later expanded to multi-line orders, those order-level costs must be allocated before line-level profitability is aggregated.

## 🚧 Project Status

**Foundation complete — dashboard build pending.**

- [x] Repository and project structure
- [x] Deterministic synthetic data generator
- [x] SQL database setup and staging schema
- [x] Validation and cleaning layer
- [x] Analytical business queries
- [x] Post-load QA / reconciliation checks
- [x] Power BI dashboard blueprint
- [ ] Power BI star schema
- [ ] DAX measures
- [ ] Dashboard pages
- [ ] Screenshots and final portfolio evidence

## 👤 Author

**Kushank Kashyap** — Data Analyst / Business Analyst / BI Analyst

Skills demonstrated: **SQL • Power BI • DAX • Data Modeling • Excel • Business Analysis • Data Storytelling**
