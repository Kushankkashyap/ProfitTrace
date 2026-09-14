# ProfitTrace — Final Portfolio QA Checklist

Use this checklist after the Power BI build is complete and before presenting the repository to recruiters.

## Technical

- [ ] SQL scripts execute in the documented order: `01 → 00 → 04 → 05 → 07 → 06`.
- [ ] Validation returns zero unexpected integrity/domain errors.
- [ ] Analytical views are created successfully.
- [ ] Revenue, discount, refund, cost and profit reconcile to the documented identities.
- [ ] `FactProfitability` contains one analytical row per order in the current generated dataset.
- [ ] `DimDate`, `DimCustomer` and `DimProduct` relationships are 1:* and single-direction.
- [ ] All KPI values are measure-driven; no hard-coded dashboard totals.
- [ ] No unexplained many-to-many relationship exists.
- [ ] No raw order-level Returns/Shipping join multiplies fact rows.

## Analytical

- [ ] Return Rate uses delivered orders as denominator.
- [ ] Profit Margin uses Net Revenue as denominator.
- [ ] Discount Rate uses Gross Revenue as denominator.
- [ ] Late Delivery % uses delivered orders as denominator.
- [ ] Late-delivery analysis is described as association, not causation.
- [ ] One-time vs Repeat definition is documented.
- [ ] Synthetic-data disclaimer is visible in documentation/README.
- [ ] Any LTV/ROI-style interpretation is clearly labeled as an analytical approximation if introduced.

## Dashboard

- [ ] Four pages are complete.
- [ ] Executive page has a clear profitability story.
- [ ] Profitability page supports category → product investigation.
- [ ] Returns page connects refunds, reasons and delivery performance.
- [ ] Customer page supports commercial segmentation.
- [ ] Slicers behave correctly across relevant visuals.
- [ ] Cross-filtering/drilldown interactions work as intended.
- [ ] Number formats are consistent.
- [ ] Titles use business language.
- [ ] No temporary visuals, default titles or editing artifacts remain.
- [ ] Visual hierarchy is clear at normal laptop viewing size.
- [ ] Tooltips provide useful detail without overcrowding the canvas.

## GitHub

- [ ] README accurately describes the finished project and actual dashboard.
- [ ] Screenshots match the final PBIX.
- [ ] SQL and documentation are organized into folders.
- [ ] PBIX is referenced/attached appropriately if size/access permits.
- [ ] No credentials, local machine paths or secrets are committed.
- [ ] No false claims about real-company results are present.
- [ ] Final repository structure is clean and recruiter-readable.
- [ ] The final README highlights business impact, technical stack and key findings before implementation details.
