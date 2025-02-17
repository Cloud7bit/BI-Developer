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

select * 
	from retail
	where customerid is null;


select count(*)	
	from retail; -- 10,83,818

--Remove Bad Records
--Filter the resultset to exclude records where the customerID is blank. 
select *
    from retail
			where customerid is not null; -- 8,13,658

--Check for Duplicate Rows
--Utilize Common Table Expressions (CTE's), and apply a query to filter for the relevant records.
--Pass clean data to a temp table		

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


--COHORT ANALYSIS
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


--Calculate Cohort Index
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

select * 
	from cohorts_retention
		where customerid=17850
			order by invoiceno;		

--Retrieve the unique customerID, cohort date and cohort index from cohorts_retention
--Pass the above query into the PIVOT operator
--Pass the query into a temp table cohort_pivot

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

-- Cohort analysis on revenue level
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


-- Cohort Analysis in SQL for Order level
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

-- The following code will show cohort retention on order levels
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





