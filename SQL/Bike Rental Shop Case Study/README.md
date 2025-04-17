
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

| Category      | Number of Bikes |
|---------------|----------------|
| Road bike     | 3              |
| Electric      | 2              |
| Mountain bike | 3              |
| Hybrid        | 2              |


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

| Name           | Membership Count |
|----------------|------------------|
| Alice Smith    | 3                |
| Bob Johnson    | 3                |
| John Doe       | 2                |
| Eva Brown      | 2                |
| Michael Lee    | 2                |
| Daniel Miller  | 0                |
| Sarah White    | 0                |
| Olivia Taylor  | 0                |
| David Wilson   | 0                |
| Emily Davis    | 0                |


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

| id | Category      | Old Price per Hour | New Price per Hour | Old Price per Day | New Price per Day |
|----|--------------|--------------------|--------------------|-------------------|-------------------|
| 1  | mountain bike| 10.00              | 5.00               | 50.00             | 25.00             |
| 2  | road bike    | 12.00              | 6.00               | 60.00             | 30.00             |
| 3  | hybrid       | 8.00               | 4.00               | 40.00             | 20.00             |
| 4  | electric     | 15.00              | 13.50              | 75.00             | 67.50             |
| 5  | mountain bike| 10.00              | 5.00               | 50.00             | 25.00             |
| 6  | road bike    | 12.00              | 6.00               | 60.00             | 30.00             |
| 7  | hybrid       | 8.00               | 4.00               | 40.00             | 20.00             |
| 8  | electric     | 15.00              | 13.50              | 75.00             | 67.50             |
| 9  | mountain bike| 10.00              | 5.00               | 50.00             | 25.00             |
| 10 | road bike    | 12.00              | 6.00               | 60.00             | 30.00             |

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

| Category      | Available Bikes Count | Rented Bikes Count |
|--------------|----------------------|--------------------|
| road bike    | 3                    | 0                  |
| electric     | 2                    | 0                  |
| mountain bike| 1                    | 1                  |
| hybrid       | 0                    | 1                  |


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

| Year | Month | Revenue |
|------|-------|---------|
| 2022 | 11    | 200.00  |
| 2022 | 12    | 150.00  |
| 2022 |       | 350.00  |
| 2023 | 1     | 110.00  |
| 2023 | 2     | 40.00   |
| 2023 | 3     | 110.00  |
| 2023 | 4     | 90.00   |
| 2023 | 5     | 120.00  |
| 2023 | 6     | 115.00  |
| 2023 | 7     | 150.00  |
| 2023 | 8     | 125.00  |
| 2023 | 9     | 175.00  |
| 2023 | 10    | 335.00  |
| 2023 |       | 1370.00 |
|      |       | 1720.00 |



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

| Year | Month | Membership Type Name | Total Revenue |
|------|-------|---------------------|---------------|
| 2023 | 8     | Basic Annual        | 500.00        |
| 2023 | 8     | Basic Monthly       | 100.00        |
| 2023 | 8     | Premium Monthly     | 200.00        |
| 2023 | 9     | Basic Annual        | 500.00        |
| 2023 | 9     | Basic Monthly       | 100.00        |
| 2023 | 9     | Premium Monthly     | 200.00        |
| 2023 | 10    | Basic Annual        | 500.00        |
| 2023 | 10    | Basic Monthly       | 100.00        |
| 2023 | 10    | Premium Monthly     | 200.00        |
| 2023 | 11    | Basic Annual        | 500.00        |
| 2023 | 11    | Basic Monthly       | 100.00        |
| 2023 | 11    | Premium Monthly     | 200.00        |


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

| Membership Type Name | Month | Total Revenue |
|----------------------|-------|---------------|
| Basic Annual         | 8     | 500.00        |
| Basic Annual         | 9     | 500.00        |
| Basic Annual         | 10    | 500.00        |
| Basic Annual         | 11    | 500.00        |
| Basic Annual         |       | 2000.00       |
| Basic Monthly        | 8     | 100.00        |
| Basic Monthly        | 9     | 100.00        |
| Basic Monthly        | 10    | 100.00        |
| Basic Monthly        | 11    | 100.00        |
| Basic Monthly        |       | 400.00        |
| Premium Monthly      | 8     | 200.00        |
| Premium Monthly      | 9     | 200.00        |
| Premium Monthly      | 10    | 200.00        |
| Premium Monthly      | 11

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
| Rental Count Category | Customer Count |
|----------------------|---------------|
| between 5 and 10     | 1             |
| more than 10         | 1             |
| fewer than 5         | 8             |


------------------------------------------------------

