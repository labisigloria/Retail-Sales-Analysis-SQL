 CREATE DATABASE sql_project;
 USE sql_project;
 
 DESCRIBE orders_dirty;
 
 SELECT *
 FROM orders_dirty; 
 
 SELECT *
 FROM orders_dirty
 WHERE orderid IS NULL OR 
 trim(orderid) = '';
 
  SELECT *
 FROM orders_dirty
 WHERE customerid IS NULL OR customerid = '';
 
 SELECT *
 FROM orders_dirty
 WHERE customername IS NULL OR customername = '';
 
 SELECT *
 FROM orders_dirty
 WHERE product IS NULL OR product = '';
 
 SELECT *
 FROM orders_dirty
 WHERE category IS NULL OR category = '';
 
 SELECT category, count(*) AS total_records
 FROM orders_dirty
 GROUP BY category
 ORDER BY category;
 
 SELECT orderid, product, category
 from orders_dirty
 WHERE category IS NULL OR trim(category) = ''
       OR category <> trim(category);
 
 SELECT quantity, count(*) AS occurences
 FROM orders_dirty
 GROUP BY quantity;
 
 SELECT *
 FROM orders_dirty
 WHERE quantity IS NULL
 OR TRIM(quantity) = ' ';
 
 SELECT *
 FROM orders_dirty
 WHERE UPPER(TRIM(quantity)) = 'NULL';
 
 SELECT Orderid, customerid, customername, product, quantity, price, orderdate
 FROM orders_dirty
 WHERE quantity IS NULL
 OR TRIM(quantity) = '';
 
 SELECT *
 FROM orders_dirty
 WHERE price <= 0 OR price IS NULL;
 
 SELECT 
 o.orderid, o.product, o.price AS suspicious_price,
 p.lowest_valid_price, p.highest_valid_price, p.average_valid_price
 FROM orders_dirty AS o
 JOIN (
 SELECT product, min(price) AS lowest_valid_price, max(price) AS highest_valid_price, avg(price) AS average_valid_price
 FROM orders_dirty
 WHERE price > 0
 GROUP BY product) AS p
 ON o.product = p.product
 WHERE o.price <= 0 OR o.price IS NULL;
 
 -- Creating a clean table
 CREATE TABLE orders_cleaned AS
 SELECT *
 FROM orders_dirty;
 
 SELECT * FROM ORDERS_CLEANED;
 
 -- correcting negative prices in price column
 UPDATE orders_cleaned
 SET price = CASE
 WHEN orderid = 1 THEN 20000
 WHEN orderid = 10 THEN 18000
 WHEN orderid = 19 THEN 6000
 end
 WHERE orderid IN (1, 10, 19);
 
 
 -- cleaning customer name column
 SELECT orderid, customername, trim(customername) AS cleaned_name
 FROM orders_cleaned
 WHERE customername <> trim(customername);
 
 UPDATE orders_cleaned
 SET customername = trim(customername)
 WHERE customername <> trim(customername);
 
 -- cleaning the category column
 UPDATE orders_cleaned
 SET category = CASE
    WHEN lower(trim(category)) = 'electronics' THEN 'Electronics'
    WHEN lower(trim(category)) = 'accessories' THEN 'Accessories'
    ELSE trim(category)
    end
    WHERE category IS NOT NULL AND trim(category) <> '';
    
    UPDATE orders_cleaned
    SET category = 'Electronics'
    WHERE lower(trim(category)) = 'electroncs';
 
 UPDATE orders_cleaned
 SET category = 'Accessories'
 WHERE orderid = 13
 AND (category IS NULL OR trim(category) = '');
 
 -- cleaning the quantity column
 UPDATE orders_cleaned
 SET quantity = null
 WHERE trim(quantity) = '';
 
 ALTER TABLE orders_cleaned
 MODIFY COLUMN quantity INT NULL;
 
 -- cleaning the orderdate column
ALTER TABLE orders_cleaned
ADD COLUMN orderdate_converted DATE;

UPDATE orders_cleaned
SET orderdate_converted = str_to_date(orderdate, '%Y-%m-%d')
WHERE orderdate LIKE '%-%';

UPDATE orders_cleaned
SET orderdate_converted = str_to_date(orderdate, '%d/%m/%Y')
where orderdate like '%/%';

ALTER TABLE orders_cleaned
DROP COLUMN orderdate;

ALTER TABLE orders_cleaned
change column orderdate_converted OrderDate DATE;

DESCRIBE orders_cleaned;
-- Data quality summary
SELECT
    COUNT(*) AS total_records,
    COUNT(quantity) AS records_with_quantity,
    SUM(quantity IS NULL) AS missing_quantity_records,
    SUM(quantity * price) AS recorded_revenue
FROM orders_cleaned;

