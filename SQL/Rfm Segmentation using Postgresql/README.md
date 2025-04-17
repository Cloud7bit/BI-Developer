
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

| Unique Customers |
|------------------|
| 92               |

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

| Total Sales Transactions | Total Sales Value | Average Sales Value | Minimum Sales Value | Maximum Sales Value |
|-------------------------|-------------------|---------------------|---------------------|---------------------|
| 2823                    | $  10,032,629     | $       3,554       | $         482       | $      14,083       |

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
 
| Product Line      | Total Sales     | No. of Orders |
|-------------------|----------------|--------------|
| Classic Cars      | $   3,919,616  | 199          |
| Vintage Cars      | $   1,903,151  | 175          |
| Trucks and Buses  | $   1,127,790  | 73           |
| Motorcycles       | $   1,166,388  | 72           |
| Ships             | $     714,437  | 65           |
| Planes            | $     975,004  | 59           |
| Trains            | $     226,243  | 45           |

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
 
| Year ID | Number of Orders | Total Sales      |
|---------|------------------|------------------|
| 2004    | 1345             | $   4,724,163    |
| 2003    | 1000             | $   3,516,980    |
| 2005    | 478              | $   1,791,487    |

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
 
| Month ID | Number of Orders | Total Sales     |
|----------|------------------|-----------------|
| 1        | 229              | $     785,874   |
| 2        | 224              | $     810,442   |
| 3        | 212              | $     754,501   |
| 4        | 178              | $     669,391   |
| 5        | 252              | $     923,973   |
| 6        | 131              | $     454,757   |
| 7        | 141              | $     514,876   |
| 8        | 191              | $     659,311   |
| 9        | 171              | $     584,724   |
| 10       | 317              | $   1,121,215   |
| 11       | 597              | $   2,118,886   |
| 12       | 180              | $     634,679   |

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
 
| Qtr ID | Number of Orders | Total Sales     |
|--------|------------------|-----------------|
| 1      | 665              | $   2,350,818   |
| 2      | 561              | $   2,048,120   |
| 3      | 503              | $   1,758,911   |
| 4      | 1094             | $   3,874,780   |

------------------------------------------------------

 ```sql
--Average Order Size (Quantity Ordered)
SELECT 
    ROUND(AVG(quantityordered), 0) average_order_size
FROM
    sales;
 ```
 **Output:**
 
| Average Order Size |
|--------------------|
| 35                 |

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

| Status      | Number of Orders | Total Sales     |
|-------------|------------------|-----------------|
| Shipped     | 2617             | $   9,291,501   |
| Cancelled   | 60               | $     194,487   |
| Resolved    | 47               | $     150,718   |
| On Hold     | 44               | $     178,979   |
| In Process  | 41               | $     144,730   |
| Disputed    | 14               | $      72,213   |

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

| Month ID | Total Sales     | Frequency |
|----------|----------------|-----------|
| 11       | $   1,089,048  | 301       |
| 10       | $     552,924  | 159       |
| 8        | $     461,501  | 133       |
| 12       | $     372,803  | 110       |
| 7        | $     327,144  | 91        |
| 9        | $     320,751  | 95        |
| 1        | $     316,577  | 91        |
| 2        | $     311,420  | 86        |
| 6        | $     286,674  | 85        |
| 5        | $     273,438  | 74        |
| 4        | $     206,148  | 64        |
| 3        | $     205,734  | 56        |

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

| Month ID | Product Line      | Total Sales     | Frequency |
|----------|-------------------|----------------|-----------|
| 11       | Classic Cars      | $     372,232  | 105       |
| 11       | Vintage Cars      | $     233,990  | 65        |
| 11       | Motorcycles       | $     151,712  | 39        |
| 11       | Trucks and Buses  | $     123,811  | 29        |
| 11       | Planes            | $     121,131  | 36        |
| 11       | Ships             | $      63,901  | 21        |
| 11       | Trains            | $      22,271  | 6         |

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

