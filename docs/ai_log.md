# AI-Assisted Analysis with Human-in-the-Loop Verification Log

This log documents the structured steering, inspection, verification, and governance protocols applied to AI assistant outputs throughout the Big Billion Days Regional Performance Review.

---

## 1. Five-Part Prompt for SQL Query Generation (Part A — q13)

Below is the structured five-part prompt designed to steer an AI assistant to generate query `q13` without hallucinated syntax, invalid aliases, or unpermitted SQL features:

```text
[Role]
You are a Senior SQL Analytics Engineer specializing in retail sales reporting and revenue performance tracking.

[Task]
Write an ANSI SQL / SQLite-compliant query that evaluates regional sales representatives' monthly performance against their assigned monthly revenue targets, categorizing each rep-month into a performance tier.

[Context]
The database schema consists of the following relational tables and columns:
- reps: rep_id (INTEGER), rep_name (VARCHAR(50)), region (VARCHAR(20)), monthly_target (INTEGER)
- customers: customer_id (INTEGER), first_name (VARCHAR(30)), last_name (VARCHAR(30)), city (VARCHAR(30)), region (VARCHAR(20)), age (INTEGER), rep_id (INTEGER)
- orders: order_id (INTEGER), customer_id (INTEGER), item (VARCHAR(50)), quantity (INTEGER), amount (INTEGER), status (VARCHAR(20)), order_month (VARCHAR(7))

Relationships:
- customers.rep_id references reps.rep_id
- orders.customer_id references customers.customer_id

SQL Dialect: Standard ANSI SQL compatible with SQLite / PostgreSQL / MySQL.

[Constraints]
1. Count completed orders only (orders.status = 'completed'). Orders with 'pending' or 'disputed' status must be excluded.
2. Group rows by the sales representative, the order calendar month, and the representative's monthly target.
3. Compute performance_tier using a CASE expression evaluated directly on the aggregate expression:
   - 'Below Target': when completed revenue is strictly below monthly_target
   - 'On Target': when completed revenue is at least monthly_target and strictly below 1.1 * monthly_target
   - 'Above Target': when completed revenue is at least 1.1 * monthly_target
4. Do NOT use WITH clauses (CTEs), window functions, subqueries, or stored procedures.
5. Do NOT filter on derived column aliases or aggregates in WHERE; all aggregate logic must be evaluated directly in the SELECT and GROUP BY clauses.
6. Order output rows by rep_name ascending, then order_month ascending.

[Format]
Return raw SQL code only, beginning with a one-line SQL comment stating the business question. Include table aliases (r, c, o) on all column references.
```

---

## 2. Inspection of Scenario D1

An AI assistant was asked the vague prompt *"which regions sell the most?"* and produced the following response:

```sql
SELECT region_name, SUM(total_sales) AS sales
FROM sales
WHERE SUM(total_sales) > 80000
GROUP BY region_name
ORDER BY sales DESC;
```
> *"North is the strongest region, and its revenue grew 38% month over month."*

### Defect Analysis Matrix

| # | Assistant's Flawed Output | Defect Description | Classification | Correct Clause / Technical Fix |
|---|---|---|---|---|
| **1** | `FROM sales` | Non-existent table name. The database has no table named `sales`. | **fake method/function** | Replace `FROM sales` with `FROM customers c JOIN orders o ON c.customer_id = o.customer_id`. |
| **2** | `SELECT region_name, SUM(total_sales)` | Non-existent column names. The schema contains `region` on `customers` and `amount` on `orders`, not `region_name` or `total_sales`. | **fake method/function** | Select `c.region` and aggregate `SUM(o.amount) AS revenue`. |
| **3** | `WHERE SUM(total_sales) > 80000` | Aggregation filter placed in `WHERE`. SQL standard disallows aggregate functions in `WHERE` because rows are filtered before group aggregation. | **logic error** | Relocate the aggregate condition to a post-aggregation `HAVING` clause: `HAVING SUM(o.amount) > 80000`. |
| **4** | *"North ... revenue grew 38% month over month"* | Hallucinated temporal metric completely contradicted by actual transaction records. | **phantom statistic** | Compute actual month-over-month growth from audited data (`q11`): North fell from ₹53,500 (Sep) to ₹41,300 (Oct), which is **-22.8%** contraction. |

---

## 3. Verification of Scenario D1

### Corrected SQL Script (`sql/d1_corrected.sql`)
The repaired query was saved to `sql/d1_corrected.sql`:

