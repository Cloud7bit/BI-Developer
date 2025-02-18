
# Olympic Games Case Study

The dataset contains a historical record of the modern Olympic Games, spanning from Athens 1896 to Rio 2016. It offers an excellent opportunity to explore the evolution of the Olympics over time, focusing on various aspects such as the participation and achievements of women, the performance of different nations, and the development of sports and events. I plan to analyze this dataset using SQL to answer 20 insightful questions.


## Tech Stack Used 

Postgresql

![sql-server](https://github.com/user-attachments/assets/459cb5aa-236a-4aaa-b29a-41b648e446fa)

## Database Structure:
The database consists of two table:
- OLYMPICS_HISTORY and
- OLYMPICS_HISTORY_NOC_REGIONS


#### To start, I will create the necessary tables and import the dataset into them.

```sql
DROP TABLE IF EXISTS OLYMPICS_HISTORY;
CREATE TABLE IF NOT EXISTS OLYMPICS_HISTORY
(
    id          INT,
    name        VARCHAR,
    sex         VARCHAR,
    age         VARCHAR,
    height      VARCHAR,
    weight      VARCHAR,
    team        VARCHAR,
    noc         VARCHAR,
    games       VARCHAR,
    year        INT,
    season      VARCHAR,
    city        VARCHAR,
    sport       VARCHAR,
    event       VARCHAR,
    medal       VARCHAR
);

DROP TABLE IF EXISTS OLYMPICS_HISTORY_NOC_REGIONS;
CREATE TABLE IF NOT EXISTS OLYMPICS_HISTORY_NOC_REGIONS
(
    noc         VARCHAR,
    region      VARCHAR,
    notes       VARCHAR
);

select * from OLYMPICS_HISTORY;
select * from OLYMPICS_HISTORY_NOC_REGIONS;

```
**output:**
![Image](https://github.com/user-attachments/assets/e2abca9e-99ca-4c6c-bf16-cd20728abd0f)

![Image](https://github.com/user-attachments/assets/f1ca5003-39ac-41c8-8b3c-33403f94b861)

------------------------------------------------------ 

### Here are the questions I answered using sql

#### 1. How many olympics games have been held? Problem Statement: Write a SQL query to find the total no of Olympic Games held as per the dataset.
```sql
SELECT 
    COUNT(DISTINCT(games)) AS total_olympic_games
FROM 
	olympics_history;

```
**output:**

![Image](https://github.com/user-attachments/assets/f8494037-9eb7-4466-a10b-4cc40b074dbd)

#### 2. List down all Olympics games held so far. Problem Statement: Write a SQL query to list down all the Olympic Games held so far.
```sql
SELECT 
	year,season,city 
FROM 
	olympics_history
GROUP BY
	year,season,city 
ORDER BY 
	year;
```
**output:**

![Image](https://github.com/user-attachments/assets/d24ee5e3-b7c7-471d-9ae6-09fe08ddf30f)

#### 3. Mention the total no of nations who participated in each olympics game? Problem Statement: SQL query to fetch total no of countries participated in each olympic games.	
```sql
WITH all_countries AS (

SELECT 
	o.games,nr.region
FROM
	olympics_history o
JOIN
	olympics_history_noc_regions nr
ON 
	o.noc=nr.noc
GROUP BY
	o.games,nr.region
)
SELECT
	games,COUNT(1) AS total_countries
FROM
	all_countries
GROUP BY
	games
ORDER BY
	games;
```
**output:**

![Image](https://github.com/user-attachments/assets/4b409395-6bd8-4ca1-86a0-523f4ef7ff9c)

#### 4. Which year saw the highest and lowest no of countries participating in olympics .Problem Statement: Write a SQL query to return the Olympic Games which had the highest participating countries and the lowest participating countries.
```sql
WITH all_countries AS (

SELECT
	oh.games,nr.region
FROM
	OLYMPICS_HISTORY oh
JOIN
	OLYMPICS_HISTORY_NOC_REGIONS nr
ON
	oh.noc=nr.noc
GROUP BY 
	oh.games,nr.region
),

tot_countries AS(

SELECT 
	games,COUNT(*) AS total_countries
FROM
	all_countries 
GROUP BY 
	games
)
	
SELECT 
	CONCAT((
SELECT 
	games || ' - ' || total_countries
FROM
	tot_countries
ORDER BY 
	total_countries ASC LIMIT 1
	
	))
	AS lowest_countries,

	CONCAT((
SELECT
	games || ' - ' || total_countries
FROM
	tot_countries
ORDER BY 
	total_countries DESC LIMIT 1 
	))
	AS highest_countries
FROM 
	tot_countries
LIMIT 1;
```
**output:**

![Image](https://github.com/user-attachments/assets/505b291f-239f-4923-868e-8d7a9ed29c8a)


```
#### 5. Which nation has participated in all of the olympic games .Problem Statement: SQL query to return the list of countries who have been part of every Olympics games.

```sql
WITH tot_games AS(
SELECT
	COUNT(DISTINCT games) AS total_games
FROM 
	olympics_history
),
countries AS(
SELECT 
	oh.games,nr.region AS country
FROM
	olympics_history oh
JOIN
	olympics_history_noc_regions nr
ON
	oh.noc = nr.noc
GROUP BY 
	oh.games,nr.region
),
countries_participated AS(
SELECT
	country,COUNT(1) AS total_participated_games
FROM 
	countries
GROUP BY
	country
)
SELECT
	cp.*
FROM
	countries_participated cp
JOIN
	tot_games tg
ON 
	cp.total_participated_games = tg.total_games
ORDER BY
	1;
```
**output:**

![Image](https://github.com/user-attachments/assets/8bae58c6-35de-4a6b-a997-aeda973e1484)

#### 6. Identify the sport which was played in all summer olympics.Problem Statement: SQL query to fetch the list of all sports which have been part of every olympics.
```sql
WITH t1 AS (
SELECT
	COUNT(DISTINCT games) AS total_games
FROM 
	olympics_history
WHERE
	season = 'Summer'
	),
t2 AS (
SELECT 
	DISTINCT sport,games
FROM 
	olympics_history
WHERE
	season = 'Summer'
ORDER BY 
	games
),
t3 AS (
SELECT 
	sport , COUNT(games) AS no_of_games
FROM
	t2
GROUP BY 
	sport)
SELECT
	t3.sport,t3.no_of_games,t1.total_games
FROM 
	t3
JOIN
	t1
ON
	t3.no_of_games = t1.total_games;
```
**output:**

![Image](https://github.com/user-attachments/assets/e921e453-3463-4d69-969e-f1f3ab7c6fe3)

#### 7. Which Sports were just played only once in the olympics. Problem Statement: Using SQL query, Identify the sport which were just played once in all of olympics.
```sql
WITH t1 AS (
SELECT 
	DISTINCT games,sport
FROM
	olympics_history
ORDER BY 
	games
),
t2 AS (
SELECT
	sport,COUNT(games) AS no_of_games
FROM
	t1
GROUP BY 
	sport
)
SELECT 
	t1.sport,t2.no_of_games,t1.games
FROM
	t2
JOIN
	t1
ON
	t1.sport = t2.sport
WHERE
	t2.no_of_games = '1'
ORDER BY 
	t1.sport;

```
**output:**

![Image](https://github.com/user-attachments/assets/d9174ed9-179f-4ad6-827b-c6f81c53159c)

#### 8. Fetch the total no of sports played in each olympic games.Problem Statement: Write SQL query to fetch the total no of sports played in each olympics.
```sql
SELECT
	games,COUNT(DISTINCT sport) AS no_of_sports
FROM
	olympics_history
GROUP BY
	games
ORDER BY
	no_of_sports DESC;
```
**output:**

![Image](https://github.com/user-attachments/assets/2ea887ad-d606-4691-8be5-d9899c363905)

### 9. Fetch oldest athletes to win a gold medal. Problem Statement: SQL Query to fetch the details of the oldest athletes to win a gold medal at the olympics.
```sql
WITH t1 AS (
SELECT 
	name,sex,CAST(CASE WHEN age = 'NA' THEN '0' ELSE age END AS int) as age,team,games,city,
	sport,event,medal
FROM
	olympics_history	
),
rank AS (
SELECT 
	*,RANK() OVER(ORDER BY age DESC) AS rnk
FROM
	t1
WHERE
	medal = 'Gold'
)
SELECT
	*
FROM 
	rank
WHERE 
	rnk = 1;
```
**output:**

![Image](https://github.com/user-attachments/assets/c6f594e4-ae51-4c08-afb9-402d8d67b0f6)

#### 10.Find the Ratio of male and female athletes participated in all olympic games.Problem Statement: Write a SQL query to get the ratio of male and female participants
```sql
WITH t1 AS(
SELECT 
	sex, count(1) AS cnt
FROM
	olympics_history
GROUP BY 
	sex),
t2 AS(
SELECT 
	*,ROW_NUMBER() OVER(ORDER BY cnt) AS rn 
FROM
	t1
),
min_cnt AS(
SELECT
	cnt 
FROM
	t2
WHERE 
	rn = 1
),
max_cnt AS(
SELECT
	cnt
FROM
	t2
WHERE
	rn = 2
)
SELECT 
	CONCAT('1 : ', ROUND(max_cnt.cnt::decimal/min_cnt.cnt, 2)) AS ratio
FROM	
	min_cnt, max_cnt;
```
**output:**

![Image](https://github.com/user-attachments/assets/86cf4fd2-2157-40f0-a659-502eedd14adf)

#### 11. Fetch the top 5 athletes who have won the most gold medals.Problem Statement: SQL query to fetch the top 5 athletes who have won the most gold medals.
```sql
WITH RankedMedals AS (
SELECT
       name,team,COUNT(1) AS total_gold_medals,DENSE_RANK() OVER (ORDER BY COUNT(1) DESC) AS rank
FROM
      OLYMPICS_HISTORY
WHERE 
      medal = 'Gold'
GROUP BY
      name, team
)
SELECT
    name,team,total_gold_medals
FROM
    RankedMedals
WHERE
    rank <= 5
ORDER BY
    rank, total_gold_medals DESC;
```
**output:**

![Image](https://github.com/user-attachments/assets/8e6cb3f7-c96b-4345-8f96-361a34bad919)

#### 12. Fetch the top 5 athletes who have won the most medals (gold/silver/bronze).Problem Statement: SQL Query to fetch the top 5 athletes who have won the most medals (Medals include gold, silver and bronze).	
```sql
WITH RankedMedals AS (
SELECT
       name,team,COUNT(1) AS total_medals,DENSE_RANK() OVER (ORDER BY COUNT(1) DESC) AS rank
FROM
      OLYMPICS_HISTORY
WHERE 
      medal in ('Gold', 'Silver', 'Bronze')
GROUP BY
      name, team
)
SELECT
    name,team,total_medals
FROM
    RankedMedals
WHERE
    rank <= 5
ORDER BY
    rank, total_medals DESC;
```
**output:**

![Image](https://github.com/user-attachments/assets/573c1921-fb84-499f-ab51-87858de755fb)

#### 13. Fetch the top 5 most successful countries in olympics. Success is defined by no of medals won.Problem Statement: Write a SQL query to fetch the top 5 most successful countries in olympics.(Success is defined by no of medals won).
```sql
WITH RankedMedals AS (
SELECT
       nr.region,COUNT(o.Medal) AS total_medals,DENSE_RANK() OVER (ORDER BY COUNT(1) DESC) AS rank
FROM
      OLYMPICS_HISTORY o
JOIN
	OLYMPICS_HISTORY_NOC_REGIONS nr
ON
	o.noc = nr.noc
WHERE 
	medal <> 'NA'
GROUP BY
      nr.region
ORDER BY 
	total_medals DESC
)
SELECT
    region,total_medals,rank
FROM
    RankedMedals
WHERE
    rank <= 5
ORDER BY
    rank, total_medals DESC;
```
**output:**

![Image](https://github.com/user-attachments/assets/71825484-ad5d-45e8-9cf8-8d3b8d108496)

#### 14. List down total gold, silver and bronze medals won by each country.Problem Statement: Write a SQL query to list down the  total gold, silver and bronze medals won by each country.
```sql
CREATE EXTENSION TABLEFUNC;
SELECT 
	country
    	, coalesce(gold, 0) as gold
    	, coalesce(silver, 0) as silver
    	, coalesce(bronze, 0) as bronze
FROM CROSSTAB('
SELECT
	nr.region AS country,o.medal,COUNT(1) AS total_medals
FROM
      OLYMPICS_HISTORY o
JOIN
	OLYMPICS_HISTORY_NOC_REGIONS nr
ON
	o.noc = nr.noc
WHERE 
	medal <> ''NA''
GROUP BY
	nr.region,o.medal
ORDER BY
	nr.region,o.medal',
'VALUES (''Bronze''),(''Gold''),(''Silver'')')
AS FINAL_RESULT(country varchar, bronze bigint, gold bigint, silver bigint)
ORDER BY
	gold DESC, silver DESC, bronze DESC;
```
**output:**

![Image](https://github.com/user-attachments/assets/eb74af5b-205c-4b57-bd2f-05449d755f39)

#### 15. List down total gold, silver and bronze medals won by each country corresponding to each olympic games.Problem Statement: Write a SQL query to list down the  total gold, silver and bronze medals won by each country corresponding to each olympic games.
```sql	
SELECT substring(games,1,position(' - ' in games) - 1) as games
        , substring(games,position(' - ' in games) + 3) as country
        , coalesce(gold, 0) as gold
        , coalesce(silver, 0) as silver
        , coalesce(bronze, 0) as bronze
FROM CROSSTAB('
SELECT CONCAT(games, '' - '', nr.region) as games, medal, count(1) as total_medals
FROM 
	olympics_history oh
JOIN 
	olympics_history_noc_regions nr ON nr.noc = oh.noc
WHERE 
	medal <> ''NA''
GROUP BY 
	games,nr.region,medal
ORDER BY 
	games,medal',
'values (''Bronze''), (''Gold''), (''Silver'')')
AS FINAL_RESULT(games text, bronze bigint, gold bigint, silver bigint);
```
**output:**

![Image](https://github.com/user-attachments/assets/f54884e9-3abc-4bd0-abfd-2767b2fc007d)

#### 16. Identify which country won the most gold, most silver and most bronze medals in each olympic games.Problem Statement: Write SQL query to display for each Olympic Games, which country won the highest gold, silver and bronze medals.
```sql
WITH temp AS(
SELECT substring(games,1,position(' - ' in games) - 1) as games
        , substring(games,position(' - ' in games) + 3) as country
        , coalesce(gold, 0) as gold
        , coalesce(silver, 0) as silver
        , coalesce(bronze, 0) as bronze
FROM CROSSTAB('
SELECT CONCAT(games, '' - '', nr.region) as games, medal, count(1) as total_medals
FROM 
	olympics_history oh
JOIN 
	olympics_history_noc_regions nr ON nr.noc = oh.noc
WHERE 
	medal <> ''NA''
GROUP BY 
	games,nr.region,medal
ORDER BY 
	games,medal',
'values (''Bronze''), (''Gold''), (''Silver'')')
AS FINAL_RESULT(games text, bronze bigint, gold bigint, silver bigint)
)
SELECT 
	DISTINCT games,
			CONCAT(FIRST_VALUE(country) OVER(PARTITION BY games ORDER BY gold DESC), ' - ',
			FIRST_VALUE(gold) OVER(PARTITION BY games ORDER BY gold DESC)) AS Max_Gold,
			CONCAT(FIRST_VALUE(country) OVER(PARTITION BY games ORDER BY silver DESC), ' - ',
			FIRST_VALUE(silver) OVER(PARTITION BY games ORDER BY silver DESC)) AS Max_Silver,
			CONCAT(FIRST_VALUE(country) OVER(PARTITION BY games ORDER BY bronze DESC), ' - ',
			FIRST_VALUE(bronze) OVER(PARTITION BY games ORDER BY bronze DESC)) AS Max_Bronze			
FROM 
	temp
ORDER BY 
	games;
```
**output:**

![Image](https://github.com/user-attachments/assets/ee0880a4-fd5a-4b55-8efd-273349d395e7)

#### 17. Identify which country won the most gold, most silver, most bronze medals and the most medals in each olympic games.Problem Statement: Similar to the previous query, identify during each Olympic Games, which country won the highest gold,silver and bronze medals. Along with this, identify also the country with the most medals in each olympic games.
```sql
WITH temp AS(
SELECT substring(games,1,position(' - ' in games) - 1) as games
        , substring(games,position(' - ' in games) + 3) as country
        , coalesce(gold, 0) as gold
        , coalesce(silver, 0) as silver
        , coalesce(bronze, 0) as bronze
FROM CROSSTAB('
SELECT CONCAT(games, '' - '', nr.region) as games, medal, count(1) as total_medals
FROM 
	olympics_history oh
JOIN 
	olympics_history_noc_regions nr ON nr.noc = oh.noc
WHERE 
	medal <> ''NA''
GROUP BY 
	games,nr.region,medal
ORDER BY 
	games,medal',
'values (''Bronze''), (''Gold''), (''Silver'')')
AS FINAL_RESULT(games text, bronze bigint, gold bigint, silver bigint)
),
tot_medals AS(
SELECT
	o.games,nr.region AS country , COUNT(1) AS total_medals
FROM
	OLYMPICS_HISTORY o
JOIN
	OLYMPICS_HISTORY_NOC_REGIONS nr
ON
	o.noc = nr.noc
WHERE
	medal <> 'NA'
GROUP BY
	o.games,nr.region
ORDER BY
	1,2
)
SELECT 
	DISTINCT t.games,
			CONCAT(FIRST_VALUE(t.country) OVER(PARTITION BY t.games ORDER BY gold DESC), ' - ',
			FIRST_VALUE(gold) OVER(PARTITION BY t.games ORDER BY gold DESC)) AS Max_Gold,
			CONCAT(FIRST_VALUE(t.country) OVER(PARTITION BY t.games ORDER BY silver DESC), ' - ',
			FIRST_VALUE(silver) OVER(PARTITION BY t.games ORDER BY silver DESC)) AS Max_Silver,
			CONCAT(FIRST_VALUE(t.country) OVER(PARTITION BY t.games ORDER BY bronze DESC), ' - ',
			FIRST_VALUE(bronze) OVER(PARTITION BY t.games ORDER BY bronze DESC)) AS Max_Bronze,
			CONCAT(FIRST_VALUE(t.country) OVER(PARTITION BY t.games ORDER BY total_medals DESC), ' - ',
			FIRST_VALUE(tm.total_medals) OVER(PARTITION BY t.games ORDER BY tm.total_medals DESC)) AS Max_medals
FROM 
	temp t
JOIN
	tot_medals tm
ON
	t.games = tm.games and t.country = tm.country
ORDER BY 
	t.games;
```
**output:**

![Image](https://github.com/user-attachments/assets/50076e59-43ca-4683-95b9-18300f30fec3)

#### 18. Which countries have never won gold medal but have won silver/bronze medals? Problem Statement: Write a SQL Query to fetch details of countries which have won silver or bronze medal but never won a gold medal.
```sql
WITH temp AS(
SELECT country
        , coalesce(gold, 0) as gold
        , coalesce(bronze, 0) as bronze
		, coalesce(silver, 0) as silver
FROM CROSSTAB('
SELECT nr.region AS country, medal, count(1) as total_medals
FROM 
	olympics_history oh
JOIN 
	olympics_history_noc_regions nr 
ON
	nr.noc = oh.noc
WHERE 
	medal <> ''NA''
GROUP BY 
	nr.region,medal
ORDER BY 
	nr.region,medal',
'values (''Bronze''), (''Gold''), (''Silver'')')
AS FINAL_RESULT(country varchar, bronze bigint, gold bigint, silver bigint)
)
SELECT
	* 
FROM
	temp
WHERE
	gold = 0 and (silver > 0 or bronze >0)
ORDER BY 
	gold DESC nulls last, silver DESC nulls last, bronze DESC nulls last;
```
**output:**

![Image](https://github.com/user-attachments/assets/bc39bdc5-7b73-4a2b-bf71-061c618fe811)

#### 19. In which Sport/event, Norway has won highest medals.Problem Statement: Write SQL Query to return the sport which has won India the highest no of medals. 
```sql
WITH t1 AS(
SELECT 
	sport,COUNT(1) AS total_medals
FROM
	OLYMPICS_HISTORY 
WHERE
	medal <> 'NA' 
	AND
	team = 'Norway'
GROUP BY
	sport
ORDER BY
	total_medals DESC),
t2 AS(
SELECT
	*,RANK() OVER (ORDER BY total_medals DESC) as rnk
FROM 
	t1
)
SELECT
	sport,total_medals
FROM 
	t2
WHERE 
	rnk = 1;
```
**output:**

![Image](https://github.com/user-attachments/assets/bcea9dec-b984-469e-b004-1c9837a43f42)

#### 20. Break down all olympic games where Norway won medal for Hockey and how many medals in each olympic games. Problem Statement: Write an SQL Query to fetch details of all Olympic Games where India won medal(s) in hockey. 
```sql
Select * from OLYMPICS_HISTORY;
Select * from OLYMPICS_HISTORY_NOC_REGIONS;

SELECT 
	team,sport,games,COUNT(1) AS total_medals
FROM
	OLYMPICS_HISTORY
WHERE
	medal <> 'NA'
	AND
	team = 'Norway'
GROUP BY 
	team,sport,games
ORDER BY 
	total_medals DESC;
```
**output:**

![Image](https://github.com/user-attachments/assets/0aa289ed-b94f-424d-b700-29aefa8b4f57)