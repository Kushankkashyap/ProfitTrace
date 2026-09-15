# 💰 ProfitTrace | E-Commerce Profitability & Returns Intelligence

> **Trace the Revenue. Find the Leakage. Protect the Profit.**

ProfitTrace is an end-to-end analytics project built around a practical commercial question:

> **Revenue looks healthy, but where is the business actually losing profit?**

The project follows a realistic analyst workflow from operational source data in Excel, through SQL Server for validation and transformation, to Power BI for interactive decision support.

Rather than treating revenue as the final KPI, ProfitTrace follows the economics of an order from selling price to discount, refund, product cost, shipping and return-related cost.

## 🎯 Business Case

An e-commerce business wants to grow sales without quietly giving away margin. Leadership needs to understand:

- Which categories and products create the most profit?
- Where are discounts eroding margin?
- Which products generate strong sales but weak economics?
- How much financial leakage is associated with returns?
- Is late delivery associated with higher return activity?
- Which customer segments and acquisition channels create stronger economics?
- Are repeat customers materially more valuable than one-time buyers?

## 🧰 Tool Stack

| Tool | Purpose |
|---|---|
| **Excel** | Operational source data and business-friendly raw files |
| **SQL Server / SSMS** | Staging, validation, cleaning, transformation, QA and business analysis |
| **Power BI** | Star-schema modeling, DAX, visualization and decision support |
| **DAX** | KPI and interactive business measures |

## 🔄 End-to-End Workflow

```text
Excel Source Workbooks
        ↓
SQL Server Staging
        ↓
Data Quality Validation
        ↓
Cleaning & Standardization
        ↓
Analytical Views
        ↓
Business Analysis & QA
        ↓
Power BI Star Schema
        ↓
Clean Business-Facing DAX Measures
        ↓
Executive Decision Dashboard
```

## 📊 Source Data

The portfolio dataset contains connected business entities and behavioral patterns designed to support meaningful commercial analysis.

| Entity | Records | Purpose |
|---|---:|---|
| Customers | 1,000 | Customer identity, geography, segment and acquisition source |
| Products | 300 | Product, category, brand, tier, price, cost and rating |
| Orders | 15,000 | 2025 order-product transactions and commercial attributes |
| Shipping | 15,000 | Shipment timing, promised delivery, carrier and shipping cost |
| Returns | 1,155 | Approved/rejected return events, reasons and financial impact |

The source data is synthetic, but it is **behaviorally structured rather than purely random**. Examples include higher return propensity for Fashion, elevated return likelihood after late delivery, different discount intensity by category and customer segment, and different product economics across tiers.

A small number of controlled data-quality issues are also present in the raw layer, including inconsistent text casing/whitespace and one discount above the approved 0% to 30% business range. These issues create a genuine reason to perform SQL validation and cleaning.

## 📈 Power BI Dashboard

### 1. Executive Profit Command Center

A management-level view of Net Revenue, Gross Profit, Profit Margin, Delivered Orders, Return Rate and Return Leakage. The page highlights the monthly profit trend, category contribution and the path from revenue to profit.

**Decision:** Where should management focus first to protect profit?

### 2. Profitability Deep Dive

Category, subcategory and product analysis with revenue, discount, refund, profit and margin. Scatter analysis helps identify high-sales products with weak profitability and high-discount products with compressed margins.

**Decision:** Which products are commercially attractive but economically weak?

### 3. Returns & Operational Leakage

Return reasons, refund value, return rate, late delivery and delivery performance are brought together to quantify operational leakage.

**Decision:** Which operational problems deserve investigation because they coincide with financial leakage?

### 4. Customer & Commercial Intelligence

Customer profitability, one-time versus repeat economics, acquisition-channel performance and customer segments provide a commercial view beyond transaction volume.

**Decision:** Which customer groups and acquisition sources create sustainable value?

## 🗄️ SQL Engineering & Analysis

The SQL layer is deliberately separated into stages so the workflow is auditable:

