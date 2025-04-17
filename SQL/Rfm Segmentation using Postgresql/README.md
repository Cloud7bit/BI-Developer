
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
SELECT 
    COUNT(DISTINCT customername) unique_customers
FROM
    sales;
```
**Output:**   

 ![Unique customers](https://github.com/user-attachments/assets/a5f829dd-2865-47d3-a5d0-833224dbeced)
------------------------------------------------------

 ```sql
--Summarize Sales Data	
SELECT 
    COUNT(sales) AS total_sales_transactions,
    TO_CHAR(ROUND(SUM(sales), 0), '$999,999,999') AS total_sales_value,
    TO_CHAR(ROUND(AVG(sales), 0), '$999,999,999') AS average_sales_value,
    TO_CHAR(ROUND(MIN(sales), 0), '$999,999,999') AS minimum_sales_value,
    TO_CHAR(ROUND(MAX(sales), 0), '$999,999,999') AS maximum_sales_value
FROM
    sales;
 ```
 **Output:**  
 ![summarize sales data](https://github.com/user-attachments/assets/63ac2ae3-9224-4bb7-a21b-b1abd1b517ba)
------------------------------------------------------
 
 ```sql
 --Calculating total_sales and number of orders by productline		 
SELECT 
    productline,
    TO_CHAR(ROUND(SUM(sales), 0), '$999,999,999') total_sales,
    COUNT(DISTINCT ordernumber) no_of_orders
FROM
    sales
GROUP BY 1
ORDER BY 3 DESC;
 ```
 **Output:**
 
 ![productline](https://github.com/user-attachments/assets/d5600f47-b72a-4fbf-bb76-0248421cd216)
------------------------------------------------------

 ```sql
--Calculating # of orders and total_sales by year
SELECT 
    year_id,
    COUNT(*) number_of_orders,
    TO_CHAR(ROUND(SUM(sales), 0), '$999,999,999') total_sales
FROM
    sales
GROUP BY 1
ORDER BY 2 DESC;
 ```
 **Output:**
 
 ![sales by year](https://github.com/user-attachments/assets/0b9daddc-08a1-4c10-bde3-845eb00b8f84)
------------------------------------------------------

```sql
--Calculating # of  orders and  total_sales by month_id
SELECT 
    month_id,
    COUNT(*) number_of_orders,
    TO_CHAR(ROUND(SUM(sales), 0), '$999,999,999') revenue
FROM
    sales
GROUP BY 1
ORDER BY 1;
 ```
 **Output:**
 
 ![sales by month](https://github.com/user-attachments/assets/d45a4eba-3786-4ebf-a8ad-dac56e29e5e5)
------------------------------------------------------

 ```sql
--Calculating # of orders and sales by Quarter
SELECT 
    qtr_id,
    COUNT(*) number_of_orders,
    TO_CHAR(ROUND(SUM(sales), 0), '$999,999,999') total_sales
FROM
    sales
GROUP BY 1
ORDER BY 1;
 ```
 **Output:**
 
 ![sales by quater](https://github.com/user-attachments/assets/77858b3c-d5a3-449b-8e01-d8d273f82987)
------------------------------------------------------

 ```sql
--Average Order Size (Quantity Ordered)
SELECT 
    ROUND(AVG(quantityordered), 0) average_order_size
FROM
    sales;
 ```
 **Output:**
 
 ![Average Order Size (Quantity Ordered)](https://github.com/user-attachments/assets/18445f33-f312-4f1b-8c67-c2b31170401c)
------------------------------------------------------

```sql
--Orders by Status
SELECT 
    status,
    COUNT(*) number_of_orders,
    TO_CHAR(ROUND(SUM(sales), 0), '$999,999,999') total_sales
FROM
    sales
GROUP BY 1
ORDER BY 2 DESC;
```
**Output:**

![sales by status](https://github.com/user-attachments/assets/351176a8-556f-4d7d-9986-6a344544c463)
------------------------------------------------------

```sql
-- What was the best month for sales in a specific year? How much was earned that month?
SELECT 
    month_id,
    TO_CHAR(SUM(sales), '$999,999,999') total_sales,
    COUNT(ordernumber) frequency
