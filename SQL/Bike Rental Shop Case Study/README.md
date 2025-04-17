
# Bike Rental Shop Case Study Using Postgresql

In this project, I worked as a Data Analyst for Emily, the owner of a bike shop. I utilized SQL to analyze and extract key insights from the shop's database, addressing business questions like the total number of bikes owned by category and the monthly rental revenue. This data-driven approach provided Emily with valuable insights to support her business growth strategies.

## Tech Stack Used 

Postgresql

![sql-server](https://github.com/user-attachments/assets/459cb5aa-236a-4aaa-b29a-41b648e446fa)

## Data Source
The dataset can be accessed on learnsql via this [link](https://learnsql.com/log-in/?redirect=/course/2023-advanced-sql-practice-challenges/november-challenge/introduction/introduction/)

## Database Structure:
The Shop’s database consists of 5 tables :
- Customer
- Bike
- Rental
- Membership_type
- Membership

## Following are the business questions that Emily wants answers to. 
- Emily would like to know how many bikes the shop owns by category. 
```sql
SELECT 
    category, COUNT(*) AS number_of_bikes
FROM
    bike
GROUP BY category;

```
**Output:**

![1](https://github.com/user-attachments/assets/ea6e5e97-eadf-45ab-8c97-3bab89155424)

------------------------------------------------------ 

- Emily needs a list of customer names with the total number of memberships purchased by each.

```sql
SELECT 
    c.name, COUNT(m.id) AS membership_count
FROM
    membership m
        RIGHT JOIN
    customer c ON m.customer_id = c.id
GROUP BY 1
ORDER BY 2 DESC;
```
**Output:**

![2](https://github.com/user-attachments/assets/ca84e559-62d1-4a28-9892-2a679a019c11)

------------------------------------------------------ 

- Emily is working on a special offer for the winter months. She needs help to prepare a list of new rental prices?
Electric bikes should have a 10% discount for hourly rentals and a 20% discount for daily rentals. Mountain bikes should have a 20% discount for hourly rentals and a 
50% discount for daily rentals. All other bikes should have a 50% discount for all types of rentals.


```sql
SELECT 
    id,
    category,
    price_per_hour AS old_price_per_hour,
    CASE
        WHEN
            category = 'electric'
        THEN
            ROUND(price_per_hour - (price_per_hour * 0.1),
                    2)
        WHEN
            category = 'mountain bike'
        THEN
            ROUND(price_per_hour - (price_per_hour * 0.5),
                    2)
        ELSE ROUND(price_per_hour - (price_per_hour * 0.5),
                2)
    END AS new_price_per_hour,
    price_per_day AS old_price_per_day,
    CASE
        WHEN category = 'electric' THEN ROUND(price_per_day - (price_per_day * 0.1), 2)
        WHEN category = 'mountain bike' THEN ROUND(price_per_day - (price_per_day * 0.5), 2)
        ELSE ROUND(price_per_day - (price_per_day * 0.5), 2)
    END AS new_price_per_day
FROM
    bike;
```            
**Output:**

![3](https://github.com/user-attachments/assets/649eab7d-d147-4963-9fa2-6a61c0af7b3d)

------------------------------------------------------ 

- Emily is looking for counts of the rented bikes and of the available bikes in each category.


```sql 
SELECT 
    category,
    COUNT(CASE
        WHEN status = 'available' THEN 1
    END) AS available_bikes_count,
    COUNT(CASE
        WHEN status = 'rented' THEN 1
    END) AS rented_bikes_count
FROM
    bike
GROUP BY category;
```  
**Output:**

![4](https://github.com/user-attachments/assets/9f3041d4-c916-4525-9fa0-14cb74eaca95)

------------------------------------------------------ 
- Emily is preparing a sales report. She needs to know the total revenue from rentals by month, the total by year, and the all-time across all the years. 
```sql 
SELECT 
    EXTRACT(YEAR FROM start_timestamp) AS year,
    EXTRACT(MONTH FROM start_timestamp) AS month,
    SUM(total_paid) AS revenue
FROM
    rental
GROUP BY GROUPING SETS ( (year, month) , (year) , () )
ORDER BY year , month;
```
**Output:**

![5](https://github.com/user-attachments/assets/96e3ad3a-603f-4a91-bae5-9b6285747d4f)

------------------------------------------------------ 

-  Emily has asked me to get the total revenue from memberships for each combination of year, month, and membership type.


```sql
SELECT 
    EXTRACT(YEAR FROM start_date) AS year,
    EXTRACT(MONTH FROM start_date) AS month,
    mt.name AS membership_type_name,
    SUM(total_paid) AS total_revenue
FROM
    membership m
        LEFT JOIN
    membership_type mt ON m.membership_type_id = mt.id
GROUP BY year , month , mt.name
ORDER BY year , month , mt.name;
```
**Output:**

![6](https://github.com/user-attachments/assets/2bcf675b-f7dd-4104-b480-a74bd3d8ddf5)

------------------------------------------------------ 

- Next, Emily would like data about memberships purchased in 2023, with subtotals and grand totals for all the different combinations of membership types and months


```sql
SELECT 
    mt.name AS membership_type_name,
    EXTRACT(MONTH FROM start_date) AS month,
    SUM(total_paid) AS total_revenue
FROM
    membership m
        JOIN
    membership_type mt ON m.membership_type_id = mt.id
WHERE
    EXTRACT(YEAR FROM start_date) = 2023
GROUP BY CUBE (membership_type_name , month)
ORDER BY membership_type_name , month;
```
**Output:**

![7](https://github.com/user-attachments/assets/595630f6-9182-43db-a4f3-ac5987b53be2)
------------------------------------------------------ 

- Now it's time for the final task.
Emily wants to segment customers based on the number of rentals and see the count of customers in 
each segment

```sql
WITH cte AS (
	SELECT 
		customer_id,COUNT(*),
		CASE WHEN COUNT(*)>10 THEN 'more than 10' 
		 WHEN COUNT(*) BETWEEN 5 AND 10 THEN 'between 5 and 10'
		 ELSE 'fewer than 5' 
		 END AS category
	FROM 
		rental 
	GROUP BY customer_id
)
SELECT 
	category AS rental_count_category ,
    COUNT(*) AS customer_count 
FROM 
	cte 
GROUP BY category
ORDER BY customer_count;

```
**Output:**
![8](https://github.com/user-attachments/assets/ae7a4d15-6f02-449b-a8cd-2062251d6800)

------------------------------------------------------