```sql
-- Business Question: Which regions generated more than INR 80,000 in total completed revenue?
SELECT
    c.region,
    SUM(o.amount) AS revenue
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
WHERE o.status = 'completed'
GROUP BY c.region
HAVING SUM(o.amount) > 80000
ORDER BY revenue DESC;
```

### Execution Results
Executing `sql/d1_corrected.sql` on the verified database returns **exactly 2 rows**:

| region | revenue (INR) |
|---|---|
| **North** | ₹119,300 |
| **South** | ₹82,500 |

*(East with ₹69,500 and West with ₹74,900 fall below the ₹80,000 threshold and are correctly filtered out).*

### North Month-over-Month Revenue Analysis
Using the audited regional-monthly figures from Part A's query `q11`:
- **North Revenue in 2026-09:** ₹53,500 (8 completed orders)
- **North Revenue in 2026-10:** ₹41,300 (6 completed orders)
- **Calculation:**
  $$\text{MoM Percentage Change} = \frac{41,300 - 53,500}{53,500} \times 100 = \frac{-12,200}{53,500} \times 100 = -22.8037\% \approx -22.8\%$$

### Comparison with AI Claim
- **Assistant's Claim:** *"revenue grew 38% month over month"*
- **Actual Empirical Ground Truth:** North revenue **contracted by 22.8%** from September to October 2026.
- **Conclusion:** The assistant's claim of 38% growth is completely contradicted by the data. The assistant hallucinated positive momentum when the underlying reality was a sharp double-digit decline.

---

## 4. Human-in-the-Loop Governance Protocol

The five-stage human-in-the-loop audit protocol was applied to Scenario D1 as follows:

1. **Specification:**
   The human analyst establishes the precise business requirements, including schema definitions (`customers` and `orders`), the exact definition of realized revenue (`status = 'completed'`), the threshold (`> 80000`), and the chronological periods for month-over-month comparison.
2. **Execution:**
   The AI assistant is invoked to produce SQL code and an interpretive analytical narrative. The raw, unvetted output is captured in an isolated scratch environment without feeding directly into executive reports.
3. **Inspection:**
   The analyst conducts code and syntax inspection against the database schema and SQL grammar standards. In Scenario D1, inspection immediately surfaced four fatal defects: referencing a non-existent `sales` table, hallucinating `region_name` and `total_sales` attributes, violating SQL order of execution by placing `SUM()` inside `WHERE`, and making an unevidenced 38% growth claim.
4. **Verification:**
   The analyst executes the corrected SQL against the database compiler, validating the resulting row count (2 rows) and values (North: ₹119,300; South: ₹82,500). Furthermore, the analyst queries monthly totals from `q11` to independently compute the September-to-October growth rate, proving North actually experienced a -22.8% decline.
5. **Decision:**
   **Reject the original AI output** because the query fails with fatal syntax and schema errors (`Table not found: sales`), and the accompanying commentary contains a dangerous phantom statistic that would mislead leadership regarding regional performance. **Accept the corrected query (`sql/d1_corrected.sql`) and verified narrative** because the script runs flawlessly, accurately joins `customers` and `orders`, adheres to SQL aggregation standards with `HAVING`, and reflects verified ground truth (-22.8% MoM change).

---

## 5. Investigation and Prompt for Scenario D2 (Spreadsheet Lookup Error)

### Five-Part Diagnostic Prompt for AI Assistant
```text
[Role]
You are an expert Spreadsheet Architect and Formula Debugger.

[Task]
Identify the root cause of a #N/A lookup error in Google Sheets / Excel and provide the exact repaired formula.

[Context]
- Products Dimension Tab: Occupies range products!$A$1:$C$10. Header is in row 1. Column A holds product item names (e.g., 'Smart Watch'), Column B holds category, and Column C holds unit price.
- Orders Tab: Row 2 represents the first order line. Cell G2 holds the lookup key: ' Smart Watch' (with a leading space before the letter 'S').
- Formula Entered in Orders Tab Cell C2 (or Unit Price column):
  =VLOOKUP(G2, products!$A$2:$C$10, 3, FALSE)
- Expected Behavior: The formula should match 'Smart Watch' in products!A2:C10 and return the unit price (4500).

[Constraints]
Preserve the exact-match requirement (last parameter FALSE) and absolute range anchoring ($A$2:$C$10). Do not modify the underlying products master tab.

[Format]
1. State the exact technical root cause in one clear paragraph.
2. Provide the corrected formula ready to be copied down the column.
```

