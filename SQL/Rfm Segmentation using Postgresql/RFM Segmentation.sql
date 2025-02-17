--RFM Segementation: Recency, Frequency, and Monetary information based Segmentation of Customers

drop table if exists sales;

create table sales(
    ordernumber INTEGER,
    quantityordered NUMERIC(8, 2),
    priceeach NUMERIC(8, 2),
    orderlinenumber INTEGER,
    sales NUMERIC(8, 2),
    orderdate VARCHAR(16),
    status VARCHAR(16),
    qtr_id SMALLINT,
    month_id SMALLINT,
    year_id INTEGER,
    productline VARCHAR(32),
    msrp NUMERIC(8, 0),
    productcode VARCHAR(16),
    customername VARCHAR(64),
    phone VARCHAR(32),
    addressline1 VARCHAR(64),
    addressline2 VARCHAR(64),
    city VARCHAR(16),
    state VARCHAR(16),
    postalcode VARCHAR(16),
    country VARCHAR(24),
    territory VARCHAR(24),
    contactlastname VARCHAR(16),
    contactfirstname VARCHAR(16),
    dealsize VARCHAR(10)
);

--inspecting data
select *
 from sales limit 10;
 
select count(*)
	from sales; --2823
	
--checking unique values	
select distinct status 
	from sales;	
select distinct year_id 
	from sales;
select distinct productline
	from sales;
select distinct country 
	from sales;
select distinct dealsize 
	from sales;
select distinct territory
 	from sales;
select distinct month_id 
	from sales 
		where year_id=2005
			order by 1;
			
--EDA

--number of unique customers
select count(distinct customername) unique_customers 
		from sales;


--let's start by grouping sales by productline
select ordernumber,orderlinenumber,productline,sales,*
	from sales 
		order by 1,2
		  limit 100;
		  
		  
--Summarize Sales Data	
select 
    count(sales) as total_sales_transactions,
    to_char(round(sum(sales), 0), '$999,999,999') as total_sales_value,
    to_char(round(avg(sales), 0), '$999,999,999') as average_sales_value,
    to_char(round(min(sales), 0), '$999,999,999') as minimum_sales_value,
    to_char(round(max(sales), 0), '$999,999,999') as maximum_sales_value
		from sales;
		
--Calculating total_sales and number of orders by productline		 
select productline,to_char(round(sum(sales), 0), '$999,999,999') total_sales ,count(distinct ordernumber) no_of_orders
	from sales
		group by 1
			order by 3 desc;
			
--Calculating # of orders and total_sales by year
select year_id,count(*) number_of_orders,to_char(round(sum(sales), 0), '$999,999,999') total_sales 
	from sales
		group by 1
			order by 2 desc;
			
--Calculating # of  orders and  total_sales by month
select month_id,count(*) number_of_orders,to_char(round(sum(sales), 0), '$999,999,999') total_sales
		from sales
			group by 1
				order by 1;
				
--Calculating # of orders and total_sales by Quarter
select qtr_id,count(*) number_of_orders,to_char(round(sum(sales), 0), '$999,999,999') total_sales
		from sales
			group by 1
				order by 1;
				
--Calculating total_sales by country
select country,count(*) number_of_orders,to_char(round(sum(sales), 0), '$999,999,999') total_sales
		from sales
			group by 1
				order by 2 desc;
				
--Calculating total_sales by city
select city,count(*) number_of_orders,to_char(round(sum(sales), 0), '$999,999,999') total_sales
		from sales
			group by 1
				order by 2 desc;
				
--Average Order Size (Quantity Ordered)
select round(avg(quantityordered),0) average_order_size 
		from sales;
		
--Orders by Status
select status,count(*) number_of_orders,to_char(round(sum(sales), 0), '$999,999,999') total_sales
	from sales
		group by 1
			order by 2 desc;

--Calculating total_sales by dealsize			
select dealsize,to_char(round(sum(sales), 0), '$999,999,999') total_sales
	from sales
		group by 1
			order by 2 desc;
			