FROM
    sales
WHERE
    year_id = 2004
GROUP BY 1
ORDER BY 2 DESC;
```
**Output:**
![best month for sales](https://github.com/user-attachments/assets/a439ffbd-2245-475e-bdba-3d93f0a327ff)
------------------------------------------------------

```sql
--November seems to be the month,what product did they sell in November?
SELECT 
    month_id,
    productline,
    TO_CHAR(SUM(sales), '$999,999,999') total_sales,
    COUNT(ordernumber) frequency
FROM
    sales
WHERE
    year_id = 2004 AND month_id = 11
GROUP BY 1 , 2
ORDER BY 3 DESC; 
```
**Output:**

![2](https://github.com/user-attachments/assets/83eae10d-7251-435d-b467-79462a6ca9f9)
------------------------------------------------------

```sql
--Top 10 Customers by Sales
SELECT 
    customername,
    TO_CHAR(SUM(sales), '$999,999,999') total_sales
FROM
    sales
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10;
```
**Output:**

![Top 10 customer](https://github.com/user-attachments/assets/60119141-c744-4d03-ab3b-3141714c0be6)
------------------------------------------------------

```sql
--Top 10 Products by Sales
SELECT 
    productcode,
    productline,
    TO_CHAR(SUM(sales), '$999,999,999') total_sales
FROM
    sales
GROUP BY 1 , 2
ORDER BY 3 DESC
LIMIT 10;
```
**Output:**

![top 10 product](https://github.com/user-attachments/assets/70faede5-71f6-4120-be7f-6099e7d8c004)
------------------------------------------------------

## Customer Segmentation Using RFM

**Extracting the Latest Date from the dataset** 
```sql
SELECT 
    MAX(TO_DATE(orderdate, 'DD/MM/YY')) latest_date
FROM
    sales;
```
**Output:**

![latest date](https://github.com/user-attachments/assets/1cad173d-12af-4f1e-a913-9b85b9254fe8)
------------------------------------------------------

**Extracting the Earliest Date from the dataset** 
```sql
SELECT 
    MIN(TO_DATE(orderdate, 'DD/MM/YY')) earliest_date
FROM
    sales;
```
**Output:**

![earliest date](https://github.com/user-attachments/assets/3dc7f24c-a5ca-47a3-aab3-d0e0bd7d4fa2)
------------------------------------------------------

**Extracting Range of transaction in days from the dataset** 
```sql
SELECT 
    (MAX(TO_DATE(orderdate, 'DD/MM/YY')) - MIN(TO_DATE(orderdate, 'DD/MM/YY'))) range_of_transaction
FROM
    sales;
```
**Output:**

![range of tranaction in days](https://github.com/user-attachments/assets/c0b47207-02ee-4811-a7e8-40317298a4ba)
------------------------------------------------------

### Step #1
**Extracting the customer last transactiondate,business last transaction date,frequency,monetaryvalue and recency of each customer**
```sql
SELECT 
    customername,
    TO_CHAR(ROUND(SUM(sales), 0), '$999,999,999') monetaryvalue,
    COUNT(DISTINCT ordernumber) frequency,
    MAX(TO_DATE(orderdate, 'DD/MM/YY')) customer_last_transaction_date,
    (SELECT 
            MAX(TO_DATE(orderdate, 'DD/MM/YY'))
        FROM
            sales) business_last_transaction_date,
    (SELECT 
            MAX(TO_DATE(orderdate, 'DD/MM/YY'))
        FROM
            sales) - MAX(TO_DATE(orderdate, 'DD/MM/YY')) recency
FROM
    sales
