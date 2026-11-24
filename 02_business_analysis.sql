USE sql_project;

-- 1. STORE 1: OVERALL SALES PERFORMANCE
-- Total recorded revenue for Store 1
SELECT
    SUM(quantity * price) AS total_revenue
FROM orders_cleaned;

-- Revenue by product category in Store 1
SELECT
    category,
    SUM(quantity * price) AS total_revenue
FROM orders_cleaned
GROUP BY category
ORDER BY total_revenue DESC;

-- Which individual products generate the highest revenue?
SELECT
    product,
    SUM(quantity * price) AS total_revenue
FROM orders_cleaned
GROUP BY product
ORDER BY total_revenue DESC;

-- Which products sell the highest number of units?
SELECT
    product,
    SUM(quantity) AS total_quantity_sold
FROM orders_cleaned
GROUP BY product
ORDER BY total_quantity_sold DESC;

-- How many orders has each customer placed?
SELECT
    customerid,
    customername,
    COUNT(orderid) AS total_orders
FROM orders_cleaned
GROUP BY customerid, customername
ORDER BY total_orders DESC;

-- How much revenue does each customer generate?
SELECT
    customerid,
    customername,
    SUM(quantity * price) AS total_revenue
FROM orders_cleaned
GROUP BY customerid, customername
ORDER BY total_revenue DESC;

-- The average selling price of products in each category.
SELECT
    category,
    AVG(price) AS average_price
FROM orders_cleaned
GROUP BY category
ORDER BY average_price DESC;

-- The highest-priced and lowest-priced products.
SELECT
    product,
    MAX(price) AS highest_price,
    MIN(price) AS lowest_price,
    AVG(price) AS average_price
FROM orders_cleaned
GROUP BY product
ORDER BY average_price DESC;

-- 5 highest-revenue dates
SELECT
    orderdate,
    COUNT(orderid) AS total_orders,
    SUM(quantity * price) AS daily_revenue
FROM orders_cleaned
GROUP BY orderdate
ORDER BY daily_revenue DESC
LIMIT 5;

-- Which products generate the most revenue on each category
WITH product_ranking AS (
    SELECT
        category,
        product,
        SUM(quantity * price) AS total_revenue,
        RANK() OVER (
            PARTITION BY category
            ORDER BY SUM(quantity * price) DESC
        ) AS revenue_rank
    FROM orders_cleaned
    GROUP BY category, product
)
SELECT
    category,
    product,
    total_revenue
FROM product_ranking
WHERE revenue_rank = 1;

-- Which products contribute the highest percentage of total revenue?
WITH product_revenue AS (
    SELECT
        product,
        SUM(quantity * price) AS total_revenue
    FROM orders_cleaned
    GROUP BY product
)
SELECT
    product,
    total_revenue,
    ROUND(
        total_revenue * 100 /
        (SELECT SUM(quantity * price)
         FROM orders_cleaned), 2
    ) AS revenue_percentage
FROM product_revenue
ORDER BY revenue_percentage DESC;

-- Products with the highest quantities sold
SELECT
    product,
    SUM(quantity) AS total_quantity_sold
FROM orders_cleaned
GROUP BY product
ORDER BY total_quantity_sold DESC
LIMIT 1;

-- Products with the lowest quantities sold
SELECT
    product,
    SUM(quantity) AS total_quantity_sold
FROM orders_cleaned
GROUP BY product
ORDER BY total_quantity_sold ASC
LIMIT 1;

-- Which customers have the highest average order value?
SELECT
    customerid,
    customername,
    COUNT(orderid) AS total_orders,
    SUM(quantity * price) AS total_revenue,
    ROUND(
        SUM(quantity * price) / COUNT(orderid), 2
    ) AS average_order_value
FROM orders_cleaned
GROUP BY customerid, customername
ORDER BY average_order_value DESC;

-- Which customers have not placed any orders?
SELECT
    c.customerid,
    c.customername
FROM customers AS c
LEFT JOIN orders_cleaned AS o
    ON c.customerid = o.customerid
