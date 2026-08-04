-- =============================================
-- Euroshop Practice Database
-- File 03: Business analysis queries
-- =============================================

-- Q1: Which product are people buying the most?
SELECT 
    p.brand, 
    p.product_name, 
    sum (quantity) as total_units_sold
FROM order_items oi
JOIN products p on oi.product_id = p.product_id
GROUP BY p.brand , p.product_id, p.product_name
ORDER BY total_units_sold desc
LIMIT 10;

-- Q2: Which product is making us the most money?
SELECT 
    p.product_name,
    p.brand,
    SUM(oi.quantity * oi.unit_price) AS total_revenue
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
GROUP BY p.product_name, p.brand
ORDER BY total_revenue DESC
LIMIT 5;

-- Q3: Which product do people return the most?
Select 
    p.product_name,
    p.brand,
    count(*) as total_orders,
    count(case when o.status = 'returned' then 1 end) as total_returns,
    round(count(case when o.status = 'returned' then 1 end)* 100.0/ count(*),1) as return_rate

from order_items oi
join products p on oi.product_id = p.product_id
join orders o on oi.order_id = o.order_id
group by p.product_name, p.brand
order by return_rate DESC
limit 10;

-- Q4: Which country is our biggest market?
SELECT
    c.country,
    SUM(o.total_amount) AS total_revenue
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.country
ORDER BY total_revenue DESC;

-- Q5: How has our revenue grown month by month in 2024?
SELECT
    TO_CHAR(order_date, 'YYYY-MM') AS month,
    SUM(total_amount) AS monthly_revenue
FROM orders
GROUP BY TO_CHAR(order_date, 'YYYY-MM')
ORDER BY month ASC;

-- Q6: How many customers came back and ordered again —
--     are we retaining people or losing them after one order?
SELECT 
    CONCAT(c.first_name, ' ', c.last_name) AS full_name,
    COUNT(o.order_id) AS total_orders
FROM customers c
JOIN orders o ON o.customer_id = c.customer_id
GROUP BY c.first_name, c.last_name
HAVING COUNT(o.order_id) > 1
ORDER BY total_orders DESC;

-- Q7: How are people paying — credit card, PayPal, 
--     or debit card?
SELECT 
    payment_method,
    COUNT(*) AS total_orders,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 1) AS percentage
FROM orders
GROUP BY payment_method
ORDER BY total_orders DESC;


-- Q8: Which products are people buying together —
--     If someone buys A, are they also buying B?

SELECT p1.product_name AS product_a, p2.product_name AS product_b, 
    COUNT(*) AS times_bought_together 
FROM order_items oi1 
JOIN order_items oi2 ON oi1.order_id = oi2.order_id 
AND oi1.product_id < oi2.product_id 
JOIN products p1 ON oi1.product_id = p1.product_id 
JOIN products p2 ON oi2.product_id = p2.product_id 
GROUP BY p1.product_name, p2.product_name 
ORDER BY times_bought_together 
DESC ;

-- Q9: Who are our top 10 most valuable customers,
--     and are they spending more or less than
--     the average customer?

SELECT
    concat (c.first_name, ' ', c.last_name) as customer_name,
    SUM(o.total_amount) AS total_spent,
    ROUND(AVG(SUM(o.total_amount)) OVER (), 2) AS avg_customer_spending,
    CASE
        WHEN SUM(o.total_amount) > AVG(SUM(o.total_amount)) OVER ()
        THEN 'above average'
        ELSE 'below average'
    END AS comparison
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY total_spent DESC
LIMIT 20;

-- Q10: Which products have a return rate higher than
--      the average for their category?
WITH product_rates AS (
  SELECT
    p.product_name,
    p.brand,
    c.category_name,
    ROUND(COUNT(CASE WHEN o.status = 'returned' THEN 1 END)
      * 100.0 / COUNT(*), 1) AS return_rate
  FROM order_items oi
  JOIN products p ON oi.product_id = p.product_id
  JOIN categories c ON p.category_id = c.category_id
  JOIN orders o ON oi.order_id = o.order_id
  GROUP BY p.product_name, p.brand, c.category_name
),
category_averages AS (
  SELECT
    category_name,
    ROUND(AVG(return_rate), 1) AS category_avg_rate
  FROM product_rates
  GROUP BY category_name
)
SELECT
  pr.product_name,
  pr.brand,
  pr.category_name,
  pr.return_rate,
  ca.category_avg_rate,
  pr.return_rate - ca.category_avg_rate AS above_avg_by
FROM product_rates pr
JOIN category_averages ca ON pr.category_name = ca.category_name
WHERE pr.return_rate > ca.category_avg_rate
ORDER BY above_avg_by DESC;

-- Q11: Which country made the most money each month,
--      And did it go up or down compared to the month before?

WITH monthly_revenue AS (
  SELECT c.country,
    TO_CHAR(o.order_date, 'YYYY-MM') AS month,
    SUM(o.total_amount) AS revenue
  FROM customers c
  JOIN orders o ON c.customer_id = o.customer_id
  GROUP BY c.country, TO_CHAR(o.order_date, 'YYYY-MM')
),
ranked AS (
  SELECT country, month, revenue,
    RANK() OVER (PARTITION BY month ORDER BY revenue DESC) AS country_rank
  FROM monthly_revenue
),
top_per_month AS (
  SELECT country, month, revenue
  FROM ranked
  WHERE country_rank = 1
),
with_previous AS (
  SELECT month, country, revenue,
    LAG(revenue) OVER (PARTITION BY country ORDER BY month) AS prev_revenue
  FROM top_per_month
)
SELECT
  month, country, revenue, prev_revenue,
  CASE
    WHEN prev_revenue IS NULL THEN 'first month'
    WHEN revenue > prev_revenue THEN 'up'
    WHEN revenue < prev_revenue THEN 'down'
    ELSE 'same'
  END AS direction,
  ROUND(revenue - prev_revenue, 2) AS change
FROM with_previous
ORDER BY month ASC;
