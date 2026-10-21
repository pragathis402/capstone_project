-- Business Question: What is the total completed revenue and contribution tier (High >= 60000, Medium >= 15000, Low < 15000) for each product?
SELECT
    item,
    SUM(amount) AS total_revenue,
    CASE
        WHEN SUM(amount) >= 60000 THEN 'High'
        WHEN SUM(amount) >= 15000 THEN 'Medium'
        ELSE 'Low'
    END AS contribution_tier
FROM orders
WHERE status = 'completed'
GROUP BY item
ORDER BY total_revenue DESC;