| Customer Name                | Total Sales     |
|------------------------------|-----------------|
| Euro Shopping Channel        | $     912,294   |
| Mini Gifts Distributors Ltd. | $     654,858   |
| Australian Collectors, Co.   | $     200,995   |
| Muscle Machine Inc           | $     197,737   |
| La Rochelle Gifts            | $     180,125   |
| Dragon Souveniers, Ltd.      | $     172,990   |
| Land of Toys Inc.            | $     164,069   |
| The Sharp Gifts Warehouse    | $     160,010   |
| AV Stores, Co.               | $     157,808   |
| Anna's Decorations, Ltd      | $     153,996   |

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

| Product Code | Product Line   | Total Sales     |
|--------------|---------------|-----------------|
| S18_3232     | Classic Cars  | $     288,245   |
| S10_1949     | Classic Cars  | $     191,073   |
| S10_4698     | Motorcycles   | $     170,401   |
| S12_1108     | Classic Cars  | $     168,585   |
| S18_2238     | Classic Cars  | $     154,624   |
| S12_3891     | Classic Cars  | $     145,332   |
| S24_3856     | Classic Cars  | $     140,627   |
| S12_2823     | Motorcycles   | $     140,006   |
| S18_1662     | Planes        | $     139,422   |
| S12_1099     | Classic Cars  | $     137,177   |

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

| Latest Date |
|-------------|
| 2005-05-31  |

------------------------------------------------------

**Extracting the Earliest Date from the dataset** 
```sql
SELECT 
    MIN(TO_DATE(orderdate, 'DD/MM/YY')) earliest_date
FROM
    sales;
```
**Output:**

| Earliest Date |
|---------------|
| 2003-01-06    |

------------------------------------------------------

**Extracting Range of transaction in days from the dataset** 
```sql
SELECT 
    (MAX(TO_DATE(orderdate, 'DD/MM/YY')) - MIN(TO_DATE(orderdate, 'DD/MM/YY'))) range_of_transaction
FROM
    sales;
```
**Output:**

