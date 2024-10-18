-- data cleaning
SELECT *
 FROM pizza.pizza_sales_excel_file;

USE PIZZA;
CREATE TABLE Pizza_sales_new LIKE pizza_sales_excel_file;

SELECT *
 FROM Pizza_sales_new;
 
 INSERT Pizza_sales_new
 SELECT*
 FROM pizza_sales_excel_file;
 
 SELECT *
 FROM Pizza_sales_new;
  
 -- 1. remove dublicates
  SELECT *,
ROW_NUMBER() OVER(
  PARTITION BY pizza_id, order_id, pizza_name_id, quantity, 'order_date', order_time, unit_price, total_price, pizza_size, pizza_category, pizza_ingredients, pizza_name) AS row_num
FROM Pizza_sales_new;
 -- dublicates
WITH dublicates_count AS
(  
SELECT *,
ROW_NUMBER() OVER(
  PARTITION BY pizza_id, order_id, pizza_name_id, quantity, 
  'order_date', order_time, unit_price, total_price, pizza_size, pizza_category, 
  pizza_ingredients, pizza_name) AS row_num
FROM Pizza_sales_new
 )
 SELECT *
 FROM dublicates_count
 WHERE row_num > 1;
 -- Data is clean 
 
 CREATE TABLE `pizza_sales_new2` (
  `pizza_id` int DEFAULT NULL,
  `order_id` int DEFAULT NULL,
  `pizza_name_id` text,
  `quantity` int DEFAULT NULL,
  `order_date` text,
  `order_time` text,
  `unit_price` double DEFAULT NULL,
  `total_price` double DEFAULT NULL,
  `pizza_size` text,
  `pizza_category` text,
  `pizza_ingredients` text,
  `pizza_name` text, 
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

 SELECT *
 FROM pizza_sales_new2;
 
 INSERT into pizza_sales_new2
SELECT *,
ROW_NUMBER() OVER(
  PARTITION BY pizza_id, order_id, pizza_name_id, quantity, 
  'order_date', order_time, unit_price, total_price, pizza_size, pizza_category, 
  pizza_ingredients, pizza_name) AS row_num
FROM Pizza_sales_new;

SELECT*
FROM  Pizza_sales_new2;
 
-- 2. standardize data
SELECT*
FROM Pizza_sales_new2;

ALTER TABLE Pizza_sales_new2
ADD UNIQUE (pizza_id);

SELECT DISTINCT TRIM(pizza_name)
FROM Pizza_sales_new2;

UPDATE Pizza_sales_new2
SET pizza_name = TRIM(pizza_name)
WHERE pizza_id = 123;

SELECT*
FROM Pizza_sales_new2;

SELECT DISTINCT pizza_name_id
FROM Pizza_sales_new2
ORDER BY 1;

-- 3. Null values
SELECT *
FROM Pizza_sales_new2
WHERE 'order_date' IS NULL;

SELECT *
FROM Pizza_sales_new2
WHERE pizza_id IS NULL; 

SELECT *
FROM Pizza_sales_new2
WHERE total_price IS NULL;  

SELECT *
FROM Pizza_sales_new2
WHERE pizza_name IS NULL; 

SELECT *
FROM Pizza_sales_new2
WHERE pizza_id IS NULL; 

SELECT *
FROM Pizza_sales_new2
WHERE order_id IS NULL; 

SELECT *
FROM Pizza_sales_new2
WHERE quantity IS NULL; 
-- NO NULL DATA

-- 4. remove any columns
ALTER TABLE Pizza_sales_new2
DROP COLUMN row_num;

SELECT *
FROM Pizza_sales_new2

-- KPIs Analysis 

-- 1. Total Revenue of the PIZZA sales
SELECT (
SUM(total_price)
) AS total_revenue
FROM Pizza_sales_new2;

-- 2. Average order values
SELECT (
SUM(total_price) / COUNT(DISTINCT order_id)
) AS Avg_order_Value 
FROM Pizza_sales_new2;

-- 3. Total sold PIZZA
SELECT SUM(quantity) AS Total_pizza_sold 
FROM Pizza_sales_new2;

-- 4. total orders
SELECT COUNT(DISTINCT order_id) AS Total_Orders 
FROM Pizza_sales_new2;

-- 5. Average pizza number per order
SELECT CAST(CAST(SUM(quantity) AS DECIMAL(10,2)) / 
CAST(COUNT(DISTINCT order_id) AS DECIMAL(10,2)) AS DECIMAL(10,2))
AS Avg_Pizzas_per_order
FROM Pizza_sales_new2;

-- 6. The trending hour for Sold pizza
SELECT HOUR(order_time) AS order_hours, 
       SUM(quantity) AS total_pizzas_sold
FROM Pizza_sales_new2
GROUP BY HOUR(order_time)
ORDER BY total_pizzas_sold ASC;

-- 7. sales of every pizza category
SELECT pizza_category, CAST(SUM(total_price) AS DECIMAL(10,2)) as total_revenue,
CAST(SUM(total_price) * 100 / (SELECT SUM(total_price) from pizza_sales) AS DECIMAL(10,2)) AS PCT
FROM Pizza_sales_new2
GROUP BY pizza_category;

-- 8. sales of pizza according to size
SELECT pizza_size, CAST(SUM(total_price) AS DECIMAL(10,2)) as total_revenue,
CAST(SUM(total_price) * 100 / (SELECT SUM(total_price) from pizza_sales) AS DECIMAL(10,2)) AS PCT
FROM Pizza_sales_new2
GROUP BY pizza_size
ORDER BY pizza_size;

-- 9. Top 5-pizza revenue
SELECT 
    pizza_name, 
    SUM(total_price) AS Top5_Revenue 
FROM 
    Pizza_sales_new2 
GROUP BY 
    pizza_name 
ORDER BY 
    Top5_Revenue DESC 
LIMIT 5;

-- 10. Bottom 5-pizza revenue
SELECT 
    pizza_name, 
    SUM(total_price) AS Bottom5_Revenue 
FROM 
    Pizza_sales_new2 
GROUP BY 
    pizza_name 
ORDER BY 
    Bottom5_Revenue ASC 
LIMIT 5;

-- 11. Top 5-pizza Quantity
SELECT 
    pizza_name, 
    SUM(quantity) AS Total_Pizza_Sold_Top5
FROM 
    Pizza_sales_new2 
GROUP BY 
    pizza_name 
ORDER BY 
    Total_Pizza_Sold_Top5 DESC 
LIMIT 5;

-- 12. Bottom 5-pizza Quantity
SELECT 
    pizza_name, 
    SUM(quantity) AS Total_Pizza_Sold_Bottom 
FROM 
    Pizza_sales_new2 
GROUP BY 
    pizza_name 
ORDER BY 
    Total_Pizza_Sold_Bottom ASC
LIMIT 5;

-- 13. TOP 5 by total orders
SELECT 
    pizza_name, 
    COUNT(DISTINCT order_id) AS Total_orders_Top5
FROM 
    Pizza_sales_new2 
GROUP BY 
    pizza_name 
ORDER BY 
    Total_orders_Top5 DESC 
LIMIT 5;

-- 14. Bottom 5 by total orders
SELECT 
    pizza_name, 
    COUNT(DISTINCT order_id) AS Total_orders_Bottom5
FROM 
    Pizza_sales_new2 
GROUP BY 
    pizza_name 
ORDER BY 
    Total_orders_Bottom5 ASC
LIMIT 5;