```text
01  Database Setup
02  Staging Tables
03  Data Validation
04  Cleaning & Analytical Views
05  Business Analysis
06  Post-Load QA
07  Final Portfolio QA
```

The project demonstrates practical SQL skills including joins, CTEs, conditional logic, aggregations, window functions, date analysis, data-quality checks, financial reconciliation and customer/product profitability analysis.

The cleaned profitability view is kept at **order-product-line grain**. Order-level refunds, shipping and return costs are allocated across lines so aggregation does not accidentally double-count order-level amounts.

## 💡 Core Metric Definitions

| Metric | Definition |
|---|---|
| Gross Revenue | Quantity × Unit Price |
| Discount Value | Gross Revenue × Discount % |
| Sales After Discount | Gross Revenue − Discount Value |
| Refund Value | Approved refund allocated to the analytical line |
| Net Revenue | Sales After Discount − Refund Value |
| Product Cost | Quantity × Unit Cost |
| Gross Profit | Net Revenue − Product Cost − Shipping Cost − Return Cost |
| Profit Margin | Gross Profit ÷ Net Revenue |
| Return Rate | Returned delivered orders ÷ delivered orders |
| AOV | Net Revenue ÷ delivered orders |
| Late Delivery Rate | Late delivered orders ÷ delivered orders |

## ⚠️ Analytical Discipline

ProfitTrace distinguishes **association from causation**. For example, if late-delivery orders show a higher return rate, that is evidence of an observed relationship in the dataset, not proof that late delivery caused every return.

The dataset is synthetic and the findings are portfolio examples, not claims about a real company.

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
│   ├── 05_Business_Analysis.sql
│   ├── 06_Post_Load_QA.sql
│   └── 07_Final_Portfolio_QA.sql
├── documentation/
│   ├── PROJECT_BRIEF.md
│   ├── DATA_DICTIONARY.md
│   ├── DATA_GENERATION.md
│   ├── BUILD_RUNBOOK.md
│   ├── HANDS_ON_BUILD_GUIDE.md
│   └── PORTFOLIO_QA_CHECKLIST.md
├── powerbi/
│   ├── DASHBOARD_BLUEPRINT.md
│   ├── BUILD_HANDOFF.md
│   ├── DAX_MEASURES.md
│   └── PROFITTRACE_THEME.json
├── screenshots/
└── README.md
```

## 🚀 Build Order

1. Keep the Excel workbooks as the primary source layer.
2. Use the CSV copies when the local SQL Server environment cannot read Excel directly.
3. Run `01_Database_Setup.sql`.
4. Run `02_Import_Raw_Data.sql` to create staging tables.
5. Load the five source files into `stg`.
6. Run `03_Data_Validation.sql` and inspect the intentional quality issues.
7. Run `04_Data_Cleaning.sql` to create analytical views.
8. Run `05_Business_Analysis.sql` for business findings.
9. Run `06_Post_Load_QA.sql` and `07_Final_Portfolio_QA.sql`.
10. Build the Power BI star schema and clean business-facing DAX measures.
11. Capture final dashboard screenshots and document the observed findings.

For the detailed hands-on sequence, see `documentation/HANDS_ON_BUILD_GUIDE.md`.

## 📌 Project Status

**Foundation is complete. Local SQL execution and the Power BI implementation are the remaining hands-on stages.**

- [x] Business case and recruiter-oriented scope
- [x] Source dataset design and Excel-first workflow
- [x] SQL staging model
- [x] Validation and cleaning logic
- [x] Business analysis queries
- [x] Post-load and final QA
- [x] Power BI model specification
- [x] DAX measure plan
- [x] Four-page dashboard blueprint
- [x] Hands-on build guide
- [ ] SQL Server import and QA execution on local machine
- [ ] Power BI star schema implementation
- [ ] Dashboard pages, interactions and final styling
- [ ] Final screenshots and PBIX evidence

## 👤 Author

**Kushank Kashyap**  
Data Analyst | Business Analyst | BI Analyst

**Core skills:** SQL • Power BI • DAX • Excel • Data Modeling • Business Analysis • Data Storytelling
