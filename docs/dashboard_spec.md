# Dashboard Specification and Business Narrative

This specification defines the visual architecture, data model, worksheet parameters, layout containers, and business insights for the executive Big Billion Days (BBD) Regional Performance Review dashboard, designed for authoring in Tableau Public using `data/orders_clean.csv`.

---

## 1. Data Source

- **Data File:** `data/orders_clean.csv` (63 rows of completed order transactions, 13 fields)
- **Field Definitions and Classifications:**

| Field Name | Data Type | Tableau Classification | Role & Description |
|---|---|---|---|
| `order_id` | Integer | **Dimension** | Unique transaction identifier (qualitative key; not aggregated) |
| `order_month` | String / Text | **Dimension** | Calendar month of transaction (`2026-09`, `2026-10`, `2026-11`) |
| `clean_first_name` | String / Text | **Dimension** | Standardized customer first name (Proper Case, trimmed) |
| `clean_last_name` | String / Text | **Dimension** | Standardized customer last name (Proper Case, trimmed) |
| `region` | String / Text | **Dimension** | Customer geographic sales territory (`East`, `North`, `South`, `West`) |
| `rep_name` | String / Text | **Dimension** | Assigned regional sales representative |
| `item` | String / Text | **Dimension** | Purchased product name (9 unique SKUs) |
| `category` | String / Text | **Dimension** | Product merchandise department (`Apparel`, `Electronics`, `Home`) |
| `unit_price` | Integer / Number | **Measure** | Catalog unit price in Indian Rupees (INR) |
| `quantity` | Integer / Number | **Measure** | Units purchased in order transaction |
| `amount` | Integer / Number | **Measure** | Realized transaction revenue settlement in INR |
| `revenue_calc` | Integer / Number | **Measure** | Calculated revenue verification (`unit_price * quantity`) in INR |
| `status` | String / Text | **Dimension** | Order fulfillment state (`completed`) |

---

## 2. KPI Summary Cards

The top band contains two high-impact executive KPI summary cards:

1. **Total Revenue Card**
   - **Measure:** `SUM(amount)`
   - **Value Displayed:** **₹346,200**
   - **Verification:** The revenue card value of ₹346,200 exactly reconciles with the SQL reporting layer headline KPI `total_revenue` in query `q05` and the spreadsheet pivot grand totals.
2. **Total Units Sold Card**
   - **Measure:** `SUM(quantity)`
   - **Value Displayed:** **106 Units**
   - **Verification:** Computed across all 63 completed order line items.

---

## 3. Worksheet Specifications

### Worksheet 1: Revenue by Region
- **Chart Type:** Horizontal Bar Chart
- **Shelves:**
  - **Rows:** `region` (Dimension, sorted descending by `SUM(amount)`)
  - **Columns:** `SUM(amount)` (Measure, formatted as Currency INR)
  - **Color:** `region` (Distinct regional palette)
  - **Label:** `SUM(amount)` displayed at end of bars
- **Justification:** A horizontal bar chart facilitates immediate visual ranking of geographic territories, allowing regional managers to instantly benchmark relative sales contributions.
- **Data Table:**

| Region | Sales Representative | Completed Revenue (INR) | Share of Total |
|---|---|---|---|
| **North** | Arjun Mehta | ₹119,300 | 34.46% |
| **South** | Kavya Nair | ₹82,500 | 23.83% |
| **West** | Neha Kulkarni | ₹74,900 | 21.63% |
| **East** | Sanjay Roy | ₹69,500 | 20.08% |
| **Total** | | **₹346,200** | **100.00%** |

---

### Worksheet 2: Revenue by Category
- **Chart Type:** Vertical Bar Chart
- **Shelves:**
  - **Columns:** `category` (Dimension, sorted descending by `SUM(amount)`)
  - **Rows:** `SUM(amount)` (Measure, formatted as Currency INR)
  - **Color:** `category` (Categorical palette: Blue for Electronics, Orange for Home, Green for Apparel)
  - **Label:** `SUM(amount)` displayed on top of bars
- **Justification:** A vertical column bar chart provides a clean, discrete comparison among the three primary merchandise departments to evaluate portfolio contribution.
- **Data Table:**

| Category | Completed Revenue (INR) | Units Sold | Share of Total |
|---|---|---|---|
| **Electronics** | ₹142,300 | 39 | 41.10% |
| **Home** | ₹126,400 | 36 | 36.51% |
| **Apparel** | ₹77,500 | 31 | 22.39% |
| **Total** | **₹346,200** | **106** | **100.00%** |

---

