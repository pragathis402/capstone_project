-- Business Question: What are the top 5 highest-value completed transactions across all regions?
SELECT
    order_id,
    customer_id,
    item,
    amount
FROM orders
WHERE status = 'completed'
ORDER BY amount DESC, order_id ASC
LIMIT 5;