GROUP BY customername;
```
**Output:**

![rfm](https://github.com/user-attachments/assets/7a0b90dd-9029-4111-b9ca-8a9ccec82bf8)
------------------------------------------------------

**Using NTILE to segment 3 factors Recency(R),Frequency(F), and Monetary(M) into 4 groups,Calculating total rfm scores , rfm category combination and saving it into View as rfm_segment so that we can call it everytime with ease if the data updates**
```sql
--Creating View
CREATE VIEW rfm_segment
AS
WITH rfm_cal
AS (
	SELECT customername
		,to_char(round(sum(sales), 0), '$999,999,999') monetaryvalue
		,count(DISTINCT ordernumber) frequency
		,max(to_date(orderdate, 'DD/MM/YY')) customer_last_transaction_date
		,(
			SELECT max(to_date(orderdate, 'DD/MM/YY'))
			FROM sales
			) business_last_transaction_date
		,
		-- calculate recency in days
		(
			SELECT max(to_date(orderdate, 'DD/MM/YY'))
			FROM sales
			) - max(to_date(orderdate, 'DD/MM/YY')) recency
	FROM sales
	GROUP BY customername
	)
	,rfm_scores
AS (
	SELECT c.*
		,ntile(4) OVER (
			ORDER BY c.recency DESC
			) rfm_recency_score
		,ntile(4) OVER (
			ORDER BY c.frequency
			) rfm_frequency_score
		,ntile(4) OVER (
			ORDER BY c.monetaryvalue
			) rfm_monetary_score
	FROM rfm_cal c
	)
SELECT s.*
	,(s.rfm_recency_score + s.rfm_frequency_score + s.rfm_monetary_score) total_rfm_score
	,CONCAT (
		s.rfm_recency_score::VARCHAR
		,s.rfm_frequency_score::VARCHAR
		,s.rfm_monetary_score::VARCHAR
		) rfm_category_combination
FROM rfm_scores s;

-- view desiered entries rfm_segment
SELECT rfm_recency_score
	,rfm_frequency_score
	,rfm_monetary_score
	,total_rfm_score
	,rfm_category_combination
FROM rfm_segment;
```
**Output:**

![rfm view](https://github.com/user-attachments/assets/93844bf9-988d-4d90-9322-c6557b47bb2c)
------------------------------------------------------

**There are 32 distinct rfm_category_combination**
```sql
-- view distinct rfm category combinations
SELECT DISTINCT
    rfm_category_combination
FROM
    rfm_segment
ORDER BY 1;
```
**Output:**

![rfm_category_combination](https://github.com/user-attachments/assets/a403ded7-00ac-4fbc-97d9-aa4479f0d758)
------------------------------------------------------

**Now we Segment Customers using rfm_category_combination from rfm_segment view**
```sql
-- categorize customers based on rfm category combination 
SELECT 
    customername,
    CASE
        WHEN
            rfm_category_combination IN ('111' , '112',
                '121',
                '123',
                '132',
                '211',
                '212',
                '114',
                '141')
        THEN
            'churned customer'
        WHEN
            rfm_category_combination IN ('133' , '134',
                '143',
                '244',
                '334',
                '343',
                '344',
                '144')
        THEN
            'slipping away, cannot lose'
        WHEN rfm_category_combination IN ('311' , '411', '331') THEN 'new customers'
        WHEN rfm_category_combination IN ('222' , '231', '221', '223', '233', '322') THEN 'potential churners'
        WHEN rfm_category_combination IN ('323' , '333', '321', '341', '422', '332', '432') THEN 'active'
        WHEN rfm_category_combination IN ('433' , '434', '443', '444') THEN 'loyal'
        ELSE 'cannot be defined'
    END AS customer_segment
FROM
    rfm_segment;
```
**Output:**

![segment](https://github.com/user-attachments/assets/0ca1a149-7d24-45b7-88ad-39dcd99bcd21)
------------------------------------------------------

### Conclusion:
- Based on our customer segmentation analysis, we have identified seven distinct customer groups. With this information, we can recommend to the marketing team to focus on developing a customized plan to target customers who are active and loyal.To re-engage customers who are slipping away, the marketing team can send them personalized messages with enticing offers.
- Customers who have already churned may not respond as effectively to marketing efforts. However, by focusing on the right customer groups, the marketing team can optimize their strategies and achieve better results.