### Worksheet 3: Revenue Trend by Month and Category
- **Chart Type:** Multi-Line Trend Chart
- **Shelves:**
  - **Columns:** `order_month` (Dimension, continuous chronological sequence `2026-09`, `2026-10`, `2026-11`)
  - **Rows:** `SUM(amount)` (Measure, formatted as Currency INR)
  - **Color:** `category` (Separate colored trend line per category)
  - **Tooltip:** `order_month`, `category`, `SUM(amount)`, `SUM(quantity)`
- **Justification:** Multi-series line charts are optimal for displaying continuous temporal trajectories, highlighting monthly velocity changes and category mix shifts across the campaign lifecycle.
- **Data Table:**

| Order Month | Apparel (INR) | Electronics (INR) | Home (INR) | Monthly Total (INR) |
|---|---|---|---|---|
| **2026-09** | ₹24,700 | ₹43,000 | ₹30,600 | **₹98,300** |
| **2026-10** | ₹30,600 | ₹49,900 | ₹12,600 | **₹93,100** |
| **2026-11** | ₹22,200 | ₹49,400 | ₹83,200 | **₹154,800** |
| **Total** | **₹77,500** | **₹142,300** | **₹126,400** | **₹346,200** |

---

### Worksheet 4: Region × Category Detail
- **Chart Type:** Cross-Tabular Text Matrix / Heatmap Table
- **Shelves:**
  - **Rows:** `category`
  - **Columns:** `region`
  - **Text (Marks):** `SUM(amount)`
  - **Color:** `SUM(amount)` (Sequential blue gradient shading cells by magnitude)
- **Justification:** A structured cross-tabulation provides exact, granular cell values required by category managers for auditing SKU-level sales across regional boundaries.
- **Data Table:**

| Category | East (INR) | North (INR) | South (INR) | West (INR) | Total (INR) |
|---|---|---|---|---|---|
| **Apparel** | ₹10,600 | ₹19,400 | ₹10,000 | ₹37,500 | **₹77,500** |
| **Electronics** | ₹21,400 | ₹73,400 | ₹28,700 | ₹18,800 | **₹142,300** |
| **Home** | ₹37,500 | ₹26,500 | ₹43,800 | ₹18,600 | **₹126,400** |
| **Total** | **₹69,500** | **₹119,300** | **₹82,500** | **₹74,900** | **₹346,200** |

---

## 4. Dashboard Layout and Interactivity

- **Canvas Size:** Fixed Dashboard, 1200px width × 900px height.
- **Top-to-Bottom Container Structure:**
  1. **Header Container (Vertical, Top):**
     - Dashboard Title: `Flipkart Big Billion Days (BBD) — Regional Performance Review`
     - Subtitle: `Traceable Order Analytics & Promotion Strategy Dashboard`
  2. **Executive KPI Container (Horizontal):**
     - Left Card: Total Revenue (₹346,200)
     - Right Card: Total Units Sold (106)
  3. **Interactive Control Bar Container (Horizontal):**
     - Category Filter: Single-value dropdown or multi-select pill control positioned directly below KPI cards. Configured as **Apply to All Worksheets using this Data Source** (`orders_clean.csv`).
  4. **Primary Trend Container (Vertical):**
     - Worksheet 3: *Revenue Trend by Month and Category* spanning full dashboard width (600px width × 250px height).
  5. **Comparative Analysis Container (Horizontal):**
     - Left Half: Worksheet 1 (*Revenue by Region*, 580px width)
     - Right Half: Worksheet 2 (*Revenue by Category*, 580px width)
  6. **Granular Detail Container (Vertical, Bottom):**
     - Worksheet 4: *Region × Category Detail* text table displaying exact reconciliation matrices.
- **Interactive Action Filtering ("Use as Filter"):**
  - When a user clicks a regional bar in Worksheet 1 (*Revenue by Region*), Tableau applies an interactive filter passing `region` across all other worksheets on the dashboard, instantly slicing the KPI cards, monthly trend lines, category distribution, and detail matrix exclusively to that selected territory.

---

## 5. Insight and Recommendation Narrative

### Visualization Summary
The dashboard provides an executive, end-to-end view of Flipkart’s Big Billion Days performance across three monthly campaign cycles (September, October, and November 2026). Slicing 63 completed orders worth ₹346,200 across four geographical zones, it highlights significant geographic specializations, category shifts, and monthly sales surges, enabling leadership to align future inventory commitments and promotional capital allocations with verified consumer purchasing patterns.

