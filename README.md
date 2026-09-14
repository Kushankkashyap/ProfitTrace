# 💰 ProfitTrace | E-Commerce Profitability & Returns Intelligence

> **Trace the Revenue. Find the Leakage. Protect the Profit.**

ProfitTrace is an end-to-end data analytics project built around a practical e-commerce question:

> **An e-commerce business is generating strong revenue, but where is the profit actually being lost?**

The project follows a realistic analyst workflow, starting with raw Excel business data, moving through SQL Server for data validation, cleaning and analysis, and ending in Power BI for interactive reporting and decision support.

The analysis focuses on the gap between sales and actual profitability by examining discounts, refunds, product costs, shipping costs, returns and delivery performance.

## 🎯 Business Objectives

- Measure gross revenue, net revenue, gross profit and profit margin.
- Identify categories, products and regions where strong sales do not translate into strong profit.
- Quantify profitability leakage from discounts, refunds, product costs and shipping.
- Evaluate the relationship between delivery performance and return activity.
- Compare one-time and repeat customer economics.
- Translate analytical findings into practical commercial and operational actions.

## 🔄 End-to-End Workflow

```text
Raw Excel Files
      ↓
SQL Server Import / Staging
      ↓
Data Validation
      ↓
Data Cleaning & Transformation
      ↓
Business Analysis Queries
      ↓
Power BI Data Model
      ↓
DAX Measures
      ↓
Interactive Profitability Dashboard
```

This structure keeps each tool focused on a clear part of the analytics process:

| Tool | Role in the project |
|---|---|
| Excel | Raw operational source data |
| SQL Server / SSMS | Data loading, validation, cleaning, transformation and analysis |
| Power BI | Data modeling, visualization and interactive reporting |
| DAX | KPI calculations and business metrics |

## 📁 Repository Structure

```text
ProfitTrace/
├── data/
│   └── README.md
├── sql/
│   ├── 01_Database_Setup.sql
│   ├── 02_Import_Raw_Data.sql
│   ├── 03_Data_Validation.sql
│   ├── 04_Data_Cleaning.sql
│   ├── 05_Analytics_Views.sql
│   ├── 06_Business_Analysis.sql
│   └── 07_Post_Load_QA.sql
├── documentation/
│   ├── PROJECT_BRIEF.md
│   ├── DATA_DICTIONARY.md
│   ├── DATA_GENERATION.md
│   ├── BUILD_RUNBOOK.md
│   └── PORTFOLIO_QA_CHECKLIST.md
├── powerbi/
│   ├── DASHBOARD_BLUEPRINT.md
│   └── DAX_MEASURES.md
├── screenshots/
├── README.md
└── .gitignore
```

## 📊 Dashboard

The Power BI report is designed as a four-page decision-support dashboard.

### 1. Executive Profit Command Center

A management view of revenue, net revenue, orders, gross profit, margin and return performance. Monthly trends, category profitability, regional performance and a profit-leakage view help highlight where commercial attention is needed.

### 2. Profitability Deep Dive

A detailed category, subcategory and product analysis covering revenue, net revenue, profit, margin, discounts and returns. A discount-intensity analysis helps identify products where higher discounting is accompanied by weaker profitability.

### 3. Returns & Operational Leakage

An operational view covering returned orders, return rate, refund value, return reasons, delivery performance and late-delivery patterns. The objective is to identify where customer experience and operational issues may be contributing to financial leakage.

### 4. Customer & Commercial Intelligence

Customer-level analysis covering one-time versus repeat behavior, average order value, revenue, profit and customer profitability segments. The page is designed to highlight commercially valuable customer groups and weaker customer economics.

## 🔎 Key Business Questions

1. Which categories generate the most revenue but the least profit?
2. How much profitability is affected by discounting?
3. Which products have strong sales but weak margins?
4. Where do returns create the largest financial leakage?
5. Is late delivery associated with higher return activity?
6. Which regions and customer segments generate stronger economics?
7. Are repeat customers more valuable than one-time customers?

## 💡 Core Metrics

| Metric | Definition |
|---|---|
| Gross Revenue | Quantity × unit selling price before discount |
| Discount Value | Gross Revenue × discount percentage |
| Net Revenue | Gross Revenue − Discount Value − Refund Value |
| Gross Profit | Net Revenue − Product Cost − Shipping Cost |
| Profit Margin | Gross Profit ÷ Net Revenue |
| Return Rate | Returned delivered orders ÷ delivered orders |
| AOV | Net Revenue ÷ Orders |
| Late Delivery Rate | Late delivered orders ÷ delivered orders |

## 🗄️ SQL Analysis

SQL Server is used for the core data preparation and analytical workflow. The project includes separate stages for loading source data, validating quality, cleaning and transforming the data, creating analytical views, and producing business analysis outputs.

The SQL work demonstrates practical analyst skills including:

- Multi-table joins
- CTEs
- Conditional logic with `CASE`
- Aggregations and conditional aggregations
- Window functions
- Date-based analysis
- Data-quality checks
- Profitability and return calculations
- Customer and product-level analysis

### Recommended Build Order

```text
1. Database setup
2. Import Excel source data
3. Data validation
4. Data cleaning and transformation
5. Analytical views
6. Business analysis
7. Post-load QA
8. Power BI model and dashboard
```

The SQL layer is designed to keep business logic close to the data while leaving presentation and interactive analysis to Power BI.

## 📌 Data & Methodology

The project uses portfolio data designed to represent a realistic e-commerce operating environment. The source files contain customers, products, orders, returns and shipping information across connected business entities.

The dataset is synthetic and is intended for portfolio and learning purposes. Any patterns or findings shown in the dashboard should be treated as analytical examples rather than claims about a real company.

The project maintains a clear distinction between **association and causation**. For example, a relationship between late deliveries and returns can be investigated in the data, but the analysis does not by itself prove that late delivery caused a return.

## 🚧 Project Status

**Foundation and analytics design complete. Power BI implementation in progress.**

- [x] Business case and analytical scope
- [x] Repository structure
- [x] Data model and business definitions
- [x] SQL workflow design
- [x] Power BI semantic-model specification
- [x] DAX measure plan
- [x] Four-page dashboard blueprint
- [ ] Final Excel source files
- [ ] SQL Server import and cleaning workflow
- [ ] Post-load QA using final source data
- [ ] Power BI star schema implementation
- [ ] Dashboard pages and interactions
- [ ] Final screenshots and portfolio evidence
- [ ] Final recruiter-facing project summary

## 👤 Author

**Kushank Kashyap**

Data Analyst | Business Analyst | BI Analyst

**Core skills:** SQL • Power BI • DAX • Excel • Data Modeling • Business Analysis • Data Storytelling
