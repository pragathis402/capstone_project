-- Business Question: What are the pending orders awaiting processing, including their customer, item, and order amount?
SELECT
    order_id,
    customer_id,
    item,
    amount
FROM orders
WHERE status = 'pending'
ORDER BY order_id ASC;