### Summary Analysis
1. **Regional Performance Disparity and Electronics Concentration in North:**
   - North emerged as the campaign's largest sales driver, generating ₹119,300 (34.5% of total revenue) and outperforming East (₹69,500) by 71.7% and West (₹74,900) by 59.3%.
   - However, North’s dominance is heavily concentrated in Electronics, which contributed ₹73,400 (61.5% of North's total sales). Conversely, South showed a more balanced distribution, generating ₹43,800 in Home goods and ₹28,700 in Electronics to achieve ₹82,500 overall.
2. **West's Distinct Apparel Specialization:**
   - While Electronics led national sales overall (₹142,300), the West region demonstrated a distinct product preference: Apparel dominated West’s sales at ₹37,500, representing nearly half (50.1%) of West's ₹74,900 total revenue.
   - West generated more Apparel revenue than East (₹10,600), North (₹19,400), and South (₹10,000) combined (₹40,000 across the other three regions), underscoring an intense regional concentration for lifestyle fashion in Western metro hubs.
3. **Temporal Trajectory and November Home Goods Explosion:**
   - Monthly sales remained relatively flat between September (₹98,300 across 19 orders) and October (₹93,100 across 20 orders, a 5.3% dip), before surging 66.3% in November to ₹154,800 across 24 orders.
   - This massive November acceleration was propelled almost entirely by the Home category, which expanded by 560.3% from ₹12,600 in October to ₹83,200 in November, driven by high-ticket Air Fryer purchases (four peak orders of ₹15,600 each across East, South, and West). Meanwhile, North experienced a sharp consecutive deceleration, dropping from ₹53,500 in September to ₹41,300 in October, and hitting a low of ₹24,500 in November.

### Recommendations
1. **Deploy Targeted Apparel Promotion Capital in the West Region:**
   - *Target:* West Region — Apparel Category (`Running Shoes`, `Denim Jacket`, `Cotton Kurta`).
   - *Concrete Action:* Reallocate ₹15,000 of underutilized regional marketing budget toward localized digital campaigns, influencer styling partnerships, and cart-building bundle discounts in Mumbai, Pune, and Ahmedabad.
   - *Motivating Data:* West generated ₹37,500 in Apparel sales (48.4% of total national Apparel revenue of ₹77,500), proving high regional consumer willingness to buy fashion items.
   - *Success Metric:* West monthly Apparel revenue growth (target: >= 25% increase) and Apparel average order value (AOV).
2. **Pre-Position Bulk Home Appliance Inventory in East and South Fulfillment Hubs:**
   - *Target:* East & South Regions — Home Category (`Air Fryer`).
   - *Concrete Action:* Contract regional warehouse capacity and pre-stock Air Fryers in Kolkata and Bengaluru distribution centers prior to the November sales wave.
   - *Motivating Data:* Home revenue exploded to ₹83,200 in November, with Air Fryers accounting for ₹104,000 of completed revenue across the campaign (the single highest product SKU), including multiple maximum-basket orders of ₹15,600 in East and South.
   - *Success Metric:* Fulfillment order cycle time (target: < 24 hours) and zero stockout incidents during the November campaign peak.
3. **Revitalize North Customer Engagement and Rep Support to Halt MoM Contraction:**
   - *Target:* North Region — Multi-category cross-selling.
   - *Concrete Action:* Provide sales rep Arjun Mehta with customer reactivation incentives, targeting the 25–40 demographic in Delhi, Lucknow, and Jaipur with category crossover coupons (e.g., offering Home/Apparel discounts to past Electronics buyers).
   - *Motivating Data:* North revenue contracted consecutively by 22.8% from September (₹53,500) to October (₹41,300), and plunged another 40.7% to ₹24,500 in November, causing Arjun Mehta's performance to drop from 'Above Target' to 'Below Target'.
   - *Success Metric:* Representative monthly target achievement percentage (rebound to >= 100% of the ₹40,000 monthly target) and non-electronics revenue contribution in North.

---

## 6. End-to-End Reconciliation Table

The table below confirms the exact numerical alignment across every layer of the analytics pipeline:

| Dimension / Aggregation Layer | Total Revenue (INR) | Reconciled Against | Match Status |
|---|---|---|---|
| **Dashboard Total Revenue KPI** | ₹346,200 | Pipeline Target | **Match** |
| **Sum of Revenue by Region Bars** | ₹346,200 | Dashboard KPI | **Match** |
| **Sum of Revenue by Category Bars** | ₹346,200 | Dashboard KPI | **Match** |
| **Part B Pivot Table Grand Total** | ₹346,200 | Spreadsheet Pivot | **Match** |
| **Part A SQL Query q05 total_revenue** | ₹346,200 | SQL Reporting Layer | **Match** |

*All five independent calculations produce exactly ₹346,200 across 63 completed orders.*