### Root Cause Analysis
The `#N/A` lookup failure occurs because `VLOOKUP` performs a strict character-by-character string comparison when the `is_sorted` argument is `FALSE`. Cell `G2` contains the string `" Smart Watch"` containing a stray leading space (ASCII 32), whereas the product master catalog cell `products!A2` contains `"Smart Watch"` without spaces. Because `" Smart Watch"` $\neq$ `"Smart Watch"`, the exact-match lookup fails to find a matching entry.

### Repaired Formula
Wrap the lookup key `G2` with `TRIM()` to strip leading, trailing, and duplicate whitespace prior to lookup evaluation:

```excel
=VLOOKUP(TRIM(G2), products!$A$2:$C$10, 3, FALSE)
```

*(Alternatively, using `XLOOKUP`: `=XLOOKUP(TRIM(G2), products!$A$2:$A$10, products!$C$2:$C$10, "UNKNOWN_ITEM")`)*

---

## 6. Skeptical-Analyst Challenge on Part C Recommendation

### Skeptical Analyst Prompt
```text
[Role]
Act as an adversarial, highly skeptical Senior Analytics Director who interrogates business recommendations for hidden flaws, correlation-vs-causation fallacies, and unstated assumptions.

[Task]
Critique and stress-test the following business recommendation from the Big Billion Days Regional Performance Review:
"Deploy ₹15,000 promotional capital to the West Region for Apparel campaigns, motivated by West generating ₹37,500 in Apparel sales (48.4% of total national Apparel revenue of ₹77,500)."

[Requirements]
1. Challenge the recommendation's core assumptions, separating correlation from causation.
2. List at least 3 critical unstated assumptions that must hold true for this capital allocation to generate positive ROI.
3. For each unstated assumption, specify an empirical figure or diagnostic query from the dataset that would confirm or weaken it.
```

### Skeptical Critique: Three Unstated Assumptions and Verifying Checks

1. **Unstated Assumption 1: Historical Sales Concentration Reflects High Marketing Elasticity Rather Than Demand Saturation.**
   - *Vulnerability:* The recommendation assumes that because West generated ₹37,500 in Apparel sales, additional marketing spend will produce incremental sales. If the existing customer base in West is already purchasing at maximum capacity, marketing dollars will merely subsidize organic buyers rather than acquiring new customers.
   - *Verifying Data Check:* Check customer penetration and order frequency among West customers. In `q04` and `q10`, the West region comprises 6 customers. Customer 24 (`Reena Kulkarni`) has never placed an order (`q10`), while the remaining 5 customers placed all West orders. Furthermore, checking monthly Apparel revenue in West shows sales dropped from ₹15,400 in October to ₹8,600 in November. If existing customers curtailed spending in November, an advertising campaign might fail unless it successfully activates inactive customers like Customer 24.
2. **Unstated Assumption 2: Unit Gross Margins in Apparel Are Sufficient to Absorb a ₹15,000 Promotional Budget.**
   - *Vulnerability:* Total completed Apparel revenue across all three months in West was ₹37,500 across 13 units. Reallocating ₹15,000 of marketing budget represents 40.0% of West's total historical Apparel gross turnover.
   - *Verifying Data Check:* Check product catalog unit prices (`products` table): `Cotton Kurta` sells for ₹1,400, `Denim Jacket` for ₹2,500, and `Running Shoes` for ₹3,600. Assuming typical retail apparel gross margins of ~30%, total historical margin earned in West was approximately ₹11,250 ($37,500 \times 0.30$). Spending ₹15,000 on promotions exceeds the entire gross margin pool earned by the category to date. The assumption of financial feasibility is severely weakened unless unit economics or merchant co-op funding cover the ad spend.
3. **Unstated Assumption 3: Apparel Demand in West Is Broad-Based Across Products Rather Than Distorted by One-Off Footwear Purchases.**
   - *Vulnerability:* The recommendation treats "Apparel" as a monolithic high-performing category. If sales are overwhelmingly driven by one high-ticket item (such as `Running Shoes`), marketing spent across the broader apparel assortment will suffer from poor conversion.
   - *Verifying Data Check:* Check SKU-level sales within West Apparel. In `orders_clean.csv`, West completed Apparel transactions consist of:
     - `Running Shoes`: 6 orders totaling ₹25,200 (7 units @ ₹3,600)
     - `Denim Jacket`: 1 order totaling ₹7,500 (3 units @ ₹2,500)
     - `Cotton Kurta`: 3 orders totaling ₹4,800 (4 units @ ₹1,400)
     `Running Shoes` alone accounts for **67.2%** (₹25,200 / ₹37,500) of West's Apparel revenue! Promoting traditional ethnic wear (`Cotton Kurta`) would yield poor returns; promotional spending must be strictly targeted at athletic footwear and premium outerwear.
