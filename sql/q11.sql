-- Business Question: How does regional sales performance (order count, unique customer count, total revenue, and average revenue) trend month-over-month for completed orders?
-- Join Choice Justification: An INNER JOIN between customers and orders is used because the analysis reports strictly on realized, completed sales transactions; orders must match valid customer records, and customers without orders should not appear in this sales performance breakdown.
-- Distinct Count Justification: COUNT(DISTINCT c.customer_id) is necessary because repeat customers place multiple orders within the same region and calendar month; a simple non-distinct COUNT would inflate the unique active customer reach metric.
SELECT
    c.region,
    o.order_month,
    COUNT(o.order_id) AS number_of_orders,
    COUNT(DISTINCT c.customer_id) AS number_of_customers,
    SUM(o.amount) AS total_revenue,
    AVG(o.amount) AS average_revenue
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
WHERE o.status = 'completed'
GROUP BY c.region, o.order_month
ORDER BY c.region ASC, o.order_month ASC;
