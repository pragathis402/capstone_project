# Spreadsheet Cleaning and Reconciliation Notes

This document details the data preparation, formulas, data validation checks, reconciliation, and pivot table analysis conducted in the spreadsheet layer (Google Sheets / Microsoft Excel) based on the order-level fact extract `data/orders_enriched.csv` and the product catalog.

---

## 1. Setup

- **Created Tabs:**
  1. `orders`: Receives the raw 90-row export from Part A (`data/orders_enriched.csv`), containing columns `order_id` through `status`.
  2. `products`: Reference dimension table populated with the 9 products loaded into range `A1:C10` (Header in row 1: `item`, `category`, `unit_price`, sorted alphabetically by item).
  3. `completed_orders`: Target analytical table created by filtering `orders` for `status = 'completed'`, sorting the visible rows by `amount` descending, and pasting as values (63 rows).
- **Import Configuration:**
  - `orders` row count: Header plus 90 imported order rows (rows 2 to 91).
  - Column `order_month` was explicitly imported and formatted as **Plain text** to prevent automatic date conversion (e.g., preserving literal ISO strings such as `2026-09`, `2026-10`, `2026-11`).
- **Product Reference Range:**
  - Range: `products!$A$1:$C$10` (Data range `products!$A$2:$C$10`).
- **Fallback Verification Test (Spare Cell):**
  - To verify that the error-handling fallback in `XLOOKUP` functions as designed when encountering unmapped products, an audit formula was evaluated in spare cell `Z2` on the `orders` tab:
    ```excel
    =XLOOKUP("Mystery Item", products!$A$2:$A$10, products!$C$2:$C$10, "UNKNOWN_ITEM")
    ```
  - **Result:** Displayed `UNKNOWN_ITEM` as expected. In the production dataset of 90 orders, all 90 items exist in the catalog, so the fallback does not trigger on production rows.
- **Filtering and Sorting Sequence:**
  - Applied filter: `status = 'completed'`.
  - Applied sort: `amount` descending (Largest to Smallest).
  - Copied 63 visible rows and pasted as values into `completed_orders`.
  - Dropped raw `first_name` and `last_name` columns; retained `clean_first_name` and `clean_last_name`.
  - Arranged columns in exact export order: `order_id`, `order_month`, `clean_first_name`, `clean_last_name`, `region`, `rep_name`, `item`, `category`, `unit_price`, `quantity`, `amount`, `revenue_calc`, `status`.

---

## 2. Spreadsheet Formulas (First Data Row)

The following formulas were entered into row 2 of the `orders` tab (first data row) and copied down across all 90 rows:

| Added Column | Cell | Formula as Typed | Explanation |
|---|---|---|---|
| `clean_first_name` | `K2` | `=PROPER(TRIM(C2))` | Strips leading, trailing, and duplicate spaces from raw `first_name` (`C2`) and converts text to Proper Case (capitalized initial letter). |
| `clean_last_name` | `L2` | `=PROPER(TRIM(D2))` | Strips leading, trailing, and duplicate spaces from raw `last_name` (`D2`) and converts text to Proper Case. |
| `category` | `M2` | `=VLOOKUP(G2, products!$A$2:$C$10, 2, FALSE)` | Performs an exact match lookup of `item` (`G2`) against the anchored products table range, retrieving `category` from column 2. |
| `unit_price` | `N2` | `=XLOOKUP(G2, products!$A$2:$A$10, products!$C$2:$C$10, "UNKNOWN_ITEM")` | Performs an exact lookup of `item` (`G2`) in `products!$A$2:$A$10` and returns `unit_price` from `products!$C$2:$C$10`, falling back to `"UNKNOWN_ITEM"`. |
| `revenue_calc` | `O2` | `=N2*H2` | Multiplies unit price (`N2`) by order quantity (`H2`) using cell references to verify calculated revenue against recorded `amount`. |

---

## 3. Aggregate Block on `completed_orders`

On the `completed_orders` tab, summary metrics were computed on the `amount` column (`K2:K64`) in a dedicated summary block:

| Metric | Formula | Value (INR) |
|---|---|---|
| **COUNT** | `=COUNT(K2:K64)` | 63 |
| **SUM** | `=SUM(K2:K64)` | 346,200 |
| **AVERAGE** | `=AVERAGE(K2:K64)` | 5,495.24 |
| **MIN** | `=MIN(K2:K64)` | 1,100 |
| **MAX** | `=MAX(K2:K64)` | 15,600 |

---

## 4. Reconciliation Table

Reconciliation between the spreadsheet summary statistics on `completed_orders` and the SQL reporting layer output (`q05`):

| Metric | Spreadsheet Value | SQL Layer (q05) Value | Match / Mismatch |
|---|---|---|---|
| **COUNT (total_orders)** | 63 | 63 | **Match** |
| **SUM (total_revenue)** | 346,200 | 346,200 | **Match** |
| **AVERAGE (avg_order_value)** | 5,495.24 | 5,495.24 | **Match** |

