# 💰 ProfitTrace — E-Commerce Profitability & Returns Intelligence

> **Trace the Revenue. Find the Leakage. Protect the Profit.**

ProfitTrace is an end-to-end analytics portfolio project built to answer a practical e-commerce question:

> **An e-commerce business is generating strong revenue, but where is the profit actually being lost?**

The project combines **SQL Server, data validation/cleaning, Power BI, DAX and business analysis** to trace revenue from order to net revenue and ultimately to profit, while investigating discounting, returns, shipping performance and customer behavior.

## 🎯 Business Objectives

- Measure revenue, net revenue, gross profit and margin performance.
- Identify products, categories and regions where revenue does not translate into profit.
- Quantify profit leakage from discounts, returns and operational costs.
- Understand whether late delivery is associated with higher return activity.
- Compare new vs. repeat customers and customer profitability.
- Surface actionable commercial and operational recommendations.

## 🧩 Project Architecture

```text
Raw Data (CSV)
      ↓
SQL Server — Staging / Validation / Cleaning
      ↓
Business Analysis — SQL Views & Queries
      ↓
Power BI — Star Schema + DAX
      ↓
Executive Profitability & Returns Dashboard
```

## 📁 Repository Structure

```text
ProfitTrace/
├── data/                  # Synthetic source datasets
├── sql/                   # Database, validation, cleaning and analysis scripts
├── documentation/         # Business requirements, data dictionary and methodology
├── powerbi/               # Power BI model / dashboard documentation
├── screenshots/            # Final dashboard screenshots
├── README.md
└── .gitignore
```

## 🛠️ Technology Stack

| Layer | Tools |
|---|---|
| Data | CSV / synthetic e-commerce data |
| Database | Microsoft SQL Server / T-SQL |
| BI | Microsoft Power BI |
| Calculations | DAX |
| Data Modeling | Star schema |
| Documentation | Markdown |

## 📊 Planned Dashboard Pages

### 1. Executive Profit Command Center
Revenue, net revenue, orders, gross profit, margin %, return rate, monthly trends, category profitability, regional margin and profit-leakage indicators.

### 2. Profitability Deep Dive
Category → subcategory → product analysis with revenue, net revenue, profit, margin, discount and return metrics, plus a discount-vs-margin profitability view.

### 3. Returns & Operational Leakage
Return rate, refund value, return reasons, delivery performance and the relationship between late delivery and returns.

### 4. Customer & Commercial Intelligence
New vs. repeat behavior, AOV, orders/customer, customer revenue/profit and profitability segmentation.

## 🔎 Core Analytical Questions

1. Which categories generate the most revenue but the least profit?
2. How much profit is being sacrificed through discounting?
3. Which products have high sales but structurally weak margins?
4. Where are returns creating the largest financial leakage?
5. Does late delivery coincide with higher return rates?
6. Which regions and customer segments are most profitable?
7. Are repeat customers economically more valuable than new customers?

## 📌 Data Note

The project uses synthetic data designed for portfolio and learning purposes. Business findings will be presented as analytical insights from the modeled dataset, not as claims about a real company.

## 🚧 Project Status

**Phase 1 — Foundation:** In progress

- [x] Repository created
- [ ] Source datasets finalized
- [ ] SQL database and tables
- [ ] Data validation and cleaning
- [ ] Business analysis queries
- [ ] Power BI star schema
- [ ] DAX measures
- [ ] Dashboard pages
- [ ] Screenshots and final documentation

## 👤 Author

**Kushank Kashyap** — Data Analyst / Business Analyst / BI Analyst

Skills demonstrated: **SQL • Power BI • DAX • Data Modeling • Excel • Business Analysis • Data Storytelling**