WHERE o.customerid IS NULL;

-- Which customers have placed orders but have missing email addresses?
SELECT DISTINCT
    c.customerid,
    c.customername,
    c.email
FROM customers AS c
INNER JOIN orders_cleaned AS o
    ON c.customerid = o.customerid
WHERE c.email IS NULL
   OR TRIM(c.email) = '';

-- 2. COMBINED STORE ANALYSIS
-- Which customers have placed orders in both Store 1 and Store 2?
SELECT DISTINCT
    o1.customerid,
    o1.customername
FROM orders_cleaned AS o1
INNER JOIN orders_store2 AS o2
    ON o1.customerid = o2.customerid;
    
-- Which products are available in Store 2 but are not recorded in Store 1?
SELECT DISTINCT
    s2.product
FROM orders_store2 AS s2
LEFT JOIN orders_cleaned AS s1
    ON s2.product = s1.product
WHERE s1.product IS NULL;

-- Which category generates the highest combined revenue across both stores?
SELECT
    category,
    SUM(quantity * price) AS total_combined_revenue
FROM (
    SELECT category, quantity, price
    FROM orders_cleaned
    UNION ALL
    SELECT category, quantity, price
    FROM orders_store2
) AS combined_sales
GROUP BY category
ORDER BY total_combined_revenue DESC;

-- Which store contributes more to overall revenue?
SELECT
    'Store 1' AS store_name,
    SUM(quantity * price) AS total_revenue
FROM orders_cleaned
UNION ALL
SELECT
    'Store 2' AS store_name,
    SUM(quantity * price) AS total_revenue
FROM orders_store2;

-- What percentage of combined revenue does each store contribute?
WITH store_revenue AS (
    SELECT
        'Store 1' AS store_name,
        SUM(quantity * price) AS total_revenue
    FROM orders_cleaned

    UNION ALL

    SELECT
        'Store 2' AS store_name,
        SUM(quantity * price) AS total_revenue
    FROM orders_store2
)

SELECT
    store_name,
    total_revenue,
    ROUND(
        total_revenue * 100 /
        (SELECT SUM(total_revenue) FROM store_revenue),
        2
    ) AS revenue_percentage
FROM store_revenue
ORDER BY revenue_percentage DESC;

-- Which product categories generate the highest revenue in each store?
WITH combined_sales AS (
    SELECT
        'Store 1' AS store_name,
        category,
        SUM(quantity * price) AS total_revenue
    FROM orders_cleaned
    GROUP BY category
    UNION ALL
    SELECT
        'Store 2' AS store_name,
        category,
        SUM(quantity * price) AS total_revenue
    FROM orders_store2
    GROUP BY category
)
SELECT
    store_name,
    category,
    total_revenue
FROM combined_sales
ORDER BY store_name, total_revenue DESC;

-- Which products are generating the highest revenue across both stores combined?
WITH combined_products AS (
    SELECT
        product,
        quantity * price AS revenue
    FROM orders_cleaned
    UNION ALL
    SELECT
        product,
        quantity * price AS revenue
    FROM orders_store2
)
SELECT
    product,
    SUM(revenue) AS total_revenue
FROM combined_products
GROUP BY product
ORDER BY total_revenue DESC;

-- Which products contribute the highest percentage of total combined revenue?
WITH combined_products AS (
    SELECT
        product,
        SUM(quantity * price) AS revenue
    FROM orders_cleaned
    GROUP BY product

    UNION ALL

    SELECT
        product,
        SUM(quantity * price) AS revenue
    FROM orders_store2
    GROUP BY product
),

product_revenue AS (
    SELECT
        product,
        SUM(revenue) AS total_revenue
    FROM combined_products
    GROUP BY product
)
SELECT
    product,
    total_revenue,
    ROUND(
        total_revenue * 100 /
        (SELECT SUM(total_revenue) FROM product_revenue),
        2
    ) AS revenue_percentage
FROM product_revenue
ORDER BY revenue_percentage DESC;