-- What was the best month for sales in a specific year? How much was earned that month?
select month_id,to_char(sum(sales), '$999,999,999') total_sales,count(ordernumber) frequency
	from sales
		where year_id=2004 -- Need to change this value to filter by different years  
			group by 1    
      			order by 2 desc;
				  
--November seems to be the month,what product did they sell in November?
select month_id,productline,to_char(sum(sales), '$999,999,999') total_sales,count(ordernumber) frequency
	from sales 
		where year_id = 2004 and month_id=11 -- Need to change this value to filter by different years and month
			group by 1,2
				order by 3 desc; 

--Top 10 Customers by Sales
select 
    customername, 
     to_char(sum(sales), '$999,999,999')  total_sales 
		from sales
			group by 1
				order by 2 desc
					limit 10;

--Top 10 Products by Sales
select productcode,productline,to_char(sum(sales), '$999,999,999') total_sales 
		from sales
			group by 1,2
				order by 3 desc
					limit 10;

				
--To Convert orderdate from varchar to date we have to use to_date function
select orderdate 
	from sales limit 5;
	
select to_date(orderdate,'DD/MM/YY') date 
	from sales;
	
--Min,max and range of transaction of date	
select max(to_date(orderdate,'DD/MM/YY'))  latest_date	
	from sales; --"2005-05-31"
	
select min(to_date(orderdate,'DD/MM/YY'))  earliest_date
	from sales; --"2003-01-06"

select (max(to_date(orderdate,'DD/MM/YY')) - min(to_date(orderdate,'DD/MM/YY'))) range_of_transaction 
	from sales; -- Range of transaction is 876 days
	
select 
    extract(year from max(to_date(orderdate, 'DD/MM/YY'))) - 
    extract(year from min(to_date(orderdate, 'DD/MM/YY')))  year_difference
		from sales; -- Range of transaction is 2 years
	
-- Rfm segmentation: segmenting your customer basen on Recency(r),Frequency(f), and Monetary(m) scores

drop view rfm_segment;	

create view rfm_segment as
with rfm_cal as (
    select
        customername,
        to_char(round(sum(sales), 0), '$999,999,999')  monetaryvalue,
        count(distinct ordernumber)  frequency,
		max(to_date(orderdate,'DD/MM/YY')) customer_last_transaction_date,
		(select max(to_date(orderdate,'DD/MM/YY')) 
			from sales) business_last_transaction_date,
        -- calculate recency in days
        (select max(to_date(orderdate, 'DD/MM/YY')) from sales) - max(to_date(orderdate, 'DD/MM/YY')) recency
             from sales
			 	group by customername),
				 
rfm_scores as (
    select c.*,
		ntile(4) over(order by c.recency desc) rfm_recency_score,
		ntile(4) over(order by c.frequency) rfm_frequency_score,
		ntile(4) over(order by c.monetaryvalue) rfm_monetary_score
			from rfm_cal c)
			
    select
    s.*,
    (s.rfm_recency_score + s.rfm_frequency_score + s.rfm_monetary_score) total_rfm_score,
    concat(s.rfm_recency_score::varchar, s.rfm_frequency_score::varchar, s.rfm_monetary_score::varchar) rfm_category_combination
		from rfm_scores s; 
	

-- view desiered entries rfm_segment
select rfm_recency_score,rfm_frequency_score,rfm_monetary_score,total_rfm_score,rfm_category_combination
	from rfm_segment;

-- view distinct rfm category combinations
select distinct rfm_category_combination
 from rfm_segment
  order by 1;

-- categorize customers based on rfm category combination 
select customername,
    case
        when rfm_category_combination in ('111', '112', '121', '123', '132', '211', '212', '114', '141') then 'churned customer'
        when rfm_category_combination in ('133', '134', '143', '244', '334', '343', '344', '144') then 'slipping away, cannot lose'
        when rfm_category_combination in ('311', '411', '331') then 'new customers'
        when rfm_category_combination in ('222', '231', '221', '223', '233', '322') then 'potential churners'
        when rfm_category_combination in ('323', '333', '321', '341', '422', '332', '432') then 'active'
        when rfm_category_combination in ('433', '434', '443', '444') then 'loyal'
        else 'cannot be defined'
   	    end as customer_segment
			from rfm_segment;
	















