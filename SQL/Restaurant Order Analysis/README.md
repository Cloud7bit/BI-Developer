
# Olympic Games Case Study

Taste of the World Café has diverse menu offerings and serves a generous amount of portions.

 At the start of the year they debuted a new menu and they asked me to dig into the customer data to see which menu items are doing well / not  well and what the top customers seem to like best . 

My objectives are :

1.Explore the menu_items  table to get an idea of what’s on the new menu.
2.Explore the order_details table to get an idea of the data that’s been collected.
3.Use both tables to understand how customers are reacting to the new menu.

My job is to use sql to tackle these objectives.

## Tech Stack Used 

MySql

![Image](https://github.com/user-attachments/assets/cfcbe607-2a02-4392-94fc-340c1b5fc37a)

## Database Structure:
The database consists of two table:
- menu_items and
- order_details

------------------------------------------------------ 

### Here are the questions I answered using sql

### Objective_1
#### 1.View the menu_items table.
```sql
SELECT
	*
FROM
	menu_items;
``` 
**Output:**

![Image](https://github.com/user-attachments/assets/2b69ed04-411b-4c6f-812d-f734ac2ad34b)

#### 2.Write a query to find the number of items on the menu.\
```sql
SELECT 
	COUNT(*) AS Number_of_Items
FROM
	menu_items;
```
**Output:**

![Image](https://github.com/user-attachments/assets/ad68aad0-ebe4-489d-8ee6-6f483ee38e67)

#### 3.What are the least and most expensive items on the menu?
```sql
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
```
**Output:**

![Image](https://github.com/user-attachments/assets/be148b60-f63b-4adb-ac8f-43bc84c40d50)

![Image](https://github.com/user-attachments/assets/e39caccd-4a2a-444f-ad19-1facbf4bff48)

#### 4.How many Italian dishes are on the menu?
```sql
SELECT 
	COUNT(*)
FROM 
	menu_items
WHERE
	category = 'Italian';
```
**Output:**

![Image](https://github.com/user-attachments/assets/1316b4a4-1e25-4670-b918-d96f36ccaa88)

#### 5.What are the least and most expensive Italian dishes on the menu?  
```sql
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
```
**Output:**

![Image](https://github.com/user-attachments/assets/3502f477-b87e-4474-8456-6cd6bfb17160)

![Image](https://github.com/user-attachments/assets/adc7a9af-ef6b-46a7-8630-900e7e066620)

#### 6.How many dishes are in each category? 
```sql
SELECT
	category,COUNT(*) as Number_of_Dishes
FROM
	menu_items
GROUP BY 
	category;
```
**Output:**

![Image](https://github.com/user-attachments/assets/a53eef01-0224-4d89-ad14-34629f486fb0)

#### 7.What is the average dish price within each category?
```sql
SELECT
	category,ROUND(AVG(price),2) as AVG_Dish_Price
FROM
	menu_items
GROUP BY 
	category;
```
**Output:**

![Image](https://github.com/user-attachments/assets/3e528c7e-8d03-4851-bcf5-7fa0b6f2b8e3)

### Objective_2
#### 1.View the order_details table.
```sql
SELECT
	*
FROM
	order_details;
```
**Output:**

![Image](https://github.com/user-attachments/assets/b0728252-b346-46b6-8f44-d7926a246b84)

#### 2.What is the date range of the table?
```sql
SELECT
	MIN(order_date) AS min_order_date,MAX(order_date) AS max_order_date
FROM
	order_details;
```
**Output:**

![Image](https://github.com/user-attachments/assets/92013a1d-a6b4-4581-b596-34cecc935abc)

#### 3.How many orders were made within this date range? 
```sql
SELECT
	COUNT(DISTINCT order_id) as orders
FROM 
	order_details;
```
**Output:**

![Image](https://github.com/user-attachments/assets/b453f593-ad4b-4a4d-81ec-df63b2a5bb68)

#### 4.How many items were ordered within this date range?
```sql
SELECT
	COUNT(*) as items
FROM
	order_details;
```
**Output:**

![Image](https://github.com/user-attachments/assets/0298b799-cac6-4ffe-9a32-0e8a20b7ae5b)

#### 5.Which orders had the most number of items?
```sql
SELECT 
	order_id, COUNT(item_id) AS Num_items 
FROM
	order_details
GROUP BY
	order_id
ORDER BY 
	2 DESC;
```
**Output:**

![Image](https://github.com/user-attachments/assets/7438518b-7b77-452f-b829-70b58e13f30d)

#### 6.How many orders had more than 12 items?  
```sql  
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
```
**Output:**

![Image](https://github.com/user-attachments/assets/cc1ad7cf-0164-4df0-bd25-9af6a188062a)

### Objective_3
#### 1.Combine the menu_items and order_details tables into a single table.
```sql    
SELECT
		*
FROM
	order_details o
LEFT JOIN
	menu_items m
ON
	o.item_id = m.menu_item_id;
```
**Output:**

![Image](https://github.com/user-attachments/assets/ff50ea69-d8cd-43fb-a28d-4eedc78f8c16)

#### 2.What were the least and most ordered items? What categories were they in?
```sql
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
``` 
**Output:**

![Image](https://github.com/user-attachments/assets/d0550452-eed6-42ed-8445-de194c78c9e9)

![Image](https://github.com/user-attachments/assets/47af77bb-bef3-4e90-8c78-b0e4a89031fc)

#### 3.What were the top 5 orders that spent the most money?
```sql
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
```
**Output:**

![Image](https://github.com/user-attachments/assets/9b130608-d4a7-46d4-afef-ef3c244aae18)

#### 4.View the details of the highest spend order. Which specific items were purchased?
```sql
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
```
**Output:**

![Image](https://github.com/user-attachments/assets/c77e4020-afd0-499b-a918-b1dd0e311499)

#### 5.View the details of the top 5 highest spend orders. 
```sql   
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
```
**Output:**

![Image](https://github.com/user-attachments/assets/63bf5151-e450-4c02-a8d8-4eb1e466e28d)

#### 6.How much was the most expensive order in the dataset?
```sql
SELECT 
    o.order_id, SUM(m.price) AS total_order_price
FROM
    order_details o
        JOIN
    menu_items m ON o.item_id = m.menu_item_id
GROUP BY o.order_id
ORDER BY total_order_price DESC
LIMIT 1;
```
**Output:**

![Image](https://github.com/user-attachments/assets/9cb627af-e568-4d26-8e05-775de686539e)
