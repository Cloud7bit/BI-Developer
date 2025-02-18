USE restaurant_db;

-- Objective_1
-- 1.View the menu_items table.
SELECT
	*
FROM
	menu_items;
    
-- 2.Write a query to find the number of items on the menu.
SELECT 
	COUNT(*) AS Number_of_Items
FROM
	menu_items;

-- 3.What are the least and most expensive items on the menu?
SELECT 
	* 
FROM
	menu_items
ORDER BY 
	price
LIMIT 
	1;

SELECT 
	*
FROM
	menu_items
ORDER BY 
	price DESC
LIMIT 
	1;
    
-- 4.How many Italian dishes are on the menu?
SELECT 
	COUNT(*)
FROM 
	menu_items
WHERE
	category = 'Italian';

-- 5.What are the least and most expensive Italian dishes on the menu?  
SELECT 
	   *
FROM 
	menu_items
WHERE
	category = 'Italian'
ORDER BY 
	price
LIMIT 
	1;

SELECT 
	   *
FROM 
	menu_items
WHERE
	category = 'Italian'
ORDER BY 
	price DESC
LIMIT 
	1;

-- 6.How many dishes are in each category? 
SELECT
	category,COUNT(*) as Number_of_Dishes
FROM
	menu_items
GROUP BY 
	category;
    
-- 7.What is the average dish price within each category?
SELECT
	category,ROUND(AVG(price),2) as AVG_Dish_Price
FROM
	menu_items
GROUP BY 
	category;
    
-- Objective_2
-- 1.View the order_details table.
SELECT
	*
FROM
	order_details;

-- 2.What is the date range of the table?
SELECT
	MIN(order_date) AS min_order_date,MAX(order_date) AS max_order_date
FROM
	order_details;
    
-- 3.How many orders were made within this date range? 
SELECT
	COUNT(DISTINCT order_id) as orders
FROM 
	order_details;

-- 4.How many items were ordered within this date range?
SELECT
	COUNT(*) as items
FROM
	order_details;

-- 5.Which orders had the most number of items?
SELECT 
	order_id, COUNT(item_id) AS Num_items 
FROM
	order_details
GROUP BY
	order_id
ORDER BY 
	2 DESC;
-- 6.How many orders had more than 12 items?    
SELECT
	COUNT(*) AS Orders
FROM
(SELECT 
	order_id, COUNT(item_id) AS Num_items 
FROM
	order_details
GROUP BY
	order_id
HAVING 
	Num_items > 12) AS Num_Orders;
    
-- Objective_3
-- 1.Combine the menu_items and order_details tables into a single table.    
SELECT
		*
FROM
	order_details o
LEFT JOIN
	menu_items m
ON
	o.item_id = m.menu_item_id;

-- 2.What were the least and most ordered items? What categories were they in?
SELECT
		item_name,COUNT(order_details_id) AS Num_Orders,category
FROM
	order_details o
LEFT JOIN
	menu_items m
ON
	o.item_id = m.menu_item_id
GROUP BY
	item_name,category
ORDER BY
	2;

SELECT
		item_name,COUNT(order_details_id) AS Num_Orders,category
FROM
	order_details o
LEFT JOIN
	menu_items m
ON
	o.item_id = m.menu_item_id
GROUP BY
	item_name,category
ORDER BY
	2 DESC;
    
-- 3.What were the top 5 orders that spent the most money?
SELECT
		order_id,sum(price) AS Total_spend
FROM
	order_details o
LEFT JOIN
	menu_items m
ON
	o.item_id = m.menu_item_id
GROUP BY
	order_id
ORDER BY
	2 DESC
LIMIT 5;

-- 4.View the details of the highest spend order. Which specific items were purchased?
SELECT
		category,COUNT(item_id) as Num_item
FROM
	order_details o
LEFT JOIN
	menu_items m
ON
	o.item_id = m.menu_item_id
WHERE 
	order_id = 440
GROUP BY
	category
ORDER BY 
	2 DESC;

-- 5.View the details of the top 5 highest spend orders.    
SELECT
		order_id,category,COUNT(item_id) as Num_item
FROM
	order_details o
LEFT JOIN
	menu_items m
ON
	o.item_id = m.menu_item_id
WHERE 
	order_id in (440,2075,1957,330,2675)
GROUP BY
	order_id,category;
    
-- 6.How much was the most expensive order in the dataset?
SELECT 
    o.order_id, SUM(m.price) AS total_order_price
FROM
    order_details o
        JOIN
    menu_items m ON o.item_id = m.menu_item_id
GROUP BY o.order_id
ORDER BY total_order_price DESC
LIMIT 1;