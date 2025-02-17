
# Cohort Analysis Using Postgresql

In this project, I performed an analysis of an online retail dataset by conducting a retention cohort analysis using SQL. A cohort refers to a group of individuals who share a common experience during a defined time period. Cohort analysis is a powerful technique for uncovering actionable insights about customer churn, product engagement, product value, and other key metrics. Whether applied to different technologies or domains, cohort analysis offers strong data evaluation capabilities for making informed decisions.

I will use a range of SQL techniques to:

- Handle missing values
- Extract the month from a date
- Assign a cohort to each transaction
- Assign a cohort index to every transaction
- Create a cohort table to calculate retention rates
- Create a cohort table to calculate churn rates
- Create a cohort table to calculate retention on revenue lavel
- Create a cohort table to calculate retention on order lavel
- Interpret the retention rate

## Tech Stack Used 

Postgresql

![sql-server](https://github.com/user-attachments/assets/459cb5aa-236a-4aaa-b29a-41b648e446fa)

## Data Source
The dataset can be accessed on Kaggle via this [link](https://www.kaggle.com/datasets/kashyapankush/online-retail-store-dataset)

## Procedure and Sql code is given below : 


- First I created a table into which I can import the dataset.

```sql
create schema cohort_analysis;
set search_path to cohort_analysis;
create table retail (
    invoiceno varchar(10),
    stockcode varchar(20),
    description varchar(200),
    quantity numeric(8,2),
    invoicedate varchar(25),
    unitprice numeric(8,2),
    customerid bigint,
    country varchar(25)
);

```
------------------------------------------------------ 

- Now that the data has been imported  let's select all the columns and inspect our records.

```sql
select * 
	from retail
         	limit 10;

select count(*)	
	from retail; --  5,41,909


select * 
	from retail
	where customerid is null;
```
**Output:**

![1](https://github.com/user-attachments/assets/b7ee0be6-36c6-45e8-aefb-a9f1da65fa99)
![2](https://github.com/user-attachments/assets/7d2736a6-23fd-41c9-bcc6-aa7c818b2dd4)
![2](https://github.com/user-attachments/assets/3d828acf-e5ce-4a9f-84ec-820122bb8931)

The dataset comprises of 10,83,818 rows and 8 columns.There are a number of missing records in the customerID column.So my first task was to handle the missing data by filtering the result set to exclude records where the customerID is null.

------------------------------------------------------ 

- Filter the resultset to exclude records where the customerID is blank. 

```sql
select *
	from retail
	where customerid is not null; --8,13,658
```            
**Output:**

![4](https://github.com/user-attachments/assets/2ff2b65a-a714-447b-8ba1-1be902e11144)

The filtered result set contains 8,13,658 records. In order to narrow the focus to the most relevant records, we will filter the records to only include those where the unit price and quantity is greater than zero.

------------------------------------------------------ 

- Checking for Duplicate Rows.Utilizing Common Table Expressions (CTE's), and apply a query to filter for the relevant records and Passing the  clean data to a temporary table	.

```sql  
-- Create a Common Table Expression (CTE) to filter and check for duplicates
drop table if exists retail_clean;

with retail as (
    -- select records where customerid is not null
    select 
        *
    	from retail
    		where customerid is not null
),
quantity_unit_price as (
    -- select records with valid quantity and unitprice values
    select
        *
    	from retail
    		where quantity > 0 and unitprice > 0
),
dup_check as (
    -- check for duplicate rows using row_number() partitioned by invoiceno, stockcode, and quantity
    select 
        *, 
        row_number() over (partition by invoiceno, stockcode, quantity order by invoicedate::date) as dup
    		from quantity_unit_price
)
-- insert the clean data (non-duplicate rows) into a temporary table
select 
    *
	into temp table retail_clean
		from dup_check
			where dup = 1;

--Retrieve all records from the retail_clean temp table

select *
	from retail_clean; --3,92,666

```  
**Output:**

![5](https://github.com/user-attachments/assets/5262c1f0-60ca-4275-b350-48cfc8969fa4)

The retail cte filters the retail dataset, excluding rows where customerid is NULL, meaning only records with valid customer IDs are kept.The quantity_unit_price cte filters the dataset further to retain only records with positive quantity and unitprice. Any rows with non-positive values for these fields are removed, ensuring data integrity.The dup_check cte uses the ROW_NUMBER() window function to check for duplicate rows.The partition by invoiceno, stockcode, quantity clause groups the data by these columns.
The order by invoicedate::date orders the rows within each group by the invoice date.The ROW_NUMBER() function assigns a unique row number to each row within its partition. The first occurrence of each duplicate group gets dup = 1, and any duplicates get higher numbers.Then we select only the rows where dup = 1 (the first occurrence, i.e., the non-duplicate rows) and inserts them into a temporary table called retail_clean.

With the data now cleaned and stored in a temporary table, it can be easily accessed and retrieved for further analysis. Specifically, this data can be utilized for conducting a cohort analysis.

------------------------------------------------------ 
- Now we can proceed to conduct Cohort Analysis
```sql 
--The unique identifier (CustomerID) will be obtained and linked to the date of the first purchase (First Invoice Date).
--Pass data into a temp table (cohort)
drop table if exists cohort;

select
    customerid,
    min(invoicedate::date) as first_purchase_date,
    -- Creates a cohort date based on the year and month of the customer's first purchase,setting day to 1
	-- make_date(year, month, 1): Constructs a new date using the extracted year and month, but sets the day to 1. 
	-- This means the cohort date will always be the first day of the month in which the first purchase occurred.
    make_date(extract(year from min(invoicedate::date))::int, extract(month from min(invoicedate::date))::int, 1) as cohort_date
		into temp table cohort
			from retail_clean
				group by customerid;
		
select * 
	from Cohort
		order by cohort_date
            limit 10;

```
**Output:**

![6](https://github.com/user-attachments/assets/dff243a8-6082-4731-badf-494e34214975)

In the initial cohort analysis, we’ll first identify each customer by their unique ID (CustomerID) and link it to the date they made their first purchase. Then, we’ll assign each customer a cohort date, which is simply the first day of the month when they made that first purchase.

------------------------------------------------------ 

- Now I will calculate Cohort Index.A cohort index is an integer representation of the number of months that has passed since a customer's first engagement.

```sql
--Join the retail_clean and cohort tables on CustomerID. 
--Retrieve the invoice dates and the cohort dates from each table
--Common Table Expression (CTE) to join online_retail_clean and cohort tables on CustomerID
drop table if exists cohorts_retention;

with cte as (
    select
        o.*,
        c.cohort_date,
        extract(year from o.invoicedate::date) as invoice_year,
        extract(month from o.invoicedate::date) as invoice_month,
        extract(year from c.cohort_date) as cohort_year,
        extract(month from c.cohort_date) as cohort_month,
		round(o.quantity * o.unitprice, 2) as revenue 
	    from retail_clean as o
	    	left join cohort as c
	    		on o.customerid = c.customerid
),
cte2 as (
    -- derive the year_diff and month_diff columns
	-- cte2 calculates the difference between the transaction date and the cohort date in terms of years and months.
	-- these two columns (year_diff and month_diff) represent the time difference between when the customer made their first purchase 
	-- and when the transaction occurred.
    select 
        cte.*,
        (invoice_year - cohort_year) as year_diff,
        (invoice_month - cohort_month) as month_diff
    		from cte
)
-- calculate cohort index and insert into temporary table 'cohorts_retention'
select 
    cte2.*,
    (year_diff * 12 + month_diff + 1) as cohort_index
		into temp table cohorts_retention
			from cte2;

--Select all columns from cohorts_retention temp table
select *
	from cohorts_retention
		order by cohort_date ;
```
**Output:**

![7](https://github.com/user-attachments/assets/4448f8c8-2693-487a-9930-cb1f5743394e)

This CTE, named cte, joins the retail_clean and cohort tables based on CustomerID. It retrieves all the records (o.*) from retail_clean and also fetches the cohort_date from the cohort table.It then extracts the year and month from the invoicedate (the transaction date) and the cohort_date (the customer's purchase month).Additionally, it calculates the revenue for each transaction by multiplying quantity by unitprice, rounding the result to two decimal places.This second CTE, cte2, calculates the time difference between the invoice date and the cohort date:year_diff: The difference in years between the transaction year (invoice_year) and the cohort year (cohort_year).month_diff: The difference in months between the transaction month (invoice_month) and the cohort month (cohort_month).This final part calculates the cohort index, which indicates how many months have passed since the customer's first purchase.

**cohort_index = (year_diff * 12 + month_diff + 1)** .

This formula converts the year_diff into months, adds the month_diff, and adds 1 to make the cohort index start at 1 (the first month).The result, along with all other columns from cte2, is inserted into a temporary table called cohorts_retention.

------------------------------------------------------ 

- Now that I have the cohort index number, the next step is to use the temporary table to create a pivot table. This temporary pivot table will display cohort retention across different levels for further analysis.

```sql
-- Cohort analysis on customer level
create extension if not exists tablefunc;

drop table if exists cohort_pivot1;

create temporary table cohort_pivot1 as 
select *
from crosstab(
    $$
    select 
        cohort_date,  -- this will be the row identifier
        cohort_index,  -- this will be used as the pivot column (1, 2, 3,...)
        count(customerid) as customer_count -- this is the value to aggregate (count of customerid)
	from cohorts_retention
    group by cohort_date, cohort_index
    order by cohort_date, cohort_index
    $$,
    -- provide the list of cohort indexes that you want as columns (1-13)
    $$values (1), (2), (3), (4), (5), (6), (7), (8), (9), (10), (11), (12), (13)$$
) as pivot_table(
    cohort_date date, 
    cohort_1 int, 
    cohort_2 int, 
    cohort_3 int, 
    cohort_4 int, 
    cohort_5 int, 
    cohort_6 int, 
    cohort_7 int, 
    cohort_8 int, 
    cohort_9 int, 
    cohort_10 int, 
    cohort_11 int, 
    cohort_12 int, 
    cohort_13 int
);

```
------------------------------------------------------ 

- Now using the above cohort_pivot1 table I will conduct cohort retention on customer level.

```sql
--the following code will show customer count per month

select
    cohort_date,
    cohort_1 as customer_count_1,
    cohort_2 as customer_count_2,
    cohort_3 as customer_count_3,
    cohort_4 as customer_count_4,
    cohort_5 as customer_count_5,
    cohort_6 as customer_count_6,
    cohort_7 as customer_count_7,
    cohort_8 as customer_count_8,
    cohort_9 as customer_count_9,
    cohort_10 as customer_count_10,
    cohort_11 as customer_count_11,
    cohort_12 as customer_count_12,
    cohort_13 as customer_count_13
		from cohort_pivot1;
```
**Output:**

![9](https://github.com/user-attachments/assets/0a44b155-85d0-4055-b953-a0c2cab400bf)

The resulting table provides insight on the number of customers who have continued to use a product or service over time, which can be further analyzed through the calculation of retention rates.

------------------------------------------------------

- Using the above cohort_pivot1 table I will now show the retention rate on customer level
```sql
--the following code will show retentation rate
select
    cohort_date,
    round(1.0 * cohort_1 / cohort_1 * 100, 2) || '%' as cohort_1_rate,
    round(1.0 * cohort_2 / cohort_1 * 100, 2) || '%' as cohort_2_rate,
    round(1.0 * cohort_3 / cohort_1 * 100, 2) || '%' as cohort_3_rate,
    round(1.0 * cohort_4 / cohort_1 * 100, 2) || '%' as cohort_4_rate,
    round(1.0 * cohort_5 / cohort_1 * 100, 2) || '%' as cohort_5_rate,
    round(1.0 * cohort_6 / cohort_1 * 100, 2) || '%' as cohort_6_rate,
    round(1.0 * cohort_7 / cohort_1 * 100, 2) || '%' as cohort_7_rate,
    round(1.0 * cohort_8 / cohort_1 * 100, 2) || '%' as cohort_8_rate,
    round(1.0 * cohort_9 / cohort_1 * 100, 2) || '%' as cohort_9_rate,
    round(1.0 * cohort_10 / cohort_1 * 100, 2) || '%' as cohort_10_rate,
    round(1.0 * cohort_11 / cohort_1 * 100, 2) || '%' as cohort_11_rate,
    round(1.0 * cohort_12 / cohort_1 * 100, 2) || '%' as cohort_12_rate,
    round(1.0 * cohort_13 / cohort_1 * 100, 2) || '%' as cohort_13_rate
from cohort_pivot1;	
```
**Output:**

![10](https://github.com/user-attachments/assets/e0e5f777-913d-4a25-b6f2-dbc9208c6a89)

The resulting table provides insight on the retention rate of customers who have continued to use a product or service over time.

------------------------------------------------------

- Now I will conduct churned Cuatomer count  per month using cohort_pivot1 table
```sql
-- the following code will show customer churn count by customer count

select
    cohort_date,
-- For each cohort, we calculate churn as the difference between the 
-- number of customers in one cohort and the number of customers in the next cohort (i.e., cohort_n - cohort_(n+1)).
    abs(cohort_1 - cohort_2) as churn_cohort_1,
    abs(cohort_2 - cohort_3) as churn_cohort_2,
    abs(cohort_3 - cohort_4) as churn_cohort_3,
    abs(cohort_4 - cohort_5) as churn_cohort_4,
    abs(cohort_5 - cohort_6) as churn_cohort_5,
    abs(cohort_6 - cohort_7) as churn_cohort_6,
    abs(cohort_7 - cohort_8) as churn_cohort_7,
    abs(cohort_8 - cohort_9) as churn_cohort_8,
    abs(cohort_9 - cohort_10) as churn_cohort_9,
    abs(cohort_10 - cohort_11) as churn_cohort_10,
    abs(cohort_11 - cohort_12) as churn_cohort_11,
    abs(cohort_12 - cohort_13) as churn_cohort_12
	from cohort_pivot1
		order by cohort_date;
```
**Output:**

![11](https://github.com/user-attachments/assets/40fec1de-5b01-4c8e-8617-daee4740873f)

The resulting table provides insight on the number of customers who have stopped  using our product or service over time.

------------------------------------------------------

- Now I will conduct churned Cuatomer Rate per month using cohort_pivot1 table
```sql
-- the following code will show customer churn rate per month
-- abs(cohort_n - cohort_(n+1)) / cohort_n * 100 to give the churn rate per cohort.
select cohort_date,
    round(abs(cohort_1 - cohort_2) / cohort_1::numeric * 100, 2) || '%' as churn_1,
    round(abs(cohort_2 - cohort_3) / cohort_2::numeric * 100, 2) || '%' as churn_2,
    round(abs(cohort_3 - cohort_4) / cohort_3::numeric * 100, 2) || '%' as churn_3,
    round(abs(cohort_4 - cohort_5) / cohort_4::numeric * 100, 2) || '%' as churn_4,
    round(abs(cohort_5 - cohort_6) / cohort_5::numeric * 100, 2) || '%' as churn_5,
    round(abs(cohort_6 - cohort_7) / cohort_6::numeric * 100, 2) || '%' as churn_6,
    round(abs(cohort_7 - cohort_8) / cohort_7::numeric * 100, 2) || '%' as churn_7,
    round(abs(cohort_8 - cohort_9) / cohort_8::numeric * 100, 2) || '%' as churn_8,
    round(abs(cohort_9 - cohort_10) / cohort_9::numeric * 100, 2) || '%' as churn_9,
    round(abs(cohort_10 - cohort_11) / cohort_10::numeric * 100, 2) || '%' as churn_10,
    round(abs(cohort_11 - cohort_12) / cohort_11::numeric * 100, 2) || '%' as churn_11,
    round(abs(cohort_12 - cohort_13) / cohort_12::numeric * 100, 2) || '%' as churn_12
		from cohort_pivot1
			order by cohort_date;
```            
**Output:**

![12](https://github.com/user-attachments/assets/5f6867f2-63a6-4369-9c1b-7e12b4577279)

The resulting table provides insight on the Churn Rate of customers who have stopped  using our product or service over time.

------------------------------------------------------

- Next, I will perform cohort analysis based on revenue. To do this, I’ll adjust the pivot table so that the columns display revenue figures for each cohort.
```sql 
drop table if exists cohort_pivot2;

create temporary table cohort_pivot2 as 
select *
from crosstab(
    $$
    select 
        cohort_date,  -- this will be the row identifier
        cohort_index,  -- this will be used as the pivot column (1, 2, 3,...)
        sum(revenue) as total_revenue  -- this is the value to aggregate (sum of revenue)
    from cohorts_retention
    group by cohort_date, cohort_index
    order by cohort_date, cohort_index
    $$,
    -- provide the list of cohort indexes that you want as columns (1-13)
    $$values (1), (2), (3), (4), (5), (6), (7), (8), (9), (10), (11), (12), (13)$$
) as pivot_table(
    cohort_date date, 
    revenue_1 numeric, 
    revenue_2 numeric, 
    revenue_3 numeric, 
    revenue_4 numeric, 
    revenue_5 numeric, 
    revenue_6 numeric, 
    revenue_7 numeric, 
    revenue_8 numeric, 
    revenue_9 numeric, 
    revenue_10 numeric, 
    revenue_11 numeric, 
    revenue_12 numeric, 
    revenue_13 numeric
);
```
------------------------------------------------------

- Now I will calculate cohort retention on revenue level using cohort_pivot2 table
```sql
-- the following code will show cohort retentation on revenue levels
select
    cohort_date,
    to_char(revenue_1, '$999,999.99') as ret_rev_1,
    to_char(revenue_2, '$999,999.99') as ret_rev_2,
    to_char(revenue_3, '$999,999.99') as ret_rev_3,
    to_char(revenue_4, '$999,999.99') as ret_rev_4,
    to_char(revenue_5, '$999,999.99') as ret_rev_5,
    to_char(revenue_6, '$999,999.99') as ret_rev_6,
    to_char(revenue_7, '$999,999.99') as ret_rev_7,
    to_char(revenue_8, '$999,999.99') as ret_rev_8,
    to_char(revenue_9, '$999,999.99') as ret_rev_9,
    to_char(revenue_10, '$999,999.99') as ret_rev_10,
    to_char(revenue_11, '$999,999.99') as ret_rev_11,
    to_char(revenue_12, '$999,999.99') as ret_rev_12,
    to_char(revenue_13, '$999,999.99') as ret_rev_13
from cohort_pivot2;

```
**Output:**

![13](https://github.com/user-attachments/assets/49c4614a-1859-4108-9f89-8261c24af877)

The resulting table provides insight about retention on Revenue level .

------------------------------------------------------

- Next, I will perform cohort analysis based on order. To do this, I’ll adjust the pivot table so that the columns display revenue figures for each cohort.

```sql
drop table if exists cohort_pivot3

create temporary table cohort_pivot3 as 
select *
from crosstab(
    $$
    select 
        cohort_date,  -- this will be the row identifier
        cohort_index,  -- this will be used as the pivot column (1, 2, 3,...)
        count(distinct invoiceno) as total_orders  -- this will count distinct invoices (orders)
    from cohorts_retention
    group by cohort_date, cohort_index
    order by cohort_date, cohort_index
    $$,
    -- Provide the list of cohort indexes that you want as columns (1-13)
    $$values (1), (2), (3), (4), (5), (6), (7), (8), (9), (10), (11), (12), (13)$$
) as pivot_table(
    cohort_date date, 
    orders_1 int, 
    orders_2 int, 
    orders_3 int, 
    orders_4 int, 
    orders_5 int, 
    orders_6 int, 
    orders_7 int, 
    orders_8 int, 
    orders_9 int, 
    orders_10 int, 
    orders_11 int, 
    orders_12 int, 
    orders_13 int
);
```
------------------------------------------------------

- Now using the above cohort_pivot3 table I will conduct retention on order level
```sql
select
    cohort_date,
    orders_1 as ret_orders_1,
    orders_2 as ret_orders_2,
    orders_3 as ret_orders_3,
    orders_4 as ret_orders_4,
    orders_5 as ret_orders_5,
    orders_6 as ret_orders_6,
    orders_7 as ret_orders_7,
    orders_8 as ret_orders_8,
    orders_9 as ret_orders_9,
    orders_10 as ret_orders_10,
    orders_11 as ret_orders_11,
    orders_12 as ret_orders_12,
    orders_13 as ret_orders_13
from cohort_pivot3;
```
**Output:**

![14](https://github.com/user-attachments/assets/089e36db-5018-4590-8086-147da319c7a3)

The resulting table provides insight about retention on Order level .

