# ProfitTrace — Final Portfolio QA Checklist

## Technical

- [ ] SQL scripts execute in the documented order.
- [ ] Validation returns zero unexpected integrity/domain errors.
- [ ] Analytical views are created successfully.
- [ ] Revenue, discount, refund, cost and profit reconcile.
- [ ] Power BI relationships are one-to-many and single-direction.
- [ ] All KPI values are measure-driven.
- [ ] No unexplained many-to-many relationship exists.

## Analytical

- [ ] Return Rate uses delivered orders as denominator.
- [ ] Profit Margin uses Net Revenue as denominator.
- [ ] Discount Rate uses Gross Revenue as denominator.
- [ ] Late Delivery % uses delivered orders as denominator.
- [ ] Late-delivery analysis is described as association, not causation.
- [ ] One-time vs Repeat definition is documented.
- [ ] Synthetic-data disclaimer is visible in documentation.

## Dashboard

- [ ] Four pages are complete.
- [ ] Executive page has a clear profitability story.
- [ ] Profitability page supports category → product investigation.
- [ ] Returns page connects refunds, reasons and delivery performance.
- [ ] Customer page supports commercial segmentation.
- [ ] Slicers behave correctly.
- [ ] Number formats are consistent.
- [ ] Titles use business language.
- [ ] No temporary visuals or editing artifacts remain.

## GitHub

- [ ] README accurately describes the finished project.
- [ ] Screenshots match the final PBIX.
- [ ] SQL and documentation are organized into folders.
- [ ] PBIX is referenced/attached appropriately if size/access permits.
- [ ] No credentials, local machine paths or secrets are committed.
- [ ] Final repository structure is clean and recruiter-readable.
