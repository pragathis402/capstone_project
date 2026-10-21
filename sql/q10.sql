-- Business Question: Which registered customers have never placed any orders during the sale campaign?
SELECT
    c.customer_id,
    c.first_name,
    c.last_name,
    c.region
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL
ORDER BY c.customer_id ASC;