*Note: The SQL query `q05` yields `avg_order_value = 5495.238095...`, which rounds to `5,495.24`, perfectly matching the spreadsheet's two-decimal currency display.*

---

## 5. Pivot Tables

### Pivot Table (i): Revenue by Category and Region (INR)
- **Rows:** `category`
- **Columns:** `region`
- **Values:** Sum of `amount`

| Category | East | North | South | West | Grand Total |
|---|---|---|---|---|---|
| **Apparel** | ₹10,600 | ₹19,400 | ₹10,000 | ₹37,500 | **₹77,500** |
| **Electronics** | ₹21,400 | ₹73,400 | ₹28,700 | ₹18,800 | **₹142,300** |
| **Home** | ₹37,500 | ₹26,500 | ₹43,800 | ₹18,600 | **₹126,400** |
| **Grand Total** | **₹69,500** | **₹119,300** | **₹82,500** | **₹74,900** | **₹346,200** |

### Pivot Table (ii): Monthly Sales and Order Volume
- **Rows:** `order_month`
- **Values:** Sum of `amount`, Count of `order_id`

| Order Month | Sum of Amount (INR) | Count of Orders |
|---|---|---|
| **2026-09** | ₹98,300 | 19 |
| **2026-10** | ₹93,100 | 20 |
| **2026-11** | ₹154,800 | 24 |
| **Grand Total** | **₹346,200** | **63** |

---

## 6. Data Validation and Governance

1. **Handling of Missing Amounts:**
   - As identified in Part A (`q02`), exactly three orders contain `NULL` transaction amounts:
     - `order_id = 1001`: Customer 10 (`MEERA Patil`), South region, `Bluetooth Speaker`, quantity 2, status `pending`.
     - `order_id = 1010`: Customer 19 (`Gaurav Yadav`), East region, `Wireless Earbuds`, quantity 1, status `pending`.
     - `order_id = 1064`: Customer 20 (`Isha Pillai`), West region, `Bluetooth Speaker`, quantity 1, status `pending`.
   - **Rationale and Treatment:** All three records carry a fulfillment status of `pending`. Under the strict operational definition established for this campaign, revenue is recognized exclusively upon order completion (`status = 'completed'`). When applying the filter `status = 'completed'` to generate `completed_orders`, these three orders were naturally excluded from revenue computation. Furthermore, using our added formula `revenue_calc = unit_price * quantity`, the potential transaction values can be fully reconstructed: Order 1001 = ₹5,600 (2 × ₹2,800), Order 1010 = ₹3,200 (1 × ₹3,200), and Order 1064 = ₹2,800 (1 × ₹2,800). This confirmed that no completed transaction had missing financial data.

2. **Data Type Consistency Checks:**
   - Numerical fields (`unit_price`, `quantity`, `amount`, `revenue_calc`) were confirmed to be stored as genuine numeric formats using spreadsheet formula checks (`=ISNUMBER(...)` returned `TRUE` across all data rows).
   - `order_month` was locked as Plain Text (`@`) to prevent spreadsheet auto-parsers from coercing strings into month-year dates (e.g., September 1, 2026), ensuring uniform downstream interoperability.

3. **Duplicate and Outlier Analysis:**
   - Checked for duplicate identifiers using `=COUNTIF(A:A, A2)`: All 90 `order_id`s in `orders` and all 63 in `completed_orders` are strictly unique (count = 1).
   - **Outliers / Maximum Values:**
     - The maximum order value among completed transactions is **₹15,600**.
     - Exactly four orders tie for this maximum value:
       - `order_id = 1061`: Customer 16 (`Nisha Mishra`, West), 3 × `Air Fryer` @ ₹5,200 = ₹15,600 (`2026-11`).
       - `order_id = 1065`: Customer 22 (`Tanvi Thakur`, South), 3 × `Air Fryer` @ ₹5,200 = ₹15,600 (`2026-11`).
       - `order_id = 1069`: Customer 15 (`Aditya Rao`, East), 3 × `Air Fryer` @ ₹5,200 = ₹15,600 (`2026-11`).
       - `order_id = 1077`: Customer 3 (`Rahul Verma`, East), 3 × `Air Fryer` @ ₹5,200 = ₹15,600 (`2026-11`).
     - All four top-ticket orders occurred during the peak November sale cycle and represent bulk multi-unit purchases of the premium `Air Fryer`.

4. **Documented Decision for Successor Analysts:**
   - *Governance Rule:* When computing campaign KPIs and downstream visual dimensions, never calculate revenue directly from `quantity * unit_price` without cross-checking the audited `amount` field. While `revenue_calc` matches `amount` across all completed orders in this campaign, future promotional discount coupons, merchant concessions, or bulk pricing adjustments would create variance between listed catalogue price and realized cash collected. The audited settlement field `amount` must remain the single source of financial truth for reporting.
