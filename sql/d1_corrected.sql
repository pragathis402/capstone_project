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
