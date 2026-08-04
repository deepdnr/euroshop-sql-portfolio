VIEW 1 — view_revenue_by_country
         Wraps Q4
    -- Business use: which country is our biggest market?
         Team: strategy, runs monthly

CREATE VIEW view_revenue_by_country AS
SELECT
    c.country,
    SUM(o.total_amount) AS total_revenue
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.country


VIEW 2 — view_monthly_revenue
         Wraps Q5
    -- Business use: how is revenue trending month by month?
         Team: finance, runs every month

CREATE VIEW view_monthly_revenue AS
SELECT
    TO_CHAR(order_date, 'YYYY-MM') AS month,
    SUM(total_amount) AS monthly_revenue
FROM orders
GROUP BY TO_CHAR(order_date, 'YYYY-MM')


VIEW 3 — view_return_rates
         Wraps Q3
    -- Business use: which products have the highest return rate?
         Team: operations, runs weekly

CREATE VIEW view_return_rates AS
SELECT p.product_name,
    p.brand,
    COUNT(*) AS total_orders,
    COUNT(CASE WHEN o.status = 'returned' THEN 1 END) AS total_returns,
    ROUND(COUNT(CASE WHEN o.status = 'returned' THEN 1 END) * 100.0 / COUNT(*), 1) AS return_rate
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
JOIN orders o ON oi.order_id = o.order_id
GROUP BY p.product_name, p.brand


VIEW 4 — view_customer_retention
         Wraps Q6
    -- Business use: which customers are coming back?
         Team: marketing, runs for campaigns
CREATE VIEW view_customer_retention AS
SELECT 
    CONCAT(c.first_name, ' ', c.last_name) AS full_name,
    COUNT(o.order_id) AS total_orders
FROM customers c
JOIN orders o ON o.customer_id = c.customer_id
GROUP BY c.first_name, c.last_name
HAVING COUNT(o.order_id) > 1