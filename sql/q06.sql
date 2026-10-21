-- Business Question: What is the breakdown of order volume and total gross order value by fulfillment status?
SELECT
    status,
    COUNT(*) AS number_of_orders,
    SUM(amount) AS total_amount
FROM orders
GROUP BY status
ORDER BY number_of_orders DESC;
