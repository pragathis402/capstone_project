# Big Billion Days Regional Performance Review — SQL, Spreadsheet, Dashboard and AI-Verified Analysis

## Project Overview

This repository contains the complete, traceable analytics pipeline for the Flipkart Big Billion Days (BBD) sales performance review. The project evaluates four relational database tables spanning three monthly sales cycles (`2026-09`, `2026-10`, `2026-11`), reconciling order-level facts from raw SQL queries through spreadsheet cleaning, pivot table analysis, executive dashboard specification, and human-in-the-loop AI verification.

All figures reconcile end-to-end across every layer, establishing a single source of truth of **63 completed orders** generating **₹346,200** in total completed revenue across **106 units sold**.

---

## Technical Environment & Tools

- **SQL Compiler & Dialect:** SQLite 3.45+ (ANSI SQL compliant; fully compatible with PostgreSQL and MySQL).
- **Spreadsheet Software:** Google Sheets / Microsoft Excel.
- **Dashboard Platform:** Tableau Public / Tableau Desktop (complete specification, sheet shelves, container layout, and filter actions detailed in `docs/dashboard_spec.md`).
- **AI Verification Framework:** Human-in-the-Loop (HITL) 5-stage protocol (Specification, Execution, Inspection, Verification, Decision) documented in `docs/ai_log.md`.

---

## Executive Summary: Three Key Findings

Across the three-month Big Billion Days sale campaign, three critical commercial trends emerged:

1. **North Region Scale vs. Temporal Deceleration:** North was the largest contributor to gross completed revenue, generating ₹119,300 (34.5% of total sales) and outperforming the East (₹69,500) and West (₹74,900) regions. However, North’s revenue declined steeply month-over-month, dropping 22.8% from September (₹53,500) to October (₹41,300), and falling an additional 40.7% to ₹24,500 in November, causing rep Arjun Mehta to miss target in month 3.
2. **West Region's Lifestyle Apparel Specialization:** While Electronics led national sales overall (₹142,300), the West territory exhibited an intense consumer preference for Apparel, which generated ₹37,500 (50.1% of West's total revenue). West alone accounted for 48.4% of all Apparel revenue nationwide, with Running Shoes comprising 67.2% of that regional category demand.
3. **November Surge Driven by High-Ticket Home Appliances:** Campaign revenue surged by 66.3% in November to ₹154,800 across 24 orders, following flat performance across September (₹98,300) and October (₹93,100). This peak was overwhelmingly driven by Home merchandise, which expanded by 560.3% to ₹83,200 in November, anchored by the Air Fryer (₹104,000 total sales; four peak orders tying for the maximum basket size of ₹15,600).

---

## Repository Structure & File Index

The repository is organized into four modular, interconnected stages:

| File Path | Project Stage | Description |
|---|---|---|
| [`README.md`](README.md) | Project Governance | Project overview, technical stack, executive findings, file index, and assumptions. |
| [`sql/00_schema_and_seed.sql`](sql/00_schema_and_seed.sql) | Part A: SQL Layer | DDL and DML script creating and populating `reps`, `products`, `customers`, and `orders`. |
| [`sql/q01.sql`](sql/q01.sql) | Part A: SQL Layer | Pending orders awaiting fulfillment (19 rows). |
| [`sql/q02.sql`](sql/q02.sql) | Part A: SQL Layer | Audit of orders with missing / NULL transaction amounts (3 rows). |
| [`sql/q03.sql`](sql/q03.sql) | Part A: SQL Layer | Top 5 highest-value completed transactions. |
| [`sql/q04.sql`](sql/q04.sql) | Part A: SQL Layer | Target customer segment: North/West customers aged 25–40 (8 rows). |
| [`sql/q05.sql`](sql/q05.sql) | Part A: SQL Layer | Headline executive KPIs for completed orders (Count: 63, Revenue: ₹346,200). |
| [`sql/q06.sql`](sql/q06.sql) | Part A: SQL Layer | Order breakdown by status (completed, pending, disputed). |
| [`sql/q07.sql`](sql/q07.sql) | Part A: SQL Layer | Strong products generating > ₹20,000 in completed revenue (4 SKUs). |
| [`sql/q08.sql`](sql/q08.sql) | Part A: SQL Layer | Demographic customer profiles by region (average, min, max age). |
| [`sql/q09.sql`](sql/q09.sql) | Part A: SQL Layer | Consolidated order-level fact table joining customers and reps (90 rows). |
| [`sql/q10.sql`](sql/q10.sql) | Part A: SQL Layer | Inactive registered customers who never placed an order (4 customers). |
| [`sql/q11.sql`](sql/q11.sql) | Part A: SQL Layer | Region and month matrix with order counts, unique customers, and revenue (12 rows). |
| [`sql/q12.sql`](sql/q12.sql) | Part A: SQL Layer | Product revenue contribution tiers (High, Medium, Low). |
| [`sql/q13.sql`](sql/q13.sql) | Part A: SQL Layer | Sales representative monthly performance vs. targets (Below, On, Above Target). |
| [`results/query_results.md`](results/query_results.md) | Part A: SQL Layer | Documented execution outputs, seed row check, and Markdown tables for q01–q13. |
| [`data/orders_enriched.csv`](data/orders_enriched.csv) | Part A: SQL Layer | Fact extract exported from `q09` (Header + 90 order rows). |
| [`docs/spreadsheet_notes.md`](docs/spreadsheet_notes.md) | Part B: Spreadsheet | Formulas used, aggregate blocks, pivot tables, validation, and reconciliation. |
| [`data/orders_clean.csv`](data/orders_clean.csv) | Part B: Spreadsheet | Cleaned completed orders dataset (Header + 63 rows, 13 standardized columns). |
| [`docs/dashboard_spec.md`](docs/dashboard_spec.md) | Part C: Dashboard | Visual specifications for Tableau Public, KPI cards, worksheets, and business narrative. |
| [`docs/ai_log.md`](docs/ai_log.md) | Part D: AI Verification | 5-part prompts, inspection defect matrix, HITL protocol, and skeptical analyst challenge. |
| [`sql/d1_corrected.sql`](sql/d1_corrected.sql) | Part D: AI Verification | Corrected SQL query resolving Scenario D1 syntax/schema errors and phantom statistics. |

---

## Analytical Assumptions & Policy Decisions

Where choices were permitted in the project brief, the following assumptions were maintained:

1. **Revenue Recognition Policy:** In accordance with standard financial accounting and the project brief, "revenue" strictly denotes the sum of `amount` on transactions where `status = 'completed'`. Pending and disputed orders represent unrealized pipeline and were excluded from revenue KPIs.
2. **Missing Transaction Amounts:** Exactly three orders (`order_id` 1001, 1010, 1064) have `NULL` amounts in the raw dataset. Because all three are `status = 'pending'`, they do not affect completed revenue. In the spreadsheet layer, their expected values were verified via `unit_price * quantity`.
3. **Data Cleaning & Standardization:** Customer names were cleaned using `=PROPER(TRIM(...))` to eliminate leading, trailing, and excessive internal whitespace, standardizing all records into title casing.
4. **Order Month Preservation:** The `order_month` field was imported and stored explicitly as plain text (e.g., `'2026-09'`) across CSVs and spreadsheets to prevent automatic date coercion.
5. **Deterministic Sorting:** Ties in queries or sheets were resolved using deterministic secondary sort keys (e.g., `order_id ASC` or `customer_id ASC`).
