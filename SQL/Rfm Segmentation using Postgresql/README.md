
# RFM Marketing Analysis Using Postgresql

## What's RFM Analysis?
**RFM** Stands for **Recency**, **Frequency** and **Monetary** which is a form of analysis often used in Marketing which segments customers based on those 3 factors.
## Objectives
- To collect transaction data
- To calculate RFM scores
- To carry out segmentation from RFM scores
- To carry out segment analysis
- To determine which customers to target from our new customer list

## Questions that I tried to answer in this project:
- What's the total number of unique customers, orders and total sales,avg.sales,maximum and minimum Sales
- Total orders and revenue made based on time intervals(i.e by year, quater and  month)
- Top 10 Customers by Sales
- Top 10 Products by  Sales
- Some basic EDA
- Segmenting customers based on their **recent paid order**, **order frequency** and **how much s/he pays** 

  ------------------------------------------------------

```sql
--Number of unique customers
select count(distinct customername) unique_customers 
		from sales;
```
**Output:**   

 ![Unique customers](https://github.com/user-attachments/assets/a5f829dd-2865-47d3-a5d0-833224dbeced)
------------------------------------------------------

 ```sql
--Summarize Sales Data	
select 
    count(sales) as total_sales_transactions,
    to_char(round(sum(sales), 0), '$999,999,999') as total_sales_value,
    to_char(round(avg(sales), 0), '$999,999,999') as average_sales_value,
    to_char(round(min(sales), 0), '$999,999,999') as minimum_sales_value,
    to_char(round(max(sales), 0), '$999,999,999') as maximum_sales_value
		from sales;
 ```
 **Output:**  
 ![summarize sales data](https://github.com/user-attachments/assets/63ac2ae3-9224-4bb7-a21b-b1abd1b517ba)
------------------------------------------------------
 
 ```sql
 --Calculating total_sales and number of orders by productline		 
select productline,to_char(round(sum(sales), 0), '$999,999,999') total_sales ,count(distinct ordernumber) no_of_orders
	from sales
		group by 1
			order by 3 desc;
 ```
 **Output:**
 ![productline](https://github.com/user-attachments/assets/d5600f47-b72a-4fbf-bb76-0248421cd216)
------------------------------------------------------

 ```sql
--Calculating # of orders and total_sales by year
select year_id,count(*) number_of_orders,to_char(round(sum(sales), 0), '$999,999,999') total_sales
	from sales
		group by 1
			order by 2 desc;
 ```
 **Output:**
 ![sales by year](https://github.com/user-attachments/assets/0b9daddc-08a1-4c10-bde3-845eb00b8f84)
------------------------------------------------------

```sql
--Calculating # of  orders and  total_sales by month_id
select month_id,count(*) number_of_orders,to_char(round(sum(sales), 0), '$999,999,999') revenue
		from sales
			group by 1
				order by 1;
 ```
 **Output:**
 ![sales by month](https://github.com/user-attachments/assets/d45a4eba-3786-4ebf-a8ad-dac56e29e5e5)
------------------------------------------------------

 ```sql
--Calculating # of orders and sales by Quarter
select qtr_id,count(*) number_of_orders,to_char(round(sum(sales), 0), '$999,999,999') total_sales
		from sales
			group by 1
				order by 1;
 ```
 **Output:**
 ![sales by quater](https://github.com/user-attachments/assets/77858b3c-d5a3-449b-8e01-d8d273f82987)
------------------------------------------------------

 ```sql
--Average Order Size (Quantity Ordered)
select round(avg(quantityordered),0) average_order_size 
		from sales;
 ```
 **Output:**
 ![Average Order Size (Quantity Ordered)](https://github.com/user-attachments/assets/18445f33-f312-4f1b-8c67-c2b31170401c)
------------------------------------------------------

```sql
--Orders by Status
select status,count(*) number_of_orders,to_char(round(sum(sales), 0), '$999,999,999') total_sales
	from sales
		group by 1
			order by 2 desc;
```
**Output:**
![sales by status](https://github.com/user-attachments/assets/351176a8-556f-4d7d-9986-6a344544c463)
------------------------------------------------------

```sql
-- What was the best month for sales in a specific year? How much was earned that month?
select month_id,TO_CHAR(SUM(sales), '$999,999,999') total_sales, count(ordernumber) frequency
	from sales
		where year_id=2004 -- Need to change this value to filter by different years  
			group by 1    
      			order by 2 desc;
```
**Output:**
![best month for sales](https://github.com/user-attachments/assets/a439ffbd-2245-475e-bdba-3d93f0a327ff)
------------------------------------------------------

```sql
--November seems to be the month,what product did they sell in November?
select month_id,productline,TO_CHAR(SUM(sales), '$999,999,999') total_sales,count(ordernumber) frequency
	from sales 
		where year_id = 2004 and month_id=11 -- Need to change this value to filter by different years and month
			group by 1,2
				order by 3 desc; 
```
**Output:**
![2](https://github.com/user-attachments/assets/83eae10d-7251-435d-b467-79462a6ca9f9)
------------------------------------------------------

```sql
--Top 10 Customers by Sales
select 
    customername, 
     TO_CHAR(SUM(sales), '$999,999,999')  total_sales 
		from sales
			group by 1
				order by 2 desc
					limit 10;
```
**Output:**
![Top 10 customer](https://github.com/user-attachments/assets/60119141-c744-4d03-ab3b-3141714c0be6)
------------------------------------------------------

```sql
--Top 10 Products by Sales
select productcode,productline,TO_CHAR(SUM(sales), '$999,999,999') total_sales 
		from sales
			group by 1,2
				order by 3 desc
					limit 10;
```
**Output:**
![top 10 product](https://github.com/user-attachments/assets/70faede5-71f6-4120-be7f-6099e7d8c004)
------------------------------------------------------

## Customer Segmentation Using RFM

**Extracting the Latest Date from the dataset** 
```sql
select max(to_date(orderdate,'DD/MM/YY'))  latest_date	
	from sales;
```
**Output:**
![latest date](https://github.com/user-attachments/assets/1cad173d-12af-4f1e-a913-9b85b9254fe8)
------------------------------------------------------

**Extracting the Earliest Date from the dataset** 
```sql
select min(to_date(orderdate,'DD/MM/YY'))  earliest_date
	from sales;
```
**Output:**
![earliest date](https://github.com/user-attachments/assets/3dc7f24c-a5ca-47a3-aab3-d0e0bd7d4fa2)
------------------------------------------------------

**Extracting Range of transaction in days from the dataset** 
```sql
select (max(to_date(orderdate,'DD/MM/YY')) - min(to_date(orderdate,'DD/MM/YY'))) range_of_transaction 
	from sales;
```
**Output:**
![range of tranaction in days](https://github.com/user-attachments/assets/c0b47207-02ee-4811-a7e8-40317298a4ba)
------------------------------------------------------

### Step #1
**Extracting the customer last transactiondate,business last transaction date,frequency,monetaryvalue and recency of each customer**
```sql
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
			 	group by customername;
```
**Output:**
![rfm](https://github.com/user-attachments/assets/7a0b90dd-9029-4111-b9ca-8a9ccec82bf8)
------------------------------------------------------

**Using NTILE to segment 3 factors Recency(R),Frequency(F), and Monetary(M) into 4 groups,Calculating total rfm scores , rfm category combination and saving it into View as rfm_segment so that we can call it everytime with ease if the data updates**
```sql
--Creating View
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
```
**Output:**
![rfm view](https://github.com/user-attachments/assets/93844bf9-988d-4d90-9322-c6557b47bb2c)
------------------------------------------------------

**There are 32 distinct rfm_category_combination**
```sql
-- view distinct rfm category combinations
select distinct rfm_category_combination
 from rfm_segment
  order by 1;
```
**Output:**
![rfm_category_combination](https://github.com/user-attachments/assets/a403ded7-00ac-4fbc-97d9-aa4479f0d758)
------------------------------------------------------

**Now we Segment Customers using rfm_category_combination from rfm_segment view**
```sql
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
```
**Output:**
![segment](https://github.com/user-attachments/assets/0ca1a149-7d24-45b7-88ad-39dcd99bcd21)
------------------------------------------------------

### Conclusion:
- Based on our customer segmentation analysis, we have identified seven distinct customer groups. With this information, we can recommend to the marketing team to focus on developing a customized plan to target customers who are active and loyal.To re-engage customers who are slipping away, the marketing team can send them personalized messages with enticing offers.
- Customers who have already churned may not respond as effectively to marketing efforts. However, by focusing on the right customer groups, the marketing team can optimize their strategies and achieve better results.