| Year Difference |
|-----------------|
| 2               |

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
| Customer Name                   | Monetary Value  | Frequency | Customer Last Transaction Date | Business Last Transaction Date | Recency |
|----------------------------------|----------------|-----------|-------------------------------|-------------------------------|---------|
| Alpha Cognac                    | $      70,488  | 3         | 2005-03-28                    | 2005-05-31                    | 64      |
| Amica Models & Co.              | $      94,117  | 2         | 2004-09-09                    | 2005-05-31                    | 264     |
| Anna's Decorations, Ltd         | $     153,996  | 4         | 2005-03-09                    | 2005-05-31                    | 83      |
| Atelier graphique               | $      24,180  | 3         | 2004-11-25                    | 2005-05-31                    | 187     |
| Australian Collectables, Ltd    | $      64,591  | 3         | 2005-05-09                    | 2005-05-31                    | 22      |
| Australian Collectors, Co.      | $     200,995  | 5         | 2004-11-29                    | 2005-05-31                    | 183     |
| Australian Gift Network, Co     | $      59,469  | 3         | 2005-02-02                    | 2005-05-31                    | 118     |
| Auto-Moto Classics Inc.         | $      26,479  | 3         | 2004-12-03                    | 2005-05-31                    | 179     |
| Auto Assoc. & Cie.              | $      64,834  | 2         | 2004-10-11                    | 2005-05-31                    | 232     |
| Auto Canal Petit                | $      93,171  | 3         | 2005-04-07                    | 2005-05-31                    | 54      |
| AV Stores, Co.                  | $     157,808  | 3         | 2004-11-17                    | 2005-05-31                    | 195     |
| Baane Mini Imports              | $     116,599  | 4         | 2004-11-05                    | 2005-05-31                    | 207     |
| Bavarian Collectables Imports, Co.| $      34,994| 1         | 2004-09-15                    | 2005-05-31                    | 258     |
| Blauer See Auto, Co.            | $      85,172  | 4         | 2004-11-05                    | 2005-05-31                    | 207     |
| Boards & Toys Co.               | $       9,129  | 2         | 2005-02-08                    | 2005-05-31                    | 112     |
| CAF Imports                     | $      49,642  | 2         | 2004-03-19                    | 2005-05-31                    | 438     |
| Cambridge Collectables Co.      | $      36,164  | 2         | 2004-05-08                    | 2005-05-31                    | 388     |
| Canadian Gift Exchange Network  | $      75,239  | 2         | 2004-10-22                    | 2005-05-31                    | 221     |
| Classic Gift Ideas, Inc         | $      67,507  | 2         | 2004-10-14                    | 2005-05-31                    | 229     |
| Classic Legends Inc.            | $      77,795  | 3         | 2004-11-21                    | 2005-05-31                    | 191     |
| Clover Collections, Co.         | $      57,756  | 2         | 2004-09-16                    | 2005-05-31                    | 257     |
| Collectable Mini Designs Co.    | $      87,489  | 2         | 2004-02-26                    | 2005-05-31                    | 460     |
| Collectables For Less Inc.      | $      81,578  | 3         | 2005-01-20                    | 2005-05-31                    | 131     |
| Corporate Gift Ideas Co.        | $     149,883  | 4         | 2005-02-23                    | 2005-05-31                    | 97      |
| Corrida Auto Replicas, Ltd      | $     120,615  | 3         | 2004-11-01                    | 2005-05-31                    | 211     |
| Cruz & Sons Co.                 | $      94,016  | 3         | 2004-11-16                    | 2005-05-31                    | 196     |
| Daedalus Designs Imports        | $      69,052  | 2         | 2004-02-21                    | 2005-05-31                    | 465     |
| Danish Wholesale Imports        | $     145,042  | 5         | 2005-04-15                    | 2005-05-31                    | 46      |
| Diecast Classics Inc.           | $     122,138  | 4         | 2005-05-30                    | 2005-05-31                    | 1       |
| Diecast Collectables            | $      70,860  | 2         | 2004-04-26                    | 2005-05-31                    | 400     |
| Double Decker Gift Stores, Ltd  | $      36,019  | 2         | 2004-01-22                    | 2005-05-31                    | 495     |
| Dragon Souveniers, Ltd.         | $     172,990  | 5         | 2005-03-02                    | 2005-05-31                    | 90      |
| Enaco Distributors              | $      78,412  | 3         | 2004-11-24                    | 2005-05-31                    | 188     |
| Euro Shopping Channel           | $     912,294  | 26        | 2005-05-31                    | 2005-05-31                    | 0       |
| FunGiftIdeas.com                | $      98,924  | 3         | 2005-03-03                    | 2005-05-31                    | 89      |
| Gift Depot Inc.                 | $     101,895  | 3         | 2005-05-05                    | 2005-05-31                    | 26      |
| Gift Ideas Corp.                | $      57,294  | 3         | 2004-12-04                    | 2005-05-31                    | 178     |
| Gifts4AllAges.com               | $      83,210  | 3         | 2005-05-06                    | 2005-05-31                    | 25      |
| giftsbymail.co.uk               | $      78,241  | 2         | 2004-11-01                    | 2005-05-31                    | 211     |
| Handji Gifts& Co                | $     115,499  | 4         | 2005-04-23                    | 2005-05-31                    | 38      |
| Heintze Collectables            | $     100,596  | 2         | 2004-10-22                    | 2005-05-31                    | 221     |
| Herkku Gifts                    | $     111,640  | 3         | 2004-09-03                    | 2005-05-31                    | 270     |
| Iberia Gift Imports, Corp.      | $      54,724  | 2         | 2004-10-06                    | 2005-05-31                    | 237     |
| L'ordine Souveniers             | $     142,601  | 3         | 2005-05-10                    | 2005-05-31                    | 21      |
| La Corne D'abondance, Co.       | $      97,204  | 3         | 2004-11-20                    | 2005-05-31                    | 192     |
| La Rochelle Gifts               | $     180,125  | 4         | 2005-05-31                    | 2005-05-31                    | 0       |
| Land of Toys Inc.               | $     164,069  | 4         | 2004-11-15                    | 2005-05-31                    | 197     |
| Lyon Souveniers                 | $      78,570  | 3         | 2005-03-17                    | 2005-05-31                    | 75      |
| Marseille Mini Autos            | $      74,936  | 3         | 2005-01-06                    | 2005-05-31                    | 145     |
| Marta's Replicas Co.            | $     103,080  | 2         | 2004-10-13                    | 2005-05-31                    | 230     |
| Men 'R' US Retailers, Ltd.      | $      48,048  | 2         | 2004-01-09                    | 2005-05-31                    | 508     |
| Microscale Inc.                 | $      33,145  | 2         | 2004-11-03                    | 2005-05-31                    | 209     |
| Mini Auto Werke                 | $      52,264  | 3         | 2005-03-10                    | 2005-05-31                    | 82      |
| Mini Caravy                     | $      80,438  | 3         | 2005-04-14                    | 2005-05-31                    | 47      |
| Mini Classics                   | $      85,556  | 2         | 2004-10-15                    | 2005-05-31                    | 228     |
| Mini Creations Ltd.             | $     108,951  | 3         | 2005-01-07                    | 2005-05-31                    | 144     |
| Mini Gifts Distributors Ltd.    | $     654,858  | 17        | 2005-05-29                    | 2005-05-31                    | 2       |
| Mini Wheels Co.                 | $      74,476  | 3         | 2004-11-18                    | 2005-05-31                    | 194     |
| Motor Mint Distributors Inc.    | $      83,682  | 3         | 2004-11-17                    | 2005-05-31                    | 195     |
| Muscle Machine Inc              | $     197,737  | 4         | 2004-12-01                    | 2005-05-31                    | 181     |
| Norway Gifts By Mail, Co.       | $      79,224  | 2         | 2004-08-21                    | 2005-05-31                    | 283     |
| Online Diecast Creations Co.    | $     131,685  | 3         | 2004-11-04                    | 2005-05-31                    | 208     |
| Online Mini Collectables        | $      57,198  | 2         | 2004-09-10                    | 2005-05-31                    | 263     |
| Osaka Souveniers Co.            | $      67,605  | 2         | 2004-04-13                    | 2005-05-31                    | 413     |
| Oulu Toy Supplies, Inc.         | $     104,370  | 3         | 2005-01-31                    | 2005-05-31                    | 120     |
| Petit Auto                      | $      74,973  | 3         | 2005-05-30                    | 2005-05-31                    | 1       |
| Quebec Home Shopping Network    | $      74,205  | 3         | 2005-05-01                    | 2005-05-31                    | 30      |
| Reims Collectables              | $     135,043  | 5         | 2005-03-30                    | 2005-05-31                    | 62      |
| Rovelli Gifts                   | $     137,956  | 3         | 2004-11-12                    | 2005-05-31                    | 200     |
| Royal Canadian Collectables, Ltd.| $      74,635 | 2         | 2004-08-20                    | 2005-05-31                    | 284     |
| Royale Belge                    | $      33,440  | 4         | 2005-01-10                    | 2005-05-31                    | 141     |
| Salzburg Collectables           | $     149,799  | 4         | 2005-05-17                    | 2005-05-31                    | 14      |
| Saveley & Henriot, Co.          | $     142,874  | 3         | 2004-03-02                    | 2005-05-31                    | 455     |
| Scandinavian Gift Ideas         | $     134,259  | 3         | 2005-03-03                    | 2005-05-31                    | 89      |
| Signal Collectibles Ltd.        | $      50,219  | 2         | 2004-02-10                    | 2005-05-31                    | 476     |
| Signal Gift Stores              | $      82,751  | 3         | 2004-11-29                    | 2005-05-31                    | 183     |
| Souveniers And Things Co.       | $     151,571  | 4         | 2005-05-29                    | 2005-05-31                    | 2       |
| Stylish Desk Decors, Co.        | $      88,805  | 3         | 2004-12-03                    | 2005-05-31                    | 179     |
| Suominen Souveniers             | $     113,961  | 3         | 2005-01-06                    | 2005-05-31                    | 145     |
| Super Scale Inc.                | $      79,472  | 2         | 2004-05-04                    | 2005-05-31                    | 392     |
| Technics Stores Inc.            | $     120,783  | 4         | 2005-01-05                    | 2005-05-31                    | 146     |
| Tekni Collectables Inc.         | $      83,228  | 3         | 2005-04-03                    | 2005-05-31                    | 58      |
| The Sharp Gifts Warehouse       | $     160,010  | 4         | 2005-04-22                    | 2005-05-31                    | 39      |
| Tokyo Collectables, Ltd         | $     120,563  | 4         | 2005-04-22                    | 2005-05-31                    | 39      |
| Toms Spezialitten, Ltd          | $     100,307  | 2         | 2004-10-16                    | 2005-05-31                    | 227     |
| Toys of Finland, Co.            | $     111,250  | 3         | 2005-02-09                    | 2005-05-31                    | 111     |
| Toys4GrownUps.com               | $     104,562  | 3         | 2005-01-12                    | 2005-05-31                    | 139     |
| UK Collectables, Ltd.           | $     118,008  | 3         | 2005-04-08                    | 2005-05-31                    | 53      |
| Vida Sport, Ltd                 | $     117,714  | 2         | 2004-08-30                    | 2005-05-31                    | 274     |
| Vitachrome Inc.                 | $      88,041  | 3         | 2004-11-05                    | 2005-05-31                    | 207     |
| Volvo Model Replicas, Co        | $      75,755  | 4         | 2004-11-19                    | 2005-05-31                    | 193     |
| West Coast Collectables Co.     | $      46,085  | 2         | 2004-01-29                    | 2005-05-31                    | 488     |

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
FROM rfm_segment
LIMIT 20;
```
**Output:**

| RFM Recency Score | RFM Frequency Score | RFM Monetary Score | Total RFM Score | RFM Category Combination |
|-------------------|--------------------|--------------------|-----------------|-------------------------|
| 1                 | 1                  | 1                  | 3               | 111                     |
| 1                 | 1                  | 1                  | 3               | 111                     |
| 1                 | 1                  | 1                  | 3               | 111                     |
| 1                 | 1                  | 1                  | 3               | 111                     |
| 1                 | 1                  | 1                  | 3               | 111                     |
| 1                 | 2                  | 3                  | 6               | 123                     |
| 1                 | 3                  | 4                  | 8               | 134                     |
| 1                 | 1                  | 1                  | 3               | 111                     |
| 1                 | 1                  | 1                  | 3               | 111                     |
| 1                 | 1                  | 2                  | 4               | 112                     |
| 1                 | 1                  | 2                  | 4               | 112                     |
| 1                 | 1                  | 1                  | 3               | 111                     |
| 1                 | 1                  | 2                  | 4               | 112                     |
| 1                 | 1                  | 2                  | 4               | 112                     |
| 1                 | 2                  | 3                  | 6               | 123                     |
| 1                 | 2                  | 3                  | 6               | 123                     |
| 1                 | 2                  | 3                  | 6               | 123                     |
| 1                 | 1                  | 1                  | 3               | 111                     |
| 1                 | 1                  | 1                  | 3               | 111                     |
| 1                 | 1                  | 1                  | 3               | 111                     |

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

| Value |
|-------|
| 111   |
| 112   |
| 123   |
| 134   |
| 211   |
| 212   |
| 221   |
| 223   |
| 224   |
| 232   |
| 233   |
| 234   |
| 242   |
| 243   |
| 244   |
| 311   |
| 321   |
| 322   |
| 323   |
| 324   |
| 332   |
| 333   |
| 341   |
| 343   |
| 344   |
| 421   |
| 423   |
| 432   |
| 433   |
| 434   |
| 443   |
| 444   |

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

| Customer Name                        | Status                      |
|---------------------------------------|-----------------------------|
| Men 'R' US Retailers, Ltd.           | churned customer            |
| Double Decker Gift Stores, Ltd        | churned customer            |
| West Coast Collectables Co.           | churned customer            |
| Signal Collectibles Ltd.              | churned customer            |
| Daedalus Designs Imports              | churned customer            |
| Collectable Mini Designs Co.          | churned customer            |
| Saveley & Henriot, Co.                | slipping away, cannot lose  |
| CAF Imports                           | churned customer            |
| Osaka Souveniers Co.                  | churned customer            |
| Diecast Collectables                  | churned customer            |
| Super Scale Inc.                      | churned customer            |
| Cambridge Collectables Co.            | churned customer            |
| Royal Canadian Collectables, Ltd.     | churned customer            |
| Norway Gifts By Mail, Co.             | churned customer            |
| Vida Sport, Ltd                       | churned customer            |
| Herkku Gifts                          | churned customer            |
| Amica Models & Co.                    | churned customer            |
| Online Mini Collectables              | churned customer            |
| Bavarian Collectables Imports, Co.    | churned customer            |
| Clover Collections, Co.               | churned customer            |
| Iberia Gift Imports, Corp.            | churned customer            |
| Auto Assoc. & Cie.                    | churned customer            |
| Marta's Replicas Co.                  | churned customer            |
| Classic Gift Ideas, Inc               | churned customer            |
| Mini Classics                         | churned customer            |
| Toms Spezialitten, Ltd                | potential churners          |
| Canadian Gift Exchange Network        | churned customer            |
| Heintze Collectables                  | potential churners          |
| giftsbymail.co.uk                     | churned customer            |
| Corrida Auto Replicas, Ltd            | cannot be defined           |
| Microscale Inc.                       | churned customer            |
| Online Diecast Creations Co.          | cannot be defined           |
| Blauer See Auto, Co.                  | cannot be defined           |
| Vitachrome Inc.                       | potential churners          |
| Baane Mini Imports                    | cannot be defined           |
| Rovelli Gifts                         | cannot be defined           |
| Land of Toys Inc.                     | slipping away, cannot lose  |
| Cruz & Sons Co.                       | potential churners          |
| Motor Mint Distributors Inc.          | cannot be defined           |
| AV Stores, Co.                        | cannot be defined           |
| Mini Wheels Co.                       | cannot be defined           |
| Volvo Model Replicas, Co              | cannot be defined           |
| La Corne D'abondance, Co.             | potential churners          |
| Classic Legends Inc.                  | cannot be defined           |
| Enaco Distributors                    | cannot be defined           |
| Atelier graphique                     | potential churners          |
| Australian Collectors, Co.            | slipping away, cannot lose  |
| Signal Gift Stores                    | active                      |
| Muscle Machine Inc                    | slipping away, cannot lose  |
| Auto-Moto Classics Inc.               | active                      |
| Stylish Desk Decors, Co.              | active                      |
| Gift Ideas Corp.                      | active                      |
| Technics Stores Inc.                  | slipping away, cannot lose  |
| Marseille Mini Autos                  | potential churners          |
| Suominen Souveniers                   | active                      |
| Mini Creations Ltd.                   | active                      |
| Royale Belge                          | active                      |
| Toys4GrownUps.com                     | active                      |
| Collectables For Less Inc.            | active                      |
| Oulu Toy Supplies, Inc.               | slipping away, cannot lose

------------------------------------------------------

### Conclusion:
- Based on our customer segmentation analysis, we have identified seven distinct customer groups. With this information, we can recommend to the marketing team to focus on developing a customized plan to target customers who are active and loyal.To re-engage customers who are slipping away, the marketing team can send them personalized messages with enticing offers.
- Customers who have already churned may not respond as effectively to marketing efforts. However, by focusing on the right customer groups, the marketing team can optimize their strategies and achieve better results.




